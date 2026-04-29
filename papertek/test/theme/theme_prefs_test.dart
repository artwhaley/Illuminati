import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:papertek/theme/app_theme_mode.dart';
import 'package:papertek/theme/theme_prefs.dart';

void main() {
  group('ThemeSettings', () {
    test('should clamp ctKelvin to [3000, 9000]', () {
      const low = ThemeSettings(mode: AppThemeMode.dark, ctKelvin: 1000.0);
      expect(low.ctKelvin, 3000.0);

      const high = ThemeSettings(mode: AppThemeMode.dark, ctKelvin: 15000.0);
      expect(high.ctKelvin, 9000.0);

      const mid = ThemeSettings(mode: AppThemeMode.dark, ctKelvin: 5000.0);
      expect(mid.ctKelvin, 5000.0);
    });
  });

  group('AppThemeModeExtension', () {
    test('fromStorageValue should default to dark for unknown values', () {
      expect(AppThemeModeExtension.fromStorageValue(null), AppThemeMode.dark);
      expect(AppThemeModeExtension.fromStorageValue('invalid'), AppThemeMode.dark);
    });

    test('fromStorageValue should return correct mode for valid values', () {
      expect(AppThemeModeExtension.fromStorageValue('light'), AppThemeMode.light);
      expect(AppThemeModeExtension.fromStorageValue('ct'), AppThemeMode.ct);
      expect(AppThemeModeExtension.fromStorageValue('dark'), AppThemeMode.dark);
    });
  });

  group('ThemePrefs', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadThemeSettings should return defaults when nothing is stored', () async {
      final settings = await ThemePrefs.loadThemeSettings();
      expect(settings.mode, AppThemeMode.dark);
      expect(settings.ctKelvin, 6500.0);
    });

    test('saveThemeSettings and loadThemeSettings should persist values', () async {
      const settings = ThemeSettings(mode: AppThemeMode.light, ctKelvin: 4500.0);
      await ThemePrefs.saveThemeSettings(settings);

      final loaded = await ThemePrefs.loadThemeSettings();
      expect(loaded.mode, AppThemeMode.light);
      expect(loaded.ctKelvin, 4500.0);
    });

    test('loadThemeSettings should handle partial/corrupt values gracefully', () async {
      SharedPreferences.setMockInitialValues({
        'papertek.theme.mode.v1': 'ct',
        // missing kelvin
      });

      final settings = await ThemePrefs.loadThemeSettings();
      expect(settings.mode, AppThemeMode.ct);
      expect(settings.ctKelvin, 6500.0);
    });
  });
}
