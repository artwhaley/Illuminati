import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:papertek/theme/app_theme_factory.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('buildDarkTheme returns a dark theme with correct background', (tester) async {
    final theme = AppThemeFactory.buildDarkTheme();
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, const Color(0xFF0B0D11));
  });

  testWidgets('buildLightTheme returns a light theme', (tester) async {
    final theme = AppThemeFactory.buildLightTheme();
    expect(theme.brightness, Brightness.light);
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF3F4F6));
  });

  testWidgets('buildCtTheme returns different schemes for different kelvins', (tester) async {
    final warm = AppThemeFactory.buildCtTheme(3000.0);
    final cool = AppThemeFactory.buildCtTheme(9000.0);
    
    expect(warm.colorScheme.primary, isNot(cool.colorScheme.primary));
    expect(warm.scaffoldBackgroundColor, isNot(cool.scaffoldBackgroundColor));
  });

  testWidgets('buildCtTheme preserves DM Sans font', (tester) async {
    final theme = AppThemeFactory.buildCtTheme(6500.0);
    expect(theme.textTheme.bodyMedium?.fontFamily, contains('DMSans'));
  });
}
