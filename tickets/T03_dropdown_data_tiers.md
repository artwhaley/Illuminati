# T03 — Dropdown data-tier sorting and color coding

## SCOPE — exactly two files

| File | Change |
|---|---|
| `papertek/lib/ui/main_shell.dart` | Read rows before dialog; compute `headersWithData`; pass to screen |
| `papertek/lib/ui/import/column_mapping_screen.dart` | New parameter; split remaining headers into two tiers; color coding |

Do not touch any other file.

---

## BACKGROUND

The import column-mapping dialog shows a dropdown per PaperTek field. Currently
those dropdowns have two sections: auto-match suggestions at the top, then all
other headers alphabetically.

We are adding a third tier and color coding so the user can see at a glance
which import columns actually contain data:

**Final dropdown order for each field:**
1. `— none —` (null, always first)
2. Auto-match suggestions — amber/yellow text, existing divider below
3. Headers that have at least one non-empty data cell — normal text, alphabetical
4. Divider
5. Headers where every data row is empty — grey text, alphabetical, still selectable

Suggestions are excluded from tiers 3 and 5 (no duplicates).

---

## CURRENT FILE CONTENTS

### `papertek/lib/ui/main_shell.dart` — `_importFixtures` method only

```dart
Future<void> _importFixtures() async {
  // Step 1: Pick file
  final picked = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv', 'txt', 'tsv'],
    lockParentWindow: true,
  );
  if (picked == null || picked.files.single.path == null) return;
  final path = picked.files.single.path!;

  // Step 2: Read headers
  const reader = DelimitedRowReader();
  final List<String> importHeaders;
  try {
    importHeaders = await reader.readHeaders(path);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not read file: $e')));
    }
    return;
  }

  // Step 3: Build suggestions and initial mapping
  final suggestions = RowMatcher().suggest(importHeaders);
  final initialMapping = RowMatcher().greedyAssign(importHeaders);

  // Step 4: Show column mapping screen → get confirmed mapping
  if (!mounted) return;
  final confirmedMapping = await showDialog<Map<ColumnSpec, String?>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ColumnMappingScreen(
      path: path,
      rowReader: reader,
      importHeaders: importHeaders,
      suggestions: suggestions,
      initialMapping: initialMapping,
      importServiceProvider: importServiceProvider,
    ),
  );
  if (confirmedMapping == null) return;

  // Step 5: Read full rows
  final List<Map<String, String>> rawRows;
  try {
    rawRows = await reader.readRows(path);
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not parse file: $e')));
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
        ) ??
        [];
  }

  // Step 7: Run import
  if (!mounted) return;
  final service = ref.read(importServiceProvider);
  if (service == null) return;
  try {
    final importResult = await service.importRows(
      rawRows,
      confirmedMapping,
      multipartDecisions: decisions,
      sourceFileName: path.split(Platform.pathSeparator).last,
    );
    if (mounted) {
      showDialog<void>(
        context: context,
        builder: (_) => ImportSummaryDialog(result: importResult),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }
}
```

### `papertek/lib/ui/import/column_mapping_screen.dart` — full file

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/import/row_reader.dart';
import '../../services/import/row_matcher.dart';
import '../../services/import/import_service.dart';
import '../spreadsheet/column_spec.dart';

class ColumnMappingScreen extends ConsumerStatefulWidget {
  const ColumnMappingScreen({
    super.key,
    required this.path,
    required this.rowReader,
    required this.importHeaders,
    required this.suggestions,
    required this.initialMapping,
    required this.importServiceProvider,
  });

  final String path;
  final RowReader rowReader;
  final List<String> importHeaders;
  final Map<ColumnSpec, List<MatchSuggestion>> suggestions;
  final Map<ColumnSpec, String?> initialMapping;
  final ProviderBase<ImportService?> importServiceProvider;

  @override
  ConsumerState<ColumnMappingScreen> createState() =>
      _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends ConsumerState<ColumnMappingScreen> {
  late Map<ColumnSpec, String?> _mapping;
  bool _isLoading = false;
  late final List<ColumnSpec> _importableColumns;

  @override
  void initState() {
    super.initState();
    _importableColumns = kColumns.where((c) => c.isImportable).toList();
    _mapping = Map<ColumnSpec, String?>.from(widget.initialMapping);
    for (final col in _importableColumns) {
      _mapping.putIfAbsent(col, () => null);
    }
  }

  bool get _canImport {
    final posSpec = kColumns.firstWhere((c) => c.id == 'position');
    return _mapping[posSpec] != null && !_isLoading;
  }

  Future<void> _runImport() async {
    Navigator.of(context).pop(Map<ColumnSpec, String?>.from(_mapping));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Map Import Columns'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 640,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Match each PaperTek field to a column from your file.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _importableColumns.length,
                itemBuilder: (_, i) {
                  final col = _importableColumns[i];
                  return _ColumnMappingRow(
                    column: col,
                    currentHeader: _mapping[col],
                    allHeaders: widget.importHeaders,
                    suggestions: widget.suggestions[col] ?? [],
                    onChanged: (newValue) => setState(() {
                      if (newValue != null) {
                        for (final key in _mapping.keys) {
                          if (key != col && _mapping[key] == newValue) {
                            _mapping[key] = null;
                          }
                        }
                      }
                      _mapping[col] = newValue;
                    }),
                  );
                },
              ),
            ),
            const Divider(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canImport ? _runImport : null,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import'),
        ),
      ],
    );
  }
}

class _ColumnMappingRow extends StatelessWidget {
  const _ColumnMappingRow({
    required this.column,
    required this.currentHeader,
    required this.allHeaders,
    required this.suggestions,
    required this.onChanged,
  });

  final ColumnSpec column;
  final String? currentHeader;
  final List<String> allHeaders;
  final List<MatchSuggestion> suggestions;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final suggestionHeaders = suggestions.map((s) => s.importHeader).toSet();
    final remainingHeaders = allHeaders
        .where((h) => !suggestionHeaders.contains(h))
        .toList()
      ..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              column.label,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 260,
            child: DropdownButton<String?>(
              value: currentHeader,
              isExpanded: true,
              onChanged: (v) => onChanged(v == '\x00' ? null : v),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— none —'),
                ),
                if (suggestions.isNotEmpty) ...[
                  ...suggestions.map((s) => DropdownMenuItem<String?>(
                        value: s.importHeader,
                        child: Text(
                          s.importHeader,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                  const DropdownMenuItem<String?>(
                    value: '\x00',
                    enabled: false,
                    child: Divider(),
                  ),
                ],
                ...remainingHeaders.map((h) => DropdownMenuItem<String?>(
                      value: h,
                      child: Text(h, overflow: TextOverflow.ellipsis),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## REQUIRED CHANGES

### FILE 1: `main_shell.dart` — `_importFixtures` only

**Move Step 5 (read full rows) to before Step 4 (show dialog).** After reading
rows, compute a `Set<String>` of headers that have at least one non-empty cell,
then pass it to `ColumnMappingScreen`. The `rawRows` variable is then reused
as-is in Step 6 and Step 7 — no second file read.

Replace the current Steps 3–5 block with:

```dart
// Step 3: Build suggestions and initial mapping
final suggestions = RowMatcher().suggest(importHeaders);
final initialMapping = RowMatcher().greedyAssign(importHeaders);

// Step 4: Read full rows (needed for data-tier hints in the mapping dialog)
if (!mounted) return;
final List<Map<String, String>> rawRows;
try {
  rawRows = await reader.readRows(path);
} catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Could not read file: $e')));
  }
  return;
}

// Compute which headers have at least one non-empty value across all rows.
final headersWithData = <String>{
  for (final row in rawRows)
    for (final entry in row.entries)
      if (entry.value.trim().isNotEmpty) entry.key,
};

// Step 5: Show column mapping screen → get confirmed mapping
if (!mounted) return;
final confirmedMapping = await showDialog<Map<ColumnSpec, String?>>(
  context: context,
  barrierDismissible: false,
  builder: (_) => ColumnMappingScreen(
    path: path,
    rowReader: reader,
    importHeaders: importHeaders,
    suggestions: suggestions,
    initialMapping: initialMapping,
    headersWithData: headersWithData,
    importServiceProvider: importServiceProvider,
  ),
);
if (confirmedMapping == null) return;
```

Then remove the old Step 5 block (the `rawRows` read that used to follow the
dialog) since `rawRows` is now read before the dialog. Steps 6 and 7 continue
using `rawRows` unchanged — they just receive it from the earlier read.

---

### FILE 2: `column_mapping_screen.dart`

**Add `headersWithData` parameter to `ColumnMappingScreen`:**

```dart
final Set<String> headersWithData;
```

Add it as a required named parameter in the constructor, alongside the existing
parameters. Pass it through to `_ColumnMappingRow` in the `ListView.builder`.

**Add `headersWithData` field to `_ColumnMappingRow`:**

```dart
final Set<String> headersWithData;
```

Add it as a required named parameter in `_ColumnMappingRow`'s constructor.

**Replace the `remainingHeaders` computation and dropdown items in
`_ColumnMappingRow.build`** with the three-tier version:

```dart
final suggestionHeaders = suggestions.map((s) => s.importHeader).toSet();

final withData = allHeaders
    .where((h) => !suggestionHeaders.contains(h) && headersWithData.contains(h))
    .toList()
  ..sort();

final withoutData = allHeaders
    .where((h) => !suggestionHeaders.contains(h) && !headersWithData.contains(h))
    .toList()
  ..sort();
```

**Dropdown items — full updated list:**

```dart
items: [
  // Always-present null option
  const DropdownMenuItem<String?>(
    value: null,
    child: Text('— none —'),
  ),

  // Tier 1: auto-match suggestions — amber text
  if (suggestions.isNotEmpty) ...[
    ...suggestions.map((s) => DropdownMenuItem<String?>(
          value: s.importHeader,
          child: Text(
            s.importHeader,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFC8960C)),
          ),
        )),
    const DropdownMenuItem<String?>(
      value: '\x00',
      enabled: false,
      child: Divider(),
    ),
  ],

  // Tier 2: headers with data — normal text
  ...withData.map((h) => DropdownMenuItem<String?>(
        value: h,
        child: Text(h, overflow: TextOverflow.ellipsis),
      )),

  // Tier 3: headers without data — grey text, preceded by divider
  if (withoutData.isNotEmpty) ...[
    const DropdownMenuItem<String?>(
      value: '\x01',
      enabled: false,
      child: Divider(),
    ),
    ...withoutData.map((h) => DropdownMenuItem<String?>(
          value: h,
          child: Text(
            h,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9E9E9E)),
          ),
        )),
  ],
],
```

**Update `onChanged`** to guard both sentinel values:

```dart
onChanged: (v) => onChanged((v == '\x00' || v == '\x01') ? null : v),
```

---

## THINGS YOU MUST NOT DO

- Do not add any new files.
- Do not modify `row_matcher.dart`, `import_service.dart`,
  `multipart_detection_screen.dart`, or any file not listed in SCOPE.
- Do not change any logic in `_importFixtures` other than reordering the read
  and adding the `headersWithData` computation and parameter.
- Do not remove the 1:1 enforcement logic in `_ColumnMappingScreenState.onChanged`
  (the loop that nulls out other fields holding the same header).
- Do not alter the amber color (`0xFFC8960C`) or grey color (`0xFF9E9E9E`)
  — leave color tuning to the developer.

---

## GO / NO-GO CRITERIA

Run: `flutter analyze`

Zero errors. Then launch the app, import a file where some columns are
populated and some are empty. Verify:
- Auto-matched suggestions appear in amber at the top of each dropdown.
- Populated columns appear in normal text below the first divider.
- Empty columns appear in grey below the second divider.
- Selecting a grey (empty) column still works and assigns it.
- The 1:1 rule still holds: picking a header for one field clears it from any
  other field that held it.
