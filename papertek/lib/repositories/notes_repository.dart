import 'package:drift/drift.dart';
import '../database/database.dart';

class NoteActionData {
  const NoteActionData({
    required this.id,
    required this.noteId,
    required this.body,
    required this.userId,
    required this.timestamp,
  });

  final int id;
  final int noteId;
  final String body;
  final String userId;
  final DateTime timestamp;
}

class NoteWithDetails {
  const NoteWithDetails({
    required this.id,
    required this.type,
    required this.body,
    required this.createdBy,
    required this.createdAt,
    required this.completed,
    this.completedAt,
    this.completedBy,
    required this.elevated,
    this.fixtureTypeId,
    this.fixtureTypeName,
    required this.linkedFixtureIds,
    required this.linkedPositionNames,
    required this.actionCount,
    this.latestActionPreview,
  });

  final int id;
  final String type;
  final String body;
  final String createdBy;
  final DateTime createdAt;
  final bool completed;
  final DateTime? completedAt;
  final String? completedBy;
  final bool elevated;
  final int? fixtureTypeId;
  final String? fixtureTypeName;
  final List<int> linkedFixtureIds;
  final List<String> linkedPositionNames;
  final int actionCount;
  final String? latestActionPreview;
}

class FixtureSearchResult {
  const FixtureSearchResult({
    required this.fixtureId,
    this.channel,
    this.position,
    this.unitNumber,
    this.fixtureType,
    this.function,
    this.focus,
    required this.rank,
  });

  final int fixtureId;
  final String? channel;
  final String? position;
  final int? unitNumber;
  final String? fixtureType;
  final String? function;
  final String? focus;
  final double rank;
}

class NotesRepository {
  NotesRepository(this._db);

  final AppDatabase _db;

  Future<int> createNote({
    required String type,
    required String body,
    required String userId,
    List<int>? fixtureIds,
    List<String>? positionNames,
    int? fixtureTypeId,
  }) async {
    return await _db.transaction(() async {
      final noteId = await _db.into(_db.notes).insert(NotesCompanion(
            type: Value(type),
            body: Value(body),
            createdBy: Value(userId),
            createdAt: Value(DateTime.now().toUtc().toIso8601String()),
            fixtureTypeId: Value(fixtureTypeId),
          ));

      if (fixtureIds != null) {
        for (final fid in fixtureIds) {
          await _db.into(_db.noteFixtures).insert(NoteFixturesCompanion(
                noteId: Value(noteId),
                fixtureId: Value(fid),
              ));
        }
      }

      if (positionNames != null) {
        for (final pos in positionNames) {
          await _db.into(_db.notePositions).insert(NotePositionsCompanion(
                noteId: Value(noteId),
                positionName: Value(pos),
              ));
        }
      }

      return noteId;
    });
  }

  Stream<List<NoteWithDetails>> watchNotes({
    required String type,
    bool? completed,
    bool? elevated,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
    String? positionFilter,
    int? fixtureIdFilter,
  }) {
    var sql = '''
      SELECT 
        n.id, n.type, n.body, n.created_by, n.created_at, n.completed, n.completed_at, n.completed_by, n.elevated, n.fixture_type_id,
        ft.name AS fixture_type_name,
        (SELECT COUNT(*) FROM note_actions WHERE note_id = n.id) AS action_count,
        (SELECT body FROM note_actions WHERE note_id = n.id ORDER BY timestamp DESC LIMIT 1) AS latest_action_preview,
        (SELECT group_concat(fixture_id) FROM note_fixtures WHERE note_id = n.id) AS linked_fixtures,
        (SELECT group_concat(position_name, '|') FROM note_positions WHERE note_id = n.id) AS linked_positions
      FROM notes n
      LEFT JOIN fixture_types ft ON ft.id = n.fixture_type_id
      WHERE n.type = ?
    ''';

    final variables = <Variable>[Variable.withString(type)];

    if (completed != null) {
      sql += ' AND n.completed = ?';
      variables.add(Variable.withInt(completed ? 1 : 0));
    }

    if (elevated != null) {
      sql += ' AND n.elevated = ?';
      variables.add(Variable.withInt(elevated ? 1 : 0));
    }

    if (fromDate != null) {
      sql += ' AND n.created_at >= ?';
      variables.add(Variable.withString(fromDate.toUtc().toIso8601String()));
    }

    if (toDate != null) {
      sql += ' AND n.created_at <= ?';
      variables.add(Variable.withString(toDate.toUtc().toIso8601String()));
    }

    if (search != null && search.isNotEmpty) {
      sql += ' AND n.body LIKE ?';
      variables.add(Variable.withString('%$search%'));
    }

    if (positionFilter != null) {
      sql += ' AND EXISTS (SELECT 1 FROM note_positions np WHERE np.note_id = n.id AND np.position_name = ?)';
      variables.add(Variable.withString(positionFilter));
    }

    if (fixtureIdFilter != null) {
      sql += ' AND EXISTS (SELECT 1 FROM note_fixtures nf WHERE nf.note_id = n.id AND nf.fixture_id = ?)';
      variables.add(Variable.withInt(fixtureIdFilter));
    }

    sql += ' ORDER BY n.created_at DESC';

    return _db.customSelect(
      sql,
      variables: variables,
      readsFrom: {
        _db.notes,
        _db.noteActions,
        _db.noteFixtures,
        _db.notePositions,
        _db.fixtureTypes,
      },
    ).watch().map((rows) {
      return rows.map((row) {
        final d = row.data;

        List<int> fids = [];
        if (d['linked_fixtures'] != null) {
          fids = (d['linked_fixtures'] as String)
              .split(',')
              .map((s) => int.parse(s.trim()))
              .toList();
        }

        List<String> pos = [];
        if (d['linked_positions'] != null) {
          pos = (d['linked_positions'] as String).split('|');
        }

        return NoteWithDetails(
          id: d['id'] as int,
          type: d['type'] as String,
          body: d['body'] as String,
          createdBy: d['created_by'] as String,
          createdAt: DateTime.parse(d['created_at'] as String).toLocal(),
          completed: (d['completed'] as int) == 1,
          completedAt: d['completed_at'] != null
              ? DateTime.parse(d['completed_at'] as String).toLocal()
              : null,
          completedBy: d['completed_by'] as String?,
          elevated: (d['elevated'] as int) == 1,
          fixtureTypeId: d['fixture_type_id'] as int?,
          fixtureTypeName: d['fixture_type_name'] as String?,
          linkedFixtureIds: fids,
          linkedPositionNames: pos,
          actionCount: d['action_count'] as int,
          latestActionPreview: d['latest_action_preview'] as String?,
        );
      }).toList();
    });
  }

  Stream<List<NoteActionData>> watchActionsForNote(int noteId) {
    return (_db.select(_db.noteActions)
          ..where((t) => t.noteId.equals(noteId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)]))
        .watch()
        .map((rows) => rows.map((r) => NoteActionData(
              id: r.id,
              noteId: r.noteId,
              body: r.body,
              userId: r.userId,
              timestamp: DateTime.parse(r.timestamp).toLocal(),
            )).toList());
  }

  Future<void> toggleCompleted(int noteId, String userId) async {
    await _db.transaction(() async {
      final current = await (_db.select(_db.notes)..where((t) => t.id.equals(noteId))).getSingleOrNull();
      if (current == null) return;

      final isCompleted = current.completed == 1;
      await (_db.update(_db.notes)..where((t) => t.id.equals(noteId))).write(NotesCompanion(
        completed: Value(isCompleted ? 0 : 1),
        completedAt: Value(isCompleted ? null : DateTime.now().toUtc().toIso8601String()),
        completedBy: Value(isCompleted ? null : userId),
      ));
    });
  }

  Future<void> toggleElevated(int noteId) async {
    await _db.transaction(() async {
      final current = await (_db.select(_db.notes)..where((t) => t.id.equals(noteId))).getSingleOrNull();
      if (current == null) return;

      await (_db.update(_db.notes)..where((t) => t.id.equals(noteId))).write(NotesCompanion(
        elevated: Value(current.elevated == 1 ? 0 : 1),
      ));
    });
  }

  Future<void> updateBody(int noteId, String newBody) async {
    await (_db.update(_db.notes)..where((t) => t.id.equals(noteId))).write(NotesCompanion(
      body: Value(newBody),
    ));
  }

  Future<int> addAction({
    required int noteId,
    required String body,
    required String userId,
  }) async {
    return await _db.into(_db.noteActions).insert(NoteActionsCompanion(
      noteId: Value(noteId),
      body: Value(body),
      userId: Value(userId),
      timestamp: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  Future<void> hardDelete(int noteId) async {
    // note_actions, note_fixtures, note_positions CASCADE
    await (_db.delete(_db.notes)..where((t) => t.id.equals(noteId))).go();
  }

  Future<void> addFixtureLink(int noteId, int fixtureId) async {
    await _db.into(_db.noteFixtures).insert(NoteFixturesCompanion(
      noteId: Value(noteId),
      fixtureId: Value(fixtureId),
    ), mode: InsertMode.insertOrIgnore);
  }

  Future<void> removeFixtureLink(int noteId, int fixtureId) async {
    await (_db.delete(_db.noteFixtures)
      ..where((t) => t.noteId.equals(noteId) & t.fixtureId.equals(fixtureId))).go();
  }

  Future<void> addPositionLink(int noteId, String positionName) async {
    await _db.into(_db.notePositions).insert(NotePositionsCompanion(
      noteId: Value(noteId),
      positionName: Value(positionName),
    ), mode: InsertMode.insertOrIgnore);
  }

  Future<void> removePositionLink(int noteId, String positionName) async {
    await (_db.delete(_db.notePositions)
      ..where((t) => t.noteId.equals(noteId) & t.positionName.equals(positionName))).go();
  }

  Future<List<FixtureSearchResult>> searchFixtures(String query) async {
    if (query.trim().isEmpty) return [];

    final tokens = query.trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (tokens.isEmpty) return [];

    // Build FTS5 prefix-match phrase: "token1"* AND "token2"*
    final matchPhrase = tokens.map((t) => '"' + t + '"*').join(' AND ');
    print('SEARCH query=' + query + ' matchPhrase=' + matchPhrase);

    final sql = '''
      SELECT f.id AS fixture_id, fts.channel, fts.position, fts.fixture_type, fts.function, fts.focus,
             f.unit_number,
             bm25(fixtures_fts) AS rank
      FROM fixtures_fts fts
      JOIN fixtures f ON f.id = fts.rowid
      WHERE fixtures_fts MATCH ?
      ORDER BY rank
      LIMIT 20
    ''';

    try {
      final rows = await _db.customSelect(sql, variables: [Variable.withString(matchPhrase)]).get();
      print('SEARCH: found \${rows.length} rows');
      for (var r in rows) {
        print("  - \${r.data['channel']} | \${r.data['position']} | \${r.data['fixture_type']}");
      }

      return rows.map((r) {
        final d = r.data;
        return FixtureSearchResult(
          fixtureId: d['fixture_id'],
          channel: d['channel'],
          position: d['position'],
          unitNumber: d['unit_number'],
          fixtureType: d['fixture_type'],
          function: d['function'],
          focus: d['focus'],
          rank: (d['rank'] as num).toDouble(),
        );
      }).toList();
    } catch (e, st) {
      print('SEARCH ERROR: \$e\\n\$st');
      return [];
    }
  }

  Future<void> rebuildFtsIndex() async {
    await _db.transaction(() async {
      await _db.customStatement('DELETE FROM fixtures_fts');
      await _db.customStatement('''
        INSERT INTO fixtures_fts(rowid, channel, position, fixture_type, function, focus)
        SELECT f.id, 
               (SELECT channel FROM fixture_parts WHERE fixture_id = f.id AND part_type = 'intensity' LIMIT 1),
               f.position, 
               f.fixture_type, 
               f.function, 
               f.focus
        FROM fixtures f
        WHERE f.deleted = 0;
      ''');
    });
  }
}
