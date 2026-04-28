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

      // 2. Process each decision
      for (final entry in decisions.entries) {
        final revId = entry.key;
        final decision = entry.value;

        final rev = await (_db.select(_db.revisions)..where((r) => r.id.equals(revId))).getSingleOrNull();
        if (rev == null) continue;

        if (decision == ReviewDecision.approve) {
          await _approveRevision(rev, commitId);
        } else {
          await _rejectRevision(rev, commitId);
        }
      }

      // 3. Clear undo stack (committed changes are permanent)
      _tracked.undoStack.clearAll();

      return commitId;
    });
  }

  Future<void> _approveRevision(Revision rev, int commitId) async {
    // Update status
    await (_db.update(_db.revisions)..where((r) => r.id.equals(rev.id))).write(RevisionsCompanion(
      status: const Value('committed'),
      commitId: Value(commitId),
    ));

    // For delete operations, we need to actually delete the row now
    if (rev.operation == 'delete') {
      if (rev.targetTable == 'fixtures') {
        await (_db.delete(_db.fixtures)..where((f) => f.id.equals(rev.targetId!))).go();
      } else if (rev.targetTable == 'fixture_parts') {
        await (_db.delete(_db.fixtureParts)..where((f) => f.id.equals(rev.targetId!))).go();
      }
    }

    // 3. Auto-reject conflicts:
    // Any other pending revisions for this same field are now obsolete.
    if (rev.fieldName != null) {
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
    // Update status
    await (_db.update(_db.revisions)..where((r) => r.id.equals(rev.id))).write(RevisionsCompanion(
      status: const Value('rejected'),
      commitId: Value(commitId),
    ));

    // Reverse the change
    if (rev.operation == 'update') {
      if (!revisionUpdateTargetIsSafe(rev.targetTable, rev.fieldName)) {
        throw StateError(
          'Reject rollback: invalid revision target '
          'table=${rev.targetTable} field=${rev.fieldName}',
        );
      }
      final oldVal = rev.oldValue != null ? jsonDecode(rev.oldValue!) : null;
      await _db.customStatement(
        'UPDATE ${rev.targetTable} SET ${rev.fieldName} = ? WHERE id = ?',
        [oldVal, rev.targetId],
      );
    } else if (rev.operation == 'insert') {
      // Actually delete the inserted row
      if (rev.targetTable == 'fixtures') {
        await (_db.delete(_db.fixtures)..where((f) => f.id.equals(rev.targetId!))).go();
      } else if (rev.targetTable == 'fixture_parts') {
        await (_db.delete(_db.fixtureParts)..where((f) => f.id.equals(rev.targetId!))).go();
      }
    } else if (rev.operation == 'delete') {
      // Clear the 'deleted' flag
      if (rev.targetTable == 'fixtures') {
        await (_db.update(_db.fixtures)..where((f) => f.id.equals(rev.targetId!)))
            .write(const FixturesCompanion(deleted: Value(0)));
      } else if (rev.targetTable == 'fixture_parts') {
        await (_db.update(_db.fixtureParts)..where((f) => f.id.equals(rev.targetId!)))
            .write(const FixturePartsCompanion(deleted: Value(0)));
      }
    }
  }
}
