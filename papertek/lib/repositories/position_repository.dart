import 'package:drift/drift.dart';
import '../database/database.dart';

/// Manages lighting positions and position groups.
///
/// Position ordering uses a shared sort_order integer — lower = higher in list.
/// Group sort_order positions groups among ungrouped positions in the same
/// top-level namespace; position sort_order is relative to its context
/// (within its group, or among top-level ungrouped positions).
class PositionRepository {
  PositionRepository(this._db);

  final AppDatabase _db;

  // ── Queries ──────────────────────────────────────────────────────────────

  Stream<List<LightingPosition>> watchAll() =>
      (_db.select(_db.lightingPositions)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Stream<List<PositionGroup>> watchGroups() =>
      (_db.select(_db.positionGroups)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<List<LightingPosition>> getAll() =>
      (_db.select(_db.lightingPositions)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  // ── Position CRUD ─────────────────────────────────────────────────────────

  Future<int> addPosition(String name) async {
    final maxOrder = await _nextTopLevelOrder();
    return _db.into(_db.lightingPositions).insert(
          LightingPositionsCompanion(
            name: Value(name),
            sortOrder: Value(maxOrder),
          ),
        );
  }

  Future<void> renamePosition(int id, String name) =>
      (_db.update(_db.lightingPositions)..where((t) => t.id.equals(id)))
          .write(LightingPositionsCompanion(name: Value(name)));

  Future<void> updateTrim(int id, String? value) =>
      (_db.update(_db.lightingPositions)..where((t) => t.id.equals(id)))
          .write(LightingPositionsCompanion(trim: Value(value)));

  Future<void> updateFromPlasterLine(int id, String? value) =>
      (_db.update(_db.lightingPositions)..where((t) => t.id.equals(id)))
          .write(LightingPositionsCompanion(fromPlasterLine: Value(value)));

  Future<void> updateFromCenterLine(int id, String? value) =>
      (_db.update(_db.lightingPositions)..where((t) => t.id.equals(id)))
          .write(LightingPositionsCompanion(fromCenterLine: Value(value)));

  Future<void> deletePosition(int id) =>
      (_db.delete(_db.lightingPositions)..where((t) => t.id.equals(id))).go();

  /// Persists a new ordering for all top-level items in one transaction.
  ///
  /// [orderedItems] is the complete list of top-level items in their desired
  /// order; each entry carries the id and whether it is a group.
  Future<void> reorderTopLevel(
      List<({int id, bool isGroup})> orderedItems) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedItems.length; i++) {
        final item = orderedItems[i];
        if (item.isGroup) {
          await (_db.update(_db.positionGroups)
                ..where((t) => t.id.equals(item.id)))
              .write(PositionGroupsCompanion(sortOrder: Value(i)));
        } else {
          await (_db.update(_db.lightingPositions)
                ..where((t) => t.id.equals(item.id)))
              .write(LightingPositionsCompanion(sortOrder: Value(i)));
        }
      }
    });
  }

  /// Persists a new ordering for positions within a single group.
  Future<void> reorderWithinGroup(
      int groupId, List<int> orderedPositionIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedPositionIds.length; i++) {
        await (_db.update(_db.lightingPositions)
              ..where((t) => t.id.equals(orderedPositionIds[i])))
            .write(LightingPositionsCompanion(sortOrder: Value(i)));
      }
    });
  }

  // ── Combine ───────────────────────────────────────────────────────────────

  /// Combines two positions into one. All fixtures from [deleteId] are
  /// reassigned to [keepId], then [deleteId] is removed. If [newName] is
  /// supplied the kept position (and all its fixtures) are renamed atomically.
  Future<void> combinePositions({
    required int keepId,
    required int deleteId,
    String? newName,
  }) async {
    final keepRow = await (_db.select(_db.lightingPositions)
          ..where((t) => t.id.equals(keepId)))
        .getSingle();
    final deleteRow = await (_db.select(_db.lightingPositions)
          ..where((t) => t.id.equals(deleteId)))
        .getSingle();

    final finalName = newName ?? keepRow.name;

    await _db.transaction(() async {
      // Reassign fixtures from the deleted position to finalName.
      await (_db.update(_db.fixtures)
            ..where((t) => t.position.equals(deleteRow.name)))
          .write(FixturesCompanion(position: Value(finalName)));
      // If using a custom name, also update fixtures already under keepRow.
      if (newName != null && keepRow.name != finalName) {
        await (_db.update(_db.fixtures)
              ..where((t) => t.position.equals(keepRow.name)))
            .write(FixturesCompanion(position: Value(finalName)));
        await (_db.update(_db.lightingPositions)
              ..where((t) => t.id.equals(keepId)))
            .write(LightingPositionsCompanion(name: Value(finalName)));
      }
      await deletePosition(deleteId);
    });
  }

  // ── Group CRUD ────────────────────────────────────────────────────────────

  Future<int> createGroup(String name, List<int> positionIds) async {
    final order = await _nextGroupOrder();
    late int groupId;
    await _db.transaction(() async {
      groupId = await _db.into(_db.positionGroups).insert(
            PositionGroupsCompanion(
              name: Value(name),
              sortOrder: Value(order),
            ),
          );
      for (var i = 0; i < positionIds.length; i++) {
        await (_db.update(_db.lightingPositions)
              ..where((t) => t.id.equals(positionIds[i])))
            .write(LightingPositionsCompanion(
              groupId: Value(groupId),
              sortOrder: Value(i),
            ));
      }
    });
    return groupId;
  }

  Future<void> renameGroup(int id, String name) =>
      (_db.update(_db.positionGroups)..where((t) => t.id.equals(id)))
          .write(PositionGroupsCompanion(name: Value(name)));

  /// Ungroups all positions in the group then deletes it.
  Future<void> deleteGroup(int id) async {
    await _db.transaction(() async {
      // Ungroup all positions so they surface at the top level.
      final nextOrder = await _nextTopLevelOrder();
      final members = await (_db.select(_db.lightingPositions)
            ..where((t) => t.groupId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      for (var i = 0; i < members.length; i++) {
        await (_db.update(_db.lightingPositions)
              ..where((t) => t.id.equals(members[i].id)))
            .write(LightingPositionsCompanion(
              groupId: const Value(null),
              sortOrder: Value(nextOrder + i),
            ));
      }
      await (_db.delete(_db.positionGroups)..where((t) => t.id.equals(id)))
          .go();
    });
  }

  Future<void> addPositionToGroup(int positionId, int groupId) async {
    final memberCount = await (_db.select(_db.lightingPositions)
          ..where((t) => t.groupId.equals(groupId)))
        .get()
        .then((r) => r.length);
    await (_db.update(_db.lightingPositions)
          ..where((t) => t.id.equals(positionId)))
        .write(LightingPositionsCompanion(
          groupId: Value(groupId),
          sortOrder: Value(memberCount),
        ));
  }

  Future<void> removeFromGroup(int positionId) async {
    // Capture the group id before clearing it.
    final pos = await (_db.select(_db.lightingPositions)
          ..where((t) => t.id.equals(positionId)))
        .getSingle();
    final groupId = pos.groupId;

    final order = await _nextTopLevelOrder();
    await (_db.update(_db.lightingPositions)
          ..where((t) => t.id.equals(positionId)))
        .write(LightingPositionsCompanion(
          groupId: const Value(null),
          sortOrder: Value(order),
        ));

    // Delete the parent group if it is now empty.
    if (groupId != null) {
      final remaining = await (_db.select(_db.lightingPositions)
            ..where((t) => t.groupId.equals(groupId)))
          .get();
      if (remaining.isEmpty) {
        await (_db.delete(_db.positionGroups)
              ..where((t) => t.id.equals(groupId)))
            .go();
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<int> _nextTopLevelOrder() async {
    final posMax = await (_db.select(_db.lightingPositions)
          ..where((t) => t.groupId.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
          ..limit(1))
        .getSingleOrNull()
        .then((r) => r?.sortOrder ?? -1);
    final grpMax = await (_db.select(_db.positionGroups)
          ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
          ..limit(1))
        .getSingleOrNull()
        .then((r) => r?.sortOrder ?? -1);
    return (posMax > grpMax ? posMax : grpMax) + 1;
  }

  Future<int> _nextGroupOrder() async {
    final r = await (_db.select(_db.positionGroups)
          ..orderBy([(t) => OrderingTerm.desc(t.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
    return (r?.sortOrder ?? -1) + 1;
  }
}
