import 'dart:io';
import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' as raw_sqlite;
import '../database/database.dart';

/// Creates and opens .papertek show files with full schema version gating.
class ShowFileService {
  /// Creates a new .papertek file at [path], seeds the required show_meta row,
  /// and returns an open database ready to use.
  Future<AppDatabase> createShow(
    String path, {
    required String showName,
  }) async {
    // SQLite on Windows creates companion files (-wal, -shm) that must be
    // removed first; otherwise Windows may refuse to delete the main file.
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final companion = File('$path$suffix');
      if (companion.existsSync()) {
        try {
          companion.deleteSync();
        } catch (_) {}
      }
    }
    final existing = File(path);
    if (existing.existsSync()) {
      try {
        existing.deleteSync();
      } catch (e) {
        throw Exception(
          'Cannot overwrite the existing file.\n'
          'It may be open in another application — close it and try again.\n'
          'Detail: $e',
        );
      }
    }
    final db = AppDatabase.openFile(path);
    await db.customStatement('SELECT 1');
    await db.into(db.showMeta).insert(ShowMetaCompanion(
          showName: Value(showName),
          // Producer is set later on the Show Info page.
          producer: const Value(''),
          schemaVersion: const Value(AppDatabase.currentSchemaVersion),
        ));
    return db;
  }

  /// Opens an existing .papertek file with schema version gating.
  ///
  /// Returns `(database, null)` on success.
  /// Returns `(null, errorMessage)` when the file's schema is newer than the app.
  Future<(AppDatabase?, String?)> openShow(String path) async {
    if (!File(path).existsSync()) {
      return (null, 'File not found:\n$path');
    }

    final fileVersion = _readUserVersion(path);

    if (fileVersion > AppDatabase.currentSchemaVersion) {
      return (
        null,
        'This show file was created with a newer version of PaperTek '
            '(schema v$fileVersion).\n\n'
            'Please update the app to open it.',
      );
    }

    final db = AppDatabase.openFile(path);
    await db.customStatement('SELECT 1');
    await _mirrorSchemaVersion(db);
    return (db, null);
  }

  int _readUserVersion(String path) {
    // Open via sqlite3 directly — avoids Drift's ensureOpen/migration machinery.
    final db = raw_sqlite.sqlite3.open(path, mode: raw_sqlite.OpenMode.readOnly);
    try {
      final result = db.select('PRAGMA user_version');
      return result.firstOrNull?['user_version'] as int? ?? 0;
    } finally {
      db.dispose();
    }
  }

  Future<void> _mirrorSchemaVersion(AppDatabase db) async {
    final row = await db.select(db.showMeta).getSingleOrNull();
    if (row == null) return;
    await (db.update(db.showMeta)..where((t) => t.id.equals(row.id))).write(
      const ShowMetaCompanion(
        schemaVersion: Value(AppDatabase.currentSchemaVersion),
      ),
    );
  }
}
