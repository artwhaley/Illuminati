# TICKET-04: Add Add-Mode State to `SpreadsheetViewController`

## Context
The `SpreadsheetViewController` is the central state owner for the spreadsheet tab. We need
to add all "Add Fixture Mode" state to it so that the sidebar, the tab, and ultimately the
repository API are all coordinated through one `ChangeNotifier`.

### Prerequisite
TICKET-03 must be completed. `FixtureDraft` must exist at
`papertek/lib/ui/spreadsheet/fixture_draft.dart`.

### File to modify
- `papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart`

---

## Current State

### Relevant top of `SpreadsheetViewController`
```dart
class SpreadsheetViewController extends ChangeNotifier {
  // ... constructor, repo, presetRepo, dataSource ...

  // ── Grid State ─────────────────────────────────────────────────────────────
  final DataGridController gridController = DataGridController();
  final TextEditingController searchController = TextEditingController();

  List<String> colOrder = ...;
  Set<String> hiddenCols = {};
  // ... sort, presets ...

  // ── Actions ────────────────────────────────────────────────────────────────
  Future<void> addFixture() async {
    await repo.addFixture();
  }
```

---

## Tasks

### 1. Add import for `FixtureDraft`
At the top of `spreadsheet_view_controller.dart`, add:
```dart
import 'fixture_draft.dart';
```

### 2. Add add-mode state fields
Under the existing `// ── Grid State` block, add a new section:
```dart
// ── Add Fixture Mode ───────────────────────────────────────────────────────

/// Whether the sidebar is currently in "Add Fixture" mode.
bool isAddMode = false;

/// The draft being composed in add mode. Null when not in add mode.
FixtureDraft? addDraft;

/// Whether to stay in add mode after a successful insert.
bool continueAdding = false;

/// Which column IDs are included in the donor prefill mask.
/// Persists for the life of the session.
/// Defaults to all editable column IDs (all non-readOnly columns except '#').
Set<String> addModeMask = _defaultMask();

static Set<String> _defaultMask() {
  return kColumns
      .where((c) => !c.isReadOnly && c.id != '#')
      .map((c) => c.id)
      .toSet();
}

/// The column ID of the last field the user edited in add mode.
/// Used to restore focus after a continue-adding insert.
String? lastEditedAddField;
```

### 3. Add add-mode control methods
Add the following methods to the `// ── Database Operations` section (near `addFixture`):

```dart
/// Enter add mode. If [donor] is provided, prefill the draft using [addModeMask].
void enterAddMode({FixtureRow? donor}) {
  isAddMode = true;
  addDraft = donor != null
      ? FixtureDraft.fromDonor(donor, addModeMask)
      : FixtureDraft();
  notifyListeners();
}

/// Exit add mode and discard the draft.
void cancelAddMode() {
  isAddMode = false;
  addDraft = null;
  notifyListeners();
}

/// Update the mask and re-apply it to the current draft if one exists and
/// a donor row is selected.
void setAddModeMask(Set<String> mask, {FixtureRow? donor}) {
  addModeMask = mask;
  if (isAddMode && addDraft != null && donor != null) {
    addDraft = FixtureDraft.fromDonor(donor, mask);
  }
  notifyListeners();
}

void setContinueAdding(bool value) {
  continueAdding = value;
  notifyListeners();
}
```

### 4. Replace the existing `addFixture()` stub
The current `addFixture()` calls `repo.addFixture()` unconditionally. Replace it with:
```dart
/// Called from the sidebar "ADD FIXTURE" button.
/// Inserts the current [addDraft] via the repository, then either
/// stays in add mode (advance draft) or exits.
Future<void> submitAddFixture() async {
  final draft = addDraft;
  if (draft == null) return;

  await repo.addFixtureFromDraft(draft);

  if (continueAdding) {
    draft.advanceForContinue();
    // Trigger a rebuild so the sidebar editor reflects the updated draft.
    notifyListeners();
  } else {
    cancelAddMode();
  }
}
```

Keep `addFixture()` as a passthrough for now in case it is called elsewhere (it will be wired
up properly in TICKET-07 when the sidebar is built):
```dart
Future<void> addFixture() async {
  await repo.addFixture();
}
```

---

## Verification / Tests

Run `flutter analyze` — zero errors.

Behavioral checks (no UI yet — these verify the logic):
- [ ] `enterAddMode()` with no donor → `isAddMode == true`, `addDraft` is non-null, all
  draft fields are null.
- [ ] `enterAddMode(donor: someRow)` with mask `{'position', 'type'}` →
  `addDraft.position == someRow.position`, `addDraft.channel == null`.
- [ ] `cancelAddMode()` → `isAddMode == false`, `addDraft == null`.
- [ ] `setAddModeMask({'chan'}, donor: someRow)` while in add mode → draft rebuilt with
  only channel populated.
- [ ] `continueAdding = true`, submit → draft stays, `unitNumber` incremented.
