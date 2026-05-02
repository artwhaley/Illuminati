# T01 — Add greedy 1:1 assignment to RowMatcher

## SCOPE
Modify **one file** only: `papertek/lib/services/import/row_matcher.dart`
Also create **one new test file**: `papertek/test/import/row_matcher_test.dart`

Do not touch any other file.

---

## BACKGROUND

PaperTek is a Flutter/Dart lighting paperwork app. The import pipeline reads a
CSV/TSV, detects which import-file columns correspond to which PaperTek fields,
and writes fixtures to a database.

`RowMatcher` currently has one method — `suggest()` — that scores every import
header against every importable field and returns a ranked list of suggestions
per field. Each field can have multiple suggestions.

We are moving to a **1:1 mapping** model: each import header may be used by at
most one field, and each field may use at most one header. This ticket adds the
new `greedyAssign()` method that implements that model. The existing `suggest()`
method must be left **completely unchanged** — it is still used by the UI to
populate dropdown ordering.

---

## CURRENT FILE — `papertek/lib/services/import/row_matcher.dart`

```dart
import '../../../ui/spreadsheet/column_spec.dart';

class MatchSuggestion {
  final String importHeader;
  final int score; // 0–100
  final bool isExact;
  const MatchSuggestion({
    required this.importHeader,
    required this.score,
    required this.isExact,
  });
}

class RowMatcher {
  static const int _threshold = 30;

  String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  int _score(String importHeader, List<String> aliases) {
    final h = _normalize(importHeader);
    final normalizedAliases = aliases.map(_normalize).toList();

    // Exact match
    if (normalizedAliases.contains(h)) return 100;

    // Contains match
    var containsScore = 0;
    for (final a in normalizedAliases) {
      if (h.contains(a) || a.contains(h)) {
        final candidate = 60 + (a.length * 0.4).clamp(0.0, 30.0).toInt();
        if (candidate > containsScore) containsScore = candidate;
      }
    }

    // Word overlap
    final aliasWordSet = <String>{};
    for (final a in normalizedAliases) {
      aliasWordSet.addAll(a.split(' '));
    }
    final headerWords = h.split(' ');
    final matchingWordCount =
        headerWords.where((w) => aliasWordSet.contains(w)).length;
    final overlapScore = aliasWordSet.isEmpty
        ? 0
        : ((matchingWordCount / aliasWordSet.length) * 50).toInt();

    return containsScore > overlapScore ? containsScore : overlapScore;
  }

  Map<ColumnSpec, List<MatchSuggestion>> suggest(List<String> importHeaders) {
    final result = <ColumnSpec, List<MatchSuggestion>>{};

    for (final column in kColumns) {
      if (!column.isImportable || column.importAliases == null) continue;

      final suggestions = <MatchSuggestion>[];
      for (final header in importHeaders) {
        final score = _score(header, column.importAliases!);
        if (score >= _threshold) {
          suggestions.add(MatchSuggestion(
            importHeader: header,
            score: score,
            isExact: score == 100,
          ));
        }
      }
      suggestions.sort((a, b) => b.score.compareTo(a.score));
      result[column] = suggestions;
    }

    return result;
  }
}
```

---

## REQUIRED CHANGE

Add a new method `greedyAssign` to the `RowMatcher` class. Do NOT modify
anything else in the file.

### Method signature

```dart
Map<ColumnSpec, String?> greedyAssign(List<String> importHeaders)
```

### Behavior

1. **Score all pairs.** For every importable column (where `column.isImportable`
   is true and `column.importAliases != null`) and every header in
   `importHeaders`, compute `_score(header, column.importAliases!)`.

2. **Keep only above-threshold pairs.** Discard any pair whose score is below
   `_threshold` (30).

3. **Sort descending by score.** Highest-confidence pairs first.

4. **Greedy assignment.** Walk the sorted list. For each pair:
   - If this column has already been assigned, skip.
   - If this header has already been claimed by another column, skip.
   - Otherwise: assign the header to this column; mark both as used.

5. **Return a map** containing an entry for every importable column that has
   aliases. Columns that were not assigned get a `null` value.

### Important constraints
- Every import header appears in the output map **at most once** across all
  fields (a header cannot be assigned to two fields).
- Every field appears in the output map **at most once** (a field cannot be
  assigned two headers — that is the whole point of this ticket).
- The existing `suggest()` method must remain completely unchanged.

---

## TEST FILE — `papertek/test/import/row_matcher_test.dart`

Create this file exactly:

```dart
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
```

---

## GO / NO-GO CRITERIA

Run: `flutter test test/import/row_matcher_test.dart`

All 6 tests must pass. If any test fails, the ticket is not complete.
