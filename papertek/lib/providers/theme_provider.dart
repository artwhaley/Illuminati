import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme_mode.dart';
import '../theme/theme_prefs.dart';
import '../theme/app_theme_factory.dart';

/// Notifier responsible for managing the application's theme settings.
class ThemeNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    // Return defaults initially; the app should call initialize() on startup.
    return ThemeSettings.defaultSettings;
  }

  /// Loads settings from persistent storage.
  Future<void> initialize() async {
    state = await ThemePrefs.loadThemeSettings();
  }

  /// Updates the theme mode and persists the change.
  Future<void> setMode(AppThemeMode mode) async {
    if (state.mode == mode) return;
    state = ThemeSettings(mode: mode, ctKelvin: state.ctKelvin);
    await ThemePrefs.saveThemeSettings(state);
  }

  /// Updates the color temperature (Kelvin) and persists the change.
  Future<void> setCtKelvin(double kelvin) async {
    if (state.ctKelvin == kelvin) return;
    state = ThemeSettings(mode: state.mode, ctKelvin: kelvin);
    await ThemePrefs.saveThemeSettings(state);
  }
}

/// Provider for the [ThemeSettings] state.
final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(ThemeNotifier.new);

/// Derived provider for the light theme [ThemeData].
final themeDataLightProvider = Provider<ThemeData>((ref) {
  return AppThemeFactory.buildLightTheme();
});

/// Derived provider for the dark/active theme [ThemeData].
/// If the mode is [AppThemeMode.ct], it returns the temperature-shifted theme.
final themeDataDarkProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(themeProvider);
  if (settings.mode == AppThemeMode.ct) {
    return AppThemeFactory.buildCtTheme(settings.ctKelvin);
  }
  return AppThemeFactory.buildDarkTheme();
});

/// Derived provider for the [ThemeMode] used by [MaterialApp].
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(themeProvider);
  switch (settings.mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.ct:
      // Route CT mode through the darkTheme slot
      return ThemeMode.dark;
  }
});
