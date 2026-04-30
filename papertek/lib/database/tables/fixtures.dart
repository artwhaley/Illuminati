import 'package:drift/drift.dart';

class FixtureTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get wattage => text().nullable()();
  IntColumn get partCount => integer().withDefault(const Constant(1))();
  /// WARNING: Do not embed gel, gobo, or accessory defaults here.
  /// Those are handled by the collection tables, not part rows.
  TextColumn get defaultPartsJson => text().nullable()();
}

class Fixtures extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureTypeId => integer().nullable().references(FixtureTypes, #id)();
  TextColumn get fixtureType => text().nullable()();
  // Soft-link to lighting_positions.name — nullable; null = "Unspecified"
  TextColumn get position => text().nullable()();
  IntColumn get unitNumber => integer().nullable()();
  TextColumn get wattage => text().nullable()();
  TextColumn get function => text().nullable()();
  TextColumn get focus => text().nullable()();
  IntColumn get flagged => integer().withDefault(const Constant(0))();
  // Display order — float so midpoint insertion never requires shifting other rows.
  RealColumn get sortOrder => real().withDefault(const Constant(0.0))();
  // v11 additions
  IntColumn get hung => integer().withDefault(const Constant(0))();
  IntColumn get focused => integer().withDefault(const Constant(0))();
  // v12 additions
  IntColumn get patched => integer().withDefault(const Constant(0))();
  IntColumn get deleted => integer().withDefault(const Constant(0))();
}

class FixtureParts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get partOrder => integer()();
  TextColumn get partType => text().nullable().customConstraint(
      "CHECK (part_type IN ('intensity','x','y','x_high','x_low','y_high','y_low','gobo_feature','color_feature'))")();
  TextColumn get partName => text().nullable()();
  // Soft-links
  TextColumn get channel => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get circuit => text().nullable()();
  TextColumn get ipAddress => text().nullable()();
  TextColumn get macAddress => text().nullable()();
  TextColumn get subnet => text().nullable()();
  TextColumn get ipv6 => text().nullable()();
  TextColumn get extrasJson => text().nullable()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  List<String> get customConstraints => ['UNIQUE (fixture_id, part_order)'];
}
