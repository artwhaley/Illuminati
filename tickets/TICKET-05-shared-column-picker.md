# TICKET-05: Extract Shared `ColumnCheckboxList` and Build Donor Mask Picker

## Context
The existing column picker in `column_picker.dart` is implemented as a `PopupMenuEntry<Never>`
subclass. Its internal checkbox list is tightly coupled to the popup system. We need to extract
the list into a reusable standalone widget, keep the existing popup working, and also use the
new widget to build a mask picker inside the sidebar's add-mode header.

### Prerequisite
TICKET-04 must be complete (the controller has `addModeMask` and `setAddModeMask`).

### Files to modify
- `papertek/lib/ui/spreadsheet/widgets/column_picker.dart`

### Files to create
- `papertek/lib/ui/spreadsheet/widgets/column_checkbox_list.dart`

---

## Current State

### `column_picker.dart` (full file, 63 lines)
```dart
class ColumnPickerMenuEntry extends PopupMenuEntry<Never> {
  const ColumnPickerMenuEntry({ required this.hidden, required this.onChanged });

  final Set<String> hidden;
  final void Function(Set<String>) onChanged;

  @override double get height => (kColumns.length - 1) * 40.0;
  @override bool represents(Never? value) => false;
  @override State<ColumnPickerMenuEntry> createState() => _ColumnPickerMenuEntryState();
}

class _ColumnPickerMenuEntryState extends State<ColumnPickerMenuEntry> {
  late Set<String> _hidden;

  @override void initState() { super.initState(); _hidden = Set.of(widget.hidden); }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final col in kColumns)
          if (!col.isAlwaysVisible)
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(col.label, style: GoogleFonts.jetBrainsMono(fontSize: 13)),
              value: !_hidden.contains(col.id),
              onChanged: (v) {
                setState(() { v == true ? _hidden.remove(col.id) : _hidden.add(col.id); });
                widget.onChanged(_hidden);
              },
            ),
      ],
    );
  }
}
```

---

## Tasks

### 1. Create `column_checkbox_list.dart`
Create `papertek/lib/ui/spreadsheet/widgets/column_checkbox_list.dart`:

```dart
/// A reusable checkbox list for selecting a subset of columns.
/// Used by both the column-visibility popup and the add-mode donor mask.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../column_spec.dart';

class ColumnCheckboxList extends StatefulWidget {
  const ColumnCheckboxList({
    super.key,
    required this.selected,
    required this.onChanged,
    this.columns,
  });

  /// The set of currently selected column IDs.
  final Set<String> selected;

  /// Called whenever the selection changes.
  final void Function(Set<String> selected) onChanged;

  /// Columns to show. Defaults to all non-alwaysVisible columns in [kColumns].
  final List<ColumnSpec>? columns;

  @override
  State<ColumnCheckboxList> createState() => _ColumnCheckboxListState();
}

class _ColumnCheckboxListState extends State<ColumnCheckboxList> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.of(widget.selected);
  }

  @override
  void didUpdateWidget(ColumnCheckboxList old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      _selected = Set.of(widget.selected);
    }
  }

  List<ColumnSpec> get _cols =>
      widget.columns ?? kColumns.where((c) => !c.isAlwaysVisible).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final col in _cols)
          CheckboxListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(col.label, style: GoogleFonts.jetBrainsMono(fontSize: 13)),
            value: _selected.contains(col.id),
            onChanged: (v) {
              setState(() {
                v == true ? _selected.add(col.id) : _selected.remove(col.id);
              });
              widget.onChanged(Set.of(_selected));
            },
          ),
      ],
    );
  }
}
```

### 2. Refactor `column_picker.dart` to use the new widget
Replace the internal checkbox-building logic in `_ColumnPickerMenuEntryState.build()` with
the new widget. The `_hidden` set (for the visibility picker) is the **inverse** of
`selected` (for the mask picker). Keep the inversion logic local to `column_picker.dart`:

```dart
import 'package:flutter/material.dart';
import '../column_spec.dart';
import 'column_checkbox_list.dart';

class ColumnPickerMenuEntry extends PopupMenuEntry<Never> {
  const ColumnPickerMenuEntry({ super.key, required this.hidden, required this.onChanged });

  final Set<String> hidden;
  final void Function(Set<String> hidden) onChanged;

  @override
  double get height => kColumns.where((c) => !c.isAlwaysVisible).length * 40.0;

  @override
  bool represents(Never? value) => false;

  @override
  State<ColumnPickerMenuEntry> createState() => _ColumnPickerMenuEntryState();
}

class _ColumnPickerMenuEntryState extends State<ColumnPickerMenuEntry> {
  @override
  Widget build(BuildContext context) {
    // Visibility picker uses selected = visible = NOT hidden.
    final selected = kColumns
        .where((c) => !c.isAlwaysVisible && !widget.hidden.contains(c.id))
        .map((c) => c.id)
        .toSet();

    return ColumnCheckboxList(
      selected: selected,
      onChanged: (newSelected) {
        // Convert back: hidden = all non-alwaysVisible columns NOT in newSelected.
        final newHidden = kColumns
            .where((c) => !c.isAlwaysVisible && !newSelected.contains(c.id))
            .map((c) => c.id)
            .toSet();
        widget.onChanged(newHidden);
      },
    );
  }
}
```

### 3. Expose `ColumnCheckboxList` from the barrel or ensure imports are correct
The sidebar (TICKET-06) will import `column_checkbox_list.dart` directly. No barrel file
changes are strictly required.

---

## Verification / Tests

Run `flutter analyze` — zero errors.

Manual checks:
- [ ] Open the column-picker popup (toolbar Columns button) — all checkboxes still appear
  and toggling a column still hides/shows it in the grid.
- [ ] The existing `ColumnPickerMenuEntry` height is still correct (no blank space at bottom
  of popup).
- [ ] `ColumnCheckboxList` with a custom `columns` list only renders those columns (will be
  tested visually in TICKET-06 when integrated into the sidebar mask picker).
