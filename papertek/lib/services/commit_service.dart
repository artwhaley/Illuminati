import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../repositories/tracked_write_repository.dart';
import 'revision_sql_guard.dart';

enum ReviewDecision { approve, reject }

class CommitService {
  CommitService({required AppDatabase db, required TrackedWriteRepository tracked})
      : _db = db,
        _tracked = tracked;

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  /// Processes all decisions. Creates one commits row.
  Future<int> commitBatch({
    required Map<int, ReviewDecision> decisions,
    String? notes,
  }) async {
    if (decisions.isEmpty) return -1;

    return await _db.transaction(() async {
      // 1. Create a Commit row
      final commitId = await _db.into(_db.commits).insert(CommitsCompanion(
            userId: Value(_tracked.currentUserId),
            timestamp: Value(DateTime.now().toIso8601String()),
            notes: Value(notes),
          ));

      // 2. Fetch all revisions and sort: approvals first, then rejections newest-first.
      // Rejecting newest-first ensures cascaded oldValue rollbacks restore the original value.
      final List<({int revId, ReviewDecision decision, Revision rev})> items = [];
      for (final entry in decisions.entries) {
        final rev = await (_db.select(_db.revisions)
              ..where((r) => r.id.equals(entry.key)))
            .getSingleOrNull();
        if (rev == null) continue;
        items.add((revId: entry.key, decision: entry.value, rev: rev));
      }

      // Sort: approvals first (order doesn't matter for approvals), then rejections
      // newest-first so cascaded oldValue rollbacks are applied in the correct order.
      items.sort((a, b) {
        if (a.decision == b.decision) {
          // Both approve, or both reject: sort by ID descending (newest first).
          return b.revId.compareTo(a.revId);
        }
        // Approvals before rejections.
        return a.decision == ReviewDecision.approve ? -1 : 1;
      });

      // 3. Process in sorted order.
      for (final item in items) {
        if (item.decision == ReviewDecision.approve) {
          await _approveRevision(item.rev, commitId);
        } else {
          await _rejectRevision(item.rev, commitId);
        }
      }

      // 3. Clear undo stack (committed changes are permanent)
      _tracked.undoStack.clearAll();

      return commitId;
    });
  }

  Future<void> _approveRevision(Revision rev, int commitId) async {
    if (rev.status != 'pending') return;

    await (_db.update(_db.revisions)..where((r) => r.id.equals(rev.id))).write(RevisionsCompanion(
      status: const Value('committed'),
      commitId: Value(commitId),
    ));

    // If it was a pending delete, we actually hard-delete it now.
    // Attachables are already hard-deleted during 'doDelete', but fixtures/parts use soft-delete.
    if (rev.operation == 'delete') {
      if (revisionTableNameIsSafe(rev.targetTable)) {
        await _db.customStatement(
          'DELETE FROM ${rev.targetTable} WHERE id = ?',
          [rev.targetId],
        );
      }
    }

    // Auto-reject conflicts for field updates.
    if (rev.operation == 'update' && rev.fieldName != null) {
      await (_db.update(_db.revisions)
            ..where((r) => r.targetTable.equals(rev.targetTable))
            ..where((r) => r.targetId.equals(rev.targetId!))
            ..where((r) => r.fieldName.equals(rev.fieldName!))
            ..where((r) => r.status.equals('pending'))
            ..where((r) => r.id.equals(rev.id).not()))
          .write(RevisionsCompanion(
        status: const Value('rejected'),
        commitId: Value(commitId),
      ));
    }
  }

  Future<void> _rejectRevision(Revision rev, int commitId) async {
    if (rev.status != 'pending') return;

    await (_db.update(_db.revisions)..where((r) => r.id.equals(rev.id))).write(RevisionsCompanion(
      status: const Value('rejected'),
      commitId: Value(commitId),
    ));

    switch (rev.operation) {
      case 'update':
        if (revisionUpdateTargetIsSafe(rev.targetTable, rev.fieldName)) {
          final oldVal = rev.oldValue != null ? jsonDecode(rev.oldValue!) : null;
          await _db.customStatement(
            'UPDATE ${rev.targetTable} SET ${rev.fieldName} = ? WHERE id = ?',
            [oldVal, rev.targetId],
          );
        }
      case 'insert':
        if (revisionTableNameIsSafe(rev.targetTable)) {
          await _db.customStatement(
            'DELETE FROM ${rev.targetTable} WHERE id = ?',
            [rev.targetId],
          );
        }
      case 'delete':
        if (rev.oldValue != null && revisionTableNameIsSafe(rev.targetTable)) {
          final snapshot = jsonDecode(rev.oldValue!) as Map<String, dynamic>;
          // Re-insert using the repository's snapshot restorer.
          // Since we are in a transaction, we can call it.
          await _tracked.restoreFromSnapshot(rev.targetTable, snapshot);
        }
      case 'import_batch':
        // Batch rows are rejected individually if the supervisor selects them.
        // The summary row itself doesn't have a direct rollback logic here.
        break;
    }
  }
}
