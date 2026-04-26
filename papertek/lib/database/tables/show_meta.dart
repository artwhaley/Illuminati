import 'package:drift/drift.dart';

class ShowMeta extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get showName => text()();
  TextColumn get company => text().nullable()();
  TextColumn get orgId => text().nullable()();
  TextColumn get producer => text()();
  TextColumn get designer => text().nullable()();
  TextColumn get designerUserId => text().nullable()();
  TextColumn get asstDesigner => text().nullable()();
  TextColumn get designBusiness => text().nullable()();
  TextColumn get masterElectrician => text().nullable()();
  TextColumn get masterElectricianUserId => text().nullable()();
  TextColumn get asstMasterElectrician => text().nullable()();
  TextColumn get asstMasterElectricianUserId => text().nullable()();
  TextColumn get stageManager => text().nullable()();
  TextColumn get venue => text().nullable()();
  TextColumn get techDate => text().nullable()();
  TextColumn get openingDate => text().nullable()();
  TextColumn get closingDate => text().nullable()();
  TextColumn get mode => text().nullable()();
  TextColumn get cloudId => text().nullable()();
  IntColumn get schemaVersion => integer()();
  // Migration 8: custom display labels for the six roles.
  // null = use the built-in default label string.
  TextColumn get labelDesigner => text().nullable()();
  TextColumn get labelAsstDesigner => text().nullable()();
  TextColumn get labelMasterElectrician => text().nullable()();
  TextColumn get labelProducer => text().nullable()();
  TextColumn get labelAsstMasterElectrician => text().nullable()();
  TextColumn get labelStageManager => text().nullable()();
}
