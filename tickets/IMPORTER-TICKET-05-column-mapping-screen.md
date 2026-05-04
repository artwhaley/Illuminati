# Ticket 05: ColumnMappingScreen — Multi-Header Mapping UI

## Goal
Rewrite `ColumnMappingScreen` to use `Map<ColumnSpec, List<String>>` mapping, drive the column list from `kColumns.where((c) => c.isImportable)`, use `RowMatcher` suggestions for pre-fill, and support chip-based multi-header assignment per column.

## Depends on
Tickets 01, 02, 03, 04 all complete and passing `flutter analyze`.

## Delegate to
**Sonnet** — UI rebuild with new data types and chip interaction.

---

## Context to load
Read both files in full:
- `papertek/lib/ui/import/column_mapping_screen.dart`
- `papertek/lib/services/import/row_matcher.dart` (new, from Ticket 03)

Also read (first 110 lines only):
- `papertek/lib/ui/spreadsheet/column_spec.dart`

---

## Changes to `papertek/lib/ui/import/column_mapping_screen.dart`

### New constructor
```dart
class ColumnMappingScreen extends ConsumerStatefulWidget {
  const ColumnMappingScreen({
    super.key,
    required this.path,
    required this.rowReader,
    required this.suggestions,
    required this.initialMapping,
    required this.importServiceProvider,
  });

  final String path;
  final RowReader rowReader;
  final Map<ColumnSpec, List<MatchSuggestion>> suggestions;
  final Map<ColumnSpec, List<String>> initialMapping;
  final ProviderBase<ImportService> importServiceProvider;
}
```

### State
```dart
late Map<ColumnSpec, List<String>> _mapping;

@override
void initState() {
  super.initState();
  // Deep copy so we don't mutate the passed-in map
  _mapping = {
    for (final e in widget.initialMapping.entries)
      e.key: List<String>.from(e.value),
  };
}
```

### Column list
```dart
final _importableColumns = kColumns.where((c) => c.isImportable).toList();
```
Build the mapping rows from this list. There will be 18 columns.

### Validation
```dart
bool get _canImport {
  final posSpec = kColumns.firstWhere((c) => c.id == 'position');
  return _mapping[posSpec]?.isNotEmpty == true;
}
```

### Per-column row widget

Each column is rendered as a card or row with:
1. **Label** — `column.label` (left side, fixed width)
2. **Chips** — one `Chip` per assigned header in `_mapping[column]`, each with a `deleteIcon` (×).
   Tapping delete: `_mapping[column]!.remove(header); setState(...)`.
3. **Add dropdown** — a `DropdownButton<String>` or `PopupMenuButton` with:
   - Items from `widget.suggestions[column]` sorted by score, **excluding headers already assigned to this column**
   - A visual divider after suggestions (if any suggestions exist)
   - All import headers (the full `importHeaders` list passed from parent), alphabetically sorted, **excluding headers already in the chips for this column** 
   - A "— not imported —" option (value: empty string — selecting it does nothing, just closes dropdown)
   - On select (non-empty value): `_mapping[column]!.add(selectedHeader); setState(...)`

The full `importHeaders` list (all headers from the file) needs to be available in state.
Add it as a constructor param:
```dart
required this.importHeaders,  // List<String>
```
(The orchestrator will need to pass this from `rowReader.readHeaders(path)` — see Ticket 07.)

### Import button action
```dart
Future<void> _runImport() async {
  setState(() => _isLoading = true);
  try {
    final rawRows = await widget.rowReader.readRows(widget.path);
    final service = ref.read(widget.importServiceProvider);
    final result = await service.importRows(rawRows, _mapping);
    if (mounted) {
      Navigator.of(context).pop(); // close mapping screen
      showDialog(
        context: context,
        builder: (_) => ImportSummaryDialog(result: result),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

### Imports to remove
Remove any import of: `LightwrightColumnDetector`, `CsvImportParser`, `PaperTekImportField`.

### Imports to add
```dart
import '../../../services/import/row_reader.dart';
import '../../../services/import/row_matcher.dart';
import '../../spreadsheet/column_spec.dart';
```
(Adjust relative paths as needed for the file's actual location.)

---

## Acceptance criteria

Run from `papertek/` directory. All must pass before proceeding to Ticket 06.

```bash
# 1. No analysis errors
flutter analyze

# 2. Old references removed
grep "LightwrightColumnDetector" lib/ui/import/column_mapping_screen.dart
# Expected: empty

grep "PaperTekImportField" lib/ui/import/column_mapping_screen.dart
# Expected: empty

grep "CsvImportParser" lib/ui/import/column_mapping_screen.dart
# Expected: empty

# 3. New types in use
grep "MatchSuggestion" lib/ui/import/column_mapping_screen.dart
# Expected: matches

grep "isImportable" lib/ui/import/column_mapping_screen.dart
# Expected: matches

grep "Map<ColumnSpec" lib/ui/import/column_mapping_screen.dart
# Expected: matches

# 4. RowReader in constructor
grep "RowReader" lib/ui/import/column_mapping_screen.dart
# Expected: matches
```

---

## Subagent prompt

```
You are rewriting a single Flutter widget file.

Working directory: c:\Users\artwh\Downloads\Illuminati\papertek

Read these files in full before making any changes:
  lib/ui/import/column_mapping_screen.dart
  lib/services/import/row_matcher.dart
  lib/ui/spreadsheet/column_spec.dart (first 110 lines only)

Your task: rewrite column_mapping_screen.dart. Only modify that one file.

CONSTRUCTOR — replace the existing constructor with:
  ColumnMappingScreen({
    super.key,
    required String path,
    required RowReader rowReader,
    required List<String> importHeaders,
    required Map<ColumnSpec, List<MatchSuggestion>> suggestions,
    required Map<ColumnSpec, List<String>> initialMapping,
    required ProviderBase<ImportService> importServiceProvider,
  })

STATE — replace existing state with:
  late Map<ColumnSpec, List<String>> _mapping;  // deep-copied from initialMapping in initState
  bool _isLoading = false;

COLUMN LIST — drive from:
  final _importableColumns = kColumns.where((c) => c.isImportable).toList();

VALIDATION:
  bool get _canImport {
    final posSpec = kColumns.firstWhere((c) => c.id == 'position');
    return _mapping[posSpec]?.isNotEmpty == true;
  }

PER-COLUMN ROW UI — for each column in _importableColumns, render:
  1. Column label text (column.label)
  2. A Wrap of Chip widgets, one per string in _mapping[column] (default to []).
     Each Chip has a deleteIcon; tapping it removes that header from _mapping[column] and calls setState.
  3. A dropdown (DropdownButton or PopupMenuButton) to add another header:
     - List suggestions[column] sorted by score descending, filtering out headers already in _mapping[column]
     - Visual divider (DropdownMenuItem with Divider widget) if any suggestions were shown
     - All importHeaders alphabetically, filtering out headers already in _mapping[column]
     - A '— not imported —' placeholder item (selecting it does nothing)
     - On valid selection: add header to _mapping[column], setState

IMPORT ACTION:
  async _runImport():
    rawRows = await widget.rowReader.readRows(widget.path)
    service = ref.read(widget.importServiceProvider)
    result = await service.importRows(rawRows, _mapping)
    if mounted: pop this dialog, then show ImportSummaryDialog(result: result)
    on error: show SnackBar with error message
    use _isLoading flag to show loading indicator and disable Import button

IMPORTS TO REMOVE: LightwrightColumnDetector, CsvImportParser, PaperTekImportField
IMPORTS TO ADD: row_reader.dart, row_matcher.dart, column_spec.dart (adjust relative paths)

CONSTRAINT: Do not fix unrelated bugs or refactor the file beyond these changes.
Do not modify any file other than column_mapping_screen.dart.

After changes, run `flutter analyze` from papertek/ and report the full output.
```
