import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/features/reports/report_field_registry.dart';
import 'package:papertek/repositories/fixture_repository.dart';

void main() {
  group('ReportFieldRegistry', () {
    const part = FixturePartRow(
      id: 1,
      partOrder: 0,
      channel: '101',
      dimmer: '1/1',
      circuit: 'A1',
      ipAddress: '192.168.1.10',
      color: 'R10',
      gobo: 'G1',
      accessories: 'Top Hat',
    );

    const fixture = FixtureRow(
      id: 1,
      position: 'Front',
      unitNumber: '1',
      fixtureType: 'Spot',
      patched: true,
      sortOrder: 1.0,
      hung: true,
      focused: true,
      parts: [part],
    );

    test('getPartFieldValue resolves part fields', () {
      expect(getPartFieldValue(fixture, part, 'chan'), '101');
      expect(getPartFieldValue(fixture, part, 'dimmer'), '1/1');
      expect(getPartFieldValue(fixture, part, 'circuit'), 'A1');
      expect(getPartFieldValue(fixture, part, 'ip'), '192.168.1.10');
      expect(getPartFieldValue(fixture, part, 'color'), 'R10');
      expect(getPartFieldValue(fixture, part, 'gobo'), 'G1');
      expect(getPartFieldValue(fixture, part, 'accessories'), 'Top Hat');
    });

    test('getPartFieldValue falls back to parent fields', () {
      expect(getPartFieldValue(fixture, part, 'position'), 'Front');
      expect(getPartFieldValue(fixture, part, 'instrument'), 'Spot - Part 1');
    });

    test('getPartFieldValue returns empty for unknown fields', () {
      expect(getPartFieldValue(fixture, part, 'nonexistent'), '');
    });
  });
}
