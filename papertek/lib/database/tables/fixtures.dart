import 'package:drift/drift.dart';

class FixtureTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get wattage => text().nullable()();
  IntColumn get partCount => integer().withDefault(const Constant(1))();
  TextColumn get defaultPartsJson => text().nullable()();
}

class Fixtures extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureTypeId => integer().nullable().references(FixtureTypes, #id)();
  TextColumn get fixtureType => text().nullable()();
  // Soft-link to lighting_positions.name — NOT NULL
  TextColumn get position => text()();
  IntColumn get unitNumber => integer().nullable()();
  TextColumn get wattage => text().nullable()();
  TextColumn get function => text().nullable()();
  TextColumn get focus => text().nullable()();
  IntColumn get flagged => integer().withDefault(const Constant(0))();
}

class FixtureParts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get partOrder => integer()();
  TextColumn get partType => text().nullable().customConstraint(
      "CHECK (part_type IN ('intensity','gel','x','y','x_high','x_low','y_high','y_low','gobo','gobo_feature','color_feature'))")();
  TextColumn get partName => text().nullable()();
  // Soft-links
  TextColumn get channel => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  TextColumn get macAddress => text().nullable()();
  TextColumn get subnet => text().nullable()();
  TextColumn get ipv6 => text().nullable()();
  TextColumn get extrasJson => text().nullable()();

  @override
  List<String> get customConstraints => ['UNIQUE (fixture_id, part_order)'];
}
