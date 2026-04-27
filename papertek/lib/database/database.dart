import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/show_meta.dart';
import 'tables/users_local.dart';
import 'tables/venue.dart';
import 'tables/fixtures.dart';
import 'tables/attachables.dart';
import 'tables/custom_fields.dart';
import 'tables/revisions.dart';
import 'tables/contacts.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  // Migration 1
  ShowMeta,
  UsersLocal,
  // Migration 2
  LightingPositions,
  Circuits,
  Channels,
  Addresses,
  Dimmers,
  // Migration 3
  FixtureTypes,
  Fixtures,
  FixtureParts,
  // Migration 4
  Gels,
  Gobos,
  Accessories,
  WorkNotes,
  MaintenanceLog,
  // Migration 5
  CustomFields,
  CustomFieldValues,
  Reports,
  // Migration 6
  Commits,
  Revisions,
  // Migration 7
  PositionGroups,
  // Migration 8
  RoleContacts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.forTesting(NativeDatabase connection) : super(connection);

  static AppDatabase openFile(String path) =>
      AppDatabase(NativeDatabase(File(path)));

  static const currentSchemaVersion = 11;

  static Future<AppDatabase> openDefault(String showName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, '$showName.papertek'));
    return AppDatabase.openFile(file.path);
  }

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(lightingPositions);
            await m.createTable(circuits);
            await m.createTable(channels);
            await m.createTable(addresses);
            await m.createTable(dimmers);
          }
          if (from < 3) {
            await m.createTable(fixtureTypes);
            await m.createTable(fixtures);
            await m.createTable(fixtureParts);
          }
          if (from < 4) {
            await m.createTable(gels);
            await m.createTable(gobos);
            await m.createTable(accessories);
            await m.createTable(workNotes);
            await m.createTable(maintenanceLog);
          }
          if (from < 5) {
            await m.createTable(customFields);
            await m.createTable(customFieldValues);
            await m.createTable(reports);
          }
          if (from < 6) {
            await m.createTable(commits);
            await m.createTable(revisions);
          }
          if (from < 7) {
            await m.createTable(positionGroups);
            // Phase 2 show files (schema v6) may already have these columns
            // if they were in the ShowMeta class definition before migration 7
            // was written. Wrap each addColumn to be idempotent.
            await _tryAddColumn(m, lightingPositions, lightingPositions.sortOrder);
            await _tryAddColumn(m, lightingPositions, lightingPositions.groupId);
            await _tryAddColumn(m, showMeta, showMeta.asstDesigner);
            await _tryAddColumn(m, showMeta, showMeta.stageManager);
            await _tryAddColumn(m, showMeta, showMeta.techDate);
          }
          if (from < 8) {
            await m.createTable(roleContacts);
            await _tryAddColumn(m, showMeta, showMeta.labelDesigner);
            await _tryAddColumn(m, showMeta, showMeta.labelAsstDesigner);
            await _tryAddColumn(m, showMeta, showMeta.labelMasterElectrician);
            await _tryAddColumn(m, showMeta, showMeta.labelProducer);
            await _tryAddColumn(m, showMeta, showMeta.labelAsstMasterElectrician);
            await _tryAddColumn(m, showMeta, showMeta.labelStageManager);
          }
          if (from < 9) {
            // Make fixtures.position nullable (recreates table, data preserved).
            await m.alterTable(TableMigration(fixtures));
          }
          if (from < 10) {
            await m.addColumn(fixtures, fixtures.sortOrder);
            await customStatement(
                'UPDATE fixtures SET sort_order = CAST(id AS REAL)');
          }
          if (from < 11) {
            await m.addColumn(fixtures, fixtures.accessories);
            await m.addColumn(fixtures, fixtures.hung);
            await m.addColumn(fixtures, fixtures.focused);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static Future<void> _tryAddColumn(
    Migrator m,
    TableInfo table,
    GeneratedColumn col,
  ) async {
    try {
      await m.addColumn(table, col);
    } catch (_) {
      // Column already exists — safe to ignore.
    }
  }

  Future<List<Map<String, dynamic>>> patchByChannel() => customSelect(
        '''
        SELECT c.name AS channel_name, c.notes, a.name AS address_name, a.type AS address_type
        FROM channels c
        LEFT JOIN addresses a ON a.channel = c.name
        ORDER BY c.name
        ''',
        readsFrom: {channels, addresses},
      ).map((row) => row.data).get();

  Future<List<Map<String, dynamic>>> patchByAddress() => customSelect(
        '''
        SELECT a.name AS address_name, a.type, a.channel AS channel_name, c.notes
        FROM addresses a
        LEFT JOIN channels c ON c.name = a.channel
        ORDER BY a.name
        ''',
        readsFrom: {addresses, channels},
      ).map((row) => row.data).get();
}
