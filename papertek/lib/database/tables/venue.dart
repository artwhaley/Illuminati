import 'package:drift/drift.dart';

/// Added migration 7: container for grouping lighting positions together.
class PositionGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // Top-level ordering shared with ungrouped positions (0-based).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  // Optional tint for visual distinction in the positions panel.
  TextColumn get color => text().nullable()();
}

class LightingPositions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get trim => text().nullable()();
  TextColumn get fromPlasterLine => text().nullable()();
  TextColumn get fromCenterLine => text().nullable()();
  // Added migration 7: display order (within group, or top-level when ungrouped).
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  // Added migration 7: null = ungrouped. ON DELETE SET NULL handled in repo.
  IntColumn get groupId => integer().nullable()();
}

class Circuits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get dimmer => text().nullable()();
  TextColumn get capacity => text().nullable()();
}

class Channels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get notes => text().nullable()();
}

class Addresses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get type => text().nullable()();
  TextColumn get channel => text().nullable()();
}

class Dimmers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get address => text().nullable()();
  TextColumn get pack => text().nullable()();
  TextColumn get rack => text().nullable()();
  TextColumn get location => text().nullable()();
  TextColumn get capacity => text().nullable()();
}
