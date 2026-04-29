# TICKET-08: Keyboard, Focus, and Tab-Order UX in the Draft Editor

## Context
The draft editor panel (`_DraftEditorPanel` from TICKET-06) uses the existing `PropertyEditRow`
widget, which already handles focus-loss submission. We need to layer on top:
1. **Enter key** in any field triggers the full "ADD FIXTURE" submission.
2. **Tab key** moves focus in a deterministic, practical order.
3. **Focus restoration** after continue-adding re-inserts.

### Prerequisites
- TICKET-06 (sidebar add-mode UI complete)
- TICKET-07 (submission actually works)

### Files to modify
- `papertek/lib/ui/spreadsheet/widgets/sidebar.dart`
- `papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart`

---

## Current State

`PropertyEditRow` (in `sidebar.dart`) already:
- Submits its own value on focus loss (`_onFocusChange → _submit()`).
- Calls `onSubmitted: (_) => _submit()` on `TextField` (fires on Enter).

But `_submit()` only calls `widget.onSubmit(val)` — it cannot trigger the global ADD action.

---

## Task

### 1. Add an optional `onEnterPressed` callback to `PropertyEditRow`
`PropertyEditRow` is used by both the read/view panel and the draft editor. To avoid
breaking the existing usage, add an **optional** callback:

```dart
class PropertyEditRow extends StatefulWidget {
  const PropertyEditRow({
    super.key,
    required this.label,
    required this.value,
    required this.theme,
    required this.onSubmit,
    this.accent = false,
    this.onEnterPressed,   // <-- NEW (optional)
    this.focusNode,        // <-- NEW (optional, for external tab-order control)
  });

  final void Function(String?) onSubmit;
  final VoidCallback? onEnterPressed;
  final FocusNode? focusNode;
  // ... existing fields ...
}
```

In `_PropertyEditRowState`:
- Use `widget.focusNode ?? _focus` so that when an external `FocusNode` is passed it takes
  over the internal one.
- In `onSubmitted`, after calling `_submit()`, also call `widget.onEnterPressed?.call()`.

```dart
// In _PropertyEditRowState.build(), update the TextField:
onSubmitted: (_) {
  _submit();
  widget.onEnterPressed?.call();
},
```

### 2. Add a `FocusNode` list and tab-order to `_DraftEditorPanel`

Convert `_DraftEditorPanel` from `StatelessWidget` to `StatefulWidget`. In `initState`,
create one `FocusNode` per visible masked column in tab order. Dispose them in `dispose`.

The practical tab order for data entry is:
```
position → unit → type → function → focus → accessories →
chan → dimmer → circuit → ip → subnet → mac → ipv6
```
(Network fields last since most fixtures won't need them.)

Pass each `FocusNode` to its corresponding `PropertyEditRow` via the new `focusNode` param,
and set `onEnterPressed` to call up to the parent `onSubmit` callback.

### 3. Add `lastEditedAddField` tracking to the controller

In `SpreadsheetViewController`, `updateDraftField` already exists. Update it to also record
the last-edited field:
```dart
void updateDraftField(String colId, String? val) {
  // ... existing switch ...
  lastEditedAddField = colId;
  notifyListeners();
}
```

### 4. Restore focus after continue-adding insert

After a successful insert where `continueAdding == true`, the controller calls
`notifyListeners()`. The `_DraftEditorPanel` (now stateful) should respond in
`didUpdateWidget` by requesting focus on the node matching `controller.lastEditedAddField`.

This requires passing `lastEditedAddField` down through the sidebar to `_DraftEditorPanel`.
Add it to `SpreadsheetSidebar`'s params and thread it through.

---

## Verification / Tests

- [ ] Tab from Position → Unit → Type → ... follows the defined order.
- [ ] Press Enter in the Position field → ADD FIXTURE fires (submission triggered).
- [ ] After a continue-adding insert, focus lands back on the last field edited.
- [ ] Pressing Tab from the last field does NOT submit — only Enter submits.
- [ ] Enter key in the EXISTING `PropertiesPanel` (non-add mode) still only submits
  that single field, not the whole form (onEnterPressed is null there).
