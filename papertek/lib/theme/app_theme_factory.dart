import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_color_utils.dart';

/// Factory for creating the application's [ThemeData] for different modes.
class AppThemeFactory {
  // Original Dark Theme Palette
  static const _darkBg0 = Color(0xFF0B0D11);
  static const _darkBg1 = Color(0xFF13161B);
  static const _darkBorder = Color(0xFF23272E);
  static const _darkTextMain = Color(0xFFC4C7CC);
  static const _darkTextMuted = Color(0xFF6B7280);
  static const _amber = Color(0xFFE5A50A);

  // Light Theme Palette (Refined for better contrast and sophistication)
  static const _lightBg0 = Color(0xFFF1F5F9); // Slate 100
  static const _lightBg1 = Color(0xFFFFFFFF);
  static const _lightPrimary = Color(0xFF4B4E6D); // Muted Purple-Grey
  static const _lightSecondary = Color(0xFF84DCC6); // Soft Teal
  static const _lightOutline = Color(0xFFCBD5E1); // Slate 300
  static const _lightTextMain = Color(0xFF0F172A); // Slate 900 (High contrast)
  static const _lightTextMuted = Color(0xFF475569); // Slate 600

  /// Builds the standard dark theme.
  static ThemeData buildDarkTheme() {
    final scheme = ColorScheme.dark(
      surface: _darkBg1,
      onSurface: _darkTextMain,
      onSurfaceVariant: _darkTextMuted,
      primary: _amber,
      onPrimary: _darkBg0,
      outline: _darkBorder,
      outlineVariant: _darkBorder,
      surfaceContainer: _darkBg1,
      surfaceContainerLow: _darkBg1,
      surfaceContainerLowest: _darkBg0,
      surfaceContainerHigh: Color(0xFF1C1F26),
      surfaceContainerHighest: Color(0xFF23272E),
      secondaryContainer: _amber.withValues(alpha: 0.15),
      onSecondaryContainer: _amber,
    );
    return _buildThemeFromScheme(scheme, _darkBg0, _darkTextMain);
  }

  /// Builds the standard light theme.
  static ThemeData buildLightTheme() {
    final scheme = ColorScheme.light(
      surface: _lightBg1,
      onSurface: _lightTextMain,
      onSurfaceVariant: _lightTextMuted,
      primary: _lightPrimary,
      onPrimary: Colors.white,
      secondary: _lightSecondary,
      onSecondary: _lightTextMain,
      outline: _lightOutline,
      outlineVariant: _lightOutline.withValues(alpha: 0.5),
      surfaceContainer: _lightBg1,
      surfaceContainerLow: _lightBg1, // Cards/Items usually white
      surfaceContainerLowest: _lightBg0, // Page background
    );
    return _buildThemeFromScheme(scheme, _lightBg0, _lightTextMain);
  }

  /// Builds the CT theme based on a kelvin temperature.
  static ThemeData buildCtTheme(double kelvin) {
    final baseScheme = ColorScheme.dark(
      surface: _darkBg1,
      onSurface: _darkTextMain,
      onSurfaceVariant: _darkTextMuted,
      primary: const Color(0xFF9CA3AF),
      onPrimary: _darkBg0,
      outline: _darkBorder,
      outlineVariant: _darkBorder,
      surfaceContainer: _darkBg1,
      surfaceContainerLow: _darkBg1,
      surfaceContainerLowest: _darkBg0,
      surfaceContainerHigh: Color(0xFF1C1F26),
      surfaceContainerHighest: Color(0xFF23272E),
      secondaryContainer: const Color(0xFF9CA3AF).withValues(alpha: 0.15),
      onSecondaryContainer: const Color(0xFF9CA3AF),
    );

    final shiftedScheme = ThemeColorUtils.applyTemperatureToScheme(
      baseScheme,
      kelvin,
      preserveContrast: true,
    );

    final shiftedBg0 = ThemeColorUtils.applyColorTemperature(_darkBg0, kelvin);
    final shiftedText = ThemeColorUtils.applyColorTemperature(_darkTextMain, kelvin);

    return _buildThemeFromScheme(shiftedScheme, shiftedBg0, shiftedText);
  }

  static ThemeData _buildThemeFromScheme(ColorScheme scheme, Color scaffoldBg, Color textMain) {
    final bool isDark = scheme.brightness == Brightness.dark;
    final textBase = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;
    
    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(textBase).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: isDark ? 0.15 : 0.1),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: scheme.primary);
          }
          return IconThemeData(color: scheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.bold : FontWeight.normal,
          );
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(color: scheme.primary);
          }
          return base.copyWith(color: scheme.onSurfaceVariant);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      // Subtle premium tweak: improved card and button shapes
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
    );
  }
}
