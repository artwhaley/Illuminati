/// ── DATABASE ARCHITECTURE ──────────────────────────────────────────────────
///
/// This file defines the core persistence layer using the 'Drift' (formerly Moor)
/// library. It encapsulates the SQLite schema, migrations, and low-level 
/// database queries.
///
/// THE SCHEMA:
/// The database is designed for a relational lighting design workflow. It 
/// includes tables for Fixtures, Channels, Addresses, Gels, and Gobos. 
/// It also includes a specialized "Revisions" table that acts as an audit trail.
///
/// FULL TEXT SEARCH (FTS5):
/// To support fast global searching across thousands of fixtures, we use 
/// SQLite's FTS5 virtual table engine. 
/// - Table: `fixtures_fts`
/// - Logic: We maintain this table via SQL Triggers. Every time a fixture is 
///   added or updated, the triggers automatically update the search index.
///
/// SCHEMA VERSIONING:
/// As the app evolves, we increment `currentSchemaVersion`. The `onUpgrade` 
/// block handles the structural transformations required to keep old show 
/// files compatible with newer versions of the app.
/// ─────────────────────────────────────────────────────────────────────────────

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
import 'tables/spreadsheet_view_presets.dart';
import 'tables/notes.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  // Migration 1: Base show and user data
  ShowMeta,
  UsersLocal,
  // Migration 2: Venue infrastructure
  LightingPositions,
  Circuits,
  Channels,
  Addresses,
  Dimmers,
  // Migration 3: Fixture definitions
  FixtureTypes,
  Fixtures,
  FixtureParts,
  // Migration 4: Accessories and notes
  Gels,
  Gobos,
  Accessories,
  WorkNotes,
  MaintenanceLog,
  // Migration 5: User-defined custom fields
  CustomFields,
  CustomFieldValues,
  Reports,
  // Migration 6: Revision logging and multi-user sync
  Commits,
  Revisions,
  // Migration 7: Grouping logic
  PositionGroups,
  // Migration 8: Contact management
  RoleContacts,
  // Migration 14: UI State persistence
  SpreadsheetViewPresets,
  // Migration 15+: Advanced Note system
  Notes,
  NoteActions,
  NoteFixtures,
  NotePositions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.forTesting(NativeDatabase connection) : super(connection);

  /// Opens a specific .papertek file at the given path.
  static AppDatabase openFile(String path) =>
      AppDatabase(NativeDatabase(File(path)));

  static const currentSchemaVersion = 21;

  /// Utility to open the default show file in the system's documents directory.
  static Future<AppDatabase> openDefault(String showName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, '$showName.papertek'));
    return AppDatabase.openFile(file.path);
  }

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Initialize all tables defined in the @DriftDatabase annotation.
          await m.createAll();
          // Initialize the specialized search index.
          await _createFts5Table();
          // Initialize attachable indexes.
          await customStatement('CREATE INDEX idx_gels_part ON gels(fixture_part_id);');
          await customStatement('CREATE INDEX idx_gels_fixture ON gels(fixture_id);');
          await customStatement('CREATE INDEX idx_gobos_part ON gobos(fixture_part_id);');
          await customStatement('CREATE INDEX idx_gobos_fixture ON gobos(fixture_id);');
          await customStatement('CREATE INDEX idx_acc_part ON accessories(fixture_part_id);');
          await customStatement('CREATE INDEX idx_acc_fixture ON accessories(fixture_id);');
        },
        onUpgrade: (m, from, to) async {
          // ── REWORK CUTOVER (v21) ──
          // Earlier .papertek show files are no longer supported due to the
          // Fixture Parts rework. Users must create new show files.
          // Historical migration steps (v1-v20) have been collapsed.
          
          if (from < 21) {
            // No-op for now as we are abandoning old files.
          }
        },
        beforeOpen: (details) async {
          // Enforce foreign key constraints.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// ── SEARCH INDEX (FTS5) ────────────────────────────────────────────────────
  /// We use an external content table approach for FTS5, but manually maintain 
  /// it via triggers for performance. This allows for lightning-fast keyword
  /// searches (e.g. typing "101 front wash" finds fixture 101 at the Front Wash position).
  Future<void> _createFts5Table() async {
    await customStatement('DROP TABLE IF EXISTS fixtures_fts;');

    // Define the virtual table with the columns we want to index.
    await customStatement('''
      CREATE VIRTUAL TABLE fixtures_fts USING fts5(
        channel,
        position,
        fixture_type,
        function,
        focus
      );
    ''');

    // Initial population: Populate the index with current database content.
    await customStatement('''
      INSERT INTO fixtures_fts(rowid, channel, position, fixture_type, function, focus)
      SELECT
        f.id,
        (SELECT fp.channel FROM fixture_parts fp
         WHERE fp.fixture_id = f.id AND fp.part_type = 'intensity' LIMIT 1),
        f.position,
        f.fixture_type,
        f.function,
        f.focus
      FROM fixtures f
      WHERE (f.deleted IS NULL OR f.deleted = 0);
    ''');

    // ── SYNC TRIGGERS ──
    // These triggers ensure that whenever data changes in 'fixtures' or 
    // 'fixture_parts', the 'fixtures_fts' index stays updated automatically.
    
    // 1. Update index after a new fixture is inserted.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fixtures_after_insert AFTER INSERT ON fixtures BEGIN
        INSERT INTO fixtures_fts(rowid, channel, position, fixture_type, function, focus)
        SELECT
          new.id,
          (SELECT fp.channel FROM fixture_parts fp
           WHERE fp.fixture_id = new.id AND fp.part_type = 'intensity' LIMIT 1),
          new.position,
          new.fixture_type,
          new.function,
          new.focus;
      END;
    ''');

    // 2. Update index when a fixture's metadata (position, type, etc) changes.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fixtures_after_update AFTER UPDATE ON fixtures BEGIN
        DELETE FROM fixtures_fts WHERE rowid = old.id;
        
        INSERT INTO fixtures_fts(rowid, channel, position, fixture_type, function, focus)
        SELECT
          new.id,
          (SELECT fp.channel FROM fixture_parts fp
           WHERE fp.fixture_id = new.id AND fp.part_type = 'intensity' LIMIT 1),
          new.position,
          new.fixture_type,
          new.function,
          new.focus
        WHERE (new.deleted IS NULL OR new.deleted = 0);
      END;
    ''');

    // 3. Update index when a fixture_part (Channel or Address) changes.
    // This is critical because Channel data lives in a different table.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fixture_parts_after_update AFTER UPDATE ON fixture_parts 
      WHEN new.part_type = 'intensity' OR old.part_type = 'intensity'
      BEGIN
        DELETE FROM fixtures_fts WHERE rowid = new.fixture_id;

        INSERT INTO fixtures_fts(rowid, channel, position, fixture_type, function, focus)
        SELECT
          f.id,
          (SELECT fp.channel FROM fixture_parts fp
           WHERE fp.fixture_id = f.id AND fp.part_type = 'intensity' LIMIT 1),
          f.position,
          f.fixture_type,
          f.function,
          f.focus
        FROM fixtures f
        WHERE f.id = new.fixture_id AND (f.deleted IS NULL OR f.deleted = 0);
      END;
    ''');
  }

  /// Helper to safely add columns without crashing if they already exist.
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

  // ── SPECIALIZED QUERIES ─────────────────────────────────────────────────────

  /// Returns the show patch ordered by Channel.
  Future<List<Map<String, dynamic>>> patchByChannel() => customSelect(
        '''
        SELECT c.name AS channel_name, c.notes, a.name AS address_name, a.type AS address_type
        FROM channels c
        LEFT JOIN addresses a ON a.channel = c.name
        ORDER BY c.name
        ''',
        readsFrom: {channels, addresses},
      ).map((row) => row.data).get();

  /// Returns the show patch ordered by Address.
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
