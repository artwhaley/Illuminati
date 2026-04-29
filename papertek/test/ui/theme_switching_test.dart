import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:papertek/ui/app.dart';
import 'package:papertek/providers/theme_provider.dart';
import 'package:papertek/theme/app_theme_mode.dart';
import 'package:papertek/theme/theme_prefs.dart';
import 'package:papertek/ui/settings/theme_settings_section.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Theme Switching UI Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    testWidgets('Mode switching updates active theme', (tester) async {
      final container = ProviderContainer();
      await container.read(themeProvider.notifier).initialize();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PaperTekApp(),
        ),
      );

      // Verify default is dark
      var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);

      // Open Settings (we'll just use the provider directly for brevity in this test 
      // but verify UI elements exist if possible)
      await container.read(themeProvider.notifier).setMode(AppThemeMode.light);
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('CT slider visibility toggles only in ct mode', (tester) async {
      final container = ProviderContainer();
      await container.read(themeProvider.notifier).initialize();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const PaperTekApp(),
        ),
      );

      // Trigger settings dialog (simulating the menu click)
      // Since MenuBar is complex to find by text in tests sometimes, 
      // we'll use the provider to switch to CT mode and check if the slider appears in the settings section
      // if we were to render it.
      
      // Let's actually test the ThemeSettingsSection widget directly for better isolation
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            themeProvider.overrideWith(() => _MockThemeNotifier(AppThemeMode.dark)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SingleChildScrollView(child: Column(children: [Text('Settings'), ThemeSettingsSection()]))),
          ),
        ),
      );

      expect(find.byType(Slider), findsNothing);

      // Switch to CT mode
      await tester.tap(find.text('CT Mode'));
      await tester.pumpAndSettle();

      expect(find.byType(Slider), findsOneWidget);
    });
  });
}

class _MockThemeNotifier extends ThemeNotifier {
  final AppThemeMode initialMode;
  _MockThemeNotifier(this.initialMode);

  @override
  ThemeSettings build() {
    return ThemeSettings(mode: initialMode, ctKelvin: 6500.0);
  }
}
