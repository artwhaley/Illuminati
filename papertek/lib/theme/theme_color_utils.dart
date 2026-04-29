import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utilities for applying color temperature transformations to colors and schemes.
class ThemeColorUtils {
  /// Neutral color temperature in Kelvin.
  static const double neutralKelvin = 6500.0;

  /// Applies a color temperature transformation to a single [Color].
  /// [kelvin] should be in the range [3000, 9000].
  /// 6500K is considered the neutral identity point.
  static Color applyColorTemperature(Color input, double kelvin) {
    // Clamp input kelvin just in case, though the domain model should handle it.
    final k = kelvin.clamp(3000.0, 9000.0);

    // If near neutral, return identity to avoid math jitter.
    if ((k - neutralKelvin).abs() < 1.0) return input;

    double rMult, gMult, bMult;

    if (k < neutralKelvin) {
      // Warm shift (3000K to 6500K)
      // Soften the orange: at 3000K, use (1.0, 0.9, 0.75) instead of (1.0, 0.75, 0.5)
      final t = (k - 3000.0) / (neutralKelvin - 3000.0);
      rMult = 1.0;
      gMult = 0.9 + (1.0 - 0.9) * t;
      bMult = 0.75 + (1.0 - 0.75) * t;
    } else {
      // Cool shift (6500K to 9000K)
      // Deepen the blue: at 9000K, use (0.75, 0.85, 1.0) instead of (0.9, 0.95, 1.0)
      final t = (k - neutralKelvin) / (9000.0 - neutralKelvin);
      rMult = 1.0 + (0.75 - 1.0) * t;
      gMult = 1.0 + (0.85 - 1.0) * t;
      bMult = 1.0;
    }

    final r = (input.red * rMult).round().clamp(0, 255);
    final g = (input.green * gMult).round().clamp(0, 255);
    final b = (input.blue * bMult).round().clamp(0, 255);

    return Color.fromARGB(input.alpha, r, g, b);
  }

  /// Applies color temperature to an entire [ColorScheme].
  /// If [preserveContrast] is true, checks contrast for "on" roles and falls back if too low.
  static ColorScheme applyTemperatureToScheme(
    ColorScheme scheme,
    double kelvin, {
    required bool preserveContrast,
  }) {
    if ((kelvin - neutralKelvin).abs() < 1.0) return scheme;

    Color transform(Color c) => applyColorTemperature(c, kelvin);

    // Apply to all basic roles
    final Color surface = transform(scheme.surface);

    final Color primary = transform(scheme.primary);
    final Color onPrimary = _transformWithContrast(scheme.onPrimary, primary, scheme.onPrimary, kelvin, preserveContrast);
    
    // Ensure the primary accent itself remains visible against the surface
    final Color primaryHardened = _transformWithContrast(primary, surface, scheme.primary, kelvin, preserveContrast);

    final Color secondary = transform(scheme.secondary);
    final Color onSecondary = _transformWithContrast(scheme.onSecondary, secondary, scheme.onSecondary, kelvin, preserveContrast);
    
    final Color tertiary = transform(scheme.tertiary);
    final Color onTertiary = _transformWithContrast(scheme.onTertiary, tertiary, scheme.onTertiary, kelvin, preserveContrast);
    
    final Color error = transform(scheme.error);
    final Color onError = _transformWithContrast(scheme.onError, error, scheme.onError, kelvin, preserveContrast);
    
    final Color surfaceFinal = surface;
    final Color onSurface = _transformWithContrast(scheme.onSurface, surfaceFinal, scheme.onSurface, kelvin, preserveContrast);
    final Color onSurfaceVariant = _transformWithContrast(scheme.onSurfaceVariant, surfaceFinal, scheme.onSurfaceVariant, kelvin, preserveContrast, threshold: 3.0);

    final Color outline = transform(scheme.outline);
    final Color outlineVariant = transform(scheme.outlineVariant);
    final Color shadow = transform(scheme.shadow);
    final Color scrim = transform(scheme.scrim);
    final Color inverseSurface = transform(scheme.inverseSurface);
    final Color onInverseSurface = _transformWithContrast(scheme.onInverseSurface, inverseSurface, scheme.onInverseSurface, kelvin, preserveContrast);
    final Color inversePrimary = transform(scheme.inversePrimary);

    return scheme.copyWith(
      primary: primaryHardened,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      tertiary: tertiary,
      onTertiary: onTertiary,
      error: error,
      onError: onError,
      surface: surfaceFinal,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: shadow,
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceContainer: transform(scheme.surfaceContainer),
      surfaceContainerLow: transform(scheme.surfaceContainerLow),
      surfaceContainerLowest: transform(scheme.surfaceContainerLowest),
      surfaceContainerHigh: transform(scheme.surfaceContainerHigh),
      surfaceContainerHighest: transform(scheme.surfaceContainerHighest),
      primaryContainer: transform(scheme.primaryContainer),
      onPrimaryContainer: _transformWithContrast(scheme.onPrimaryContainer, transform(scheme.primaryContainer), scheme.onPrimaryContainer, kelvin, preserveContrast),
      secondaryContainer: transform(scheme.secondaryContainer),
      onSecondaryContainer: _transformWithContrast(scheme.onSecondaryContainer, transform(scheme.secondaryContainer), scheme.onSecondaryContainer, kelvin, preserveContrast),
      tertiaryContainer: transform(scheme.tertiaryContainer),
      onTertiaryContainer: _transformWithContrast(scheme.onTertiaryContainer, transform(scheme.tertiaryContainer), scheme.onTertiaryContainer, kelvin, preserveContrast),
    );
  }

  static Color _transformWithContrast(
    Color foreground,
    Color background,
    Color originalForeground,
    double kelvin,
    bool preserveContrast, {
    double threshold = 4.5,
  }) {
    final transformed = applyColorTemperature(foreground, kelvin);
    if (!preserveContrast) return transformed;

    final double contrast = _calculateContrast(transformed, background);
    if (contrast < threshold) {
      // If the transformed color fails contrast, we still want to apply the temperature
      // shift to the original color, as it was presumably accessible in its native state.
      return applyColorTemperature(originalForeground, kelvin);
    }
    return transformed;
  }

  /// Calculates the contrast ratio between two colors.
  /// Formula: (L1 + 0.05) / (L2 + 0.05) where L1 is the lighter luminance.
  static double _calculateContrast(Color c1, Color c2) {
    final double l1 = c1.computeLuminance();
    final double l2 = c2.computeLuminance();
    return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
  }
}
