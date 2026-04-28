import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';

/// A single revision enriched with a human-readable description for display.
class RevisionView {
  RevisionView({
    required this.id,
    required this.operation,
    required this.targetTable,
    required this.targetId,
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
    required this.status,
    required this.userId,
    this.batchId,
    this.commitId,
  });

  final int id;
  final String operation;     // 'update' | 'insert' | 'delete' | 'import_batch'
  final String targetTable;
  final int? targetId;
  final String? fieldName;
  final dynamic oldValue;     // Decoded from JSON (may be String, Map, null)
  final dynamic newValue;     // Decoded from JSON (may be String, Map, null)
  final String timestamp;
  final String status;        // 'pending' | 'committed' | 'rejected'
  final String userId;
  final String? batchId;
  final int? commitId;

  static RevisionView fromRow(Revision row) {
    dynamic decode(String? json) {
      if (json == null) return null;
      try {
        return jsonDecode(json);
      } catch (_) {
        return json; // fallback — treat as raw string
      }
    }

    return RevisionView(
      id: row.id,
      operation: row.operation,
      targetTable: row.targetTable,
      targetId: row.targetId,
      fieldName: row.fieldName,
      oldValue: decode(row.oldValue),
      newValue: decode(row.newValue),
      timestamp: row.timestamp,
      status: row.status,
      userId: row.userId,
      batchId: row.batchId,
      commitId: row.commitId,
    );
  }

  /// A short human-readable description used in the status bar and undo labels.
  String get shortDescription {
    switch (operation) {
      case 'update':
        return 'Edit ${_friendlyTable(targetTable)} ${fieldName ?? 'field'}';
      case 'insert':
        return 'Add ${_friendlyTable(targetTable)}';
      case 'delete':
        return 'Delete ${_friendlyTable(targetTable)}';
      case 'import_batch':
        return 'Import batch';
      default:
        return 'Change ${_friendlyTable(targetTable)}';
    }
  }

  static String _friendlyTable(String t) {
    const map = {
      'fixtures': 'fixture',
      'fixture_parts': 'part',
      'gels': 'gel',
      'gobos': 'gobo',
      'accessories': 'accessory',
      'lighting_positions': 'position',
      'channels': 'channel',
      'addresses': 'address',
      'dimmers': 'dimmer',
      'circuits': 'circuit',
      'show_meta': 'show info',
      'fixture_types': 'fixture type',
      'role_contacts': 'contact',
    };
    return map[t] ?? t;
  }
}

/// Read-only query layer for the revisions table.
/// Never writes revision rows — that is solely TrackedWriteRepository's job.
class RevisionRepository {
  RevisionRepository(this._db);

  final AppDatabase _db;

  // ── Fixture-level queries ─────────────────────────────────────────────────

  /// Stream of fixture IDs that have at least one pending revision.
  /// Covers both the fixtures table and fixture_parts (channel, address, etc.)
  Stream<Set<int>> watchPendingFixtureIds() {
    final fixtureQuery = _db.customSelect(
      '''
      SELECT DISTINCT r.target_id AS fixture_id
      FROM revisions r
      WHERE r.status = 'pending'
        AND r.target_table = 'fixtures'

      UNION

      SELECT DISTINCT fp.fixture_id
      FROM revisions r
      JOIN fixture_parts fp ON fp.id = r.target_id
      WHERE r.status = 'pending'
        AND r.target_table = 'fixture_parts'
      ''',
      readsFrom: {_db.revisions, _db.fixtureParts},
    );

    return fixtureQuery.watch().map((rows) {
      return rows
          .map((r) => r.read<int?>('fixture_id'))
          .whereType<int>()
          .toSet();
    });
  }

  /// Stream of fixture IDs with conflicting pending revisions.
  /// Conflict = two or more pending 'update' revisions targeting the same
  /// target_table + target_id + field_name. Same user editing the same field
  /// twice counts as a conflict.
  Stream<Set<int>> watchConflictingFixtureIds() {
    final query = _db.customSelect(
      '''
      SELECT DISTINCT
        CASE
          WHEN r.target_table = 'fixtures' THEN r.target_id
          WHEN r.target_table = 'fixture_parts' THEN fp.fixture_id
          ELSE NULL
        END AS fixture_id
      FROM revisions r
      LEFT JOIN fixture_parts fp ON fp.id = r.target_id
        AND r.target_table = 'fixture_parts'
      WHERE r.status = 'pending'
        AND r.operation = 'update'
        AND EXISTS (
          SELECT 1 FROM revisions r2
          WHERE r2.target_table = r.target_table
            AND r2.target_id    = r.target_id
            AND r2.field_name   = r.field_name
            AND r2.id          != r.id
            AND r2.status      = 'pending'
            AND r2.operation   = 'update'
        )
      ''',
      readsFrom: {_db.revisions, _db.fixtureParts},
    );

    return query.watch().map((rows) {
      return rows
          .map((r) => r.read<int?>('fixture_id'))
          .whereType<int>()
          .toSet();
    });
  }

  /// Pending revisions for a specific fixture (fixture row + all its parts).
  Stream<List<RevisionView>> watchPendingForFixture(int fixtureId) {
    final query = _db.customSelect(
      '''
      SELECT r.*
      FROM revisions r
      WHERE r.status = 'pending'
        AND (
          (r.target_table = 'fixtures' AND r.target_id = ?)
          OR
          (r.target_table = 'fixture_parts' AND r.target_id IN (
            SELECT id FROM fixture_parts WHERE fixture_id = ?
          ))
        )
      ORDER BY r.timestamp ASC
      ''',
      variables: [Variable<int>(fixtureId), Variable<int>(fixtureId)],
      readsFrom: {_db.revisions, _db.fixtureParts},
    );

    return query.watch().map((rows) =>
        rows.map((r) => RevisionView.fromRow(_rowToRevision(r))).toList());
  }

  // ── Global queries ────────────────────────────────────────────────────────

  /// All pending revisions across all tracked tables, ordered by timestamp.
  Stream<List<RevisionView>> watchAllPending() {
    return (_db.select(_db.revisions)
          ..where((r) => r.status.equals('pending'))
          ..orderBy([(r) => OrderingTerm.asc(r.timestamp)]))
        .watch()
        .map((rows) => rows.map(RevisionView.fromRow).toList());
  }

  /// Pending revisions grouped by fixture ID (for the review queue).
  /// Returns a map of fixtureId → list of RevisionViews.
  /// Revisions not associated with a fixture (venue edits, etc.) are keyed
  /// under null.
  Stream<Map<int?, List<RevisionView>>> watchPendingGroupedByFixture() {
    final query = _db.customSelect(
      '''
      SELECT 
        r.*,
        CASE 
          WHEN r.target_table = 'fixtures' THEN r.target_id
          WHEN r.target_table = 'fixture_parts' THEN fp.fixture_id
          ELSE NULL
        END AS parent_fixture_id
      FROM revisions r
      LEFT JOIN fixture_parts fp ON fp.id = r.target_id AND r.target_table = 'fixture_parts'
      WHERE r.status = 'pending'
      ORDER BY r.timestamp ASC
      ''',
      readsFrom: {_db.revisions, _db.fixtureParts},
    );

    return query.watch().map((rows) {
      final result = <int?, List<RevisionView>>{};
      for (final row in rows) {
        final rev = RevisionView.fromRow(_rowToRevision(row));
        if (rev.operation == 'import_batch') continue;

        final parentId = row.read<int?>('parent_fixture_id');
        result.putIfAbsent(parentId, () => []).add(rev);
      }
      return result;
    });
  }

  /// Count of pending (unreviewed) revisions — drives a badge on the
  /// Maintenance tab icon.
  Stream<int> watchPendingCount() {
    return (_db.selectOnly(_db.revisions)
          ..addColumns([_db.revisions.id.count()])
          ..where(_db.revisions.status.equals('pending')))
        .watchSingle()
        .map((row) => row.read(_db.revisions.id.count()) ?? 0);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Converts a raw CustomSelectStatement row back to a Revision data class.
  Revision _rowToRevision(QueryRow row) {
    final d = row.data;
    return Revision(
      id: d['id'] as int,
      operation: d['operation'] as String,
      targetTable: d['target_table'] as String,
      targetId: d['target_id'] as int?,
      fieldName: d['field_name'] as String?,
      oldValue: d['old_value'] as String?,
      newValue: d['new_value'] as String?,
      batchId: d['batch_id'] as String?,
      userId: d['user_id'] as String,
      timestamp: d['timestamp'] as String,
      status: d['status'] as String,
      commitId: d['commit_id'] as int?,
    );
  }
}
