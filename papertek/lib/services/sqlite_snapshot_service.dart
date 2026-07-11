import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../database/database.dart';

class SnapshotResult {
  const SnapshotResult({
    required this.path,
    required this.bytes,
    required this.sha256,
    required this.completedAt,
  });
  final String path;
  final int bytes;
  final String sha256;
  final DateTime completedAt;
}

class SqliteSnapshotService {
  const SqliteSnapshotService();

  Future<SnapshotResult> snapshot(
    String sourcePath,
    String destinationPath,
  ) async {
    final source = _canonical(sourcePath);
    final destination = _canonical(destinationPath);
    if (source == destination)
      throw ArgumentError('Source and destination must be different.');
    final directory = Directory(p.dirname(destination));
    await directory.create(recursive: true);
    final partial =
        '$destination.${DateTime.now().microsecondsSinceEpoch}.${Random().nextInt(1 << 20)}.partial';
    final previous = '$destination.previous';
    sqlite.Database? from;
    sqlite.Database? to;
    try {
      from = sqlite.sqlite3.open(source, mode: sqlite.OpenMode.readOnly);
      to = sqlite.sqlite3.open(partial);
      from.execute('PRAGMA busy_timeout = 5000');
      to.execute('PRAGMA busy_timeout = 5000');
      await from.backup(to, nPage: 64).drain<void>();
      to.dispose();
      to = null;
      from.dispose();
      from = null;
      _validate(partial);
      final bytes = await File(partial).readAsBytes();
      final hash = sha256.convert(bytes).toString();
      final target = File(destination);
      if (target.existsSync()) {
        if (File(previous).existsSync()) await File(previous).delete();
        await target.rename(previous);
      }
      try {
        await File(partial).rename(destination);
        if (File(previous).existsSync()) await File(previous).delete();
      } catch (_) {
        if (!target.existsSync() && File(previous).existsSync())
          await File(previous).rename(destination);
        rethrow;
      }
      return SnapshotResult(
        path: destination,
        bytes: bytes.length,
        sha256: hash,
        completedAt: DateTime.now().toUtc(),
      );
    } finally {
      to?.dispose();
      from?.dispose();
      final partialFile = File(partial);
      if (partialFile.existsSync()) await partialFile.delete();
      if (File(previous).existsSync() && File(destination).existsSync()) {
        await File(previous).delete();
      }
    }
  }

  void _validate(String path) {
    final db = sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly);
    try {
      db.execute('PRAGMA busy_timeout = 5000');
      final check = db
          .select('PRAGMA quick_check')
          .first
          .values
          .first
          .toString();
      if (check != 'ok')
        throw StateError('Snapshot quick_check failed: $check');
      final version =
          (db.select('PRAGMA user_version').first.values.first as num).toInt();
      if (version > AppDatabase.currentSchemaVersion)
        throw StateError('Snapshot schema is newer than this app.');
      final tables = db.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='show_meta'",
      );
      if (tables.isEmpty ||
          (db.select('SELECT COUNT(*) FROM show_meta').first.values.first
                      as num)
                  .toInt() !=
              1) {
        throw StateError(
          'Snapshot does not contain exactly one show_meta row.',
        );
      }
    } finally {
      db.dispose();
    }
  }

  String _canonical(String value) => p.normalize(File(value).absolute.path);
  static String hashPath(String value) =>
      sha256.convert(utf8.encode(value)).toString().substring(0, 24);
}
