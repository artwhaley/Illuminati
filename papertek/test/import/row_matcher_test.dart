import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/services/import/row_matcher.dart';
import 'package:papertek/ui/spreadsheet/column_spec.dart';

void main() {
  group('RowMatcher.greedyAssign', () {
    late RowMatcher matcher;
    setUp(() => matcher = RowMatcher());

    test('returns null for every field when no headers match', () {
      final result = matcher.greedyAssign(['XYZABC_UNKNOWN_123', 'QQQQQ']);
      expect(result.values.every((v) => v == null), isTrue);
    });

    test('each header is assigned to at most one field', () {
      final headers = ['Channel', 'Position', 'Dimmer', 'Address',
                       'Circuit', 'Wattage', 'Color', 'Gobo'];
      final result = matcher.greedyAssign(headers);
      final assigned = result.values.whereType<String>().toList();
      // No header appears twice
      expect(assigned.toSet().length, equals(assigned.length));
    });

    test('each field is assigned at most one header', () {
      // Three headers all plausibly match "position"
      final result = matcher.greedyAssign(['pos', 'position', 'electric']);
      final posSpec = kColumns.firstWhere((c) => c.id == 'position');
      // position field has exactly one (or zero) assignment
      expect(result[posSpec], anyOf(isNull, isA<String>()));
      // The single assigned value appears only once in the map
      final v = result[posSpec];
      if (v != null) {
        final count = result.values.where((x) => x == v).length;
        expect(count, equals(1));
      }
    });

    test('exact match beats partial match for the same field', () {
      // 'position' is exact; 'pos' is partial — position column should win 'position'
      final result = matcher.greedyAssign(['pos', 'position']);
      final posSpec = kColumns.firstWhere((c) => c.id == 'position');
      expect(result[posSpec], equals('position'));
    });

    test('high-score pair wins over lower-score pair for the same header', () {
      // 'channel' should go to the chan field (exact/near-exact),
      // not to some other field with a weaker match.
      final result = matcher.greedyAssign(['channel']);
      final chanSpec = kColumns.firstWhere((c) => c.id == 'chan');
      expect(result[chanSpec], equals('channel'));
    });

    test('suggest() output is unaffected — still returns List<MatchSuggestion>', () {
      final suggestions = matcher.suggest(['Position', 'Channel', 'Color']);
      final posSpec = kColumns.firstWhere((c) => c.id == 'position');
      expect(suggestions[posSpec], isA<List<MatchSuggestion>>());
      expect(suggestions[posSpec]!.isNotEmpty, isTrue);
    });
  });
}
