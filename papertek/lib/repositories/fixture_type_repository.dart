import 'package:drift/drift.dart';
import '../database/database.dart';

class FixtureTypeRepository {
  FixtureTypeRepository(this._db);

  final AppDatabase _db;

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

  Future<int> addType(String name) =>
      _db.into(_db.fixtureTypes).insert(
            FixtureTypesCompanion(name: Value(name)),
          );

  Future<void> updateName(int id, String name) =>
      (_db.update(_db.fixtureTypes)..where((t) => t.id.equals(id)))
          .write(FixtureTypesCompanion(name: Value(name)));

  Future<void> updateWattage(int id, String? wattage) =>
      (_db.update(_db.fixtureTypes)..where((t) => t.id.equals(id)))
          .write(FixtureTypesCompanion(wattage: Value(wattage)));

  Future<void> updatePartCount(int id, int count) =>
      (_db.update(_db.fixtureTypes)..where((t) => t.id.equals(id)))
          .write(FixtureTypesCompanion(partCount: Value(count)));

  Future<void> deleteType(int id) =>
      (_db.delete(_db.fixtureTypes)..where((t) => t.id.equals(id))).go();

  /// Merges [deleteId] into [keepId]. All fixtures referencing [deleteId] are
  /// reassigned (both FK and soft-link name). If [newName] is supplied the
  /// kept type is also renamed, and any fixtures with the old soft-link name
  /// are updated to match.
  Future<void> mergeTypes({
    required int keepId,
    required int deleteId,
    String? newName,
  }) async {
    final keepRow = await (_db.select(_db.fixtureTypes)
          ..where((t) => t.id.equals(keepId)))
        .getSingle();
    final deleteRow = await (_db.select(_db.fixtureTypes)
          ..where((t) => t.id.equals(deleteId)))
        .getSingle();

    final finalName = newName ?? keepRow.name;

    await _db.transaction(() async {
      // Reassign FK references
      await (_db.update(_db.fixtures)
            ..where((t) => t.fixtureTypeId.equals(deleteId)))
          .write(FixturesCompanion(fixtureTypeId: Value(keepId)));
      // Reassign soft-link name references from deleted type
      await (_db.update(_db.fixtures)
            ..where((t) => t.fixtureType.equals(deleteRow.name)))
          .write(FixturesCompanion(fixtureType: Value(finalName)));
      // If renaming, update kept type's existing fixture soft-links too
      if (newName != null && keepRow.name != finalName) {
        await (_db.update(_db.fixtures)
              ..where((t) => t.fixtureType.equals(keepRow.name)))
            .write(FixturesCompanion(fixtureType: Value(finalName)));
        await (_db.update(_db.fixtureTypes)
              ..where((t) => t.id.equals(keepId)))
            .write(FixtureTypesCompanion(name: Value(finalName)));
      }
      await deleteType(deleteId);
    });
  }
}
