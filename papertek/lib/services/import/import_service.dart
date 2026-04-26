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
///
/// This class is intentionally unaware of CSV structure; swap the upstream
/// parser or detector without touching this class.
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

    await _db.transaction(() async {
      for (final row in rows) {
        try {
          final fixtureId = await _importRow(
            row: row,
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
          warnings.add('Row ${row.csvRowIndex}: skipped — $e');
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

  // ── Per-row logic ────────────────────────────────────────────────────────

  Future<int> _importRow({
    required NormalizedRow row,
    required String batchId,
    required Map<String, int> positionCache,
    required Map<String, int> fixtureTypeCache,
    required void Function() onPositionCreated,
    required void Function() onTypeCreated,
  }) async {
    // Resolve (or auto-create) position.
    final positionName = row.get(PaperTekImportField.position)!;
    await _resolvePosition(positionName, positionCache, onPositionCreated);

    // Resolve (or auto-create) fixture type.
    int? fixtureTypeId;
    final typeName = row.get(PaperTekImportField.fixtureType);
    if (typeName != null) {
      fixtureTypeId = await _resolveFixtureType(
        typeName,
        wattage: row.get(PaperTekImportField.wattage),
        cache: fixtureTypeCache,
        onCreated: onTypeCreated,
      );
    }

    final unitStr = row.get(PaperTekImportField.unitNumber);
    final unitNumber = unitStr != null ? int.tryParse(unitStr) : null;

    // Create the fixture row.
    final fixtureId = await _db.into(_db.fixtures).insert(FixturesCompanion(
          fixtureTypeId: Value(fixtureTypeId),
          fixtureType: Value(typeName),
          position: Value(positionName),
          unitNumber: Value(unitNumber),
          wattage: Value(row.get(PaperTekImportField.wattage)),
          function: Value(row.get(PaperTekImportField.function)),
          focus: Value(row.get(PaperTekImportField.focus)),
        ));

    // Primary fixture_parts row (intensity part).
    // Channel is stored as a soft-link text value (not a FK).
    // Circuit maps to the address soft-link field per the data model.
    await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
          fixtureId: Value(fixtureId),
          partOrder: const Value(0),
          partType: const Value('intensity'),
          channel: Value(row.get(PaperTekImportField.channel)),
          address: Value(row.get(PaperTekImportField.circuit)),
          extrasJson: _buildExtrasJson(row),
        ));

    // Create a Gel record when a non-empty, non-"open" color is present.
    final color = row.get(PaperTekImportField.color);
    if (color != null && !_isNoColor(color)) {
      await _db.into(_db.gels).insert(GelsCompanion(
            color: Value(color),
            fixtureId: Value(fixtureId),
          ));
    }

    // Create Gobo records.
    for (final goboField in [PaperTekImportField.gobo1, PaperTekImportField.gobo2]) {
      final goboNum = row.get(goboField);
      if (goboNum != null) {
        await _db.into(_db.gobos).insert(GobosCompanion(
              goboNumber: Value(goboNum),
              fixtureId: Value(fixtureId),
            ));
      }
    }

    // Record a per-fixture insert revision linked to the batch.
    // Snapshot captures the key display fields; child rows (parts/gels) are
    // summarised in the batch summary rather than repeated per-row.
    await _db.into(_db.revisions).insert(RevisionsCompanion(
          operation: const Value('insert'),
          targetTable: const Value('fixtures'),
          targetId: Value(fixtureId),
          newValue: Value(jsonEncode({
            'fixture_id': fixtureId,
            'position': positionName,
            'unit': unitNumber,
            'type': typeName,
            'channel': row.get(PaperTekImportField.channel),
          })),
          batchId: Value(batchId),
          userId: const Value('local-user'),
          timestamp: Value(DateTime.now().toIso8601String()),
          status: const Value('pending'),
        ));

    return fixtureId;
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
