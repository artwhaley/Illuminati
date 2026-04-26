import 'package:drift/drift.dart';
import 'fixtures.dart';

class Gels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get color => text()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get fixturePartId => integer().nullable().references(FixtureParts, #id, onDelete: KeyAction.setNull)();
  TextColumn get size => text().nullable()();
  TextColumn get maker => text().nullable()();
}

class Gobos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get goboNumber => text()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get fixturePartId => integer().nullable().references(FixtureParts, #id, onDelete: KeyAction.setNull)();
  TextColumn get size => text().nullable()();
  TextColumn get maker => text().nullable()();
}

class Accessories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
}

class WorkNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get body => text()();
  TextColumn get userId => text()();
  TextColumn get timestamp => text()();
  IntColumn get fixtureId => integer().nullable().references(Fixtures, #id, onDelete: KeyAction.setNull)();
  // Soft-link to lighting_positions.name
  TextColumn get position => text().nullable()();
}

class MaintenanceLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text()();
  TextColumn get userId => text()();
  TextColumn get timestamp => text()();
  IntColumn get resolved => integer().withDefault(const Constant(0))();
}
