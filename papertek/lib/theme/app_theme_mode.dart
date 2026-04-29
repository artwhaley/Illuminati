enum AppThemeMode { dark, light, ct }

extension AppThemeModeExtension on AppThemeMode {
  /// Converts the enum to a string value for storage.
  String toStorageValue() => name;

  /// Creates an [AppThemeMode] from a storage string value.
  /// Defaults to [AppThemeMode.dark] if the value is null or unknown.
  static AppThemeMode fromStorageValue(String? raw) {
    if (raw == null) return AppThemeMode.dark;
    try {
      return AppThemeMode.values.byName(raw);
    } catch (_) {
      return AppThemeMode.dark;
    }
  }
}
