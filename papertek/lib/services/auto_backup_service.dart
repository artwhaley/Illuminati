import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../database/database.dart';
import 'backup_settings.dart';
import 'sqlite_snapshot_service.dart';

enum BackupStatus { completed, skippedUnchanged, skippedProtected, failed }

class BackupResult {
  const BackupResult(this.status, {this.snapshot, this.error});
  final BackupStatus status;
  final SnapshotResult? snapshot;
  final Object? error;
}

class AutoBackupService {
  AutoBackupService({
    required this.database,
    required this.sourcePath,
    required this.settings,
    SqliteSnapshotService? snapshots,
    DateTime Function()? now,
    String? tempRoot,
  }) : _snapshots = snapshots ?? const SqliteSnapshotService(),
       _now = now ?? (() => DateTime.now().toUtc()),
       _tempRoot = tempRoot;

  final AppDatabase database;
  final String sourcePath;
  BackupSettings settings;
  final SqliteSnapshotService _snapshots;
  final DateTime Function() _now;
  final String? _tempRoot;
  Timer? _timer;
  StreamSubscription<Set<TableUpdate>>? _updates;
  bool _dirty = false;
  bool _running = false;
  bool _stopped = false;
  Future<BackupResult>? _active;
  String? lastError;
  bool get isDirty => _dirty;
  DateTime? lastBackupAt;
  BackupStatus? lastStatus;

  String get backupDirectory => p.join(
    _tempRoot ?? Directory.systemTemp.path,
    'papertek',
    'backups',
    SqliteSnapshotService.hashPath(_canonical(sourcePath)),
  );
  String _canonical(String value) => p.normalize(File(value).absolute.path);

  Future<void> start() async {
    _updates = database.tableUpdates().listen((_) => _dirty = true);
    _protectExistingSlots();
    _restartTimer();
  }

  void _protectExistingSlots() {
    final dir = Directory(backupDirectory);
    if (!dir.existsSync()) return;
    final slots = <String, dynamic>{};
    for (final slot in ['a', 'b']) {
      final file = File(p.join(dir.path, 'backup-$slot.papertek'));
      if (file.existsSync()) slots[slot] = {'createdAtUtc': file.lastModifiedSync().toUtc().toIso8601String(), 'bytes': file.lengthSync()};
    }
    if (slots.isEmpty) return;
    final manifestFile = File(p.join(dir.path, 'manifest.json'));
    Map<String, dynamic> current = _readManifest(manifestFile);
    final existingSlots = Map<String, dynamic>.from(current['slots'] as Map? ?? {});
    for (final entry in slots.entries) { existingSlots[entry.key] = {...entry.value, ...Map<String, dynamic>.from(existingSlots[entry.key] as Map? ?? {})}; }
    final protectedUntil = _now().add(const Duration(minutes: 30)).toIso8601String();
    final updated = {'version': 1, 'sourcePath': _canonical(sourcePath), 'protectedUntilUtc': protectedUntil, 'slots': existingSlots};
    try { final partial = File('${manifestFile.path}.partial'); partial.writeAsStringSync(jsonEncode(updated)); partial.renameSync(manifestFile.path); } catch (_) { /* status is retained by the next backup attempt */ }
  }

  void updateSettings(BackupSettings value) {
    settings = value;
    _restartTimer();
  }

  void markDirty() => _dirty = true;
  void _restartTimer() {
    _timer?.cancel();
    if (!_stopped && settings.enabled)
      _timer = Timer.periodic(
        Duration(minutes: settings.intervalMinutes),
        (_) => tick(),
      );
  }

  Future<BackupResult> tick({bool force = false}) {
    if (_active != null) return _active!;
    _active = _run(force: force);
    _active!.whenComplete(() => _active = null);
    return _active!;
  }

  Future<BackupResult> _run({required bool force}) async {
    if (!settings.enabled || (!force && !_dirty))
      return const BackupResult(BackupStatus.skippedUnchanged);
    _running = true;
    try {
      final dir = Directory(backupDirectory)..createSync(recursive: true);
      final manifestFile = File(p.join(dir.path, 'manifest.json'));
      final manifest = _readManifest(manifestFile);
      final protectedUntil = DateTime.tryParse(
        manifest['protectedUntilUtc']?.toString() ?? '',
      );
      final slots = Map<String, dynamic>.from(manifest['slots'] as Map? ?? {});
      final existing = ['a', 'b']
          .where(
            (slot) =>
                File(p.join(dir.path, 'backup-$slot.papertek')).existsSync(),
          )
          .toList();
      String? slot = existing.length < 2
          ? (existing.contains('a') ? 'b' : 'a')
          : null;
      if (slot == null) {
        if (protectedUntil != null && _now().isBefore(protectedUntil))
          return const BackupResult(BackupStatus.skippedProtected);
        final a =
            DateTime.tryParse(slots['a']?['createdAtUtc']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final b =
            DateTime.tryParse(slots['b']?['createdAtUtc']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        slot = a.isBefore(b) ? 'a' : 'b';
      }
      final target = p.join(dir.path, 'backup-$slot.papertek');
      final candidate = await _snapshots.snapshot(
        sourcePath,
        '$target.candidate',
      );
      final newest = slots.values
          .whereType<Map>()
          .map((m) => m['sha256']?.toString())
          .whereType<String>()
          .toSet();
      if (newest.contains(candidate.sha256)) {
        final file = File(candidate.path);
        if (file.existsSync()) await file.delete();
        _dirty = false;
        lastStatus = BackupStatus.skippedUnchanged;
        return const BackupResult(BackupStatus.skippedUnchanged);
      }
      await File(candidate.path).rename(target);
      slots[slot] = {
        'createdAtUtc': candidate.completedAt.toIso8601String(),
        'sha256': candidate.sha256,
        'bytes': candidate.bytes,
      };
      final updated = {
        'version': 1,
        'sourcePath': _canonical(sourcePath),
        'protectedUntilUtc': manifest['protectedUntilUtc'],
        'slots': slots,
      };
      final partial = File(p.join(dir.path, 'manifest.json.partial'));
      await partial.writeAsString(jsonEncode(updated));
      await partial.rename(manifestFile.path);
      _dirty = false;
      lastBackupAt = candidate.completedAt;
      lastStatus = BackupStatus.completed;
      lastError = null;
      return BackupResult(BackupStatus.completed, snapshot: candidate);
    } catch (error) {
      lastError = error.toString();
      lastStatus = BackupStatus.failed;
      return BackupResult(BackupStatus.failed, error: error);
    } finally {
      _running = false;
    }
  }

  Map<String, dynamic> _readManifest(File file) {
    if (!file.existsSync())
      return {
        'version': 1,
        'sourcePath': _canonical(sourcePath),
        'slots': <String, dynamic>{},
      };
    try {
      return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      return {
        'version': 1,
        'sourcePath': _canonical(sourcePath),
        'slots': <String, dynamic>{},
      };
    }
  }

  Future<void> stop() async {
    _stopped = true;
    _timer?.cancel();
    await _updates?.cancel();
    if (_active != null) await _active;
  }
}
