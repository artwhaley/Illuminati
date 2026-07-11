import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../database/database.dart';
import 'auto_backup_service.dart';
import 'backup_settings.dart';
import 'pending_write_coordinator.dart';
import 'show_file_service.dart';
import 'sqlite_snapshot_service.dart';

class ShowSession {
  const ShowSession({
    required this.database,
    required this.path,
    required this.openedAt,
  });
  final AppDatabase database;
  final String path;
  final DateTime openedAt;
}

enum CloseShowStatus { closed, alreadyClosed, failed }

class CloseShowResult {
  const CloseShowResult(this.status, {this.error});
  final CloseShowStatus status;
  final Object? error;
}

class ShowSessionNotifier extends Notifier<ShowSession?> {
  Future<void> _serial = Future<void>.value();
  PendingWriteCoordinator? _writes;
  AutoBackupService? _backups;
  PendingWriteCoordinator? get pendingWrites => _writes;

  @override
  ShowSession? build() {
    ref.listen<BackupSettings>(backupSettingsProvider, (_, next) {
      _backups?.updateSettings(next);
    });
    return null;
  }

  Future<T> _queue<T>(Future<T> Function() action) {
    final next = _serial.then((_) => action());
    _serial = next.then<void>((_) {}, onError: (_, __) {});
    return next;
  }

  String _canonical(String path) => p.normalize(File(path).absolute.path);

  Future<void> createShow(String path, {required String showName}) =>
      _queue(() async {
        await _closeCurrent(force: true);
        final canonical = _canonical(path);
        final db = await ShowFileService().createShow(
          canonical,
          showName: showName,
        );
        await _activate(db, canonical);
      });

  Future<String?> openShow(String path) => _queue(() async {
    await _closeCurrent(force: true);
    final canonical = _canonical(path);
    final (db, error) = await ShowFileService().openShow(canonical);
    if (error != null || db == null) return error ?? 'Could not open show.';
    await _activate(db, canonical);
    return null;
  });

  Future<void> saveAs(String destinationPath) => _queue(() async {
    final current = state;
    if (current == null) throw StateError('No show is open.');
    await _writes?.flushAndDrain();
    await _backups?.stop();
    final destination = _canonical(destinationPath);
    if (destination == current.path)
      throw ArgumentError('The destination is the current show.');
    final snapshot = await const SqliteSnapshotService().snapshot(
      current.path,
      destination,
    );
    final (db, error) = await ShowFileService().openShow(snapshot.path);
    if (error != null || db == null)
      throw StateError(error ?? 'Could not reopen saved show.');
    try {
      await _closeCurrent(force: true);
      await _activate(db, snapshot.path);
    } catch (_) {
      await db.close();
      rethrow;
    }
  });

  Future<CloseShowResult> closeShow({bool force = false}) => _queue(() async {
    if (state == null)
      return const CloseShowResult(CloseShowStatus.alreadyClosed);
    try {
      await _closeCurrent(force: force);
      return const CloseShowResult(CloseShowStatus.closed);
    } catch (error) {
      if (!force) return CloseShowResult(CloseShowStatus.failed, error: error);
      await _closeCurrent(force: true);
      return CloseShowResult(CloseShowStatus.closed);
    }
  });

  Future<void> shutdown() => _queue(() async {
    await _closeCurrent(force: true);
  });

  Future<void> _activate(AppDatabase db, String path) async {
    final opened = DateTime.now().toUtc();
    state = ShowSession(database: db, path: path, openedAt: opened);
    _writes = PendingWriteCoordinator();
    _backups = AutoBackupService(
      database: db,
      sourcePath: path,
      settings: ref.read(backupSettingsProvider),
    );
    await _backups!.start();
  }

  Future<void> _closeCurrent({required bool force}) async {
    final current = state;
    if (current == null) return;
    Object? firstError;
    try {
      await _writes?.flushAndDrain();
    } catch (error) {
      firstError = error;
      if (!force) rethrow;
    }
    try {
      if (_backups?.isDirty == true) {
        final result = await _backups!.tick(force: true);
        if (result.status == BackupStatus.failed) {
          throw StateError(result.error?.toString() ?? 'Final backup failed.');
        }
      }
    } catch (error) {
      firstError ??= error;
      if (!force) rethrow;
    }
    try {
      await _backups?.stop();
    } catch (error) {
      firstError ??= error;
      if (!force) rethrow;
    }
    _writes?.close();
    try {
      await current.database.close();
    } finally {
      state = null;
      _writes = null;
      _backups = null;
    }
    if (firstError != null && !force)
      Error.throwWithStackTrace(firstError!, StackTrace.current);
  }
}
