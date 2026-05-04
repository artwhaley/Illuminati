# Ticket 04: ImportService Refactor

## Goal
Refactor `ImportService.importRows` to accept `List<Map<String, String>>` raw rows and `Map<ColumnSpec, List<String>>` column mapping. Remove all `PaperTekImportField` and `NormalizedRow` references. Implement value-combination rules for collection and non-collection fields.

## Depends on
Ticket 01 (ColumnSpec.isPartLevel, isCollection, isImportable must exist).

## Delegate to
**Sonnet** — most complex ticket, requires careful refactoring of the persistence logic.

---

## Context to load
Read both files in full before delegating:
- `papertek/lib/services/import/import_service.dart` (full, ~356 lines)
- `papertek/lib/ui/spreadsheet/column_spec.dart` (full)
- `papertek/lib/services/import/csv_field_definitions.dart` (so the subagent knows what it's removing)

---

## Changes to `papertek/lib/services/import/import_service.dart`

### New imports to add
```dart
import '../../../ui/spreadsheet/column_spec.dart';
```

### Imports to remove
Any import of `csv_field_definitions.dart`, and any import that brings in `PaperTekImportField` or `NormalizedRow`.

### New `importRows` signature
```dart
Future<ImportResult> importRows(
  List<Map<String, String>> rawRows,
  Map<ColumnSpec, List<String>> columnMapping, {
  String? sourceFileName,
  List<MultipartDecision>? multipartDecisions,
})
```
`MultipartDecision` won't exist until Ticket 06. For now, accept `List<dynamic>? multipartDecisions` and ignore the parameter — the wiring will be completed in Ticket 07.

### New helper: `_resolveValue`
```dart
String? _resolveValue(
  Map<String, String> row,
  ColumnSpec col,
  Map<ColumnSpec, List<String>> mapping,
)
```

Logic:
1. Look up `mapping[col]` → list of import headers (may be null or empty → return null).
2. For each header in the list, get `row[header]` (trimmed). Collect non-null, non-empty values.
3. If `col.isCollection`:
   - For each collected value, split on `RegExp(r'[+,/;]')`, trim each token.
   - Drop tokens that are empty or match the no-color sentinel set (case-insensitive):
     `{'n/c', 'nc', 'open', 'none', '-', 'no color', 'no colour'}`
   - Flatten all tokens from all headers into one list.
   - If list is empty, return null. Otherwise join with `'|'` separator (e.g., `"R32|L132"`).
     The `'|'` separator is the internal multi-value encoding for collection fields — the persistence
     layer already splits on this when creating individual gel/gobo/accessory records.
4. If not `col.isCollection`:
   - Join the collected values with `' + '`.
   - Return null if empty.

### Value routing by isPartLevel

When iterating over the `columnMapping` to populate a fixture and its parts, use `col.isPartLevel` to route:

- **`isPartLevel: false`** → fixture-level fields. These are populated once per group, using the first non-null value across all rows in the group:
  - `position` → `_resolvePosition()`
  - `unit` → `unitNumber`
  - `instrument` → `fixtureType`
  - `purpose` → `purpose`
  - `area` → `area`

- **`isPartLevel: true`** → part-level fields. Populated per row:
  - `chan` → `channel`
  - `dimmer` → `dimmer`
  - `address` → `address`
  - `circuit` → `circuit`
  - `wattage` → `wattage`
  - `color` → gel records (split on `'|'` to create multiple)
  - `gobo` → gobo records (split on `'|'`)
  - `accessories` → accessory records (split on `'|'`)
  - `ip`, `subnet`, `mac`, `ipv6` → network fields

### Multipart grouping

Keep the existing consecutive-row grouping logic (group by position+unit+type where rows share those values and appear consecutively). The `multipartDecisions` parameter is accepted but ignored for now — it will be wired in Ticket 07.

### What to keep unchanged
- `ImportResult` class and its fields
- `_resolvePosition()` method
- `_resolveFixtureType()` method  
- All the actual DB write calls (`repo.updatePartChannel`, `repo.updatePosition`, etc.)
- The position-required validation (skip rows without a position value)
- The import transaction structure

### What to remove
- `NormalizedRow` class (and any file that defined it — check if it's in `csv_import_parser.dart` and note that file is deleted in Ticket 07, so remove the import here)
- `PaperTekImportField` usage
- Any `columnMapping[PaperTekImportField.xxx]` style lookups — replace with `_resolveValue(row, kColumnById['xxx']!, mapping)`

---

## Acceptance criteria

Run from `papertek/` directory. All must pass before proceeding to Ticket 05.

```bash
# 1. No analysis errors
flutter analyze

# 2. No PaperTekImportField references remain
grep "PaperTekImportField" lib/services/import/import_service.dart
# Expected: empty

# 3. No NormalizedRow references remain
grep "NormalizedRow" lib/services/import/import_service.dart
# Expected: empty

# 4. New signature present
grep "Map<ColumnSpec" lib/services/import/import_service.dart
# Expected: matches

# 5. Value resolver method present
grep "_resolveValue" lib/services/import/import_service.dart
# Expected: matches

# 6. isCollection used
grep "isCollection" lib/services/import/import_service.dart
# Expected: matches

# 7. isPartLevel used
grep "isPartLevel" lib/services/import/import_service.dart
# Expected: matches

# 8. ColumnSpec imported
grep "column_spec" lib/services/import/import_service.dart
# Expected: matches
```

---

## Subagent prompt

```
You are refactoring a single Dart file in a Flutter project.

Working directory: c:\Users\artwh\Downloads\Illuminati\papertek

Read these files in full before making any changes:
  lib/services/import/import_service.dart
  lib/ui/spreadsheet/column_spec.dart
  lib/services/import/csv_field_definitions.dart

Your task is to refactor import_service.dart. Only modify import_service.dart.
Do not modify column_spec.dart, csv_field_definitions.dart, or any other file.

CHANGES REQUIRED:

1. Remove the import of csv_field_definitions.dart (and any import of PaperTekImportField or NormalizedRow).
   Add an import of: ../../../ui/spreadsheet/column_spec.dart (relative from lib/services/import/)

2. Change the importRows method signature to:
   Future<ImportResult> importRows(
     List<Map<String, String>> rawRows,
     Map<ColumnSpec, List<String>> columnMapping, {
     String? sourceFileName,
     List<dynamic>? multipartDecisions,  // placeholder — ignored for now
   })

3. Add this private helper method:
   String? _resolveValue(Map<String, String> row, ColumnSpec col, Map<ColumnSpec, List<String>> mapping) {
     final headers = mapping[col];
     if (headers == null || headers.isEmpty) return null;
     final values = headers.map((h) => (row[h] ?? '').trim()).where((v) => v.isNotEmpty).toList();
     if (values.isEmpty) return null;
     if (col.isCollection) {
       final noColorSentinels = {'n/c', 'nc', 'open', 'none', '-', 'no color', 'no colour'};
       final tokens = values
         .expand((v) => v.split(RegExp(r'[+,/;]')))
         .map((t) => t.trim())
         .where((t) => t.isNotEmpty && !noColorSentinels.contains(t.toLowerCase()))
         .toList();
       return tokens.isEmpty ? null : tokens.join('|');
     }
     return values.join(' + ');
   }

4. Rewrite the body of importRows to:
   a. Build row groups for multipart detection (same logic as before — group consecutive rows by position+unit+type)
   b. For each group, use _resolveValue to extract field values:
      - fixture-level fields (isPartLevel: false): position, unit, instrument/type, purpose, area
        Use the first non-null value across all rows in the group.
      - part-level fields (isPartLevel: true): channel, dimmer, address, circuit, wattage, color, gobo, accessories, network fields
        Extract per-row.
   c. For collection fields (color, gobo, accessories): split the '|'-joined result on '|' to get
      individual record values when creating gel/gobo/accessory DB records.
   d. Keep the existing DB write calls and transaction structure.
   e. Keep _resolvePosition() and _resolveFixtureType() helper methods unchanged.
   f. Keep ImportResult unchanged.
   g. The multipartDecisions parameter is accepted but ignored in this ticket.

Use kColumnById['chan'], kColumnById['position'], etc. to look up ColumnSpec instances
when calling _resolveValue. kColumnById is defined in column_spec.dart.

CONSTRAINT: Do not fix bugs, refactor patterns, or change anything outside the import pipeline.
Stay focused on the mapping type change and the _resolveValue addition.

After making changes, run `flutter analyze` from the papertek/ directory and report the full output.
```
