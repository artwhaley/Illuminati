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
///
/// **Two operating modes:**
///
/// - **Tracked mode** (default, [designerMode] = false):
///   Every write creates a pending `revisions` row AND pushes an [UndoFrame].
///
/// - **Designer mode** ([designerMode] = true):
///   Writes happen immediately with no revision rows. Undo still works via
///   [UndoFrame] (snapshots carried in the frame). A brief summary revision is
///   written when switching back to tracked mode.
///
/// **What is NOT tracked here:**
///   Operational tables: `work_notes`, `maintenance_log`, `fixtures.flagged`.
///   Import batches are tracked for audit but excluded from the undo stack.
///
/// **TODO(auth):** Replace [currentUserId] with a real identity once Phase 9
/// auth is wired. The designer-mode toggle and the approve/reject permissions
/// will also hook into the auth layer here.
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

  /// Switch to designer mode. Caller is responsible for ensuring pending
  /// revisions have been committed before calling this (see [hasPendingRevisions]).
  void enterDesignerMode() {
    if (_designerMode) return;
    _designerMode = true;
    _designerStats = _DesignerSessionStats();
    _pendingBatchFrame = null; // clear any dangling batch
  }

  /// Switch back to tracked mode. Writes a single summary revision capturing
  /// what changed during the designer session, then returns the summary string
  /// so the caller can surface it in the UI if desired.
  ///
  /// The summary revision has operation = 'designer_session' and is immediately
  /// committed (not pending) — it is an audit log entry, not a reviewable change.
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
  //
  // Reads current value, updates the live row, inserts a pending revision
  // (tracked mode) or just applies the update (designer mode).
  // Returns the revision ID (or -1 in designer mode) and pushes an UndoFrame.

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
  //
  // Inserts the row, then records an insert revision with a JSON snapshot.
  // Returns a record with the new row ID and the revision ID.

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
  //
  // Captures a JSON snapshot BEFORE deleting, hard-deletes the row (cascade
  // handles children), then records a delete revision.
  // Returns the revision ID (or -1 in designer mode).
  //
  // The snapshot stored in oldValueJson inside the UndoFrame is sufficient
  // to restore on undo — we re-insert from it without needing a separate table.

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
  //
  // Import operations are NOT pushed to the undo stack (per spec). They use
  // the supervisor reject flow for rollback. The isImport flag on insertRow
  // enforces this.

  String beginImportBatch() => const Uuid().v4();

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
  //
  // For operations that produce multiple sub-operations that must undo
  // atomically (e.g. reorder positions, merge fixture types), the caller
  // calls beginBatchFrame() before the operations and endBatchFrame() after.
  // All sub-operations accumulate into ONE UndoFrame.

  UndoFrame? _pendingBatchFrame;

  /// Start accumulating sub-operations into a single undo frame.
  /// Returns a description string that will label the frame.
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

  /// Undo the most recent operation. Returns the description of what was undone,
  /// or null if the stack is empty.
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
          await _restoreFromSnapshot(op.targetTable, snapshot);
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
          await _restoreFromSnapshot(op.targetTable, snapshot);
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
  //
  // Restores a hard-deleted row from a JSON snapshot. Currently handles
  // fixtures (the most complex case — fixture + parts). Venue table restores
  // are simpler (single row) and delegated to generic table logic.

  Future<void> _restoreFromSnapshot(
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

    // Re-insert the fixture row with the original ID.
    await _db.customInsert(
      '''
      INSERT OR IGNORE INTO fixtures
        (id, fixture_type_id, fixture_type, position, unit_number,
         wattage, function, focus, flagged, sort_order,
         accessories, hung, focused, patched)
      VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
      ''',
      variables: [
        Variable<int>(fixtureData['id']),
        Variable<int>(fixtureData['fixture_type_id']),
        Variable<String>(fixtureData['fixture_type']),
        Variable<String>(fixtureData['position']),
        Variable<int>(fixtureData['unit_number']),
        Variable<String>(fixtureData['wattage']),
        Variable<String>(fixtureData['function']),
        Variable<String>(fixtureData['focus']),
        Variable<int>(fixtureData['flagged'] ?? 0),
        Variable<double>(fixtureData['sort_order'] ?? 0.0),
        Variable<String>(fixtureData['accessories']),
        Variable<int>(fixtureData['hung'] ?? 0),
        Variable<int>(fixtureData['focused'] ?? 0),
        Variable<int>(fixtureData['patched'] ?? 0),
      ],
      updates: {_db.fixtures},
    );

    // Re-insert parts.
    for (final part in partsData) {
      await _db.customInsert(
        '''
        INSERT OR IGNORE INTO fixture_parts
          (id, fixture_id, part_order, part_type, part_name,
           channel, address, circuit, ip_address, mac_address,
           subnet, ipv6, extras_json)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
        ''',
        variables: [
          Variable<int>(part['id']),
          Variable<int>(part['fixture_id']),
          Variable<int>(part['part_order']),
          Variable<String>(part['part_type']),
          Variable<String>(part['part_name']),
          Variable<String>(part['channel']),
          Variable<String>(part['address']),
          Variable<String>(part['circuit']),
          Variable<String>(part['ip_address']),
          Variable<String>(part['mac_address']),
          Variable<String>(part['subnet']),
          Variable<String>(part['ipv6']),
          Variable<String>(part['extras_json']),
        ],
        updates: {_db.fixtureParts},
      );
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
