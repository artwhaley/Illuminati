# Ticket 07: Wiring and Cleanup

## Goal
Update `main_shell.dart` to use the new import pipeline, update the menu label, then delete the three dead service files. This is the final integration step — `flutter analyze` must be clean at the end.

## Depends on
All prior tickets complete and passing `flutter analyze`.

## Delegate to
**Sonnet** for the main_shell.dart wiring. Then run the file deletions directly (do not subagent the deletions — they are two Bash commands).

---

## Context to load

Grep for the import method and its surrounding menu in main_shell.dart:
```bash
grep -n "_importCsv\|importCsv\|Import Fixtures\|import_csv\|ColumnMappingScreen\|CsvImportParser\|LightwrightColumn" lib/ui/main_shell.dart
```

Read just the import section of main_shell.dart:
- Lines 1–40 (imports at top of file)
- The full `_importCsv` method (use grep output above to find line numbers, then Read those lines)

Also read (first 20 lines each — just to confirm the class/constructor signatures):
- `lib/services/import/delimited_row_reader.dart`
- `lib/services/import/row_matcher.dart`
- `lib/ui/import/multipart_detection_screen.dart`
- `lib/ui/import/column_mapping_screen.dart`

---

## Changes to `papertek/lib/ui/main_shell.dart`

### 1. Update imports at top of file

**Remove** (any imports of):
- `csv_import_parser.dart`
- `lightwright_column_detector.dart`
- `csv_field_definitions.dart`

**Add**:
```dart
import '../services/import/delimited_row_reader.dart';
import '../services/import/row_matcher.dart';
import 'import/multipart_detection_screen.dart';
```
(Adjust relative paths to match the file's existing import style.)

### 2. Rename method

`_importCsv` → `_importFixtures`

### 3. Update menu label

Find: `'Import Fixtures from CSV'`
Replace with: `'Import Fixtures'`

Also update the menu item's `onTap` or callback reference from `_importCsv` to `_importFixtures`.

### 4. Rewrite `_importFixtures` body

Replace the full method body with the following pipeline. Preserve the existing file picker pattern (using file_picker package, same as current code) — just extend allowed extensions.

```dart
Future<void> _importFixtures() async {
  // Step 1: Pick file
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv', 'txt', 'tsv'],
  );
  if (result == null || result.files.single.path == null) return;
  final path = result.files.single.path!;

  // Step 2: Read headers
  final reader = DelimitedRowReader();
  final List<String> importHeaders;
  try {
    importHeaders = await reader.readHeaders(path);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read file: $e')),
      );
    }
    return;
  }

  // Step 3: Build suggestions and initial mapping
  final suggestions = RowMatcher().suggest(importHeaders);
  final initialMapping = <ColumnSpec, List<String>>{
    for (final entry in suggestions.entries)
      entry.key: entry.value.isNotEmpty ? [entry.value.first.importHeader] : [],
  };

  // Step 4: Show column mapping screen
  if (!mounted) return;
  final confirmedMapping = await showDialog<Map<ColumnSpec, List<String>>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ColumnMappingScreen(
      path: path,
      rowReader: reader,
      importHeaders: importHeaders,
      suggestions: suggestions,
      initialMapping: initialMapping,
      importServiceProvider: importServiceProvider, // use existing provider ref
    ),
  );
  if (confirmedMapping == null) return;

  // Step 5: Read full rows
  final List<Map<String, String>> rawRows;
  try {
    rawRows = await reader.readRows(path);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not parse file: $e')),
      );
    }
    return;
  }

  // Step 6: Multipart detection
  final candidates = detectMultipartCandidates(rawRows, confirmedMapping);
  List<MultipartDecision> decisions = [];
  if (candidates.isNotEmpty && mounted) {
    decisions = await showDialog<List<MultipartDecision>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MultipartDetectionScreen(candidates: candidates),
    ) ?? [];
  }

  // Step 7: Run import
  if (!mounted) return;
  final service = ref.read(importServiceProvider);
  try {
    final importResult = await service.importRows(
      rawRows,
      confirmedMapping,
      multipartDecisions: decisions,
      sourceFileName: path.split(Platform.pathSeparator).last,
    );
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => ImportSummaryDialog(result: importResult),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}
```

Note on `importServiceProvider`: match the existing pattern — the current `_importCsv` already has access to a provider. Do not change the provider reference pattern.

Note on `Platform.pathSeparator`: add `import 'dart:io';` if not already present.

---

## File deletions

After the subagent finishes and `flutter analyze` is clean, run these directly from `papertek/`:

```bash
rm lib/services/import/csv_import_parser.dart
rm lib/services/import/lightwright_column_detector.dart
rm lib/services/import/csv_field_definitions.dart
```

Then run `flutter analyze` again — this is the final AC gate.

---

## Acceptance criteria

All must pass. This is the final gate for the entire rework.

```bash
# 1. FINAL: zero errors (run after deletions)
flutter analyze
# Expected: "No issues found!" or only warnings

# 2. Dead type references gone from entire codebase
grep -r "PaperTekImportField" lib/
# Expected: empty

grep -r "LightwrightColumnDetector" lib/
# Expected: empty

grep -r "CsvImportParser" lib/
# Expected: empty

grep -r "NormalizedRow" lib/
# Expected: empty

# 3. Dead files deleted
test -f lib/services/import/csv_import_parser.dart && echo "EXISTS — not deleted" || echo "DELETED OK"
test -f lib/services/import/lightwright_column_detector.dart && echo "EXISTS — not deleted" || echo "DELETED OK"
test -f lib/services/import/csv_field_definitions.dart && echo "EXISTS — not deleted" || echo "DELETED OK"

# 4. Menu label updated
grep "Import Fixtures from CSV" lib/ui/main_shell.dart
# Expected: empty (old label gone)

grep "Import Fixtures'" lib/ui/main_shell.dart
# Expected: matches (new label present)

# 5. New pipeline types in use
grep "DelimitedRowReader\|RowMatcher\|detectMultipartCandidates" lib/ui/main_shell.dart
# Expected: all three match
```

---

## Subagent prompt

```
You are updating a single method in a Flutter app shell file and its related imports.

Working directory: c:\Users\artwh\Downloads\Illuminati\papertek

First, run this to find the _importCsv method location:
  grep -n "_importCsv\|Import Fixtures\|ColumnMappingScreen\|CsvImportParser\|LightwrightColumn" lib/ui/main_shell.dart

Then read:
  lib/ui/main_shell.dart (lines 1-40 for imports, plus the full _importCsv method based on grep output)
  lib/services/import/delimited_row_reader.dart (lines 1-20, for class name confirmation)
  lib/services/import/row_matcher.dart (lines 1-20, for class name confirmation)
  lib/ui/import/multipart_detection_screen.dart (lines 1-40, for class/function names)
  lib/ui/import/column_mapping_screen.dart (lines 1-40, for constructor signature)

Make these changes to lib/ui/main_shell.dart ONLY:

1. Remove imports of: csv_import_parser.dart, lightwright_column_detector.dart, csv_field_definitions.dart
   Add imports of: delimited_row_reader.dart, row_matcher.dart, multipart_detection_screen.dart
   (adjust relative paths to match the existing import style in the file)
   Also ensure dart:io is imported (for Platform.pathSeparator).

2. Rename _importCsv to _importFixtures everywhere it appears in the file.

3. Find the menu item with label 'Import Fixtures from CSV' and change it to 'Import Fixtures'.

4. Replace the body of _importFixtures with this pipeline:
   a. File picker — add 'txt' and 'tsv' to allowed extensions alongside 'csv'
   b. final reader = DelimitedRowReader()
   c. importHeaders = await reader.readHeaders(path)  (wrap in try/catch, show SnackBar on error)
   d. suggestions = RowMatcher().suggest(importHeaders)
   e. initialMapping = Map<ColumnSpec, List<String>> — for each entry in suggestions,
      take the first MatchSuggestion's importHeader as a single-item list (or [] if no suggestions)
   f. confirmedMapping = await showDialog(ColumnMappingScreen(
        path, reader, importHeaders, suggestions, initialMapping, importServiceProvider))
      return if null (user cancelled)
   g. rawRows = await reader.readRows(path) (try/catch, SnackBar on error)
   h. candidates = detectMultipartCandidates(rawRows, confirmedMapping)
   i. decisions = [] ; if candidates.isNotEmpty: show MultipartDetectionScreen dialog
   j. service = ref.read(importServiceProvider)
   k. result = await service.importRows(rawRows, confirmedMapping, multipartDecisions: decisions,
        sourceFileName: last path component)
   l. show ImportSummaryDialog(result: result)
   Wrap step k-l in try/catch, show SnackBar on error.
   Check mounted before each context use.

CONSTRAINT: Only modify lib/ui/main_shell.dart. Do not touch any other file.
Do not fix unrelated bugs or refactor anything else in the file.

After changes, run `flutter analyze` from papertek/ and report the full output.
If there are any errors, list each error and the file/line it came from.
```
