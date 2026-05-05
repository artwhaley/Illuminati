# Positions Tab Improvements

## Overview

Four distinct improvements to the Lighting Positions tab in the show window:

1. **Card summaries** — each position card shows fixture count + location details
2. **Delete-with-fixtures dialog** — replacing the blunt confirm dialog with a merge/orphan/delete flow
3. **Whole-card drag** — platform-aware drag-from-anywhere replacing the tiny handle
4. **"Remove empty positions" toolbar button** — pinned to bottom of left sidebar

---

## Files to touch (exactly these, no others)

| File | Change summary |
|------|----------------|
| `lib/providers/show_provider.dart` | Add `fixtureCountsByPositionProvider` |
| `lib/repositories/position_repository.dart` | Add `nullifyFixturesAtPosition()` and `deleteFixturesAtPosition()` |
| `lib/ui/positions/widgets/position_card.dart` | Fixture count + details display; whole-card drag |
| `lib/ui/positions/widgets/position_group_card.dart` | Fixture count in member tiles; whole-card drag |
| `lib/ui/positions/widgets/position_dialogs.dart` | New `PositionDeleteWithFixturesDialog` |
| `lib/ui/positions/lighting_positions_tab.dart` | Pass counts to cards; restructure toolbar; updated call sites |
| `lib/ui/positions/positions_controller.dart` | Update `deleteSelected()`; add `removeEmptyPositions()` |

Do **not** modify any other files. Do not refactor unrelated code. Do not add comments beyond what is necessary to explain non-obvious logic.

---

## 1. `lib/providers/show_provider.dart`

Add after `positionGroupsProvider`:

```dart
/// Streams a map of position-name → fixture count.
final fixtureCountsByPositionProvider =
    StreamProvider.autoDispose<Map<String, int>>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return Stream.value({});
  return db.select(db.fixtures).watch().map((fixtures) {
    final counts = <String, int>{};
    for (final f in fixtures) {
      if (f.position != null) {
        counts[f.position!] = (counts[f.position!] ?? 0) + 1;
      }
    }
    return counts;
  });
});
```

---

## 2. `lib/repositories/position_repository.dart`

Add two new methods:

```dart
/// Sets position = null on all fixtures currently assigned to [positionName].
/// Used when a position is deleted and the user chooses to orphan its fixtures
/// (they will appear as "Unassigned" in any fixture view that handles null positions).
Future<void> nullifyFixturesAtPosition(String positionName) async {
  final affected = await (_db.select(_db.fixtures)
        ..where((f) => f.position.equals(positionName)))
      .get();
  final batchId = _tracked.beginImportBatch();
  for (final f in affected) {
    await _tracked.updateField(
      table: 'fixtures',
      id: f.id,
      field: 'position',
      newValue: null,
      readCurrentValue: () async => f.position,
      applyUpdate: (v) async {
        await (_db.update(_db.fixtures)..where((r) => r.id.equals(f.id)))
            .write(FixturesCompanion(position: Value(v)));
      },
      batchId: batchId,
    );
  }
}

/// Deletes all fixture records assigned to [positionName].
/// Destructive — use only when the user explicitly confirms fixture deletion.
Future<void> deleteFixturesAtPosition(String positionName) async {
  final affected = await (_db.select(_db.fixtures)
        ..where((f) => f.position.equals(positionName)))
      .get();
  final batchId = _tracked.beginImportBatch();
  for (final f in affected) {
    await _tracked.deleteRow(
      table: 'fixtures',
      id: f.id,
      buildSnapshot: () async => f.toJson(),
      doDelete: () =>
          (_db.delete(_db.fixtures)..where((r) => r.id.equals(f.id))).go(),
      batchId: batchId,
    );
  }
}
```

---

## 3. `lib/ui/positions/widgets/position_card.dart`

### 3a. New parameter

Add `required this.fixtureCount` (int) to `PositionCard`.

The `LightingPosition position` field already carries `trim`, `fromPlasterLine`, and `fromCenterLine` — no extra parameters needed for those.

### 3b. Platform-aware drag helper

Add at file top-level (outside the class):

```dart
Widget _platformDrag({required int index, required Widget child}) {
  final isDesktop = defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;
  return isDesktop
      ? ReorderableDragStartListener(index: index, child: child)
      : ReorderableDelayedDragStartListener(index: index, child: child);
}
```

Add `import 'package:flutter/foundation.dart';` if not already present.

### 3c. Wrap entire card with drag listener

In `build()`, wrap the outermost `Padding` widget with:
```dart
return _platformDrag(
  index: widget.index,
  child: Padding(...),  // existing outermost Padding
);
```

### 3d. Remove the drag handle icon

Delete the `ReorderableDragStartListener` + `Icons.drag_indicator` icon from inside the card's `Row`.

### 3e. New right-side detail column

Replace the space where the drag handle was with a right-aligned detail column:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.end,
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(
      '${widget.fixtureCount} fixture${widget.fixtureCount == 1 ? '' : 's'}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: widget.fixtureCount > 0
            ? theme.colorScheme.primary.withValues(alpha: 0.85)
            : const Color(0xFF4B5263),
      ),
    ),
    if (widget.position.trim != null)
      _detailText('trim ${widget.position.trim}', theme),
    if (widget.position.fromPlasterLine != null)
      _detailText('${widget.position.fromPlasterLine} from plaster', theme),
    if (widget.position.fromCenterLine != null)
      _detailText('${widget.position.fromCenterLine} OC', theme),
  ],
),
```

Add helper (outside state class, inside file):
```dart
Widget _detailText(String text, ThemeData theme) => Text(
  text,
  style: theme.textTheme.labelSmall?.copyWith(
    color: const Color(0xFF4B5263),
    fontSize: 10,
  ),
);
```

---

## 4. `lib/ui/positions/widgets/position_group_card.dart`

### 4a. New parameter

Add `required this.fixtureCounts` (Map<String, int>) to `PositionGroupCard`.

### 4b. Platform-aware drag helper

Add the same `_platformDrag` top-level function as in `position_card.dart`.

### 4c. Group header — whole-row drag

Wrap the group header's `InkWell`'s parent `Padding` with `_platformDrag(index: widget.index, child: ...)`.

Remove the `ReorderableDragStartListener` + `Icons.drag_indicator` from the header `Row`'s trailing position.

The header row already has an expand/collapse icon and folder icon on the left — do not remove those. Only remove the dedicated drag indicator on the right end.

### 4d. Member tiles — whole-tile drag + fixture count

In `_buildMemberTile`, wrap the outer `Padding` (the one with `key: ValueKey(pos.id)`) with `_platformDrag(index: index, child: ...)`.

Remove the `ReorderableDragStartListener` + `Icons.drag_indicator` from the tile `Row`.

Add fixture count to the right of the position name in the member tile row:
```dart
Text(
  '${widget.fixtureCounts[pos.name] ?? 0}',
  style: theme.textTheme.labelSmall?.copyWith(
    color: (widget.fixtureCounts[pos.name] ?? 0) > 0
        ? amber.withValues(alpha: 0.85)
        : const Color(0xFF4B5263),
    fontSize: 10,
  ),
),
```

Member tiles are compact (38px height) — show count only, not the full trim/plaster/center detail lines.

---

## 5. `lib/ui/positions/widgets/position_dialogs.dart`

### 5a. Result types

Add a sealed class hierarchy at the top of the file (or in `position_list_item.dart` — choose whichever already has sealed types):

```dart
sealed class DeleteWithFixturesResult {}

class MergeFixturesInto extends DeleteWithFixturesResult {
  const MergeFixturesInto(this.target);
  final LightingPosition target;
}

class OrphanFixtures extends DeleteWithFixturesResult {
  const OrphanFixtures();
}

class DeleteFixturesToo extends DeleteWithFixturesResult {
  const DeleteFixturesToo();
}
```

### 5b. New dialog class `PositionDeleteWithFixturesDialog`

Constructor parameters:
```dart
final List<({LightingPosition pos, int count})> positionsWithFixtures;
final List<LightingPosition> availableTargets;  // may be empty
```

Returns `DeleteWithFixturesResult?` (null = cancelled).

**State:** `LightingPosition? _selectedTarget` — initialized in `initState()` to the best name-match from `availableTargets`:

```dart
// Best match: the target whose name shares the longest common prefix
// with the first position being deleted. Falls back to first target.
LightingPosition? _bestMatch(List<LightingPosition> targets, String referenceName) {
  if (targets.isEmpty) return null;
  return targets.reduce((best, t) {
    int sharedLength(String a, String b) {
      int i = 0;
      while (i < a.length && i < b.length && a[i] == b[i]) i++;
      return i;
    }
    return sharedLength(t.name, referenceName) >= sharedLength(best.name, referenceName)
        ? t
        : best;
  });
}
```

**Dialog layout:**

```
Title: "Positions Have Fixtures"

Body:
  Text: "The following positions have fixtures assigned:"
  [for each positionsWithFixtures entry]
    Row: "• [pos.name] — [count] fixture(s)"   (small, grey)

  SizedBox(height: 16)
  Divider

  [if availableTargets is not empty]
    Text: "Move all fixtures to:" (labelSmall, grey)
    SizedBox(height: 8)
    DropdownButton<LightingPosition>(
      value: _selectedTarget,
      items: availableTargets.map(...).toList(),
      onChanged: (v) => setState(() => _selectedTarget = v),
    )
    SizedBox(height: 8)
    FilledButton("Move Fixtures",
      onPressed: _selectedTarget == null ? null : () =>
          Navigator.of(context).pop(MergeFixturesInto(_selectedTarget!)))

  SizedBox(height: 12)
  Divider

  Text: "Or leave fixtures unassigned:" (labelSmall, grey)
  SizedBox(height: 8)
  OutlinedButton("Leave as Unassigned",
    onPressed: () => Navigator.of(context).pop(const OrphanFixtures()))
  Text: "(fixtures remain in the show but have no position)",
      style: labelSmall grey

  SizedBox(height: 12)
  Divider

  Text: "Or remove them entirely:" (labelSmall, grey)
  SizedBox(height: 8)
  OutlinedButton styled with error color: "Delete Fixtures Too",
    onPressed: () => Navigator.of(context).pop(const DeleteFixturesToo())
  Text: "(permanently deletes the fixture records)",
      style: labelSmall grey

Actions row:
  TextButton("Cancel", onPressed: () => Navigator.of(context).pop(null))
```

**Width:** `SizedBox(width: 400)` wrapping the content column.

---

## 6. `lib/ui/positions/lighting_positions_tab.dart`

### 6a. Watch new provider in `build()`

Add near the top of build, after existing providers:
```dart
final fixtureCounts = ref.watch(fixtureCountsByPositionProvider).valueOrNull ?? {};
```

### 6b. Pass `fixtureCount` to `PositionCard`

```dart
PositionCard(
  key: ValueKey(item.listKey),
  index: i,
  position: item.pos,
  fixtureCount: fixtureCounts[item.pos.name] ?? 0,   // ADD
  selected: ...,
  ...
)
```

### 6c. Pass `fixtureCounts` to `PositionGroupCard`

```dart
PositionGroupCard(
  key: ValueKey(item.listKey),
  index: i,
  group: grp.group,
  members: grp.members,
  fixtureCounts: fixtureCounts,   // ADD
  selected: ...,
  ...
)
```

### 6d. Update `deleteSelected` call site

```dart
onPressed: (repo != null && selected.isNotEmpty)
    ? () => controller.deleteSelected(context, items, fixtureCounts, positions)
    : null,
```

### 6e. Restructure left toolbar

Change the toolbar `Container`'s child from `SingleChildScrollView(child: Column(...))` to:

```dart
Column(
  children: [
    Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: _toolbarPad),
            // existing buttons: add, delete, divider, merge, group, ungroup
            // UNCHANGED — do not reorder or alter existing buttons
          ],
        ),
      ),
    ),
    const Divider(height: 1, indent: 6, endIndent: 6),
    const SizedBox(height: 4),
    PositionToolButton(
      icon: Icons.playlist_remove,
      tooltip: 'Remove Empty Positions',
      onPressed: repo != null
          ? () => controller.removeEmptyPositions(context, positions, fixtureCounts)
          : null,
    ),
    const SizedBox(height: 8),
  ],
)
```

The `_toolbarPad` scroll animation inside the `SingleChildScrollView > Column` is preserved unchanged.

---

## 7. `lib/ui/positions/positions_controller.dart`

### 7a. Update `deleteSelected` signature and logic

New signature:
```dart
Future<void> deleteSelected(
  BuildContext context,
  List<PositionListItem> items,
  Map<String, int> fixtureCounts,
  List<LightingPosition> allPositions,
)
```

New logic:

```
1. Collect posIds (from selectedPositionIds), grpIds (from selectedGroupIds).
   If both empty → return.

2. Identify positions with fixtures:
   positionsWithFixtures = allPositions
     .where((p) => posIds.contains(p.id) && (fixtureCounts[p.name] ?? 0) > 0)
     .map((p) => (pos: p, count: fixtureCounts[p.name]!))
     .toList();

3. If positionsWithFixtures.isEmpty:
   → show existing showPositionConfirmDialog (unchanged).
   → on confirm: delete posIds + grpIds as before.

4. If positionsWithFixtures.isNotEmpty:
   availableTargets = allPositions
     .where((p) => !posIds.contains(p.id))
     .toList();

   result = await showDialog<DeleteWithFixturesResult>(
     context: context,
     builder: (_) => PositionDeleteWithFixturesDialog(
       positionsWithFixtures: positionsWithFixtures,
       availableTargets: availableTargets,
     ),
   );

   if result == null → return (user cancelled, do nothing).

   if result is MergeFixturesInto(target):
     for each entry in positionsWithFixtures:
       await repo.combinePositions(keepId: target.id, deleteId: entry.pos.id);
       // combinePositions moves fixtures AND deletes the source position
     for each id in posIds where NOT in positionsWithFixtures.map(e => e.pos.id):
       await repo.deletePosition(id);

   if result is OrphanFixtures:
     for each entry in positionsWithFixtures:
       await repo.nullifyFixturesAtPosition(entry.pos.name);
     for each id in posIds:
       await repo.deletePosition(id);

   if result is DeleteFixturesToo:
     for each entry in positionsWithFixtures:
       await repo.deleteFixturesAtPosition(entry.pos.name);
     for each id in posIds:
       await repo.deletePosition(id);

5. Delete all selected groups regardless:
   for each id in grpIds:
     await repo.deleteGroup(id);

6. clearSelection();
```

### 7b. Add `removeEmptyPositions()`

```dart
Future<void> removeEmptyPositions(
  BuildContext context,
  List<LightingPosition> allPositions,
  Map<String, int> fixtureCounts,
) async {
  final repo = _ref.read(positionRepoProvider);
  if (repo == null) return;

  final empty = allPositions
      .where((p) => (fixtureCounts[p.name] ?? 0) == 0)
      .toList();

  if (empty.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No empty positions found.')));
    return;
  }

  final ok = await showPositionConfirmDialog(
    context,
    title: 'Remove Empty Positions',
    message: 'Remove ${empty.length} position(s) with no fixtures assigned?\n'
        'This cannot be undone.',
  );
  if (!ok) return;

  for (final p in empty) {
    await repo.deletePosition(p.id);
  }
}
```

---

## Notes for executor

- **Orphaned fixtures and "Unassigned" display:** This ticket only implements setting `fixtures.position = null` as the orphan state. Displaying orphaned fixtures under a special "Unassigned" virtual bucket in fixture views is out of scope and will be a separate ticket.

- **`_tracked.updateField` with null:** When calling `nullifyFixturesAtPosition`, the `newValue` passed is `null` and the companion should use `Value<String?>(null)` (a present-but-null Value), not `Value.absent()`. Verify this matches how the rest of the codebase handles nullable text fields.

- **No `_buildSnapshot` changes needed** for fixtures — `toJson()` already serializes position correctly.

- **Import `package:flutter/foundation.dart`** in both card files for `defaultTargetPlatform`.

- **Do not change** the `PositionConflictResolution` sealed types, the rename flow, the combine flow, or any other existing dialog logic. Only add, don't reorganize.
