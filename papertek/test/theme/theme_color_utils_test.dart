import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/theme/theme_color_utils.dart';

void main() {
  group('ThemeColorUtils.applyColorTemperature', () {
    test('6500K is identity', () {
      const color = Color(0xFF123456);
      final result = ThemeColorUtils.applyColorTemperature(color, 6500.0);
      expect(result, color);
    });

    test('3000K is warmer than 6500K', () {
      const color = Colors.grey; // (158, 158, 158)
      final result = ThemeColorUtils.applyColorTemperature(color, 3000.0);
      
      // Warm shift should have Red >= Green > Blue
      expect(result.red, color.red); // R is 1.0 multiplier
      expect(result.green, lessThan(color.green));
      expect(result.blue, lessThan(result.green));
    });

    test('9000K is cooler than 6500K', () {
      const color = Colors.grey;
      final result = ThemeColorUtils.applyColorTemperature(color, 9000.0);
      
      // Cool shift should have Blue >= Green > Red
      expect(result.blue, color.blue); // B is 1.0 multiplier
      expect(result.green, lessThan(color.green));
      expect(result.red, lessThan(result.green));
    });

    test('alpha is preserved', () {
      const color = Color(0x7F123456);
      final result = ThemeColorUtils.applyColorTemperature(color, 3000.0);
      expect(result.alpha, 0x7F);
    });

    test('channels are clamped to [0, 255]', () {
      // Test with very bright color and extreme multipliers (though our multipliers are <= 1.0)
      const color = Colors.white;
      final resultLow = ThemeColorUtils.applyColorTemperature(color, 3000.0);
      final resultHigh = ThemeColorUtils.applyColorTemperature(color, 9000.0);
      
      expect(resultLow.red, inInclusiveRange(0, 255));
      expect(resultLow.green, inInclusiveRange(0, 255));
      expect(resultLow.blue, inInclusiveRange(0, 255));
      
      expect(resultHigh.red, inInclusiveRange(0, 255));
      expect(resultHigh.green, inInclusiveRange(0, 255));
      expect(resultHigh.blue, inInclusiveRange(0, 255));
    });
  });

  group('ThemeColorUtils.applyTemperatureToScheme', () {
    test('applies transformation to multiple roles', () {
      const scheme = ColorScheme.dark(
        primary: Color(0xFF00FF00),
        surface: Color(0xFF111111),
      );
      
      final result = ThemeColorUtils.applyTemperatureToScheme(scheme, 3000.0, preserveContrast: false);
      
      expect(result.primary, isNot(scheme.primary));
      expect(result.surface, isNot(scheme.surface));
    });

    test('preserves contrast when requested', () {
      // Create a low contrast situation: grey on grey
      final scheme = ColorScheme.dark(
        surface: const Color(0xFF222222),
        onSurface: const Color(0xFF333333), // Very low contrast already
      );
      
      // Without preservation, it will just transform both
      final resultNoPreserve = ThemeColorUtils.applyTemperatureToScheme(scheme, 9000.0, preserveContrast: false);
      expect(resultNoPreserve.onSurface, isNot(scheme.onSurface));

      // With preservation, if it drops below threshold, it should fallback to original onSurface
      final resultPreserve = ThemeColorUtils.applyTemperatureToScheme(scheme, 9000.0, preserveContrast: true);
      // Since 0xFF333333 on 0xFF222222 is very low contrast, any shift might make it worse or just stay bad.
      // If our logic triggers, it returns originalForeground.
      // In this specific case, it's likely to trigger because the contrast is ~1.2:1
      expect(resultPreserve.onSurface, scheme.onSurface);
    });
  });
}
