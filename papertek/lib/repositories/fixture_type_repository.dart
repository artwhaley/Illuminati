import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

class FixtureTypeRepository {
  FixtureTypeRepository(this._db, this._tracked);

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  // ── Queries ──────────────────────────────────────────────────────────────

  Stream<List<FixtureType>> watchAll() =>
      (_db.select(_db.fixtureTypes)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> getFixtureCount(int typeId) async {
    final count = _db.fixtures.id.count();
    final row = await (_db.selectOnly(_db.fixtures)
          ..addColumns([count])
          ..where(_db.fixtures.fixtureTypeId.equals(typeId)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  Future<int> addType(String name) async {
    final res = await _tracked.insertRow(
      table: 'fixture_types',
      doInsert: () => _db.into(_db.fixtureTypes).insert(
            FixtureTypesCompanion(name: Value(name)),
          ),
      buildSnapshot: _buildSnapshot,
    );
    return res.rowId;
  }

  Future<void> updateName(int id, String name) =>
      _updateField(id, 'name', name, (r) => r.name, (v) => FixtureTypesCompanion(name: Value(v)));

  Future<void> updateWattage(int id, String? wattage) => _updateField(
      id, 'wattage', wattage, (r) => r.wattage, (v) => FixtureTypesCompanion(wattage: Value(v)));

  Future<void> updatePartCount(int id, int count) => _updateField(
      id, 'part_count', count, (r) => r.partCount, (v) => FixtureTypesCompanion(partCount: Value(v)));

  Future<void> deleteType(int id) => _tracked.deleteRow(
        table: 'fixture_types',
        id: id,
        buildSnapshot: () => _buildSnapshot(id),
        doDelete: () => (_db.delete(_db.fixtureTypes)..where((t) => t.id.equals(id))).go(),
      );

  /// Merges [deleteId] into [keepId]. All fixtures referencing [deleteId] are
  /// reassigned (both FK and soft-link name). If [newName] is supplied the
  /// kept type is also renamed, and any fixtures with the old soft-link name
  /// are updated to match.
  Future<void> mergeTypes({
    required int keepId,
    required int deleteId,
    String? newName,
  }) async {
    final keepRow =
        await (_db.select(_db.fixtureTypes)..where((t) => t.id.equals(keepId))).getSingle();
    final deleteRow =
        await (_db.select(_db.fixtureTypes)..where((t) => t.id.equals(deleteId))).getSingle();

    final finalName = newName ?? keepRow.name;
    final batchId = _tracked.beginImportBatch();

    await _db.transaction(() async {
      // Reassign FK references
      final affectedByFk = await (_db.select(_db.fixtures)
            ..where((t) => t.fixtureTypeId.equals(deleteId)))
          .get();
      for (final fixture in affectedByFk) {
        await _tracked.updateField(
          table: 'fixtures',
          id: fixture.id,
          field: 'fixture_type_id',
          newValue: keepId,
          readCurrentValue: () async => fixture.fixtureTypeId,
          applyUpdate: (v) async {
            await (_db.update(_db.fixtures)..where((t) => t.id.equals(fixture.id)))
                .write(FixturesCompanion(fixtureTypeId: Value(v)));
          },
          batchId: batchId,
        );
      }

      // Reassign soft-link name references from deleted type
      final affectedBySoftLink = await (_db.select(_db.fixtures)
            ..where((t) => t.fixtureType.equals(deleteRow.name)))
          .get();
      for (final fixture in affectedBySoftLink) {
        await _tracked.updateField(
          table: 'fixtures',
          id: fixture.id,
          field: 'fixture_type',
          newValue: finalName,
          readCurrentValue: () async => fixture.fixtureType,
          applyUpdate: (v) async {
            await (_db.update(_db.fixtures)..where((t) => t.id.equals(fixture.id)))
                .write(FixturesCompanion(fixtureType: Value(v)));
          },
          batchId: batchId,
        );
      }

      // If renaming, update kept type's existing fixture soft-links too
      if (newName != null && keepRow.name != finalName) {
        final keepSoftLinkFixtures = await (_db.select(_db.fixtures)
              ..where((t) => t.fixtureType.equals(keepRow.name)))
            .get();
        for (final fixture in keepSoftLinkFixtures) {
          await _tracked.updateField(
            table: 'fixtures',
            id: fixture.id,
            field: 'fixture_type',
            newValue: finalName,
            readCurrentValue: () async => fixture.fixtureType,
            applyUpdate: (v) async {
              await (_db.update(_db.fixtures)..where((t) => t.id.equals(fixture.id)))
                  .write(FixturesCompanion(fixtureType: Value(v)));
            },
            batchId: batchId,
          );
        }
        await _updateField(keepId, 'name', finalName, (r) => r.name,
            (v) => FixtureTypesCompanion(name: Value(v)),
            batchId: batchId);
      }
      await _tracked.deleteRow(
        table: 'fixture_types',
        id: deleteId,
        buildSnapshot: () async => deleteRow.toJson(),
        doDelete: () => (_db.delete(_db.fixtureTypes)..where((t) => t.id.equals(deleteId))).go(),
        batchId: batchId,
      );
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _updateField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(FixtureType) readField,
    FixtureTypesCompanion Function(T) buildCompanion, {
    String? batchId,
  }) =>
      _tracked.updateField(
        table: 'fixture_types',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async =>
            readField(await (_db.select(_db.fixtureTypes)..where((t) => t.id.equals(id))).getSingle()),
        applyUpdate: (v) async =>
            (_db.update(_db.fixtureTypes)..where((t) => t.id.equals(id))).write(buildCompanion(v)),
        batchId: batchId,
      );

  Future<Map<String, dynamic>> _buildSnapshot(int id) async {
    final row = await (_db.select(_db.fixtureTypes)..where((t) => t.id.equals(id))).getSingle();
    return row.toJson();
  }
}
