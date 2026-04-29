/// ── IMPORT PIPELINE & DATA PERSISTENCE ──────────────────────────────────────
///
/// This service is the final stage of the PaperTek Import Pipeline. It takes 
/// data that has been parsed and normalized and "materializes" it into the 
/// database.
///
/// THE PIPELINE:
/// 1. Detector: identifies which column is which (e.g. "Ch" vs "Chan").
/// 2. Parser: Reads the raw CSV rows.
/// 3. Normalizer: Maps the CSV columns to internal PaperTek data fields.
/// 4. Service (This File): Writes the rows to the DB using the 
///    TrackedWriteRepository.
///
/// THE "ROW GROUPING" LOGIC:
/// Some lighting fixtures have multiple parts (e.g. a LED wash with 3 pixels). 
/// In a Lightwright CSV, these often appear as multiple rows with the same 
/// Channel/Unit number but different "Part" numbers.
/// 
/// `importRows` automatically detects these duplicates and merges them into 
/// a single parent Fixture in the database with multiple FixturePart children.
/// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../repositories/tracked_write_repository.dart';
import 'csv_field_definitions.dart';
import 'csv_import_parser.dart';

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

/// Converts [NormalizedRow]s from [CsvImportParser] into database records.
///
/// Responsibilities:
///   - Look up or auto-create positions and fixture types.
///   - Write fixtures, parts, gels, and gobos in a single transaction.
///   - Record per-fixture insert revisions and one import_batch summary,
///     all sharing a single [batchId] for the supervisor queue.
class ImportService {
  ImportService({required AppDatabase db, required TrackedWriteRepository tracked})
      : _db = db,
        _tracked = tracked;

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  /// Import a list of normalised rows.
  ///
  /// All DB writes run inside one transaction for performance.
  /// Large imports (500+ rows) are fast enough in a single transaction
  /// on SQLite; revisit with a background isolate if needed for >2000 rows.
  Future<ImportResult> importRows({
    required List<NormalizedRow> rows,
    required String sourceFileName,
  }) async {
    // Caches prevent redundant lookups within a single import run.
    final positionCache = <String, int>{};
    final fixtureTypeCache = <String, int>{};

    var fixturesCreated = 0;
    var positionsCreated = 0;
    var fixtureTypesCreated = 0;
    var rowsSkipped = 0;
    final warnings = <String>[];
    final createdIds = <int>[];

    final batchId = _tracked.beginImportBatch();

    // Group rows that carry a partNumber into a single fixture per
    // (position, unit#, type) key; ungrouped rows stay as single-element lists.
    final rowGroups = _buildRowGroups(rows);

    await _db.transaction(() async {
      for (final group in rowGroups) {
        final primary = group.first;
        try {
          final fixtureId = await _importRowGroup(
            rowGroup: group,
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
          warnings.add('Row ${primary.csvRowIndex}: skipped — $e');
        }
      }
    });

    // The import_batch summary sits outside the main transaction so it
    // reflects the final counts rather than mid-flight state.
    await _tracked.endImportBatch(
      batchId: batchId,
      summary: {
        'source': sourceFileName,
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
      warnings: [...warnings, ...rows.expand((r) => r.warnings)],
      batchId: batchId,
    );
  }

  // ── Row grouping ─────────────────────────────────────────────────────────

  /// Collects consecutive rows that share the same (position, unit#, type) key
  /// AND carry a non-null partNumber into a single group; every other row forms
  /// its own single-element group. Order within the original list is preserved.
  List<List<NormalizedRow>> _buildRowGroups(List<NormalizedRow> rows) {
    final groups = <List<NormalizedRow>>[];
    // key → index into [groups] for the in-progress multi-part group.
    final keyToGroup = <String, List<NormalizedRow>>{};

    for (final row in rows) {
      final partNum = row.get(PaperTekImportField.partNumber);
      if (partNum != null) {
        final key = [
          (row.get(PaperTekImportField.position) ?? '').toLowerCase(),
          (row.get(PaperTekImportField.unitNumber) ?? '').toLowerCase(),
          (row.get(PaperTekImportField.fixtureType) ?? '').toLowerCase(),
        ].join('|');
        final existing = keyToGroup[key];
        if (existing != null) {
          existing.add(row);
        } else {
          final newGroup = [row];
          keyToGroup[key] = newGroup;
          groups.add(newGroup);
        }
      } else {
        groups.add([row]);
      }
    }
    return groups;
  }

  // ── Per-fixture logic ─────────────────────────────────────────────────────

  /// Imports one logical fixture from one or more CSV rows.
  ///
  /// Single-part: [rowGroup] has one element — existing behaviour.
  /// Multi-part:  [rowGroup] has N elements (e.g. 3 cells of a cyc) — one
  ///              fixture row is created with N intensity parts, one per
  ///              part-row, ordered by their position in the group.
  Future<int> _importRowGroup({
    required List<NormalizedRow> rowGroup,
    required String batchId,
    required Map<String, int> positionCache,
    required Map<String, int> fixtureTypeCache,
    required void Function() onPositionCreated,
    required void Function() onTypeCreated,
  }) async {
    final primary = rowGroup.first;

    // Resolve (or auto-create) position.
    final positionName = primary.get(PaperTekImportField.position)!;
    await _resolvePosition(positionName, positionCache, onPositionCreated);

    // Resolve (or auto-create) fixture type.
    int? fixtureTypeId;
    final typeName = primary.get(PaperTekImportField.fixtureType);
    if (typeName != null) {
      fixtureTypeId = await _resolveFixtureType(
        typeName,
        wattage: primary.get(PaperTekImportField.wattage),
        cache: fixtureTypeCache,
        onCreated: onTypeCreated,
      );
    }

    final unitStr = primary.get(PaperTekImportField.unitNumber);
    final unitNumber = unitStr != null ? int.tryParse(unitStr) : null;

    // Create the fixture row.
    final res = await _tracked.insertRow(
      table: 'fixtures',
      doInsert: () async {
        final fixtureId = await _db.into(_db.fixtures).insert(FixturesCompanion(
              fixtureTypeId: Value(fixtureTypeId),
              fixtureType: Value(typeName),
              position: Value(positionName),
              unitNumber: Value(unitNumber),
              wattage: Value(primary.get(PaperTekImportField.wattage)),
              function: Value(primary.get(PaperTekImportField.function)),
              focus: Value(primary.get(PaperTekImportField.focus)),
            ));

        // Intensity parts — one per row in the group (partOrder = row index).
        for (var i = 0; i < rowGroup.length; i++) {
          final partRow = rowGroup[i];
          await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
                fixtureId: Value(fixtureId),
                partOrder: Value(i),
                partType: const Value('intensity'),
                channel: Value(partRow.get(PaperTekImportField.channel)),
                address: Value(partRow.get(PaperTekImportField.circuit)),
                extrasJson: _buildExtrasJson(partRow),
              ));
        }

        // Gel and gobo records are sourced from the primary row only.
        final color = primary.get(PaperTekImportField.color);
        if (color != null && !_isNoColor(color)) {
          await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
                fixtureId: Value(fixtureId),
                partOrder: Value(rowGroup.length),
                partType: const Value('gel'),
                partName: Value(color),
              ));
        }

        final gobo1 = primary.get(PaperTekImportField.gobo1);
        if (gobo1 != null) {
          await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
                fixtureId: Value(fixtureId),
                partOrder: Value(rowGroup.length + 1),
                partType: const Value('gobo'),
                partName: Value(gobo1),
              ));
        }

        return fixtureId;
      },
      buildSnapshot: (id) async {
        final fixture = await (_db.select(_db.fixtures)..where((t) => t.id.equals(id))).getSingle();
        final parts =
            await (_db.select(_db.fixtureParts)..where((t) => t.fixtureId.equals(id))).get();
        return {
          'fixture': fixture.toJson(),
          'parts': parts.map((p) => p.toJson()).toList(),
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

  // ── Value helpers ────────────────────────────────────────────────────────

  /// Strings that mean "no gel" in standard lighting notation.
  bool _isNoColor(String value) {
    const sentinels = {'n/c', 'nc', 'open', 'none', '-', 'no color', 'no colour'};
    return sentinels.contains(value.toLowerCase().trim());
  }

  /// Stores dimmer in extras_json since there is no dedicated column on
  /// fixture_parts. Future schema versions may promote this to a real column.
  Value<String?> _buildExtrasJson(NormalizedRow row) {
    final dimmer = row.get(PaperTekImportField.dimmer);
    final notes = row.get(PaperTekImportField.notes);
    if (dimmer == null && notes == null) return const Value(null);
    return Value(jsonEncode({
      if (dimmer != null) 'dimmer': dimmer,
      if (notes != null) 'notes': notes,
    }));
  }
}
