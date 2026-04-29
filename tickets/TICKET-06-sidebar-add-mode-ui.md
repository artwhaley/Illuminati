# TICKET-06: Build Add-Mode Sidebar UI

## Context
The sidebar currently shows three action buttons (after TICKET-01: two — Add + Delete) and a
`PropertiesPanel` that displays a selected fixture's fields as read-only + editable rows.

In add mode the sidebar completely changes its personality:
- The top button becomes "Cancel Add".
- The existing `PropertiesPanel` is replaced by a **draft editor** — same field rows but
  editing the `FixtureDraft` values, not an existing fixture.
- A header banner shows "ADD FIXTURE MODE" and a "Fields..." button to open the mask picker.
- A footer area shows the "ADD FIXTURE" primary button and the "Continue adding" checkbox.

### Prerequisites
- TICKET-01 (clone removed)
- TICKET-03 (`FixtureDraft` model exists)
- TICKET-04 (controller has `isAddMode`, `addDraft`, `enterAddMode`, etc.)
- TICKET-05 (`ColumnCheckboxList` exists)

### Files to modify
- `papertek/lib/ui/spreadsheet/widgets/sidebar.dart`
- `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart` (update sidebar call site)

---

## Current Sidebar State (post TICKET-01)

```dart
class SpreadsheetSidebar extends StatelessWidget {
  const SpreadsheetSidebar({
    required this.theme,
    required this.selected,
    required this.onAdd,       // currently calls controller.addFixture()
    required this.onDelete,
    required this.onEdit,
  });
  ...
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Column(children: [
          FilledButton.icon(onPressed: onAdd, label: Text('Add Fixture')),
          SizedBox(height: 6),
          OutlinedButton.icon(onPressed: selected != null ? onDelete : null,
                              label: Text('Delete Fixture')),
        ]),
      ),
      Divider(...),
      Expanded(child: PropertiesPanel(theme: theme, fixture: selected, onEdit: onEdit)),
    ]);
  }
}
```

---

## Tasks

### 1. Add new constructor parameters to `SpreadsheetSidebar`
Replace the existing signature with:
```dart
class SpreadsheetSidebar extends StatelessWidget {
  const SpreadsheetSidebar({
    super.key,
    required this.theme,
    required this.selected,       // FixtureRow? — the currently selected fixture (or donor)
    required this.isAddMode,      // bool — whether add mode is active
    required this.addDraft,       // FixtureDraft? — the draft being composed
    required this.continueAdding, // bool
    required this.addModeMask,    // Set<String>
    required this.onEnterAddMode, // VoidCallback — toggle into add mode
    required this.onCancelAddMode,// VoidCallback
    required this.onSubmitAdd,    // VoidCallback — fires ADD FIXTURE
    required this.onContinueAddingChanged, // ValueChanged<bool>
    required this.onMaskChanged,  // ValueChanged<Set<String>>
    required this.onDraftEdit,    // void Function(String fieldId, String? value)
    required this.onDelete,       // VoidCallback
    required this.onEdit,         // Future<void> Function(String col, String? value)
  });
```

### 2. Replace `build()` with mode-aware layout
```dart
@override
Widget build(BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Top toggle button
          if (!isAddMode)
            FilledButton.icon(
              onPressed: onEnterAddMode,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Fixture'),
              style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
            )
          else
            OutlinedButton.icon(
              onPressed: onCancelAddMode,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cancel Add'),
              style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          const SizedBox(height: 6),
          // Delete button — hidden in add mode
          if (!isAddMode)
            OutlinedButton.icon(
              onPressed: selected != null ? onDelete : null,
              icon: Icon(Icons.delete_outline, size: 16,
                  color: selected != null ? theme.colorScheme.error : null),
              label: const Text('Delete Fixture'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(
                  color: selected != null
                      ? theme.colorScheme.error.withValues(alpha: 0.5)
                      : theme.colorScheme.outlineVariant,
                ),
              ),
            ),
        ]),
      ),
      Divider(height: 1, color: theme.colorScheme.outlineVariant),

      // Add mode header banner
      if (isAddMode) _AddModeHeader(
        theme: theme,
        mask: addModeMask,
        onMaskChanged: onMaskChanged,
      ),

      // Main content panel
      Expanded(
        child: isAddMode
            ? _DraftEditorPanel(
                theme: theme,
                draft: addDraft ?? FixtureDraft(),
                mask: addModeMask,
                onEdit: onDraftEdit,
              )
            : PropertiesPanel(
                theme: theme,
                fixture: selected,
                onEdit: onEdit,
              ),
      ),

      // Add mode footer
      if (isAddMode) _AddModeFooter(
        theme: theme,
        continueAdding: continueAdding,
        onSubmit: onSubmitAdd,
        onContinueChanged: onContinueAddingChanged,
      ),
    ],
  );
}
```

### 3. Implement `_AddModeHeader`
A private widget inside `sidebar.dart`:
```dart
class _AddModeHeader extends StatelessWidget {
  const _AddModeHeader({
    required this.theme,
    required this.mask,
    required this.onMaskChanged,
  });

  final ThemeData theme;
  final Set<String> mask;
  final ValueChanged<Set<String>> onMaskChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.edit_note, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'ADD FIXTURE MODE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _showMaskPicker(context),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
            child: Text('Fields…',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showMaskPicker(BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    // Only show editable, non-boolean columns as maskable fields.
    final maskableCols = kColumns
        .where((c) => !c.isReadOnly && !c.isBoolean && c.id != '#')
        .toList();

    showMenu<Never>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy + 30, pos.dx + 220, pos.dy + 400),
      elevation: 8,
      items: [
        PopupMenuItem<Never>(
          padding: EdgeInsets.zero,
          child: ColumnCheckboxList(
            selected: mask,
            columns: maskableCols,
            onChanged: onMaskChanged,
          ),
        ),
      ],
    );
  }
}
```

### 4. Implement `_AddModeFooter`
```dart
class _AddModeFooter extends StatelessWidget {
  const _AddModeFooter({
    required this.theme,
    required this.continueAdding,
    required this.onSubmit,
    required this.onContinueChanged,
  });

  final ThemeData theme;
  final bool continueAdding;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onContinueChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: onSubmit,
            child: const Text('ADD FIXTURE'),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: continueAdding,
                visualDensity: VisualDensity.compact,
                onChanged: (v) => onContinueChanged(v ?? false),
              ),
              Text('Continue adding',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 5. Implement `_DraftEditorPanel`
This mirrors `PropertiesPanel` but sources values from the draft and calls `onDraftEdit`
instead of `onEdit`. Only show fields whose column ID is in the mask:

```dart
class _DraftEditorPanel extends StatelessWidget {
  const _DraftEditorPanel({
    required this.theme,
    required this.draft,
    required this.mask,
    required this.onEdit,
  });

  final ThemeData theme;
  final FixtureDraft draft;
  final Set<String> mask;
  final void Function(String fieldId, String? value) onEdit;

  String? _draftValue(String colId) {
    return switch (colId) {
      'chan'        => draft.channel,
      'dimmer'      => draft.dimmer,
      'circuit'     => draft.circuit,
      'position'    => draft.position,
      'unit'        => draft.unitNumber?.toString(),
      'type'        => draft.fixtureType,
      'function'    => draft.function,
      'focus'       => draft.focus,
      'accessories' => draft.accessories,
      'ip'          => draft.ipAddress,
      'subnet'      => draft.subnet,
      'mac'         => draft.macAddress,
      'ipv6'        => draft.ipv6,
      _             => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <ColumnSection, List<ColumnSpec>>{};
    for (final spec in kColumns) {
      if (spec.isReadOnly || spec.isBoolean || spec.id == '#') continue;
      if (!mask.contains(spec.id)) continue;
      grouped.putIfAbsent(spec.section, () => []).add(spec);
    }

    final sectionOrder = [
      ColumnSection.patch, ColumnSection.fixture,
      ColumnSection.network, ColumnSection.other,
    ];

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        for (final section in sectionOrder)
          if (grouped.containsKey(section)) ...[
            _section(section.name.toUpperCase()),
            for (final spec in grouped[section]!)
              PropertyEditRow(
                key: ValueKey('draft-${spec.id}'),
                label: spec.label,
                value: _draftValue(spec.id),
                theme: theme,
                onSubmit: (v) => onEdit(spec.id, v),
                accent: spec.id == 'chan',
              ),
            Divider(height: 16, color: theme.colorScheme.outlineVariant),
          ],
      ],
    );
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(label, style: theme.textTheme.labelSmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.8)),
  );
}
```

### 6. Update the sidebar call site in `spreadsheet_tab.dart`

Replace the current `SpreadsheetSidebar(...)` constructor call in the `ListenableBuilder`
with:
```dart
ListenableBuilder(
  listenable: Listenable.merge([_source, _sidebarSelection]),
  builder: (ctx, _) {
    final sel = _source.selectedFixture;
    return SpreadsheetSidebar(
      theme: theme,
      selected: sel,
      isAddMode: _controller.isAddMode,
      addDraft: _controller.addDraft,
      continueAdding: _controller.continueAdding,
      addModeMask: _controller.addModeMask,
      onEnterAddMode: () => _controller.enterAddMode(donor: sel),
      onCancelAddMode: _controller.cancelAddMode,
      onSubmitAdd: () => _controller.submitAddFixture(),
      onContinueAddingChanged: _controller.setContinueAdding,
      onMaskChanged: (mask) => _controller.setAddModeMask(mask, donor: sel),
      onDraftEdit: (colId, val) {
        // Update the draft directly on the controller's draft object
        // and notify listeners.
        _controller.updateDraftField(colId, val);
      },
      onDelete: () { if (sel != null) _controller.deleteFixture(sel); },
      onEdit: (col, val) =>
          sel != null ? _controller.editCell(sel, col, val, null) : Future.value(),
    );
  },
),
```

Also add a `updateDraftField` method to `SpreadsheetViewController` (can be in TICKET-04's
section but must exist before this ticket's build):
```dart
void updateDraftField(String colId, String? val) {
  final d = addDraft;
  if (d == null) return;
  switch (colId) {
    case 'chan':        d.channel     = val; break;
    case 'dimmer':      d.dimmer      = val; break;
    case 'circuit':     d.circuit     = val; break;
    case 'position':    d.position    = val; break;
    case 'unit':        d.unitNumber  = int.tryParse(val ?? ''); break;
    case 'type':        d.fixtureType = val; break;
    case 'function':    d.function    = val; break;
    case 'focus':       d.focus       = val; break;
    case 'accessories': d.accessories = val; break;
    case 'ip':          d.ipAddress   = val; break;
    case 'subnet':      d.subnet      = val; break;
    case 'mac':         d.macAddress  = val; break;
    case 'ipv6':        d.ipv6        = val; break;
  }
  notifyListeners();
}
```

### 7. Add required imports to `sidebar.dart`
```dart
import 'column_checkbox_list.dart';
import '../fixture_draft.dart';
```

---

## Verification / Tests

Run `flutter analyze` — zero errors.

Manual checks:
- [ ] Idle state: sidebar shows "Add Fixture" + "Delete Fixture" buttons and the fixture
  properties panel.
- [ ] Click "Add Fixture" with no row selected → mode banner appears with primary container
  tint, "ADD FIXTURE MODE" label, "Fields…" button, and draft editor with all editable fields.
- [ ] Click "Add Fixture" with a row selected → draft editor pre-populated from that donor row.
- [ ] Click "Cancel Add" → returns to idle state.
- [ ] Draft editor fields are editable; typing updates the draft (verified in next ticket).
- [ ] "Fields…" opens a checkbox popup; unchecking a field removes it from the draft editor.
- [ ] Delete button is hidden when in add mode.
- [ ] Mask picker shows only editable non-boolean columns.
- [ ] "ADD FIXTURE" button is visible in the footer. (Actual insertion tested in TICKET-07.)
- [ ] "Continue adding" checkbox is visible and toggleable.
