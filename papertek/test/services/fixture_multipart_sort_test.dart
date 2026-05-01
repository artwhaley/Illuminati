import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/services/fixture_multipart_sort.dart';
import 'package:papertek/repositories/fixture_repository.dart';
import 'package:papertek/ui/spreadsheet/column_spec.dart';

void main() {
  group('resolveHeaderModeSortValue', () {
    test('parent value beats first part value', () {
      final spec = ColumnSpec(
        id: 'test',
        defaultLabel: 'TEST',
        defaultWidth: 100,
        getValue: (f) => 'parent',
        getPartValue: (f, p) => 'part',
      );
      final fixture = FixtureRow(
        id: 1,
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 1, partOrder: 0, address: '1'),
        ],
      );

      expect(resolveHeaderModeSortValue(fixture, spec), 'parent');
    });

    test('empty parent + non-empty first part yields first-part value', () {
      final spec = ColumnSpec(
        id: 'test',
        defaultLabel: 'TEST',
        defaultWidth: 100,
        getValue: (f) => '',
        getPartValue: (f, p) => 'part',
      );
      final fixture = FixtureRow(
        id: 1,
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 1, partOrder: 0, address: '1'),
        ],
      );

      expect(resolveHeaderModeSortValue(fixture, spec), 'part');
    });

    test('both empty yields empty string', () {
      final spec = ColumnSpec(
        id: 'test',
        defaultLabel: 'TEST',
        defaultWidth: 100,
        getValue: (f) => '',
        getPartValue: (f, p) => '',
      );
      final fixture = FixtureRow(
        id: 1,
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 1, partOrder: 0, address: '1'),
        ],
      );

      expect(resolveHeaderModeSortValue(fixture, spec), '');
    });
  });

  group('compareSortValue', () {
    test('numeric comparison', () {
      expect(compareSortValue('10', '2', true), 1);
      expect(compareSortValue('2', '10', true), -1);
    });

    test('natural comparison', () {
      expect(compareSortValue('A10', 'A2', true), 1);
      expect(compareSortValue('A2', 'A10', true), -1);
    });

    test('descending direction', () {
      expect(compareSortValue('10', '2', false), -1);
    });
  });
}
