import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme_mode.dart';

/// Immutable model representing theme settings.
class ThemeSettings {
  final AppThemeMode mode;
  final double ctKelvin;

  const ThemeSettings({
    required this.mode,
    required double ctKelvin,
  }) : ctKelvin = ctKelvin < 3000.0 ? 3000.0 : (ctKelvin > 9000.0 ? 9000.0 : ctKelvin);

  /// Default theme settings as per the plan.
  static const ThemeSettings defaultSettings = ThemeSettings(
    mode: AppThemeMode.dark,
    ctKelvin: 6500.0,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSettings && runtimeType == other.runtimeType && mode == other.mode && ctKelvin == other.ctKelvin;

  @override
  int get hashCode => mode.hashCode ^ ctKelvin.hashCode;

  @override
  String toString() => 'ThemeSettings(mode: $mode, ctKelvin: $ctKelvin)';
}

/// Persistence layer for theme settings using [SharedPreferences].
class ThemePrefs {
  static const String _keyMode = 'papertek.theme.mode.v1';
  static const String _keyKelvin = 'papertek.theme.ct_kelvin.v1';

  /// Loads [ThemeSettings] from storage.
  /// Returns [ThemeSettings.defaultSettings] if preferences are missing or an error occurs.
  static Future<ThemeSettings> loadThemeSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final String? rawMode = prefs.getString(_keyMode);
      final double? rawKelvin = prefs.getDouble(_keyKelvin);

      return ThemeSettings(
        mode: AppThemeModeExtension.fromStorageValue(rawMode),
        ctKelvin: rawKelvin ?? ThemeSettings.defaultSettings.ctKelvin,
      );
    } catch (e) {
      // No exceptions bubble to UI if prefs fail.
      return ThemeSettings.defaultSettings;
    }
  }

  /// Saves [ThemeSettings] to storage.
  static Future<void> saveThemeSettings(ThemeSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyMode, settings.mode.toStorageValue());
      await prefs.setDouble(_keyKelvin, settings.ctKelvin);
    } catch (e) {
      // No exceptions bubble to UI if prefs fail.
    }
  }
}
