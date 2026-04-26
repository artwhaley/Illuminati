import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';

// Single mutation API for all revision-tracked design/show data.
// Operational tables (work_notes, maintenance_log, fixtures.flagged) use
// OperationalRepository instead and do not create supervisor revisions.
class TrackedWriteRepository {
  TrackedWriteRepository(this._db);

  final AppDatabase _db;
  // Hardcoded until auth exists (Phase 9).
  static const _localUser = 'local-user';

  // ── Field-level update ──────────────────────────────────────────────────
  // Reads current value, updates the live row, inserts a pending revision.
  Future<void> updateField({
    required String table,
    required int id,
    required String field,
    required dynamic newValue,
    required Future<dynamic> Function() readCurrentValue,
    required Future<void> Function(dynamic newVal) applyUpdate,
  }) async {
    await _db.transaction(() async {
      final old = await readCurrentValue();
      await applyUpdate(newValue);
      await _db.into(_db.revisions).insert(RevisionsCompanion(
            operation: const Value('update'),
            targetTable: Value(table),
            targetId: Value(id),
            fieldName: Value(field),
            oldValue: Value(jsonEncode(old)),
            newValue: Value(jsonEncode(newValue)),
            userId: const Value(_localUser),
            timestamp: Value(DateTime.now().toIso8601String()),
            status: const Value('pending'),
          ));
    });
  }

  // ── Insert a row ─────────────────────────────────────────────────────────
  // Inserts the row, then records an insert revision with a JSON snapshot.
  Future<int> insertRow({
    required String table,
    required Insertable<dynamic> companion,
    required Future<int> Function() doInsert,
    required Future<Map<String, dynamic>> Function(int id) buildSnapshot,
    String? batchId,
  }) async {
    late int newId;
    await _db.transaction(() async {
      newId = await doInsert();
      final snapshot = await buildSnapshot(newId);
      await _db.into(_db.revisions).insert(RevisionsCompanion(
            operation: const Value('insert'),
            targetTable: Value(table),
            targetId: Value(newId),
            newValue: Value(jsonEncode(snapshot)),
            batchId: Value(batchId),
            userId: const Value(_localUser),
            timestamp: Value(DateTime.now().toIso8601String()),
            status: const Value('pending'),
          ));
    });
    return newId;
  }

  // ── Delete a row ─────────────────────────────────────────────────────────
  // Captures a JSON snapshot, deletes (cascade handles children), records revision.
  Future<void> deleteRow({
    required String table,
    required int id,
    required Future<Map<String, dynamic>> Function() buildSnapshot,
    required Future<void> Function() doDelete,
  }) async {
    await _db.transaction(() async {
      final snapshot = await buildSnapshot();
      await doDelete();
      await _db.into(_db.revisions).insert(RevisionsCompanion(
            operation: const Value('delete'),
            targetTable: Value(table),
            targetId: Value(id),
            oldValue: Value(jsonEncode(snapshot)),
            userId: const Value(_localUser),
            timestamp: Value(DateTime.now().toIso8601String()),
            status: const Value('pending'),
          ));
    });
  }

  // ── Bulk import batch ────────────────────────────────────────────────────
  // Assigns a shared batch_id; caller performs inserts using insertRow() with
  // that batch_id, then calls endImportBatch() to write the summary row.
  String beginImportBatch() => const Uuid().v4();

  Future<void> endImportBatch({
    required String batchId,
    required Map<String, dynamic> summary,
  }) async {
    await _db.into(_db.revisions).insert(RevisionsCompanion(
          operation: const Value('import_batch'),
          targetTable: const Value('fixtures'),
          newValue: Value(jsonEncode(summary)),
          batchId: Value(batchId),
          userId: const Value(_localUser),
          timestamp: Value(DateTime.now().toIso8601String()),
          status: const Value('pending'),
        ));
  }
}
