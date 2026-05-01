/// ── IMPORT PIPELINE & DATA PERSISTENCE ──────────────────────────────────────
///
/// This service is the final stage of the PaperTek Import Pipeline. It takes
/// parsed rows and a confirmed column mapping and "materializes" them into the
/// database.
///
/// THE PIPELINE:
/// 1. DelimitedRowReader: reads raw rows from the file.
/// 2. RowMatcher: suggests column mappings.
/// 3. ColumnMappingScreen: user confirms mapping.
/// 4. (Multipart detection screen — optional.)
/// 5. Service (This File): Writes the rows to the DB using the
///    TrackedWriteRepository.
/// ─────────────────────────────────────────────────────────────────────────────
library;

import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../repositories/tracked_write_repository.dart';
import '../../ui/spreadsheet/column_spec.dart';

/// Summary returned after a completed import.
class ImportResult {
  const ImportResult({
    required this.fixturesCreated,
    required this.positionsCreated,
    required this.fixtureTypesCreated,
    required this.rowsSkipped,
    required this.warnings,
    required this.batchId,
  });

  final int fixturesCreated;
  final int positionsCreated;
  final int fixtureTypesCreated;
  final int rowsSkipped;
  final List<String> warnings;

  /// The batch_id that links all revision rows for this import.
  final String batchId;
}

/// Materializes raw import rows into database records using a confirmed
/// [ColumnSpec]-based column mapping.
class ImportService {
  ImportService({required AppDatabase db, required TrackedWriteRepository tracked})
      : _db = db,
        _tracked = tracked;

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  static const _noColorSentinels = {
    'n/c', 'nc', 'open', 'none', '-', 'no color', 'no colour',
  };

  /// Import a list of raw delimited rows using [columnMapping].
  ///
  /// [multipartDecisions] is accepted but ignored — it will be wired in Ticket 07.
  Future<ImportResult> importRows(
    List<Map<String, String>> rawRows,
    Map<ColumnSpec, List<String>> columnMapping, {
    String? sourceFileName,
    List<dynamic>? multipartDecisions,
  }) async {
    final positionCache = <String, int>{};
    final fixtureTypeCache = <String, int>{};
    var fixturesCreated = 0;
    var positionsCreated = 0;
    var fixtureTypesCreated = 0;
    var rowsSkipped = 0;
    final warnings = <String>[];
    final createdIds = <int>[];

    final batchId = _tracked.beginImportBatch();

    final positionSpec = kColumnById['position']!;

    // Filter rows missing a position value.
    final validRows = <Map<String, String>>[];
    for (var i = 0; i < rawRows.length; i++) {
      final position = _resolveValue(rawRows[i], positionSpec, columnMapping);
      if (position == null || position.isEmpty) {
        rowsSkipped++;
        warnings.add('Row ${i + 2}: skipped — no position value');
      } else {
        validRows.add(rawRows[i]);
      }
    }

    final rowGroups = _buildRowGroups(validRows, columnMapping);

    await _db.transaction(() async {
      for (final group in rowGroups) {
        try {
          final fixtureId = await _importRowGroup(
            rowGroup: group,
            columnMapping: columnMapping,
            batchId: batchId,
            positionCache: positionCache,
            fixtureTypeCache: fixtureTypeCache,
            onPositionCreated: () => positionsCreated++,
            onTypeCreated: () => fixtureTypesCreated++,
          );
          createdIds.add(fixtureId);
          fixturesCreated++;
        } catch (e) {
          rowsSkipped++;
          warnings.add('Row skipped — $e');
        }
      }
    });

    await _tracked.endImportBatch(
      batchId: batchId,
      summary: {
        'source': sourceFileName ?? '',
        'fixture_count': fixturesCreated,
        'positions_created': positionsCreated,
        'rows_skipped': rowsSkipped,
        'fixture_ids': createdIds,
      },
    );

    return ImportResult(
      fixturesCreated: fixturesCreated,
      positionsCreated: positionsCreated,
      fixtureTypesCreated: fixtureTypesCreated,
      rowsSkipped: rowsSkipped,
      warnings: warnings,
      batchId: batchId,
    );
  }

  // ── Value resolution ─────────────────────────────────────────────────────

  /// Resolves a single column's value from a raw row using the confirmed mapping.
  ///
  /// For collection columns, tokens from multiple headers are split on common
  /// separators and joined with '|' for downstream DB splitting.
  /// For non-collection columns, multiple header values are joined with ' + '.
  String? _resolveValue(
    Map<String, String> row,
    ColumnSpec col,
    Map<ColumnSpec, List<String>> mapping,
  ) {
    final headers = mapping[col];
    if (headers == null || headers.isEmpty) return null;

    final values = headers
        .map((h) => (row[h] ?? '').trim())
        .where((v) => v.isNotEmpty)
        .toList();

    if (values.isEmpty) return null;

    if (col.isCollection) {
      final tokens = values
          .expand((v) => v.split(RegExp(r'[+,/;]')))
          .map((t) => t.trim())
          .where((t) =>
              t.isNotEmpty && !_noColorSentinels.contains(t.toLowerCase()))
          .toList();
      return tokens.isEmpty ? null : tokens.join('|');
    }

    return values.join(' + ');
  }

  // ── Row grouping ─────────────────────────────────────────────────────────

  /// Groups consecutive rows sharing the same (position, unit, type) key into
  /// multipart groups. All other rows form single-element groups.
  List<List<Map<String, String>>> _buildRowGroups(
    List<Map<String, String>> rows,
    Map<ColumnSpec, List<String>> mapping,
  ) {
    final groups = <List<Map<String, String>>>[];
    final keyToGroup = <String, List<Map<String, String>>>{};

    final positionSpec = kColumnById['position']!;
    final unitSpec = kColumnById['unit']!;
    final instrumentSpec = kColumnById['instrument']!;

    for (final row in rows) {
      final position = _resolveValue(row, positionSpec, mapping) ?? '';
      final unit = _resolveValue(row, unitSpec, mapping) ?? '';
      final type = _resolveValue(row, instrumentSpec, mapping) ?? '';

      if (position.isEmpty) {
        groups.add([row]);
        continue;
      }

      final key =
          '${position.toLowerCase()}|${unit.toLowerCase()}|${type.toLowerCase()}';
      final existing = keyToGroup[key];
      if (existing != null) {
        existing.add(row);
      } else {
        final newGroup = [row];
        keyToGroup[key] = newGroup;
        groups.add(newGroup);
      }
    }
    return groups;
  }

  // ── Per-fixture logic ─────────────────────────────────────────────────────

  Future<int> _importRowGroup({
    required List<Map<String, String>> rowGroup,
    required Map<ColumnSpec, List<String>> columnMapping,
    required String batchId,
    required Map<String, int> positionCache,
    required Map<String, int> fixtureTypeCache,
    required void Function() onPositionCreated,
    required void Function() onTypeCreated,
  }) async {
    // Fixture-level fields (isPartLevel: false) share one value across all parts.
    String? firstNonNull(ColumnSpec spec) {
      assert(!spec.isPartLevel, '${spec.id} is part-level; resolve per row');
      for (final row in rowGroup) {
        final v = _resolveValue(row, spec, columnMapping);
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    }

    final positionSpec = kColumnById['position']!;
    final unitSpec = kColumnById['unit']!;
    final instrumentSpec = kColumnById['instrument']!;
    final purposeSpec = kColumnById['purpose']!;
    final areaSpec = kColumnById['area']!;
    final chanSpec = kColumnById['chan']!;
    final dimmerSpec = kColumnById['dimmer']!;
    final addressSpec = kColumnById['address']!;
    final circuitSpec = kColumnById['circuit']!;
    final wattageSpec = kColumnById['wattage']!;
    final colorSpec = kColumnById['color']!;
    final goboSpec = kColumnById['gobo']!;
    final accessoriesSpec = kColumnById['accessories']!;
    final notesSpec = kColumnById['notes']!;

    final positionName = _resolveValue(rowGroup.first, positionSpec, columnMapping)!;
    await _resolvePosition(positionName, positionCache, onPositionCreated);

    int? fixtureTypeId;
    final typeName = firstNonNull(instrumentSpec);
    if (typeName != null) {
      fixtureTypeId = await _resolveFixtureType(
        typeName,
        wattage: firstNonNull(wattageSpec),
        cache: fixtureTypeCache,
        onCreated: onTypeCreated,
      );
    }

    final res = await _tracked.insertRow(
      table: 'fixtures',
      doInsert: () async {
        final fixtureId = await _db.into(_db.fixtures).insert(FixturesCompanion(
          fixtureTypeId: Value(fixtureTypeId),
          fixtureType: Value(typeName),
          position: Value(positionName),
          unitNumber: Value(firstNonNull(unitSpec)),
          purpose: Value(firstNonNull(purposeSpec)),
          area: Value(firstNonNull(areaSpec)),
        ));

        int? firstPartId;
        for (var i = 0; i < rowGroup.length; i++) {
          final partRow = rowGroup[i];
          final notes = _resolveValue(partRow, notesSpec, columnMapping);
          final partId = await _db.into(_db.fixtureParts).insert(
            FixturePartsCompanion(
              fixtureId: Value(fixtureId),
              partOrder: Value(i),
              partType: const Value('intensity'),
              channel: Value(_resolveValue(partRow, chanSpec, columnMapping)),
              dimmer: Value(_resolveValue(partRow, dimmerSpec, columnMapping)),
              address: Value(_resolveValue(partRow, addressSpec, columnMapping)),
              circuit: Value(_resolveValue(partRow, circuitSpec, columnMapping)),
              wattage: Value(_resolveValue(partRow, wattageSpec, columnMapping)),
              extrasJson: Value(notes != null ? jsonEncode({'notes': notes}) : null),
            ),
          );
          if (i == 0) firstPartId = partId;
        }
        firstPartId ??= 0;

        // Collection fields — from primary row, attached to first part.
        final colorValue = _resolveValue(rowGroup.first, colorSpec, columnMapping);
        if (colorValue != null) {
          final tokens = colorValue.split('|');
          for (var i = 0; i < tokens.length; i++) {
            await _db.into(_db.gels).insert(GelsCompanion(
              fixtureId: Value(fixtureId),
              fixturePartId: Value(firstPartId),
              color: Value(tokens[i]),
              sortOrder: Value(i.toDouble()),
            ));
          }
        }

        final goboValue = _resolveValue(rowGroup.first, goboSpec, columnMapping);
        if (goboValue != null) {
          final tokens = goboValue.split('|');
          for (var i = 0; i < tokens.length; i++) {
            await _db.into(_db.gobos).insert(GobosCompanion(
              fixtureId: Value(fixtureId),
              fixturePartId: Value(firstPartId),
              goboNumber: Value(tokens[i]),
              sortOrder: Value(i.toDouble()),
            ));
          }
        }

        final accValue = _resolveValue(rowGroup.first, accessoriesSpec, columnMapping);
        if (accValue != null) {
          final tokens = accValue.split('|');
          for (var i = 0; i < tokens.length; i++) {
            await _db.into(_db.accessories).insert(AccessoriesCompanion(
              fixtureId: Value(fixtureId),
              fixturePartId: Value(firstPartId),
              name: Value(tokens[i]),
              sortOrder: Value(i.toDouble()),
            ));
          }
        }

        return fixtureId;
      },
      buildSnapshot: (id) async {
        final fixture =
            await (_db.select(_db.fixtures)..where((t) => t.id.equals(id)))
                .getSingle();
        final parts =
            await (_db.select(_db.fixtureParts)..where((t) => t.fixtureId.equals(id)))
                .get();
        final gels =
            await (_db.select(_db.gels)..where((t) => t.fixtureId.equals(id))).get();
        final gobos =
            await (_db.select(_db.gobos)..where((t) => t.fixtureId.equals(id))).get();
        final accs =
            await (_db.select(_db.accessories)..where((t) => t.fixtureId.equals(id)))
                .get();

        return {
          'fixture': fixture.toJson(),
          'parts': parts.map((p) => p.toJson()).toList(),
          'gels': gels.map((g) => g.toJson()).toList(),
          'gobos': gobos.map((g) => g.toJson()).toList(),
          'accessories': accs.map((a) => a.toJson()).toList(),
        };
      },
      batchId: batchId,
    );

    return res.rowId;
  }

  // ── Lookup helpers ───────────────────────────────────────────────────────

  Future<void> _resolvePosition(
    String name,
    Map<String, int> cache,
    void Function() onCreated,
  ) async {
    if (cache.containsKey(name)) return;
    final existing = await (_db.select(_db.lightingPositions)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) {
      cache[name] = existing.id;
    } else {
      final id = await _db.into(_db.lightingPositions).insert(
        LightingPositionsCompanion(name: Value(name)),
      );
      cache[name] = id;
      onCreated();
    }
  }

  Future<int> _resolveFixtureType(
    String name, {
    required String? wattage,
    required Map<String, int> cache,
    required void Function() onCreated,
  }) async {
    if (cache.containsKey(name)) return cache[name]!;
    final existing = await (_db.select(_db.fixtureTypes)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) {
      cache[name] = existing.id;
      return existing.id;
    }
    final id = await _db.into(_db.fixtureTypes).insert(
      FixtureTypesCompanion(name: Value(name), wattage: Value(wattage)),
    );
    cache[name] = id;
    onCreated();
    return id;
  }
}
