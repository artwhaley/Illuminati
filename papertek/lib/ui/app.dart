import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/show_provider.dart';
import '../providers/theme_provider.dart';
import 'start_screen.dart';
import 'main_shell.dart';

class PaperTekApp extends ConsumerWidget {
  const PaperTekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final theme = ref.watch(themeDataLightProvider);
    final darkTheme = ref.watch(themeDataDarkProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'PaperTek',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: db == null ? const StartScreen() : const MainShell(),
    );
  }
}
