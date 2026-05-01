/// ── TRACKED WRITE ARCHITECTURE ──────────────────────────────────────────────
///
/// This repository is the "Gatekeeper" for all mutations to show data. Instead 
/// of writing directly to tables, every other repository in the app calls 
/// into this one.
///
/// THE "SPECIAL SAUCE":
/// 1. Tracked Mode (Standard):
///    Every time you edit a field, this repo does three things:
///    - Pushes an Undo frame to the local stack.
///    - Updates the "Live" data in the database immediately.
///    - Creates a row in the `revisions` table marked as 'pending'.
///    This allows the UI to show uncommitted changes (yellow highlights) and
///    allows other users to see what you've changed without it being "final".
///
/// 2. Designer Mode:
///    When a designer is working alone and wants maximum speed, they enter 
///    Designer Mode. Writes go straight to the database WITHOUT creating 
///    thousands of `revisions` rows. Undo still works, but the "Audit Trail"
///    is condensed into a single summary entry when they exit the mode.
///
/// 3. Undo/Redo via Snapshots:
///    Unlike standard undo systems that store "Reverse SQL", we store JSON 
///    Snapshots of the affected rows. If you delete a fixture, we store the 
///    entire fixture + its parts in the Undo frame. Undo-ing simply re-inserts 
///    from that snapshot.
/// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../services/revision_sql_guard.dart';
import 'undo_stack.dart';

// ── Designer-mode counters ────────────────────────────────────────────────────
class _DesignerSessionStats {
  int fieldsChanged = 0;
  int fixturesAdded = 0;
  int fixturesDeleted = 0;
  DateTime start = DateTime.now();
}

/// Single mutation API for all revision-tracked design/show data.
class TrackedWriteRepository {
  TrackedWriteRepository(this._db) : undoStack = UndoStack();

  final AppDatabase _db;

  /// The global undo/redo stack. Exposed so the UI can read
  /// [UndoStack.undoDescription] / [UndoStack.redoDescription] for the status bar.
  final UndoStack undoStack;

  // ── Identity ──────────────────────────────────────────────────────────────

  /// Hardcoded until Phase 9 auth.
  /// TODO(auth): Replace with real identity lookup.
  String get currentUserId => 'local-user';

  // ── Designer mode ─────────────────────────────────────────────────────────

  bool _designerMode = false;
  _DesignerSessionStats? _designerStats;

  /// Whether the repository is currently in designer (non-tracking) mode.
  bool get designerMode => _designerMode;

  /// Switch to designer mode. 
  /// In this mode, writes are committed immediately without creating individual 
  /// 'pending' revision rows for every single field edit.
  void enterDesignerMode() {
    if (_designerMode) return;
    _designerMode = true;
    _designerStats = _DesignerSessionStats();
    _pendingBatchFrame = null; // clear any dangling batch
  }

  /// Switch back to tracked mode. 
  /// Writes a single summary revision capturing what changed during the 
  /// designer session (e.g. "10 fixtures added, 50 fields edited").
  Future<String> exitDesignerMode() async {
    if (!_designerMode) return '';
    _designerMode = false;

    final stats = _designerStats ?? _DesignerSessionStats();
    _designerStats = null;

    final date =
        '${stats.start.year}-${stats.start.month.toString().padLeft(2, '0')}-${stats.start.day.toString().padLeft(2, '0')}';
    final summary = '$date: Show edited in designer mode. '
        '${stats.fixturesAdded} fixture(s) added, '
        '${stats.fixturesDeleted} fixture(s) deleted, '
        '${stats.fieldsChanged} field(s) edited.';

    // Write as an immediately-committed audit entry so it appears in history
    // but never enters the review queue.
    await _db.into(_db.revisions).insert(RevisionsCompanion(
          operation: const Value('designer_session'),
          targetTable: const Value('show'),
          newValue: Value(jsonEncode({'summary': summary})),
          userId: Value(currentUserId),
          timestamp: Value(DateTime.now().toIso8601String()),
          status: const Value('committed'),
        ));

    return summary;
  }

  /// True if there are pending revisions that would need to be committed before
  /// safely entering designer mode.
  Future<bool> hasPendingRevisions() async {
    final count = await (_db.selectOnly(_db.revisions)
          ..addColumns([_db.revisions.id.count()])
          ..where(_db.revisions.status.equals('pending')))
        .getSingle();
    return (count.read(_db.revisions.id.count()) ?? 0) > 0;
  }

  // ── Field-level update ────────────────────────────────────────────────────

  /// Updates a single field in a row.
  /// 
  /// 1. Reads current value (for Undo).
  /// 2. Applies the update to the live table.
  /// 3. In Tracked Mode: Creates a 'pending' revision row.
  /// 4. Pushes an Undo frame.
  Future<int> updateField<T>({
    required String table,
    required int id,
    required String field,
    required T newValue,
    required Future<T> Function() readCurrentValue,
    required Future<void> Function(T newVal) applyUpdate,
    String? batchId,
    String? undoDescription,
  }) async {
    return await _db.transaction(() async {
      final old = await readCurrentValue();

      // No-op guard — skip if value hasn't changed.
      if (_jsonEncode(old) == _jsonEncode(newValue)) return -1;

      await applyUpdate(newValue);

      final oldJson = _jsonEncode(old);
      final newJson = _jsonEncode(newValue);

      int revId = -1;
      if (!_designerMode) {
        revId = await _db.into(_db.revisions).insert(RevisionsCompanion(
              operation: const Value('update'),
              targetTable: Value(table),
              targetId: Value(id),
              fieldName: Value(field),
              oldValue: Value(oldJson),
              newValue: Value(newJson),
              batchId: Value(batchId),
              userId: Value(currentUserId),
              timestamp: Value(DateTime.now().toIso8601String()),
              status: const Value('pending'),
            ));
      } else {
        _designerStats?.fieldsChanged++;
      }

      final displayVal = newValue == null || newValue.toString().isEmpty ? 'blank' : newValue.toString();
      _addSubOp(UndoSubOperation(
        revisionId: _designerMode ? null : revId,
        operation: 'update',
        targetTable: table,
        targetId: id,
        fieldName: field,
        oldValueJson: oldJson,
        newValueJson: newJson,
      ), description: undoDescription ?? 'edit $field $displayVal');

      return revId;
    });
  }

  // ── Insert a row ──────────────────────────────────────────────────────────

  /// Inserts a new row and captures its initial state in a revision.
  /// 
  /// The [buildSnapshot] callback should return a Map of the newly created 
  /// row's data. This snapshot is used for Undo and for the Review Queue.
  Future<({int rowId, int revisionId})> insertRow({
    required String table,
    required Future<int> Function() doInsert,
    required Future<Map<String, dynamic>> Function(int id) buildSnapshot,
    String? batchId,
    String? undoDescription,
    bool isImport = false, // true = skip undo stack (import operations)
  }) async {
    return await _db.transaction(() async {
      final newId = await doInsert();
      final snapshot = await buildSnapshot(newId);
      final snapshotJson = jsonEncode(snapshot);

      int revId = -1;
      if (!_designerMode) {
        revId = await _db.into(_db.revisions).insert(RevisionsCompanion(
              operation: const Value('insert'),
              targetTable: Value(table),
              targetId: Value(newId),
              newValue: Value(snapshotJson),
              batchId: Value(batchId),
              userId: Value(currentUserId),
              timestamp: Value(DateTime.now().toIso8601String()),
              status: const Value('pending'),
            ));
      } else {
        if (table == 'fixtures') _designerStats?.fixturesAdded++;
      }

      if (!isImport) {
        _addSubOp(UndoSubOperation(
          revisionId: _designerMode ? null : revId,
          operation: 'insert',
          targetTable: table,
          targetId: newId,
          newValueJson: snapshotJson,
        ), description: undoDescription ?? 'Add $table');
      }

      return (rowId: newId, revisionId: revId);
    });
  }

  // ── Delete a row ──────────────────────────────────────────────────────────

  /// Deletes a row after capturing a full snapshot of its state.
  /// 
  /// IMPORTANT: This is a "Hard Delete" in the database. Undo works by 
  /// re-inserting the row from the snapshot captured in the Undo frame.
  Future<int> deleteRow({
    required String table,
    required int id,
    required Future<Map<String, dynamic>> Function() buildSnapshot,
    required Future<void> Function() doDelete,
    String? batchId,
    String? undoDescription,
  }) async {
    return await _db.transaction(() async {
      final snapshot = await buildSnapshot();
      final snapshotJson = jsonEncode(snapshot);

      await doDelete();

      int revId = -1;
      if (!_designerMode) {
        revId = await _db.into(_db.revisions).insert(RevisionsCompanion(
              operation: const Value('delete'),
              targetTable: Value(table),
              targetId: Value(id),
              oldValue: Value(snapshotJson),
              batchId: Value(batchId),
              userId: Value(currentUserId),
              timestamp: Value(DateTime.now().toIso8601String()),
              status: const Value('pending'),
            ));
      } else {
        if (table == 'fixtures') _designerStats?.fixturesDeleted++;
      }

      _addSubOp(UndoSubOperation(
        revisionId: _designerMode ? null : revId,
        operation: 'delete',
        targetTable: table,
        targetId: id,
        oldValueJson: snapshotJson,
      ), description: undoDescription ?? 'Delete $table');

      return revId;
    });
  }

  // ── Bulk import batch ─────────────────────────────────────────────────────

  /// Generates a unique ID for a bulk import operation.
  String beginImportBatch() => const Uuid().v4();

  /// Records a summary of a bulk import (e.g. "Imported 100 fixtures from plot.csv").
  Future<int> endImportBatch({
    required String batchId,
    required Map<String, dynamic> summary,
    String targetTable = 'fixtures',
  }) async {
    return await _db.into(_db.revisions).insert(RevisionsCompanion(
          operation: const Value('import_batch'),
          targetTable: Value(targetTable),
          newValue: Value(jsonEncode(summary)),
          batchId: Value(batchId),
          userId: Value(currentUserId),
          timestamp: Value(DateTime.now().toIso8601String()),
          status: const Value('pending'),
        ));
  }

  // ── Batched undo grouping ─────────────────────────────────────────────────

  UndoFrame? _pendingBatchFrame;

  /// Start accumulating sub-operations into a single undo frame.
  /// Useful for complex UI actions (like reordering) that affect multiple rows.
  void beginBatchFrame(String description) {
    _pendingBatchFrame = UndoFrame(description: description, operations: []);
  }

  /// Seal the accumulated frame and push it as one unit onto the undo stack.
  void endBatchFrame() {
    final frame = _pendingBatchFrame;
    _pendingBatchFrame = null;
    if (frame != null && frame.operations.isNotEmpty) {
      undoStack.push(frame);
    }
  }

  // ── Undo / Redo ───────────────────────────────────────────────────────────

  /// Undo the most recent operation. Returns the description of what was undone.
  Future<String?> undo() async {
    final frame = undoStack.popUndo();
    if (frame == null) return null;
    await _reverseFrame(frame);
    return frame.description;
  }

  /// Redo the most recently undone operation.
  Future<String?> redo() async {
    final frame = undoStack.popRedo();
    if (frame == null) return null;
    await _reapplyFrame(frame);
    return frame.description;
  }

  Future<void> _reverseFrame(UndoFrame frame) async {
    await _db.transaction(() async {
      // Process sub-operations in reverse order so compound operations
      // (e.g. insert A then update A) undo cleanly.
      for (final op in frame.operations.reversed) {
        await _reverseSubOp(op);
      }
    });
  }

  Future<void> _reverseSubOp(UndoSubOperation op) async {
    switch (op.operation) {
      case 'update':
        // Restore old value to the live row.
        final oldVal = op.oldValueJson != null ? jsonDecode(op.oldValueJson!) : null;
        await _applyFieldRestore(op.targetTable, op.targetId, op.fieldName!, oldVal);
        // Delete the revision row (pre-review self-correction, not a rejection).
        if (op.revisionId != null) {
          await (_db.delete(_db.revisions)
                ..where((r) => r.id.equals(op.revisionId!)))
              .go();
        }

      case 'insert':
        // Remove the inserted row (hard delete with cascade).
        await _deleteByTable(op.targetTable, op.targetId);
        if (op.revisionId != null) {
          await (_db.delete(_db.revisions)
                ..where((r) => r.id.equals(op.revisionId!)))
              .go();
        }

      case 'delete':
        // Restore the deleted row from the snapshot.
        if (op.oldValueJson != null) {
          final snapshot = jsonDecode(op.oldValueJson!) as Map<String, dynamic>;
          await restoreFromSnapshot(op.targetTable, snapshot);
        }
        if (op.revisionId != null) {
          await (_db.delete(_db.revisions)
                ..where((r) => r.id.equals(op.revisionId!)))
              .go();
        }
    }
  }

  Future<void> _reapplyFrame(UndoFrame frame) async {
    await _db.transaction(() async {
      for (final op in frame.operations) {
        await _reapplySubOp(op);
      }
    });
  }

  Future<void> _reapplySubOp(UndoSubOperation op) async {
    switch (op.operation) {
      case 'update':
        final newVal = op.newValueJson != null ? jsonDecode(op.newValueJson!) : null;
        await _applyFieldRestore(op.targetTable, op.targetId, op.fieldName!, newVal);
        // Re-insert the revision row if in tracked mode.
        if (!_designerMode) {
          await _reinsertRevision(op, operation: 'update');
        }

      case 'insert':
        // Re-insert the row from the snapshot.
        if (op.newValueJson != null) {
          final snapshot = jsonDecode(op.newValueJson!) as Map<String, dynamic>;
          await restoreFromSnapshot(op.targetTable, snapshot);
        }
        if (!_designerMode) {
          await _reinsertRevision(op, operation: 'insert');
        }

      case 'delete':
        // Re-delete the row.
        await _deleteByTable(op.targetTable, op.targetId);
        if (!_designerMode) {
          await _reinsertRevision(op, operation: 'delete');
        }
    }
  }

  Future<void> _reinsertRevision(UndoSubOperation op,
      {required String operation}) async {
    await _db.into(_db.revisions).insert(RevisionsCompanion(
          operation: Value(operation),
          targetTable: Value(op.targetTable),
          targetId: Value(op.targetId),
          fieldName: Value(op.fieldName),
          oldValue: Value(op.oldValueJson),
          newValue: Value(op.newValueJson),
          userId: Value(currentUserId),
          timestamp: Value(DateTime.now().toIso8601String()),
          status: const Value('pending'),
        ));
  }

  // ── Snapshot restore ──────────────────────────────────────────────────────

  Future<void> restoreFromSnapshot(
      String table, Map<String, dynamic> snapshot) async {
    switch (table) {
      case 'fixtures':
        await _restoreFixture(snapshot);
      default:
        await _restoreGenericRow(table, snapshot);
    }
  }

  Future<void> _restoreFixture(Map<String, dynamic> snapshot) async {
    final fixtureData = (snapshot['fixture'] ?? snapshot) as Map<String, dynamic>;
    final partsData = (snapshot['parts'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    // Re-insert the fixture row using whatever columns the snapshot carries.
    // This is intentionally schema-agnostic so it remains correct across
    // future migrations without needing to update this method.
    await _restoreGenericRow('fixtures', fixtureData);

    // Re-insert parts.
    for (final part in partsData) {
      await _restoreGenericRow('fixture_parts', part);
    }

    // Re-insert Gels
    final gelsData = (snapshot['gels'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final g in gelsData) {
      await _restoreGenericRow('gels', g);
    }

    // Re-insert Gobos
    final gobosData = (snapshot['gobos'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final g in gobosData) {
      await _restoreGenericRow('gobos', g);
    }

    // Re-insert Accessories
    final accsData = (snapshot['accessories'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    for (final a in accsData) {
      await _restoreGenericRow('accessories', a);
    }
  }

  Future<void> _restoreGenericRow(
      String table, Map<String, dynamic> row) async {
    final cols = row.keys.join(', ');
    final placeholders = row.keys.map((_) => '?').join(', ');
    final updates = _getUpdateSet(table);

    await _db.customInsert(
      'INSERT OR IGNORE INTO $table ($cols) VALUES ($placeholders)',
      variables: row.values.map((v) => Variable(v)).toList(),
      updates: updates,
    );
  }

  // ── Field restore ─────────────────────────────────────────────────────────

  Future<void> _applyFieldRestore(
      String table, int id, String field, dynamic value) async {
    if (!revisionUpdateTargetIsSafe(table, field)) {
      throw StateError(
        'Undo/redo: invalid table or field name table=$table field=$field',
      );
    }
    final dynamic encoded;
    if (value == null) {
      encoded = null;
    } else if (value is String) {
      encoded = value;
    } else {
      encoded = jsonEncode(value);
    }
    final updates = _getUpdateSet(table);

    await _db.customUpdate(
      'UPDATE $table SET $field = ? WHERE id = ?',
      variables: [Variable(encoded), Variable<int>(id)],
      updates: updates,
    );
  }

  // ── Hard delete by table ──────────────────────────────────────────────────

  Future<void> _deleteByTable(String table, int id) async {
    if (!revisionTableNameIsSafe(table)) {
      throw StateError('Undo/redo: invalid table name for delete: $table');
    }
    final updates = _getUpdateSet(table);
    await _db.customUpdate(
      'DELETE FROM $table WHERE id = ?',
      variables: [Variable<int>(id)],
      updates: updates,
    );
  }

  Set<ResultSetImplementation> _getUpdateSet(String table) {
    switch (table) {
      case 'fixtures':
        return {_db.fixtures};
      case 'fixture_parts':
        return {_db.fixtureParts};
      case 'lighting_positions':
        return {_db.lightingPositions};
      case 'position_groups':
        return {_db.positionGroups};
      case 'fixture_types':
        return {_db.fixtureTypes};
      case 'channels':
        return {_db.channels};
      case 'addresses':
        return {_db.addresses};
      case 'dimmers':
        return {_db.dimmers};
      case 'circuits':
        return {_db.circuits};
      case 'role_contacts':
        return {_db.roleContacts};
      case 'show_meta':
        return {_db.showMeta};
      case 'gels':
        return {_db.gels};
      case 'gobos':
        return {_db.gobos};
      case 'accessories':
        return {_db.accessories};
      case 'custom_field_values':
        return {_db.customFieldValues};
      default:
        return {};
    }
  }

  // ── Internal undo accumulation ────────────────────────────────────────────

  /// Adds a sub-operation to the pending batch frame (if a batch is open)
  /// or pushes a single-op frame to the undo stack.
  void _addSubOp(UndoSubOperation op, {required String description}) {
    if (_pendingBatchFrame != null) {
      // Accumulating into a batch — don't push yet.
      (_pendingBatchFrame!.operations).add(op);
    } else {
      undoStack.push(UndoFrame(description: description, operations: [op]));
    }
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  String? _jsonEncode(dynamic value) {
    if (value == null) return null;
    return jsonEncode(value);
  }
}
