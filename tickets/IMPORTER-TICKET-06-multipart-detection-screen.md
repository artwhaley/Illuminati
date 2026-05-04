# Ticket 06: MultipartDetectionScreen

## Goal
Create the `MultipartDetectionScreen` widget and its supporting data types and detection logic. This dialog appears after column mapping is confirmed. It detects rows that share the same position+unit values, presents them to the user for review, and returns the user's decision for each group.

## Depends on
Tickets 01, 04, 05 complete and passing `flutter analyze`.

## Delegate to
**Sonnet** — new widget with detection logic.

---

## Context to load
Read (for dialog style reference — do not copy its business logic):
- `papertek/lib/ui/import/column_mapping_screen.dart`

Read first 110 lines of:
- `papertek/lib/ui/spreadsheet/column_spec.dart` (for ColumnSpec type)

Grep in `import_service.dart` for "group" to understand the existing multipart grouping pattern (context only):
```bash
grep -n "group" lib/services/import/import_service.dart
```

---

## Create: `papertek/lib/ui/import/multipart_detection_screen.dart`

### Imports
```dart
import 'package:flutter/material.dart';
import '../../../services/import/import_service.dart'; // for MultipartDecision if defined there, else define here
import '../../../ui/spreadsheet/column_spec.dart';
```

### Data types (define in this file)

```dart
enum MultipartAction { merge, separate, skip }
enum MultipartConfidence { high, medium }

class MultipartGroup {
  final String position;
  final String unitNumber;
  final List<Map<String, String>> rows;
  final MultipartConfidence confidence;
  const MultipartGroup({
    required this.position,
    required this.unitNumber,
    required this.rows,
    required this.confidence,
  });
}

class MultipartDecision {
  final MultipartGroup group;
  final MultipartAction action;
  const MultipartDecision({required this.group, required this.action});
}
```

### Top-level detection function

```dart
List<MultipartGroup> detectMultipartCandidates(
  List<Map<String, String>> rawRows,
  Map<ColumnSpec, List<String>> mapping,
)
```

Implementation:
1. Find the first header assigned to the 'position' column and the 'unit' column:
   ```dart
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
   ```
   If either is null, return empty list (can't detect without both).

2. Group rows by `(posValue.toLowerCase().trim(), unitValue.toLowerCase().trim())`:
   ```dart
   final groups = <(String, String), List<Map<String, String>>>{};
   for (final row in rawRows) {
     final pos = (row[posHeader] ?? '').toLowerCase().trim();
     final unit = (row[unitHeader] ?? '').toLowerCase().trim();
     if (pos.isEmpty || unit.isEmpty) continue;
     groups.putIfAbsent((pos, unit), () => []).add(row);
   }
   ```

3. Discard groups with only 1 row.

4. For groups with 2+ rows, determine confidence:
   - **High**: check if any cell value in any row of the group matches this pattern:
     `RegExp(r'^[1-9][a-cA-C]?$|^[a-cA-C]$')` — matches "1", "2", "1a", "1b", "A", "B", etc.
     Check all mapped column values (use all headers from mapping values).
   - **Medium**: everything else.

5. Return as `List<MultipartGroup>` using the original (non-lowercased) position and unit values from the first row in each group.

### Widget

```dart
class MultipartDetectionScreen extends StatefulWidget {
  const MultipartDetectionScreen({super.key, required this.candidates});
  final List<MultipartGroup> candidates;
}
```

**`initState` auto-dismiss:**
```dart
@override
void initState() {
  super.initState();
  if (widget.candidates.isEmpty) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop(<MultipartDecision>[]);
    });
  }
}
```

**State:**
```dart
late List<MultipartAction> _actions; // one per candidate, initialized to MultipartAction.merge
```

**Build:**
- If `widget.candidates.isEmpty`: return empty `SizedBox` (auto-dismissed in initState).
- Otherwise render an `AlertDialog` or full dialog scaffold with:
  - Title: `'Multipart Fixtures Detected'`
  - Subtitle: `'${widget.candidates.length} groups of rows share the same position and unit number.'`
  - Bulk action row with two `OutlinedButton`s:
    - "Merge all" → `setState(() => _actions = List.filled(count, MultipartAction.merge))`
    - "Keep all separate" → `setState(() => _actions = List.filled(count, MultipartAction.separate))`
  - Scrollable list (`ListView.builder`) of cards, one per group:
    - Position value
    - Unit number value
    - Row count: `'${group.rows.length} rows'`
    - Confidence badge: a colored Chip — green "High confidence" or amber "Possible"
    - `DropdownButton<MultipartAction>` with items:
      - `MultipartAction.merge` → "Merge as multipart"
      - `MultipartAction.separate` → "Import as separate fixtures"
      - `MultipartAction.skip` → "Skip these rows"
      - on change: `setState(() => _actions[index] = value!)`
  - Bottom actions:
    - "Cancel" → `Navigator.of(context).pop(<MultipartDecision>[])`
    - "Apply" → build `List<MultipartDecision>` and `Navigator.of(context).pop(decisions)`

---

## Acceptance criteria

Run from `papertek/` directory. All must pass before proceeding to Ticket 07.

```bash
# 1. File exists
test -f lib/ui/import/multipart_detection_screen.dart && echo "OK" || echo "MISSING"

# 2. No analysis errors
flutter analyze

# 3. Data types present
grep "class MultipartGroup" lib/ui/import/multipart_detection_screen.dart
# Expected: matches

grep "class MultipartDecision" lib/ui/import/multipart_detection_screen.dart
# Expected: matches

grep "enum MultipartAction" lib/ui/import/multipart_detection_screen.dart
# Expected: matches

# 4. Detection function present
grep "detectMultipartCandidates" lib/ui/import/multipart_detection_screen.dart
# Expected: matches

# 5. Auto-dismiss logic present
grep "addPostFrameCallback" lib/ui/import/multipart_detection_screen.dart
# Expected: matches
```

---

## Subagent prompt

```
You are creating a new Flutter widget file.

Working directory: c:\Users\artwh\Downloads\Illuminati\papertek

Read these files first:
  lib/ui/import/column_mapping_screen.dart   (for dialog style reference only)
  lib/ui/spreadsheet/column_spec.dart        (lines 1–110 only)

Create: lib/ui/import/multipart_detection_screen.dart

This file contains the multipart detection logic and review dialog for the import pipeline.

DEFINE THESE DATA TYPES in the file:

  enum MultipartAction { merge, separate, skip }
  enum MultipartConfidence { high, medium }

  class MultipartGroup {
    final String position;
    final String unitNumber;
    final List<Map<String, String>> rows;
    final MultipartConfidence confidence;
    const MultipartGroup({required this.position, required this.unitNumber,
        required this.rows, required this.confidence});
  }

  class MultipartDecision {
    final MultipartGroup group;
    final MultipartAction action;
    const MultipartDecision({required this.group, required this.action});
  }

DEFINE THIS TOP-LEVEL FUNCTION:

  List<MultipartGroup> detectMultipartCandidates(
    List<Map<String, String>> rawRows,
    Map<ColumnSpec, List<String>> mapping,
  )

  Logic:
  1. Find the first header string assigned to id='position' and id='unit' in mapping.
     If either is null (no mapping for that column), return [].
  2. Group rawRows by (position_value.toLowerCase().trim(), unit_value.toLowerCase().trim()).
     Skip rows where either value is empty.
  3. Keep only groups with 2+ rows.
  4. For each group: determine confidence.
     High = any cell value in any row of the group matches RegExp(r'^[1-9][a-cA-C]?$|^[a-cA-C]$')
     (check all values from all headers present in mapping.values.expand)
     Medium = everything else.
  5. Return List<MultipartGroup> using original (non-lowercased) values from first row in group.

DEFINE THE WIDGET:

  class MultipartDetectionScreen extends StatefulWidget {
    final List<MultipartGroup> candidates;
    // returns List<MultipartDecision> via Navigator.pop
  }

  State:
    late List<MultipartAction> _actions; // one per candidate, all initialized to MultipartAction.merge in initState

  initState:
    If candidates is empty, schedule Navigator.of(context).pop(<MultipartDecision>[]) via addPostFrameCallback.
    Otherwise initialize _actions.

  Build:
    If candidates is empty: return SizedBox.shrink().
    Otherwise return a dialog (use Dialog or AlertDialog) with:
      Title: 'Multipart Fixtures Detected'
      Subtitle showing candidate count
      Two bulk action buttons: 'Merge all' and 'Keep all separate'
      ListView of cards, one per group, showing:
        - position, unit number, row count
        - confidence badge (Chip: green for high, amber for medium)
        - DropdownButton<MultipartAction> (merge/separate/skip)
      Bottom buttons: Cancel (pop with []) and Apply (pop with List<MultipartDecision>)

IMPORTS: package:flutter/material.dart, column_spec.dart (relative path)
Do NOT import import_service.dart or any services — the data types are self-contained here.

CONSTRAINT: Only create lib/ui/import/multipart_detection_screen.dart. No other files.

After creating the file, run `flutter analyze` from papertek/ and report the full output.
```
