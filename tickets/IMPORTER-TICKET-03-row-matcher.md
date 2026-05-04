# Ticket 03: RowMatcher

## Goal
Create `RowMatcher` — a service that scores import file headers against each importable `ColumnSpec`'s `importAliases` and returns ranked suggestions. This replaces `LightwrightColumnDetector` with a data-driven, alias-based approach.

## Depends on
Ticket 01 (importAliases and isImportable on ColumnSpec must exist).

## Delegate to
**Sonnet** — scoring algorithm logic.

---

## Context to load
- Grep for `importAliases` in `papertek/lib/ui/spreadsheet/column_spec.dart` to confirm Ticket 01 is complete.
- Read the class definition section (first ~110 lines) of `column_spec.dart` to understand `ColumnSpec`, `isImportable`, and `kColumns`.
- Read `papertek/lib/services/import/lightwright_column_detector.dart` to understand what it did (for context only — the new file replaces its function).

---

## Create: `papertek/lib/services/import/row_matcher.dart`

### Imports
```dart
import '../../../ui/spreadsheet/column_spec.dart';
```

### MatchSuggestion class
```dart
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
```

### RowMatcher class

```dart
class RowMatcher {
  static const int _threshold = 30;

  Map<ColumnSpec, List<MatchSuggestion>> suggest(List<String> importHeaders);
}
```

### Private method: `String _normalize(String s)`
```dart
return s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
```

### Private method: `int _score(String importHeader, List<String> aliases)`

Given a normalized import header and a column's alias list:

1. Normalize the import header: `final h = _normalize(importHeader)`
2. Normalize all aliases.
3. **Exact match check**: if `h` equals any normalized alias → return 100.
4. **Contains check**: for each normalized alias `a`:
   - if `h.contains(a)` OR `a.contains(h)` → candidate score = `60 + (a.length * 0.4).clamp(0.0, 30.0).toInt()`
   - Track the maximum candidate score across all aliases.
5. **Word overlap check**: 
   - Collect all unique words from all aliases (split each alias on space, flatten).
   - Split `h` on space into header words.
   - Count how many header words appear in the alias word set.
   - Overlap score = `((matchingWordCount / aliasWordSet.length) * 50).toInt()`
6. Return the maximum of the contains score (step 4) and the overlap score (step 5).
   If neither step produced a score > 0, return 0.

### `suggest(List<String> importHeaders)` implementation

```
result = Map<ColumnSpec, List<MatchSuggestion>>{}

for each column in kColumns where column.isImportable and column.importAliases != null:
  suggestions = []
  for each importHeader in importHeaders:
    score = _score(importHeader, column.importAliases!)
    if score >= _threshold:
      suggestions.add(MatchSuggestion(
        importHeader: importHeader,
        score: score,
        isExact: score == 100,
      ))
  sort suggestions by score descending
  result[column] = suggestions

return result
```

Note: A header can appear as a suggestion for multiple columns. Resolution of conflicts is handled by the UI (Ticket 05), not here.

---

## Acceptance criteria

Run from `papertek/` directory. All must pass before proceeding to Ticket 04.

```bash
# 1. File exists
test -f lib/services/import/row_matcher.dart && echo "OK" || echo "MISSING"

# 2. No analysis errors
flutter analyze

# 3. Both classes present
grep "class MatchSuggestion" lib/services/import/row_matcher.dart
# Expected: matches

grep "class RowMatcher" lib/services/import/row_matcher.dart
# Expected: matches

# 4. Scoring method present
grep "_score" lib/services/import/row_matcher.dart
# Expected: matches

# 5. Threshold constant present
grep "_threshold" lib/services/import/row_matcher.dart
# Expected: matches

# 6. Uses kColumns
grep "kColumns" lib/services/import/row_matcher.dart
# Expected: matches
```

**Manual logic check** (orchestrator reads the file and verifies):
- `_score` returns 100 for exact match (e.g., header "channel", alias "channel").
- `_score` returns >= 60 for contains match (e.g., header "dmx channel", alias "channel").
- `_score` returns < 30 for unrelated strings (e.g., header "voltage", aliases for 'chan').
- `suggest` filters out scores below 30.

---

## Subagent prompt

```
You are creating a new Dart file for a Flutter project.

Working directory: c:\Users\artwh\Downloads\Illuminati\papertek

First, read these files:
  lib/ui/spreadsheet/column_spec.dart  (lines 1–110 only — the class definition)

Verify that ColumnSpec has an `importAliases` field and an `isImportable` getter before proceeding.
If they are missing, STOP and report: "Ticket 01 prerequisite missing — importAliases not found in ColumnSpec."

Then create: lib/services/import/row_matcher.dart

The file must implement:

1. `class MatchSuggestion` with fields:
   - `final String importHeader`
   - `final int score` (0–100)
   - `final bool isExact`
   - const constructor with all required named params

2. `class RowMatcher` with:

   - `static const int _threshold = 30`

   - `String _normalize(String s)`:
     return s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

   - `int _score(String importHeader, List<String> aliases)`:
     a. Normalize importHeader with _normalize
     b. Normalize all aliases
     c. If normalized header exactly equals any alias → return 100
     d. For each alias: if header.contains(alias) OR alias.contains(header):
        candidate = 60 + (alias.length * 0.4).clamp(0.0, 30.0).toInt()
        track maximum
     e. Word overlap: collect all unique words from all aliases (split on space, flatten, deduplicate).
        Split normalized header on space. Count header words that appear in alias word set.
        overlapScore = ((matchCount / aliasWordSet.length) * 50).toInt()
     f. Return max of containsScore (step d) and overlapScore (step e). Return 0 if both are 0.

   - `Map<ColumnSpec, List<MatchSuggestion>> suggest(List<String> importHeaders)`:
     For each column in kColumns where column.isImportable and column.importAliases != null:
       Score every importHeader against that column's aliases.
       Collect MatchSuggestion objects for scores >= _threshold.
       Sort suggestions by score descending.
       Add to result map.
     Return result map.

Import: only `../../../ui/spreadsheet/column_spec.dart` (relative path from lib/services/import/).

After creating the file, run `flutter analyze` from the papertek/ directory and report the full output.
Only create lib/services/import/row_matcher.dart. Do not modify any existing files.
```
