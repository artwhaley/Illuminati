import 'package:drift/drift.dart';
import 'fixtures.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  // 'work' or 'board'
  TextColumn get type => text()();
  TextColumn get body => text()();
  TextColumn get createdBy => text()();
  TextColumn get createdAt => text()();
  IntColumn get completed => integer().withDefault(const Constant(0))();
  TextColumn get completedAt => text().nullable()();
  TextColumn get completedBy => text().nullable()();
  IntColumn get elevated => integer().withDefault(const Constant(0))();
  IntColumn get fixtureTypeId =>
      integer().nullable().references(FixtureTypes, #id, onDelete: KeyAction.setNull)();
}

class NoteActions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get body => text()();
  TextColumn get userId => text()();
  TextColumn get timestamp => text()();
}

class NoteFixtures extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  IntColumn get fixtureId =>
      integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();

  // Let Drift generate its own constraints; add UNIQUE via a separate index in migration
}

class NotePositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get noteId =>
      integer().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get positionName => text()();

  // Let Drift generate its own constraints; add UNIQUE via a separate index in migration
}
