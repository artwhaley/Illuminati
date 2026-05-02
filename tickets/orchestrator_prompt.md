# Orchestrator Prompt — Column Mapping Rework

You are a Flutter/Dart engineer implementing a well-scoped feature for a
production app. You have two tickets to execute in sequence. Both tickets
are fully specified — read them carefully before writing any code.

Ticket files are in this repo at:
- `tickets/T01_greedy_matcher.md`
- `tickets/T02_type_refactor_and_ui.md`

---

## YOUR MANDATE

Execute T01, verify it, then execute T02, verify it. That is the entire job.

You have permission to:
- Make the exact changes described in the tickets.
- Fix compile errors or test failures that result directly from your own
  changes, using the minimum edit required.
- Run `flutter analyze`, `flutter test`, and `flutter build windows` to
  verify your work.

You do not have permission to:
- Edit any file not listed in a ticket's SCOPE table.
- Refactor, rename, reformat, or "clean up" anything outside the changed lines.
- Add features, comments, or abstractions not required by the ticket spec.
- Change behavior in `multipart_detection_screen.dart` beyond the two lines
  called out in T02.
- Alter any database schema, repository, or provider.

If you notice something unrelated that looks wrong, leave it alone and note
it at the end of your final summary. Do not fix it.

---

## EXECUTION SEQUENCE

### Step 1 — Read both tickets in full before writing a single line of code.

Read `tickets/T01_greedy_matcher.md` and `tickets/T02_type_refactor_and_ui.md`
completely. Understand what T02 expects T01 to have produced before you start.

---

### Step 2 — Execute T01

Apply the changes described in T01 to:
- `papertek/lib/services/import/row_matcher.dart`

Create the test file:
- `papertek/test/import/row_matcher_test.dart`

Then run:
```
cd papertek && flutter test test/import/row_matcher_test.dart
```

**Go / no-go:** All 6 tests must pass. If any test fails:
1. Re-read the behavioral spec in T01 carefully.
2. Fix only `row_matcher.dart` (not the test file — the test file is the
   source of truth).
3. Re-run until all 6 pass.
4. If you cannot get all 6 passing after two fix attempts, stop and report
   exactly which test is failing and why.

Do not proceed to Step 3 until T01 tests are green.

---

### Step 3 — Execute T02

Apply the changes described in T02 to exactly these four files:
- `papertek/lib/services/import/import_service.dart`
- `papertek/lib/ui/import/column_mapping_screen.dart`
- `papertek/lib/ui/import/multipart_detection_screen.dart`
- `papertek/lib/ui/main_shell.dart`

Then run:
```
cd papertek && flutter analyze
```

**Go / no-go:** Zero errors. Warnings are acceptable.

If analyze reports errors:
1. Fix only the lines directly involved in the T02 changes.
2. Do not "fix" pre-existing warnings or unrelated code.
3. Re-run analyze after each fix.
4. If you cannot clear all errors after two fix attempts, stop and report
   the remaining errors verbatim.

---

### Step 4 — Final report

When both tickets are green, output a short summary:
- Which files were changed and what was done in each.
- Any fix attempts made during verification and what caused them.
- Any unrelated issues you noticed but intentionally left alone (one line each).
- Confirmation that `flutter analyze` is clean.

---

## CRITICAL REMINDERS

**The collection-field split in `_resolveValue` must be preserved.** After T02,
`_resolveValue` takes a single `String?` header, but for collection fields
(color, gobo, accessories) it must still split the cell value on `[+,/;]`
before storing. A cell like `"R80, L201"` must produce `"R80|L201"` in the DB.
If you lose that logic the import will silently corrupt color data.

**The `suggest()` method in `RowMatcher` must not change.** T01 adds
`greedyAssign()` alongside the existing `suggest()`. Both methods must exist
in the final file.

**Column IDs are correct as-is.** The IDs `instrument`, `purpose`, `area`,
and `address` all exist in `kColumns`. Do not second-guess them.
