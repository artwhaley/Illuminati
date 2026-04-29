# TICKET-01: Remove Clone Fixture Feature

## Context
The app has a "Clone Fixture" action that duplicates a selected row. We are removing all UI
entry points for cloning. The underlying `cloneFixture` method in `FixtureRepository` must
be **kept** (it may be used in import flows later).

### Files to modify
- `papertek/lib/ui/spreadsheet/widgets/sidebar.dart`
- `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart`
- `papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart`

---

## Current State

### sidebar.dart (relevant excerpt)
`SpreadsheetSidebar` is a `StatelessWidget` with these constructor params:
```dart
const SpreadsheetSidebar({
  required this.theme,
  required this.selected,
  required this.canClone,   // <-- REMOVE
  required this.onAdd,
  required this.onClone,    // <-- REMOVE
  required this.onDelete,
  required this.onEdit,
});
```
In `build()` it renders three buttons: Add Fixture, Clone Fixture (OutlinedButton.icon with
`Icons.copy_outlined`), Delete Fixture. The Clone button is the middle button.

### spreadsheet_tab.dart (relevant excerpts)
1. `_showFixtureContextMenu` method contains a `PopupMenuItem` with
   `onTap: () => _controller.cloneFixture(fixture)` and a `ListTile` labelled "Clone Fixture".
2. The `SpreadsheetSidebar(...)` constructor call passes `canClone: sel != null` and
   `onClone: () { if (sel != null) _controller.cloneFixture(sel); }`.

### spreadsheet_view_controller.dart (relevant excerpt)
```dart
Future<void> cloneFixture(FixtureRow fixture) async {
  await repo.cloneFixture(fixture.id);
}
```

---

## Tasks

### 1. `sidebar.dart`
1. Update the doc comment on line 1 from:
   `/// Contains CRUD actions (Add/Clone/Delete) and the [PropertiesPanel].`
   to:
   `/// Contains CRUD actions (Add/Delete) and the [PropertiesPanel].`
2. Remove the `canClone` and `onClone` constructor parameters and their corresponding
   `final` field declarations.
3. In the `build()` method, delete the entire `OutlinedButton.icon` block for "Clone Fixture"
   and the `SizedBox(height: 6)` that precedes it (the one between Add and Clone).
   Keep the `SizedBox(height: 6)` between Add and Delete.

### 2. `spreadsheet_tab.dart`
1. In `_showFixtureContextMenu`, delete the entire first `PopupMenuItem` (the Clone one,
   including the `onTap` and `child: ListTile`). Leave only the Delete `PopupMenuItem`.
2. In the `SpreadsheetSidebar(...)` constructor call inside the `ListenableBuilder`, remove
   the `canClone: sel != null` and `onClone: ...` lines.

### 3. `spreadsheet_view_controller.dart`
1. Delete the entire `cloneFixture` method (3 lines).
2. Do **not** touch `FixtureRepository.cloneFixture` — it stays.

---

## Verification / Tests

Run `flutter analyze` — zero new errors expected.

Manual checks:
- [ ] Sidebar shows exactly two action buttons: "Add Fixture" and "Delete Fixture".
- [ ] Right-clicking a grid row shows only "Delete Fixture" in the context menu.
- [ ] Hot-reload does not throw any `NoSuchMethodError` about `cloneFixture` or `canClone`.
- [ ] `FixtureRepository.cloneFixture` still exists and compiles (grep for it).
