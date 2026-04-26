import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/show_provider.dart';
import 'start_screen.dart';
import 'main_shell.dart';

class PaperTekApp extends ConsumerWidget {
  const PaperTekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    return MaterialApp(
      title: 'PaperTek',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: db == null ? const StartScreen() : const MainShell(),
    );
  }

  ThemeData _buildTheme() {
    const bg0 = Color(0xFF0B0D11);
    const bg1 = Color(0xFF13161B);
    const border = Color(0xFF23272E);
    const textMain = Color(0xFFC4C7CC);
    const amber = Color(0xFFE5A50A);

    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: bg0,
      colorScheme: base.colorScheme.copyWith(
        surface: bg1,
        primary: amber,
        onPrimary: bg0,
        onSurface: textMain,
      ),
      dividerTheme: const DividerThemeData(color: border, space: 1),
      textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bg1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: amber, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}
