# T11 — Verify the spreadsheet sort contract before changing behavior

## Objective

The grid appears to sort, while analyzer reports that `handleSort()` does not
override a current Syncfusion method. Establish which code path actually runs.
Do not change visible sorting behavior without a failing test and root cause.

## Investigation order

1. Read the installed `syncfusion_flutter_datagrid` version's `DataGridSource`
   API and changelog locally.
2. Trace header-sort gestures and the three-level toolbar sort into
   `FixtureDataSource`.
3. Write tests before modifying production code.

## Required tests

- clicking a sortable header changes row order ascending then descending;
- natural numeric order (`1`, `2`, `10`) is preserved;
- multipart header/parts remain adjacent in both display modes;
- three-level toolbar sorting applies primary/secondary/tertiary precedence;
- no-value edge ordering and descending direction match existing unit tests;
- filtering/grouping followed by sort produces stable row order;
- editing after sort updates the correct fixture/part, not the pre-sort index.

Prefer a widget/integration-level test around `SfDataGrid`; comparator-only tests
are insufficient.

## Production change rule

- If all behavior tests pass, remove only the invalid `@override`/dead hook or
  adapt it without changing observed behavior.
- If tests expose a real defect, make the smallest API-correct fix and document
  the before/after behavior.
- Do not upgrade Syncfusion in this ticket.

Run analyzer and the focused sort suite; report exactly which callback is used.

