# T02 — 1:1 type refactor + ColumnMappingScreen UI redesign

## SCOPE — exactly four files

| File | Change |
|---|---|
| `papertek/lib/services/import/import_service.dart` | Change mapping type; simplify `_resolveValue` |
| `papertek/lib/ui/import/column_mapping_screen.dart` | New UI: dropdown + centered layout |
| `papertek/lib/ui/import/multipart_detection_screen.dart` | Signature update only — minimal change |
| `papertek/lib/ui/main_shell.dart` | Wire greedyAssign; update types |

**Prerequisite:** T01 must be complete. `RowMatcher.greedyAssign()` must already
exist in `row_matcher.dart` before applying this ticket.

---

## BACKGROUND

In T01 we added `RowMatcher.greedyAssign()` which returns
`Map<ColumnSpec, String?>` — one optional header per field. This ticket
propagates that type through the entire pipeline and replaces the old
chips-and-popup-button UI with a simple dropdown per field.

The old mapping type `Map<ColumnSpec, List<String>>` must be **fully removed**
from all four files. After this ticket the type `Map<ColumnSpec, String?>` is
used everywhere.

---

## CURRENT FILE CONTENTS

### 1 — `papertek/lib/services/import/import_service.dart`

```dart
library;

import 'dart:convert';
import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../repositories/tracked_write_repository.dart';
import '../../ui/spreadsheet/column_spec.dart';

class ImportResult {
  const ImportResult({
    required this.fixturesCreated,
    required this.positionsCreated,
    required this.fixtureTypesCreated,
    required this.rowsSkipped,
    required this.warnings,
    required this.batchId,
  });

  final int fixturesCreated;
  final int positionsCreated;
  final int fixtureTypesCreated;
  final int rowsSkipped;
  final List<String> warnings;
  final String batchId;
}

class ImportService {
  ImportService({required AppDatabase db, required TrackedWriteRepository tracked})
      : _db = db,
        _tracked = tracked;

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  static const _noColorSentinels = {
    'n/c', 'nc', 'open', 'none', '-', 'no color', 'no colour',
  };

  Future<ImportResult> importRows(
    List<Map<String, String>> rawRows,
    Map<ColumnSpec, List<String>> columnMapping, {          // <-- CHANGE THIS TYPE
    String? sourceFileName,
    List<dynamic>? multipartDecisions,
  }) async {
    final positionCache = <String, int>{};
    final fixtureTypeCache = <String, int>{};
    var fixturesCreated = 0;
    var positionsCreated = 0;
    var fixtureTypesCreated = 0;
    var rowsSkipped = 0;
    final warnings = <String>[];
    final createdIds = <int>[];

    final batchId = _tracked.beginImportBatch();

    final positionSpec = kColumnById['position']!;

    final validRows = <Map<String, String>>[];
    for (var i = 0; i < rawRows.length; i++) {
      final position = _resolveValue(rawRows[i], positionSpec, columnMapping);
      if (position == null || position.isEmpty) {
        rowsSkipped++;
        warnings.add('Row ${i + 2}: skipped — no position value');
      } else {
        validRows.add(rawRows[i]);
      }
    }

    final rowGroups = _buildRowGroups(validRows, columnMapping);

    await _db.transaction(() async {
      for (final group in rowGroups) {
        try {
          final fixtureId = await _importRowGroup(
            rowGroup: group,
            columnMapping: columnMapping,
            batchId: batchId,
            positionCache: positionCache,
            fixtureTypeCache: fixtureTypeCache,
            onPositionCreated: () => positionsCreated++,
            onTypeCreated: () => fixtureTypesCreated++,
          );
          createdIds.add(fixtureId);
          fixturesCreated++;
        } catch (e) {
          rowsSkipped++;
          warnings.add('Row skipped — $e');
        }
      }
    });

    await _tracked.endImportBatch(
      batchId: batchId,
      summary: {
        'source': sourceFileName ?? '',
        'fixture_count': fixturesCreated,
        'positions_created': positionsCreated,
        'rows_skipped': rowsSkipped,
        'fixture_ids': createdIds,
      },
    );

    return ImportResult(
      fixturesCreated: fixturesCreated,
      positionsCreated: positionsCreated,
      fixtureTypesCreated: fixtureTypesCreated,
      rowsSkipped: rowsSkipped,
      warnings: warnings,
      batchId: batchId,
    );
  }

  // OLD _resolveValue — handles List<String> per field
  String? _resolveValue(
    Map<String, String> row,
    ColumnSpec col,
    Map<ColumnSpec, List<String>> mapping,                  // <-- CHANGE THIS TYPE
  ) {
    final headers = mapping[col];
    if (headers == null || headers.isEmpty) return null;

    final values = headers
        .map((h) => (row[h] ?? '').trim())
        .where((v) => v.isNotEmpty)
        .toList();

    if (values.isEmpty) return null;

    if (col.isCollection) {
      final tokens = values
          .expand((v) => v.split(RegExp(r'[+,/;]')))
          .map((t) => t.trim())
          .where((t) =>
              t.isNotEmpty && !_noColorSentinels.contains(t.toLowerCase()))
          .toList();
      return tokens.isEmpty ? null : tokens.join('|');
    }

    return values.join(' + ');
  }

  List<List<Map<String, String>>> _buildRowGroups(
    List<Map<String, String>> rows,
    Map<ColumnSpec, List<String>> mapping,                  // <-- CHANGE THIS TYPE
  ) {
    final groups = <List<Map<String, String>>>[];
    final keyToGroup = <String, List<Map<String, String>>>{};

    final positionSpec = kColumnById['position']!;
    final unitSpec = kColumnById['unit']!;
    final instrumentSpec = kColumnById['instrument']!;

    for (final row in rows) {
      final position = _resolveValue(row, positionSpec, mapping) ?? '';
      final unit = _resolveValue(row, unitSpec, mapping) ?? '';
      final type = _resolveValue(row, instrumentSpec, mapping) ?? '';

      if (position.isEmpty) {
        groups.add([row]);
        continue;
      }

      final key =
          '${position.toLowerCase()}|${unit.toLowerCase()}|${type.toLowerCase()}';
      final existing = keyToGroup[key];
      if (existing != null) {
        existing.add(row);
      } else {
        final newGroup = [row];
        keyToGroup[key] = newGroup;
        groups.add(newGroup);
      }
    }
    return groups;
  }

  Future<int> _importRowGroup({
    required List<Map<String, String>> rowGroup,
    required Map<ColumnSpec, List<String>> columnMapping,   // <-- CHANGE THIS TYPE
    required String batchId,
    required Map<String, int> positionCache,
    required Map<String, int> fixtureTypeCache,
    required void Function() onPositionCreated,
    required void Function() onTypeCreated,
  }) async {
    String? firstNonNull(ColumnSpec spec) {
      assert(!spec.isPartLevel, '${spec.id} is part-level; resolve per row');
      for (final row in rowGroup) {
        final v = _resolveValue(row, spec, columnMapping);
        if (v != null && v.isNotEmpty) return v;
      }
      return null;
    }

    final positionSpec = kColumnById['position']!;
    final unitSpec = kColumnById['unit']!;
    final instrumentSpec = kColumnById['instrument']!;
    final purposeSpec = kColumnById['purpose']!;
    final areaSpec = kColumnById['area']!;
    final chanSpec = kColumnById['chan']!;
    final dimmerSpec = kColumnById['dimmer']!;
    final addressSpec = kColumnById['address']!;
    final circuitSpec = kColumnById['circuit']!;
    final wattageSpec = kColumnById['wattage']!;
    final colorSpec = kColumnById['color']!;
    final goboSpec = kColumnById['gobo']!;
    final accessoriesSpec = kColumnById['accessories']!;
    final notesSpec = kColumnById['notes']!;

    final positionName = _resolveValue(rowGroup.first, positionSpec, columnMapping)!;
    await _resolvePosition(positionName, positionCache, onPositionCreated);

    int? fixtureTypeId;
    final typeName = firstNonNull(instrumentSpec);
    if (typeName != null) {
      fixtureTypeId = await _resolveFixtureType(
        typeName,
        wattage: firstNonNull(wattageSpec),
        cache: fixtureTypeCache,
        onCreated: onTypeCreated,
      );
    }

    final res = await _tracked.insertRow(
      table: 'fixtures',
      doInsert: () async {
        final fixtureId = await _db.into(_db.fixtures).insert(FixturesCompanion(
          fixtureTypeId: Value(fixtureTypeId),
          fixtureType: Value(typeName),
          position: Value(positionName),
          unitNumber: Value(firstNonNull(unitSpec)),
          purpose: Value(firstNonNull(purposeSpec)),
          area: Value(firstNonNull(areaSpec)),
        ));

        int? firstPartId;
        for (var i = 0; i < rowGroup.length; i++) {
          final partRow = rowGroup[i];
          final notes = _resolveValue(partRow, notesSpec, columnMapping);
          final partId = await _db.into(_db.fixtureParts).insert(
            FixturePartsCompanion(
              fixtureId: Value(fixtureId),
              partOrder: Value(i),
              partType: const Value('intensity'),
              channel: Value(_resolveValue(partRow, chanSpec, columnMapping)),
              dimmer: Value(_resolveValue(partRow, dimmerSpec, columnMapping)),
              address: Value(_resolveValue(partRow, addressSpec, columnMapping)),
              circuit: Value(_resolveValue(partRow, circuitSpec, columnMapping)),
              wattage: Value(_resolveValue(partRow, wattageSpec, columnMapping)),
              extrasJson: Value(notes != null ? jsonEncode({'notes': notes}) : null),
            ),
          );
          if (i == 0) firstPartId = partId;
        }
        firstPartId ??= 0;

        final colorValue = _resolveValue(rowGroup.first, colorSpec, columnMapping);
        if (colorValue != null) {
          final tokens = colorValue.split('|');
          for (var i = 0; i < tokens.length; i++) {
            await _db.into(_db.gels).insert(GelsCompanion(
              fixtureId: Value(fixtureId),
              fixturePartId: Value(firstPartId),
              color: Value(tokens[i]),
              sortOrder: Value(i.toDouble()),
            ));
          }
        }

        final goboValue = _resolveValue(rowGroup.first, goboSpec, columnMapping);
        if (goboValue != null) {
          final tokens = goboValue.split('|');
          for (var i = 0; i < tokens.length; i++) {
            await _db.into(_db.gobos).insert(GobosCompanion(
              fixtureId: Value(fixtureId),
              fixturePartId: Value(firstPartId),
              goboNumber: Value(tokens[i]),
              sortOrder: Value(i.toDouble()),
            ));
          }
        }

        final accValue = _resolveValue(rowGroup.first, accessoriesSpec, columnMapping);
        if (accValue != null) {
          final tokens = accValue.split('|');
          for (var i = 0; i < tokens.length; i++) {
            await _db.into(_db.accessories).insert(AccessoriesCompanion(
              fixtureId: Value(fixtureId),
              fixturePartId: Value(firstPartId),
              name: Value(tokens[i]),
              sortOrder: Value(i.toDouble()),
            ));
          }
        }

        return fixtureId;
      },
      buildSnapshot: (id) async {
        final fixture =
            await (_db.select(_db.fixtures)..where((t) => t.id.equals(id)))
                .getSingle();
        final parts =
            await (_db.select(_db.fixtureParts)..where((t) => t.fixtureId.equals(id)))
                .get();
        final gels =
            await (_db.select(_db.gels)..where((t) => t.fixtureId.equals(id))).get();
        final gobos =
            await (_db.select(_db.gobos)..where((t) => t.fixtureId.equals(id))).get();
        final accs =
            await (_db.select(_db.accessories)..where((t) => t.fixtureId.equals(id)))
                .get();

        return {
          'fixture': fixture.toJson(),
          'parts': parts.map((p) => p.toJson()).toList(),
          'gels': gels.map((g) => g.toJson()).toList(),
          'gobos': gobos.map((g) => g.toJson()).toList(),
          'accessories': accs.map((a) => a.toJson()).toList(),
        };
      },
      batchId: batchId,
    );

    return res.rowId;
  }

  Future<void> _resolvePosition(String name, Map<String, int> cache,
      void Function() onCreated) async {
    if (cache.containsKey(name)) return;
    final existing = await (_db.select(_db.lightingPositions)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) {
      cache[name] = existing.id;
    } else {
      final id = await _db.into(_db.lightingPositions).insert(
        LightingPositionsCompanion(name: Value(name)),
      );
      cache[name] = id;
      onCreated();
    }
  }

  Future<int> _resolveFixtureType(String name,
      {required String? wattage,
      required Map<String, int> cache,
      required void Function() onCreated}) async {
    if (cache.containsKey(name)) return cache[name]!;
    final existing = await (_db.select(_db.fixtureTypes)
          ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    if (existing != null) {
      cache[name] = existing.id;
      return existing.id;
    }
    final id = await _db.into(_db.fixtureTypes).insert(
      FixtureTypesCompanion(name: Value(name), wattage: Value(wattage)),
    );
    cache[name] = id;
    onCreated();
    return id;
  }
}
```

---

### 2 — `papertek/lib/ui/import/column_mapping_screen.dart`

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
  final Map<ColumnSpec, List<String>> initialMapping;         // <-- CHANGE TYPE
  final ProviderBase<ImportService?> importServiceProvider;

  @override
  ConsumerState<ColumnMappingScreen> createState() =>
      _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends ConsumerState<ColumnMappingScreen> {
  late Map<ColumnSpec, List<String>> _mapping;                // <-- CHANGE TYPE
  bool _isLoading = false;
  late final List<ColumnSpec> _importableColumns;

  @override
  void initState() {
    super.initState();
    _importableColumns = kColumns.where((c) => c.isImportable).toList();
    _mapping = {
      for (final e in widget.initialMapping.entries)
        e.key: List<String>.from(e.value),
    };
    for (final col in _importableColumns) {
      _mapping.putIfAbsent(col, () => []);
    }
  }

  bool get _canImport {
    final posSpec = kColumns.firstWhere((c) => c.id == 'position');
    return (_mapping[posSpec]?.isNotEmpty == true) && !_isLoading;
  }

  Future<void> _runImport() async {
    Navigator.of(context).pop(Map<ColumnSpec, List<String>>.from(_mapping));
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
          crossAxisAlignment: CrossAxisAlignment.start,          // <-- CHANGE TO center
          children: [
            Text(
              'Match each PaperTek field to one or more columns from your file. '
              'Auto-detected matches are pre-filled.',
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
                    assignedHeaders: List.from(_mapping[col] ?? []),
                    allHeaders: widget.importHeaders,
                    suggestions: widget.suggestions[col] ?? [],
                    onAddHeader: (h) => setState(
                        () => (_mapping[col] ??= []).add(h)),
                    onRemoveHeader: (h) =>
                        setState(() => _mapping[col]?.remove(h)),
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
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import'),
        ),
      ],
    );
  }
}

// OLD row widget — chips + PopupMenuButton "Add column" button
class _ColumnMappingRow extends StatelessWidget {
  const _ColumnMappingRow({
    required this.column,
    required this.assignedHeaders,
    required this.allHeaders,
    required this.suggestions,
    required this.onAddHeader,
    required this.onRemoveHeader,
  });

  final ColumnSpec column;
  final List<String> assignedHeaders;
  final List<String> allHeaders;
  final List<MatchSuggestion> suggestions;
  final ValueChanged<String> onAddHeader;
  final ValueChanged<String> onRemoveHeader;

  @override
  Widget build(BuildContext context) {
    // ... (old chips + PopupMenuButton implementation)
    // THIS ENTIRE CLASS IS BEING REPLACED
  }
}
```

---

### 3 — Relevant section of `papertek/lib/ui/main_shell.dart`

Only the `_importFixtures` method needs to change. Everything else in
`main_shell.dart` must be left untouched.

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

  // Step 3: Build suggestions and initial mapping   <-- CHANGE THIS BLOCK
  final suggestions = RowMatcher().suggest(importHeaders);
  final initialMapping = <ColumnSpec, List<String>>{
    for (final entry in suggestions.entries)
      entry.key: entry.value.isNotEmpty ? [entry.value.first.importHeader] : [],
  };

  // Step 4: Show column mapping screen → get confirmed mapping
  if (!mounted) return;
  final confirmedMapping = await showDialog<Map<ColumnSpec, List<String>>>(  // <-- CHANGE TYPE
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

---

### 4 — `papertek/lib/ui/import/multipart_detection_screen.dart` (top 88 lines only)

The rest of this file (the `MultipartDetectionScreen` widget class) must not
be touched. Only the `detectMultipartCandidates` function changes.

```dart
List<MultipartGroup> detectMultipartCandidates(
  List<Map<String, String>> rawRows,
  Map<ColumnSpec, List<String>> mapping,        // <-- CHANGE TYPE
) {
  final posHeaders = mapping.entries
      .where((e) => e.key.id == 'position')
      .expand((e) => e.value)
      .toList();
  final unitHeaders = mapping.entries
      .where((e) => e.key.id == 'unit')
      .expand((e) => e.value)
      .toList();

  final posHeader = posHeaders.isNotEmpty ? posHeaders.first : null;
  final unitHeader = unitHeaders.isNotEmpty ? unitHeaders.first : null;

  if (posHeader == null || unitHeader == null) return [];

  final groups = <(String, String), List<Map<String, String>>>{};
  for (final row in rawRows) {
    final pos = (row[posHeader] ?? '').toLowerCase().trim();
    final unit = (row[unitHeader] ?? '').toLowerCase().trim();
    if (pos.isEmpty || unit.isEmpty) continue;
    groups.putIfAbsent((pos, unit), () => []).add(row);
  }

  final allHeaders = mapping.values.expand((v) => v).toList();  // <-- CHANGE
  // ... rest of function unchanged
}
```

---

## REQUIRED CHANGES — FILE BY FILE

---

### FILE 1: `import_service.dart`

**Change every occurrence of `Map<ColumnSpec, List<String>>` to
`Map<ColumnSpec, String?>`** in these four method signatures:
- `importRows()`
- `_resolveValue()`
- `_buildRowGroups()`
- `_importRowGroup()`

**Replace `_resolveValue` body** with this simplified version:

```dart
String? _resolveValue(
  Map<String, String> row,
  ColumnSpec col,
  Map<ColumnSpec, String?> mapping,
) {
  final header = mapping[col];
  if (header == null) return null;
  final raw = (row[header] ?? '').trim();
  if (raw.isEmpty) return null;
  if (col.isCollection) {
    final tokens = raw
        .split(RegExp(r'[+,/;]'))
        .map((t) => t.trim())
        .where((t) =>
            t.isNotEmpty && !_noColorSentinels.contains(t.toLowerCase()))
        .toList();
    return tokens.isEmpty ? null : tokens.join('|');
  }
  return raw;
}
```

CRITICAL: The collection-field path (the `if (col.isCollection)` branch) must
be preserved exactly as shown. Color, gobo, and accessories columns can contain
comma/semicolon-separated values in a single cell (e.g. `"R80, L201"`) and the
split-and-rejoin logic is required to handle that.

No other logic in `import_service.dart` changes.

---

### FILE 2: `column_mapping_screen.dart`

Rewrite this file completely. The new version must satisfy all of the following:

**Types:**
- `initialMapping` parameter type: `Map<ColumnSpec, String?>`
- `_mapping` state type: `Map<ColumnSpec, String?>`
- `_runImport` pops `Map<ColumnSpec, String?>` (not List)
- `_canImport` checks `_mapping[posSpec] != null`

**`initState`:**
```dart
_importableColumns = kColumns.where((c) => c.isImportable).toList();
_mapping = Map<ColumnSpec, String?>.from(widget.initialMapping);
for (final col in _importableColumns) {
  _mapping.putIfAbsent(col, () => null);
}
```

**Layout — centered:**
- The outer `Column` inside `AlertDialog.content` must use
  `crossAxisAlignment: CrossAxisAlignment.center`
- Update the description text to: `'Match each PaperTek field to a column from your file.'`

**Per-row widget — dropdown:**

Replace `_ColumnMappingRow` entirely. Each row should be a `Padding` containing
a `Row` with:
- A right-aligned label (`SizedBox(width: 160)` with `TextAlign.right`)
- `const SizedBox(width: 16)`
- A `SizedBox(width: 260)` containing a `DropdownButton<String?>`

The dropdown items must be built in this order:
1. A `DropdownMenuItem<String?>(value: null, child: Text('— none —'))` always present
2. If the field has suggestions (score >= threshold from `widget.suggestions`):
   - One `DropdownMenuItem` per suggestion, showing an `Icons.auto_awesome` icon
     (size 14, color `theme.colorScheme.primary`) followed by the header name
   - A `DropdownMenuItem` with a `Divider()` as child and `enabled: false`
     (acts as a visual separator)
3. All remaining import headers not already in the suggestions list, sorted
   alphabetically, as plain `DropdownMenuItem<String?>` entries

The dropdown's current `value` is `_mapping[col]` (a `String?`).
`onChanged` calls `setState(() => _mapping[col] = newValue)`.

The dropdown should have `isExpanded: true` so long header names don't overflow.

**`_canImport`:**
```dart
bool get _canImport {
  final posSpec = kColumns.firstWhere((c) => c.id == 'position');
  return _mapping[posSpec] != null && !_isLoading;
}
```

---

### FILE 3: `main_shell.dart` — `_importFixtures` only

Replace Step 3 block:
```dart
// Step 3: Build suggestions and initial mapping
final suggestions = RowMatcher().suggest(importHeaders);
final initialMapping = RowMatcher().greedyAssign(importHeaders);
```

Change `showDialog` type parameter and `confirmedMapping` type:
```dart
final confirmedMapping = await showDialog<Map<ColumnSpec, String?>>(
```

No other changes to this method or any other part of `main_shell.dart`.

---

### FILE 4: `multipart_detection_screen.dart` — `detectMultipartCandidates` only

Change the function signature:
```dart
List<MultipartGroup> detectMultipartCandidates(
  List<Map<String, String>> rawRows,
  Map<ColumnSpec, String?> mapping,
)
```

Update the header lookup to work with `String?` values:
```dart
final posHeader = mapping.entries
    .where((e) => e.key.id == 'position')
    .map((e) => e.value)
    .whereType<String>()
    .firstOrNull;
final unitHeader = mapping.entries
    .where((e) => e.key.id == 'unit')
    .map((e) => e.value)
    .whereType<String>()
    .firstOrNull;
```

Update the `allHeaders` line:
```dart
final allHeaders = mapping.values.whereType<String>().toList();
```

Everything else in `multipart_detection_screen.dart` (the widget class, enums,
data classes) must be left completely unchanged.

---

## THINGS YOU MUST NOT DO

- Do not add `isImportable` or `importAliases` to `ColumnSpec` — they already exist.
- Do not rename any column IDs. All IDs (`instrument`, `purpose`, `area`, `address`,
  etc.) are correct and must stay as-is.
- Do not change `ImportResult`, `MultipartGroup`, `MultipartDecision`, or any
  enum definitions.
- Do not change the `suggest()` method in `RowMatcher`.
- Do not modify anything in `multipart_detection_screen.dart` except the
  `detectMultipartCandidates` function.
- Do not remove the collection-field split logic from `_resolveValue`.
- Do not touch any file not listed in the SCOPE table at the top.

---

## GO / NO-GO CRITERIA

Run: `flutter analyze`

Zero errors. Warnings are acceptable. If analyze reports any error, the ticket
is not complete — fix before handing off.

Additionally, launch the app and confirm:
- The import dialog opens without crashing.
- Each field row shows a dropdown (not chips).
- The dropdown is populated with suggestions at the top (with star icon),
  then a divider, then alphabetical headers.
- The Import button is disabled until Position is assigned.
