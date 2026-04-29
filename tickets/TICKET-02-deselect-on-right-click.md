# TICKET-02: Right-Click Outside Grid = Deselect

## Context
Currently, right-clicking anywhere inside the `SfDataGrid` selects a row and shows a context
menu. However right-clicking in the toolbar, filter strip, presets strip, or status bar does
nothing and leaves the grid's current selection visually active. The goal is: **a right-click
anywhere outside the grid clears the current selection** (both in the data source and the grid
controller).

### File to modify
- `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart`

---

## Current State

### Relevant layout in `spreadsheet_tab.dart` `build()`
The main content area (`Expanded` column) contains:
```dart
Column(
  children: [
    SpreadsheetToolbar(...),       // <- outside grid
    SpreadsheetFilterStrip(...),   // <- outside grid
    Expanded(
      child: SfDataGridTheme(
        child: SfDataGrid(         // <- INSIDE grid
          onCellSecondaryTap: (details) { /* selects + shows menu */ },
          ...
        ),
      ),
    ),
    SpreadsheetPresetsStrip(...),  // <- outside grid
    SpreadsheetStatusBar(...),     // <- outside grid
  ],
)
```

### How selection is currently cleared
Selection is tracked in two places:
1. `_source.setSelectedCell(null, null)` — clears the `FixtureDataSource`.
2. `_sidebarSelection.value = null` — clears the sidebar `ValueNotifier<FixtureRow?>`.
3. `_controller.gridController.currentCell = const RowColumnIndex(-1, -1)` — clears
   the `DataGridController`'s visual selection state.

---

## Task

### `spreadsheet_tab.dart`

Add a `_clearSelection()` helper method to `_SpreadsheetTabState`:
```dart
void _clearSelection() {
  _source.setSelectedCell(null, null);
  _sidebarSelection.value = null;
  _controller.gridController.currentCell = const RowColumnIndex(-1, -1);
}
```

In `build()`, wrap the entire `Expanded` main content column with a `Listener` widget:
```dart
Listener(
  onPointerDown: (event) {
    // Button 2 = right mouse button (secondary click)
    if (event.buttons == 2) {
      _clearSelection();
    }
  },
  child: Expanded(
    child: Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: Column(children: [ ... ]),
    ),
  ),
)
```

**Important:** The `SfDataGrid`'s `onCellSecondaryTap` runs AFTER this `Listener`. The
`Listener` callback runs first (pointerDown phase), which will clear selection. The grid's
own tap handler then re-selects the tapped row and shows the context menu. This is the
desired behavior: clicking inside the grid still works normally; clicking outside clears.

Verify that `Listener` does not need `behavior: HitTestBehavior.translucent` — since the
child is a `Material` widget that fills its area, the default behavior should be fine.

---

## Verification / Tests

Run `flutter analyze` — zero new errors expected.

Manual checks:
- [ ] Select a row. Right-click on the **Toolbar** — sidebar clears, grid highlight disappears.
- [ ] Select a row. Right-click on the **Filter Strip** — same result.
- [ ] Select a row. Right-click on the **Presets Strip** — same result.
- [ ] Select a row. Right-click on the **Status Bar** — same result.
- [ ] Right-click a **grid row** — row is selected AND context menu appears (normal behavior preserved).
- [ ] Left-clicking outside the grid does NOT clear selection (only right-click should).
