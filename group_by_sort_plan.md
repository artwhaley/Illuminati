# Implement Group By Sort 1 in Spreadsheet Tab

## Scope
Add a checkbox labeled `Group By Sort 1` in the spreadsheet UI near the presets/sort controls, and use Syncfusion's built-in grouping (`ColumnGroup`) to group rows by the current Sort 1 column when enabled.

## Files to Update
- [C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/widgets/toolbar.dart](C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/widgets/toolbar.dart)
- [C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/spreadsheet_tab.dart](C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/spreadsheet_tab.dart)
- [C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart](C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart)
- [C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/fixture_data_source.dart](C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/fixture_data_source.dart)
- [C:/Users/artwh/Downloads/Illuminati/papertek/lib/repositories/spreadsheet_view_preset_repository.dart](C:/Users/artwh/Downloads/Illuminati/papertek/lib/repositories/spreadsheet_view_preset_repository.dart) (only if preset DTO/schema mapping needs explicit new field handling)

## Syncfusion API Decisions (Built-in, no custom grouping engine)
- Use `DataGridSource.clearColumnGroups()` when toggle is off (or when Sort 1 is absent).
- Use `DataGridSource.addColumnGroup(ColumnGroup(name: sort1ColumnName, sortGroupRows: true))` when toggle is on and Sort 1 exists.
- Re-apply grouping whenever Sort 1 changes, sort direction changes, or preset apply changes sort state.
- Avoid manual emulation of grouped rows; rely on SfDataGrid's native group rows.

## Implementation Steps
1. **Add controller state + API**
   - In `spreadsheet_view_controller.dart`, add `bool groupBySort1` with notifier updates.
   - Add methods like:
     - `setGroupBySort1(bool enabled)`
     - internal `_syncGridGrouping()` (or equivalent) that:
       - resolves current Sort 1 column from controller/source sort state,
       - clears existing groups,
       - adds group only when `enabled == true` and Sort 1 exists.
   - Call grouping sync from existing sort mutation paths (`setSortLevel`, sort direction toggles, preset apply, and grid sort sync callbacks).

2. **Add checkbox in spreadsheet UI**
   - In `toolbar.dart`, add a checkbox labeled `Group By Sort 1` near the sort controls/presets-adjacent area.
   - Expose props for current value and `onChanged` callback.
   - Disable checkbox interaction (or keep checked but inert) only if needed by current UX policy; selected behavior is: when no Sort 1, grouping should not be applied.

3. **Wire state in tab composition**
   - In `spreadsheet_tab.dart`, pass controller value/callback into toolbar widget.
   - Ensure listener/rebuild path updates checkbox state after preset apply and sort changes.

4. **Persist with presets (confirmed requirement)**
   - In `spreadsheet_view_controller.dart` preset capture/apply methods, include `groupBySort1` in serialized view state.
   - In repository/model mapping, ensure unknown-old presets still deserialize safely with default `false`.
   - On preset apply:
     - restore sort state first,
     - restore `groupBySort1`,
     - run grouping sync so final grid reflects restored sort/group pairing.

5. **Apply no-sort fallback behavior (confirmed requirement)**
   - If `groupBySort1 == true` but Sort 1 is unset, call `clearColumnGroups()` and do not auto-pick any fallback column.
   - Keep checkbox state as-is (checked) if desired, but effective grouping remains off until Sort 1 exists.

6. **Guard against grouping/sort side effects**
   - Because `sortGroupRows: true` can influence sort metadata, keep sync order deterministic:
     - apply intended sorted columns,
     - invoke data source sort,
     - then apply grouping.
   - If this causes sort drift, switch grouping call to `sortGroupRows: false` and preserve sorting manually as fallback strategy.

## Validation Checklist
- Toggle on with Sort 1 set -> grouped rows appear by Sort 1 column.
- Toggle off -> all grouping removed.
- Change Sort 1 while toggle is on -> grouping column switches to new Sort 1.
- Clear Sort 1 while toggle is on -> grouping removed (no fallback).
- Save preset with toggle on/off -> applying preset restores both sort config and grouping behavior.
- Apply old preset (without new field) -> defaults safely (`groupBySort1 = false`).

## Suggested Test Targets
- Unit/widget tests around controller grouping sync behavior in [C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart](C:/Users/artwh/Downloads/Illuminati/papertek/lib/ui/spreadsheet/spreadsheet_view_controller.dart).
- Regression test for preset serialization compatibility in [C:/Users/artwh/Downloads/Illuminati/papertek/lib/repositories/spreadsheet_view_preset_repository.dart](C:/Users/artwh/Downloads/Illuminati/papertek/lib/repositories/spreadsheet_view_preset_repository.dart).

## Handoff Notes for Execution Agent
- Do not implement custom grouped header rows; use Syncfusion grouping APIs only.
- Keep grouping logic centralized in controller/data-source sync points to avoid divergent state.
- Preserve existing sort UX and preset behavior; this feature should be additive and low-risk.

```mermaid
flowchart LR
uiToggle[GroupBySort1Checkbox] --> controllerState[groupBySort1State]
sortState[Sort1Selection] --> groupingSync[applyGroupingSync]
controllerState --> groupingSync
groupingSync --> clearGroups[clearColumnGroups]
groupingSync --> addGroup[addColumnGroup Sort1]
addGroup --> sfGrid[SfDataGridNativeGrouping]
clearGroups --> sfGrid
```
