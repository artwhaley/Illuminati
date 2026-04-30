import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

/// Manages lighting positions and position groups.
///
/// Position ordering uses a shared sort_order integer — lower = higher in list.
/// Group sort_order positions groups among ungrouped positions in the same
/// top-level namespace; position sort_order is relative to its context
/// (within its group, or among top-level ungrouped positions).
class PositionRepository {
  PositionRepository(this._db, this._tracked);

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

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
    final res = await _tracked.insertRow(
      table: 'lighting_positions',
      doInsert: () => _db.into(_db.lightingPositions).insert(
            LightingPositionsCompanion(
              name: Value(name),
              sortOrder: Value(maxOrder),
            ),
          ),
      buildSnapshot: _buildSnapshot,
    );
    return res.rowId;
  }

  Future<void> renamePosition(int id, String name) async {
    final oldRow = await (_db.select(_db.lightingPositions)..where((t) => t.id.equals(id))).getSingle();
    final batchId = _tracked.beginImportBatch();
    await _db.transaction(() async {
      // 1. Rename the position itself.
      await _updateField(id, 'name', name, (r) => r.name, (v) => LightingPositionsCompanion(name: Value(v)), batchId: batchId);

      // 2. Update all fixtures referencing the old name.
      final fixtures = await (_db.select(_db.fixtures)..where((f) => f.position.equals(oldRow.name))).get();
      for (final f in fixtures) {
        await _tracked.updateField(
          table: 'fixtures',
          id: f.id,
          field: 'position',
          newValue: name,
          readCurrentValue: () async => f.position,
          applyUpdate: (v) async {
            await (_db.update(_db.fixtures)..where((r) => r.id.equals(f.id))).write(FixturesCompanion(position: Value(v)));
          },
          batchId: batchId,
        );
      }
    });
  }

  Future<void> updateTrim(int id, String? value) => _updateField(
      id, 'trim', value, (r) => r.trim, (v) => LightingPositionsCompanion(trim: Value(v)));

  Future<void> updateFromPlasterLine(int id, String? value) => _updateField(id, 'from_plaster_line',
      value, (r) => r.fromPlasterLine, (v) => LightingPositionsCompanion(fromPlasterLine: Value(v)));

  Future<void> updateFromCenterLine(int id, String? value) => _updateField(id, 'from_center_line',
      value, (r) => r.fromCenterLine, (v) => LightingPositionsCompanion(fromCenterLine: Value(v)));

  Future<void> deletePosition(int id) => _tracked.deleteRow(
        table: 'lighting_positions',
        id: id,
        buildSnapshot: () async => (await (_db.select(_db.lightingPositions)
                  ..where((t) => t.id.equals(id)))
                .getSingle())
            .toJson(),
        doDelete: () => (_db.delete(_db.lightingPositions)..where((t) => t.id.equals(id))).go(),
      );

  /// Persists a new ordering for all top-level items in one transaction.
  ///
  /// [orderedItems] is the complete list of top-level items in their desired
  /// order; each entry carries the id and whether it is a group.
  Future<void> reorderTopLevel(List<({int id, bool isGroup})> orderedItems) async {
    final batchId = _tracked.beginImportBatch();
    await _db.transaction(() async {
      for (var i = 0; i < orderedItems.length; i++) {
        final item = orderedItems[i];
        if (item.isGroup) {
          await _updateGroupField(item.id, 'sort_order', i, (r) => r.sortOrder,
              (v) => PositionGroupsCompanion(sortOrder: Value(v)),
              batchId: batchId);
        } else {
          await _updateField(item.id, 'sort_order', i, (r) => r.sortOrder,
              (v) => LightingPositionsCompanion(sortOrder: Value(v)),
              batchId: batchId);
        }
      }
    });
  }

  /// Persists a new ordering for positions within a single group.
  Future<void> reorderWithinGroup(int groupId, List<int> orderedPositionIds) async {
    final batchId = _tracked.beginImportBatch();
    await _db.transaction(() async {
      for (var i = 0; i < orderedPositionIds.length; i++) {
        await _updateField(orderedPositionIds[i], 'sort_order', i, (r) => r.sortOrder,
            (v) => LightingPositionsCompanion(sortOrder: Value(v)),
            batchId: batchId);
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
    final keepRow =
        await (_db.select(_db.lightingPositions)..where((t) => t.id.equals(keepId))).getSingle();
    final deleteRow =
        await (_db.select(_db.lightingPositions)..where((t) => t.id.equals(deleteId))).getSingle();

    final finalName = newName ?? keepRow.name;
    final batchId = _tracked.beginImportBatch();

    await _db.transaction(() async {
      // Reassign fixtures from the deleted position to finalName.
      final affectedFixtures = await (_db.select(_db.fixtures)
            ..where((t) => t.position.equals(deleteRow.name)))
          .get();
      for (final fixture in affectedFixtures) {
        await _tracked.updateField(
          table: 'fixtures',
          id: fixture.id,
          field: 'position',
          newValue: finalName,
          readCurrentValue: () async => fixture.position,
          applyUpdate: (v) async {
            await (_db.update(_db.fixtures)..where((t) => t.id.equals(fixture.id)))
                .write(FixturesCompanion(position: Value(v)));
          },
          batchId: batchId,
        );
      }

      // If using a custom name, also update fixtures already under keepRow.
      if (newName != null && keepRow.name != finalName) {
        final keepFixtures = await (_db.select(_db.fixtures)
              ..where((t) => t.position.equals(keepRow.name)))
            .get();
        for (final fixture in keepFixtures) {
          await _tracked.updateField(
            table: 'fixtures',
            id: fixture.id,
            field: 'position',
            newValue: finalName,
            readCurrentValue: () async => fixture.position,
            applyUpdate: (v) async {
              await (_db.update(_db.fixtures)..where((t) => t.id.equals(fixture.id)))
                  .write(FixturesCompanion(position: Value(v)));
            },
            batchId: batchId,
          );
        }
        await _updateField(keepId, 'name', finalName, (r) => r.name,
            (v) => LightingPositionsCompanion(name: Value(v)),
            batchId: batchId);
      }
      await _tracked.deleteRow(
        table: 'lighting_positions',
        id: deleteId,
        buildSnapshot: () async => deleteRow.toJson(),
        doDelete: () => (_db.delete(_db.lightingPositions)..where((t) => t.id.equals(deleteId))).go(),
        batchId: batchId,
      );
    });
  }

  // ── Group CRUD ────────────────────────────────────────────────────────────

  Future<int> createGroup(String name, List<int> positionIds) async {
    final order = await _nextGroupOrder();
    final batchId = _tracked.beginImportBatch();

    final res = await _tracked.insertRow(
      table: 'position_groups',
      doInsert: () async {
        final groupId = await _db.into(_db.positionGroups).insert(
              PositionGroupsCompanion(
                name: Value(name),
                sortOrder: Value(order),
              ),
            );
        for (var i = 0; i < positionIds.length; i++) {
          await _updateField(positionIds[i], 'group_id', groupId, (r) => r.groupId,
              (v) => LightingPositionsCompanion(groupId: Value(v)),
              batchId: batchId);
          await _updateField(positionIds[i], 'sort_order', i, (r) => r.sortOrder,
              (v) => LightingPositionsCompanion(sortOrder: Value(v)),
              batchId: batchId);
        }
        return groupId;
      },
      buildSnapshot: (id) async =>
          (await (_db.select(_db.positionGroups)..where((t) => t.id.equals(id))).getSingle())
              .toJson(),
      batchId: batchId,
    );
    return res.rowId;
  }

  Future<void> renameGroup(int id, String name) => _updateGroupField(
      id, 'name', name, (r) => r.name, (v) => PositionGroupsCompanion(name: Value(v)));

  /// Ungroups all positions in the group then deletes it.
  Future<void> deleteGroup(int id) async {
    final batchId = _tracked.beginImportBatch();
    await _db.transaction(() async {
      // Ungroup all positions so they surface at the top level.
      final nextOrder = await _nextTopLevelOrder();
      final members = await (_db.select(_db.lightingPositions)
            ..where((t) => t.groupId.equals(id))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      for (var i = 0; i < members.length; i++) {
        await _updateField(members[i].id, 'group_id', null, (r) => r.groupId,
            (v) => LightingPositionsCompanion(groupId: const Value(null)),
            batchId: batchId);
        await _updateField(members[i].id, 'sort_order', nextOrder + i, (r) => r.sortOrder,
            (v) => LightingPositionsCompanion(sortOrder: Value(v)),
            batchId: batchId);
      }
      await _tracked.deleteRow(
        table: 'position_groups',
        id: id,
        buildSnapshot: () async =>
            (await (_db.select(_db.positionGroups)..where((t) => t.id.equals(id))).getSingle())
                .toJson(),
        doDelete: () => (_db.delete(_db.positionGroups)..where((t) => t.id.equals(id))).go(),
        batchId: batchId,
      );
    });
  }

  Future<void> addPositionToGroup(int positionId, int groupId) async {
    final memberCount = await (_db.select(_db.lightingPositions)
          ..where((t) => t.groupId.equals(groupId)))
        .get()
        .then((r) => r.length);

    final batchId = _tracked.beginImportBatch();
    await _updateField(positionId, 'group_id', groupId, (r) => r.groupId,
        (v) => LightingPositionsCompanion(groupId: Value(v)),
        batchId: batchId);
    await _updateField(positionId, 'sort_order', memberCount, (r) => r.sortOrder,
        (v) => LightingPositionsCompanion(sortOrder: Value(v)),
        batchId: batchId);
  }

  Future<void> removeFromGroup(int positionId) async {
    // Capture the group id before clearing it.
    final pos = await (_db.select(_db.lightingPositions)..where((t) => t.id.equals(positionId)))
        .getSingle();
    final groupId = pos.groupId;

    final order = await _nextTopLevelOrder();
    final batchId = _tracked.beginImportBatch();

    await _updateField(positionId, 'group_id', null, (r) => r.groupId,
        (v) => LightingPositionsCompanion(groupId: const Value(null)),
        batchId: batchId);
    await _updateField(positionId, 'sort_order', order, (r) => r.sortOrder,
        (v) => LightingPositionsCompanion(sortOrder: Value(v)),
        batchId: batchId);

    // Delete the parent group if it is now empty.
    if (groupId != null) {
      final remaining = await (_db.select(_db.lightingPositions)
            ..where((t) => t.groupId.equals(groupId)))
          .get();
      if (remaining.isEmpty) {
        await _tracked.deleteRow(
          table: 'position_groups',
          id: groupId,
          buildSnapshot: () async =>
              (await (_db.select(_db.positionGroups)..where((t) => t.id.equals(groupId)))
                      .getSingle())
                  .toJson(),
          doDelete: () => (_db.delete(_db.positionGroups)..where((t) => t.id.equals(groupId))).go(),
          batchId: batchId,
        );
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

  Future<void> _updateField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(LightingPosition) readField,
    LightingPositionsCompanion Function(T) buildCompanion, {
    String? batchId,
  }) =>
      _tracked.updateField(
        table: 'lighting_positions',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async {
          final row =
              await (_db.select(_db.lightingPositions)..where((t) => t.id.equals(id))).getSingle();
          return readField(row);
        },
        applyUpdate: (v) async {
          await (_db.update(_db.lightingPositions)..where((t) => t.id.equals(id)))
              .write(buildCompanion(v));
        },
        batchId: batchId,
      );

  Future<void> _updateGroupField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(PositionGroup) readField,
    PositionGroupsCompanion Function(T) buildCompanion, {
    String? batchId,
  }) =>
      _tracked.updateField(
        table: 'position_groups',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async {
          final row =
              await (_db.select(_db.positionGroups)..where((t) => t.id.equals(id))).getSingle();
          return readField(row);
        },
        applyUpdate: (v) async {
          await (_db.update(_db.positionGroups)..where((t) => t.id.equals(id)))
              .write(buildCompanion(v));
        },
        batchId: batchId,
      );

  Future<Map<String, dynamic>> _buildSnapshot(int id) async {
    final row = await (_db.select(_db.lightingPositions)..where((t) => t.id.equals(id))).getSingle();
    return row.toJson();
  }
}
