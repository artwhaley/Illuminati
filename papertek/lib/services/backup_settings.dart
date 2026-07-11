import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackupSettings {
  const BackupSettings({required this.enabled, required this.intervalMinutes});
  final bool enabled;
  final int intervalMinutes;
  static const defaults = BackupSettings(enabled: true, intervalMinutes: 15);
  static const intervals = [5, 10, 15, 30, 60];
}

class BackupSettingsNotifier extends Notifier<BackupSettings> {
  static const _enabled = 'papertek.backup.enabled.v1';
  static const _interval = 'papertek.backup.interval_minutes.v1';
  @override
  BackupSettings build() => BackupSettings.defaults;
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final interval = prefs.getInt(_interval);
    state = BackupSettings(
      enabled: prefs.getBool(_enabled) ?? true,
      intervalMinutes: BackupSettings.intervals.contains(interval)
          ? interval!
          : 15,
    );
  }

  Future<void> setEnabled(bool value) async {
    state = BackupSettings(
      enabled: value,
      intervalMinutes: state.intervalMinutes,
    );
    await (await SharedPreferences.getInstance()).setBool(_enabled, value);
  }

  Future<void> setInterval(int value) async {
    if (!BackupSettings.intervals.contains(value)) value = 15;
    state = BackupSettings(enabled: state.enabled, intervalMinutes: value);
    await (await SharedPreferences.getInstance()).setInt(_interval, value);
  }
}

final backupSettingsProvider =
    NotifierProvider<BackupSettingsNotifier, BackupSettings>(
      BackupSettingsNotifier.new,
    );
