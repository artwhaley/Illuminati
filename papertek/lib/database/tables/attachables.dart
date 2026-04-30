import 'package:drift/drift.dart';
import 'fixtures.dart';

class Gels extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get fixturePartId => integer().references(FixtureParts, #id, onDelete: KeyAction.cascade)();
  TextColumn get color => text()();
  TextColumn get size => text().nullable()();
  TextColumn get maker => text().nullable()();
  RealColumn get sortOrder => real().withDefault(const Constant(0.0))();
}

class Gobos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get fixturePartId => integer().references(FixtureParts, #id, onDelete: KeyAction.cascade)();
  TextColumn get goboNumber => text()();
  TextColumn get size => text().nullable()();
  TextColumn get maker => text().nullable()();
  RealColumn get sortOrder => real().withDefault(const Constant(0.0))();
}

class Accessories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get fixturePartId => integer().references(FixtureParts, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  RealColumn get sortOrder => real().withDefault(const Constant(0.0))();
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
