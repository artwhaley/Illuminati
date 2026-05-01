# TICKET-13 — Maintenance Tab: Remove Flagged Feature

**Phase:** 8 of 10  
**Executor:** Sonnet  
**Delegation:** None — requires careful judgment about what to keep vs. remove. This file is 1,100+ lines and the flagged system is interleaved with the revision system.  
**Depends on:** TICKET-05 (FixtureRow no longer has `flagged`)  
**Blocks:** Nothing — but must not break the Edit Review tab

---

## Goal

Remove all flagged-fixture UI from the maintenance tab while leaving the Edit Review tab and the maintenance log entry display completely intact. This is a surgical removal, not a refactor.

---

## Files to Read First

1. `papertek/lib/ui/maintenance/maintenance_tab.dart` — full file (~1,100 lines). Read every line before touching anything. Understand which classes and widgets belong to Edit Review vs. Maintenance Log.
2. Find `show_provider.dart` (or wherever `flaggedFixturesProvider` is defined) and read the relevant provider definitions.

---

## What to Keep (do not touch)

- The entire `EditReviewTab` widget and all its children (`_RevisionCard`, `_TabularCardBody`, `_StagingRow`, etc.)
- The `MaintenanceTab` top-level widget and its `TabController` setup
- The `MaintenanceLogTab` widget structure (the tab itself stays)
- All `MaintenanceLog` database table references and log entry display
- All resolve-button logic for maintenance log entries
- `unresolvedMaintenanceProvider` and any providers that load `MaintenanceLog` records

---

## What to Remove

### In `maintenance_tab.dart`:

1. **`flaggedFixturesProvider` consumption** — any `ref.watch(flaggedFixturesProvider)` calls
2. **Flagged fixture display section** in `MaintenanceLogTab` — the part that lists fixtures where `flagged == true`. This is likely a section heading + a list of `_MaintenanceItemCard` widgets built from the flagged provider. Remove the section; keep the maintenance log entries section.
3. **`_MaintenanceItemCard` widget** — check whether this widget is used only for flagged fixtures or also for other purposes. If it's exclusively for flagged fixtures, delete it. If it's shared with maintenance log display, keep the class but remove calls that pass flagged-fixture data to it.
4. Any "Flag" / "Unflag" buttons, toggle actions, or `toggleFlag` repository calls
5. Any import of a `flaggedFixturesProvider`

### In `show_provider.dart` (or wherever the provider lives):

Remove `flaggedFixturesProvider` entirely. It should look something like:
```dart
final flaggedFixturesProvider = Provider<List<FixtureRow>>((ref) {
  return ref.watch(fixtureRowsProvider).where((f) => f.flagged).toList();
});
```
Delete this. If `flaggedFixturesProvider` is referenced anywhere else, remove those references too.

---

## After Removal

The "Maintenance Log" tab should still display:
- A list of unresolved `MaintenanceLog` entries grouped by fixture
- Resolve buttons on each entry
- "Resolve All" button per fixture group

If the tab becomes sparse or its heading no longer makes sense, update the tab label to simply "Maintenance Log" (was possibly "Maintenance" or compound).

---

## Verify

1. The Edit Review tab functions identically to before
2. The Maintenance Log tab shows log entries (if any exist) and their resolve buttons
3. No compile errors referencing `flagged`, `toggleFlag`, or `flaggedFixturesProvider`
4. `FixtureRow.flagged` is not referenced anywhere in the maintenance tab
