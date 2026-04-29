# Rework Fixture Add Behavior Plan (v2)

## Goals
- Remove clone fixture UI/entry points entirely.
- Add explicit **Add Fixture mode** in the info panel with strong visual distinction.
- Support donor-based prefill with a **field mask** (default = all editable/showable columns).
- Improve data-entry UX: Enter submits, smart tab order, continue-adding workflow.
- Deselect row when right-clicking outside the spreadsheet grid.

## Architecture & State Management
- **State Ownership:** The "Add Mode" state (`isAddMode`, `continueAdding`, `addModeMask`, and the `FixtureDraft` itself) will be owned by `SpreadsheetViewController`. This allows the tab to suppress grid selections when adding and keeps the Sidebar widget mostly stateless.
- **Draft Model:** Introduce a typed `FixtureDraft` class instead of a raw Map to hold the pending fixture data. It should include factories like `FixtureDraft.empty()` and `FixtureDraft.fromDonor(FixtureRow donor, Set<String> mask)`.
- **Mask Persistence:** The `addModeMask` should persist within the current session inside the `SpreadsheetViewController` so the user doesn't have to reselect columns every time they enter add mode.

## Implementation Scope

### 1) Remove Clone Fixture Feature
- Remove sidebar clone button from `papertek/lib/ui/spreadsheet/widgets/sidebar.dart`.
- Remove clone item from right-click context menu in `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart`.
- Remove `cloneFixture` wiring in `papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart`.
- *Note: Keep the `cloneFixture` method inside `FixtureRepository` for programmatic usage (e.g. import flows), but remove all UI hooks.*

### 2) Add Right-Click Outside Grid = Deselect
- In `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart`, wrap the main content area (or specifically the area outside the `SfDataGrid`) with a `Listener` for secondary taps.
- On right-click outside the grid:
  - Clear the datasource selected cell.
  - Clear the sidebar selection notifier.
  - Clear grid controller selection state.
  - *Note: Ensure this does not swallow right-clicks on interactive elements like the toolbar or filter strip.*

### 3) Define `FixtureDraft` Model
- Create a new data model class `FixtureDraft`.
- Fields should mirror editable fields in `FixtureRow` (e.g., `String? position`, `int? unitNumber`, `String? channel`, `String? dimmer`, etc.).
- Add a method to generate a draft from a donor row, applying a Set of allowed column IDs (the mask).
- Add a method to increment/clear specific fields after submission if `continueAdding` is true (e.g. `unitNumber++`, clear `channel`/`dimmer`/`circuit`).

### 4) Introduce Add Fixture Mode (Sidebar UI)
- In `papertek/lib/ui/spreadsheet/widgets/sidebar.dart`:
  - Top action button toggles: `Add Fixture` (idle) ↔ `Cancel Add` (add mode).
  - Add mode applies:
    - A distinct background/color treatment.
    - A prominent "Add Fixture Mode" header label alongside the Mask button.
  - Sidebar layout updates: Avoid hardcoded height reductions (like ~175px). Use Flutter's natural layout properties (`Expanded` for the `PropertiesPanel` equivalent, placing the new bottom action area naturally below it).
- Bottom action section:
  - Primary `ADD FIXTURE` button to trigger insertion.
  - `Continue adding` checkbox.

### 5) Donor Prefill Mask (with Picker Reuse)
- Refactor the existing checkbox list logic from `papertek/lib/ui/spreadsheet/widgets/column_picker.dart` into a standalone, reusable `ColumnCheckboxList` widget.
- Wrap this new widget in the existing `ColumnPickerMenuEntry` for the main view column visibility.
- Use `ColumnCheckboxList` to build a new mask picker UI in the Sidebar's add mode header.
- Mask behavior:
  - Governs which donor fields populate the `FixtureDraft` on mode entry.
  - Default: All editable columns.

### 6) Add Draft Insert Through Tracked Write Layer
- Extend `papertek/lib/repositories/fixture_repository.dart` with a new `addFixtureFromDraft(FixtureDraft draft)` API.
- **CRITICAL UNDO REQUIREMENT:** Creating a fixture with prefilled parts requires multiple inserts (fixture row + intensity part row + optional gel/gobo rows). Use `_tracked.beginBatchFrame('Add fixture')` and `_tracked.endBatchFrame()` to ensure the insertion is treated as a single Undo operation.
- Wire the controller's add-submit handler to call this new API. The grid's active multicolumn sorting will automatically place the new row.

### 7) Keyboard, Focus, and Tab Order UX
- In the sidebar add-mode editor:
  - Pressing `Enter` from any single-line field should trigger the `ADD FIXTURE` submission.
  - Establish a deterministic Tab order matching the natural data entry flow.
  - Track the `lastEditedField`.
- Post-insertion behavior:
  - If `Continue adding = true`: Remain in add mode. Update the draft (auto-increment `unitNumber`, clear `channel`/`address`), and restore focus to the `lastEditedField`.
  - If `Continue adding = false`: Exit add mode, discard the draft, and revert the top button.

## Files To Modify
- `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart` (Event listening, controller wiring)
- `papertek/lib/ui/spreadsheet/widgets/sidebar.dart` (Add mode UI, layout, action buttons)
- `papertek/lib/ui/spreadsheet/widgets/column_picker.dart` (Extract shared list)
- `papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart` (State holding, logic orchestration)
- `papertek/lib/repositories/fixture_repository.dart` (New `addFixtureFromDraft` with batching)
- *Optional new file for `FixtureDraft` model (e.g., `papertek/lib/models/fixture_draft.dart`) or keep in `spreadsheet_view_controller.dart`.*

## Execution Order
1. **Clean up Clone:** Remove clone UI and menu entry points, keeping the repo method.
2. **Outside-grid Deselect:** Add the `Listener` in `spreadsheet_tab.dart` for secondary taps.
3. **Data Model:** Create the `FixtureDraft` class.
4. **State Management:** Add draft state, mask, and add-mode toggles to `SpreadsheetViewController`.
5. **Picker Refactor:** Extract `ColumnCheckboxList` and build the donor mask UI.
6. **Sidebar UI:** Build the Add-mode visual states, header, footer, and editor interactions in `sidebar.dart`.
7. **Repository API:** Implement `addFixtureFromDraft` with undo batching in `fixture_repository.dart`.
8. **Wiring & Polish:** Connect the submit action, ensure Enter-to-submit, tab order, and `continueAdding` cleanup behaviors work correctly. Run tests to ensure regressions are handled.
