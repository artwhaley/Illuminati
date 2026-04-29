import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:papertek/providers/theme_provider.dart';
import 'package:papertek/theme/app_theme_mode.dart';

void main() {
  group('ThemeProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('initial state is defaultSettings', () {
      final container = ProviderContainer();
      expect(container.read(themeProvider).mode, AppThemeMode.dark);
      expect(container.read(themeProvider).ctKelvin, 6500.0);
    });

    test('setMode updates state and themeModeProvider', () async {
      final container = ProviderContainer();
      
      await container.read(themeProvider.notifier).setMode(AppThemeMode.light);
      
      expect(container.read(themeProvider).mode, AppThemeMode.light);
      expect(container.read(themeModeProvider), ThemeMode.light);
    });

    test('setCtKelvin updates state and keeps mode ct', () async {
      final container = ProviderContainer();
      
      await container.read(themeProvider.notifier).setMode(AppThemeMode.ct);
      await container.read(themeProvider.notifier).setCtKelvin(4000.0);
      
      expect(container.read(themeProvider).mode, AppThemeMode.ct);
      expect(container.read(themeProvider).ctKelvin, 4000.0);
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('initialize loads from storage', () async {
      SharedPreferences.setMockInitialValues({
        'papertek.theme.mode.v1': 'light',
        'papertek.theme.ct_kelvin.v1': 5000.0,
      });

      final container = ProviderContainer();
      await container.read(themeProvider.notifier).initialize();
      
      expect(container.read(themeProvider).mode, AppThemeMode.light);
      expect(container.read(themeProvider).ctKelvin, 5000.0);
    });
  });
}
