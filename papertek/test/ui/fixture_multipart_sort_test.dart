import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/services/fixture_multipart_sort.dart';
import 'package:papertek/repositories/fixture_repository.dart';
import 'package:papertek/ui/spreadsheet/column_spec.dart';

void main() {
  group('Multipart Sort Precedence', () {
    test('resolveHeaderModeSortValue_prefersParentOverFirstPart', () {
      final spec = ColumnSpec(
        id: 'chan',
        defaultLabel: 'CHAN',
        defaultWidth: 100,
        getValue: (f) => '100',
        getPartValue: (f, p) => '1',
      );
      final fixture = FixtureRow(
        id: 1,
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 1, partOrder: 0, channel: '1'),
        ],
      );

      expect(resolveHeaderModeSortValue(fixture, spec), '100');
    });

    test('resolveHeaderModeSortValue_fallsBackToFirstPart', () {
      final spec = ColumnSpec(
        id: 'chan',
        defaultLabel: 'CHAN',
        defaultWidth: 100,
        getValue: (f) => '',
        getPartValue: (f, p) => '1',
      );
      final fixture = FixtureRow(
        id: 1,
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 1, partOrder: 0, channel: '1'),
        ],
      );

      expect(resolveHeaderModeSortValue(fixture, spec), '1');
    });

    test('resolveHeaderModeSortValue_returnsEmptyForNoValue', () {
      final spec = ColumnSpec(
        id: 'chan',
        defaultLabel: 'CHAN',
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
          FixturePartRow(id: 1, partOrder: 0, channel: ''),
        ],
      );

      expect(resolveHeaderModeSortValue(fixture, spec), '');
    });
  });

  group('Header Mode Grouping and Ordering', () {
    test('headerModeComparator_keepsFixtureHeaderAndPartsTogether', () {
      final spec = ColumnSpec(
        id: 'chan',
        defaultLabel: 'CHAN',
        defaultWidth: 100,
        getValue: (f) => f.channel,
        getPartValue: (f, p) => p.channel,
        isNumeric: true,
      );
      final colById = {'chan': spec};
      final sortSpecs = [SortSpec(column: 'chan', ascending: true)];

      // Fixture A: Chan 10, 2 parts
      final fixtureA = FixtureRow(
        id: 10,
        channel: '10',
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 1, partOrder: 0, channel: '10.1'),
          FixturePartRow(id: 2, partOrder: 1, channel: '10.2'),
        ],
      );

      // Fixture B: Chan 5, 1 part
      final fixtureB = FixtureRow(
        id: 5,
        channel: '5',
        position: 'pos',
        patched: false,
        sortOrder: 2.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 3, partOrder: 0, channel: '5.1'),
        ],
      );

      final descriptors = [
        MultipartFixtureDescriptor(f: fixtureA, partOrder: null),
        MultipartFixtureDescriptor(f: fixtureA, partOrder: 0),
        MultipartFixtureDescriptor(f: fixtureA, partOrder: 1),
        MultipartFixtureDescriptor(f: fixtureB, partOrder: null),
        MultipartFixtureDescriptor(f: fixtureB, partOrder: 0),
      ];

      // Shuffle and sort
      descriptors.shuffle();
      descriptors.sort((a, b) => compareFixtureDescriptors(
        left: a,
        right: b,
        sortSpecs: sortSpecs,
        colById: colById,
      ));

      // Expected order: Fixture B (chan 5) then Fixture A (chan 10)
      // Inside each fixture: Header first, then parts in order
      expect(descriptors[0].f.id, 5);
      expect(descriptors[0].partOrder, null);
      expect(descriptors[1].f.id, 5);
      expect(descriptors[1].partOrder, 0);

      expect(descriptors[2].f.id, 10);
      expect(descriptors[2].partOrder, null);
      expect(descriptors[3].f.id, 10);
      expect(descriptors[3].partOrder, 0);
      expect(descriptors[4].f.id, 10);
      expect(descriptors[4].partOrder, 1);
    });

    test('headerModeComparator_makesNoValueSortAtExpectedEdge', () {
      final spec = ColumnSpec(
        id: 'chan',
        defaultLabel: 'CHAN',
        defaultWidth: 100,
        getValue: (f) => f.channel,
        getPartValue: (f, p) => p.channel,
        isNumeric: true,
      );
      final colById = {'chan': spec};

      final fixtureWithVal = FixtureRow(
        id: 1,
        channel: '10',
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [FixturePartRow(id: 1, partOrder: 0, channel: '10')],
      );

      final fixtureNoVal = FixtureRow(
        id: 2,
        channel: '',
        position: 'pos',
        patched: false,
        sortOrder: 2.0,
        hung: false,
        focused: false,
        parts: [FixturePartRow(id: 2, partOrder: 0, channel: '')],
      );

      // Ascending: Empty string '' comes before '10' in natural compare
      final sortSpecsAsc = [SortSpec(column: 'chan', ascending: true)];
      final descriptorsAsc = [
        MultipartFixtureDescriptor(f: fixtureWithVal, partOrder: null),
        MultipartFixtureDescriptor(f: fixtureNoVal, partOrder: null),
      ];
      descriptorsAsc.sort((a, b) => compareFixtureDescriptors(
        left: a,
        right: b,
        sortSpecs: sortSpecsAsc,
        colById: colById,
      ));
      expect(descriptorsAsc[0].f.id, 2); // No value first

      // Descending
      final sortSpecsDesc = [SortSpec(column: 'chan', ascending: false)];
      final descriptorsDesc = [
        MultipartFixtureDescriptor(f: fixtureWithVal, partOrder: null),
        MultipartFixtureDescriptor(f: fixtureNoVal, partOrder: null),
      ];
      descriptorsDesc.sort((a, b) => compareFixtureDescriptors(
        left: a,
        right: b,
        sortSpecs: sortSpecsDesc,
        colById: colById,
      ));
      expect(descriptorsDesc[0].f.id, 1); // Value first
    });
  });

  group('Headerless Mode Behavior', () {
    test('headerlessModeComparator_sortsIndependentRows', () {
      final spec = ColumnSpec(
        id: 'chan',
        defaultLabel: 'CHAN',
        defaultWidth: 100,
        getValue: (f) => f.channel,
        getPartValue: (f, p) => p.channel,
        isNumeric: true,
        isPartLevel: true,
      );

      // Fixture A: Chan 10, Parts 10.1, 10.2
      final fixtureA = FixtureRow(
        id: 10,
        channel: '10',
        position: 'pos',
        patched: false,
        sortOrder: 1.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 1, partOrder: 0, channel: '10.1'),
          FixturePartRow(id: 2, partOrder: 1, channel: '10.2'),
        ],
      );

      // Fixture B: Single part Chan 5
      final fixtureB = FixtureRow(
        id: 5,
        channel: '5',
        position: 'pos',
        patched: false,
        sortOrder: 2.0,
        hung: false,
        focused: false,
        parts: [
          FixturePartRow(id: 3, partOrder: 0, channel: '5.1'),
        ],
      );

      final descriptors = [
        (f: fixtureA, partOrder: 0),
        (f: fixtureA, partOrder: 1),
        (f: fixtureB, partOrder: null),
      ];

      // Helper to simulate _getValueForSort from FixtureDataSource
      String getValueForSortLocal(FixtureRow f, int? partOrder, ColumnSpec spec) {
        if (partOrder != null && spec.isPartLevel) {
          final part = f.parts.where((p) => p.partOrder == partOrder).firstOrNull;
          if (part != null) return spec.getPartValue?.call(f, part) ?? '';
        }
        return spec.getValue(f) ?? '';
      }

      // Sort using headerless logic
      descriptors.sort((a, b) {
        final va = getValueForSortLocal(a.f, a.partOrder, spec);
        final vb = getValueForSortLocal(b.f, b.partOrder, spec);
        return double.parse(va).compareTo(double.parse(vb));
      });

      // Expect independent row order based on the resolved value
      expect(getValueForSortLocal(descriptors[0].f, descriptors[0].partOrder, spec), '5');
      expect(getValueForSortLocal(descriptors[1].f, descriptors[1].partOrder, spec), '10.1');
      expect(getValueForSortLocal(descriptors[2].f, descriptors[2].partOrder, spec), '10.2');
    });
  });
}
