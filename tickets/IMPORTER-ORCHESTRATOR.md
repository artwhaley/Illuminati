# Orchestrator: PaperTek Importer Rework

## Project overview
Flutter/Dart project at `papertek/` within `c:\Users\artwh\Downloads\Illuminati\`.
Full design rationale: `importer rework plan.md` at the project root. Read this first.

You are executing a planned rework of the fixture import system in seven sequential tickets.
Each ticket has verifiable acceptance criteria. You must not proceed to the next ticket until all ACs pass.

---

## Permitted file scope

You and every subagent you spawn MUST only touch files in this list. Do not edit anything else.

**Modify:**
- `papertek/lib/ui/spreadsheet/column_spec.dart`
- `papertek/lib/services/import/import_service.dart`
- `papertek/lib/ui/import/column_mapping_screen.dart`
- `papertek/lib/ui/main_shell.dart` (the import method and its imports only)

**Create:**
- `papertek/lib/services/import/row_reader.dart`
- `papertek/lib/services/import/delimited_row_reader.dart`
- `papertek/lib/services/import/row_matcher.dart`
- `papertek/lib/ui/import/multipart_detection_screen.dart`

**Delete (ticket 07 only):**
- `papertek/lib/services/import/csv_import_parser.dart`
- `papertek/lib/services/import/lightwright_column_detector.dart`
- `papertek/lib/services/import/csv_field_definitions.dart`

If at any point you find yourself reading or editing a file not on this list, stop and reconsider.

---

## Initial context load

Before starting Ticket 01, read these files in full:
1. `importer rework plan.md` (root) — design rationale
2. `papertek/lib/ui/spreadsheet/column_spec.dart` — the ColumnSpec schema
3. `papertek/lib/services/import/import_service.dart` — current import pipeline
4. `papertek/lib/ui/import/column_mapping_screen.dart` — current mapping UI

Do not read anything else until a ticket specifically asks for it.

---

## Ticket execution protocol

Work through tickets in strict order: 01 → 02 → 03 → 04 → 05 → 06 → 07.

For each ticket:
1. Read `tickets/IMPORTER-TICKET-0N-*.md`
2. Load additional context files listed in the ticket
3. Decide: implement directly OR delegate to subagent (each ticket specifies which)
4. Run every AC check listed in the ticket using Bash (from the `papertek/` directory)
5. If all ACs pass: record completion, move to next ticket
6. If an AC fails: attempt exactly one fix, re-run the failing AC
7. If still failing after one fix: STOP — see Blocked Protocol below

---

## AC verification

All `flutter analyze` runs must be from the `papertek/` directory.
Zero errors required to pass. Warnings are acceptable.
Grep AC checks must return the expected output — empty string for "empty", matching line for "matches".

When delegating to a subagent: YOU run the AC checks after the subagent returns. Do not accept the subagent's self-report as sufficient.

---

## Subagent delegation

Each ticket includes a ready-to-use SUBAGENT PROMPT section. When delegating:
1. Copy the subagent prompt from the ticket verbatim
2. Spawn with `subagent_type: "sonnet"` or `"haiku"` as specified in the ticket
3. The prompt is self-contained — the subagent has no conversation history
4. After the subagent returns, run the AC checks yourself

If a subagent's output causes new `flutter analyze` errors that are outside the permitted file scope, that is a bug in the subagent's work. Fix it within scope, do not follow the subagent into unrelated files.

---

## Blocked protocol

If blocked (AC still failing after one fix attempt, or you encounter an architectural ambiguity):
- Do not guess at solutions that change the design beyond what the ticket specifies
- Do not touch files outside the permitted scope as a workaround
- STOP and output this exact format:

```
BLOCKED: Ticket [N]
Attempted: [what you tried]
Error: [exact error message or failing AC output]
Need: [specific question or decision needed from user]
```

---

## Task tracking

Use TodoWrite to track ticket status throughout. Create todos at the start:
- [ ] Ticket 01: ColumnSpec aliases
- [ ] Ticket 02: RowReader + DelimitedRowReader
- [ ] Ticket 03: RowMatcher
- [ ] Ticket 04: ImportService refactor
- [ ] Ticket 05: ColumnMappingScreen
- [ ] Ticket 06: MultipartDetectionScreen
- [ ] Ticket 07: Wiring and cleanup

Mark each complete immediately when all ACs pass.

---

## Final report

After Ticket 07 AC passes, output a report in this exact format:

```
# Importer Rework — Completion Report

## Ticket status
- Ticket 01: [Complete / Deviation: description]
- ...

## Files created
- [list]

## Files modified
- [list]

## Files deleted
- [list]

## flutter analyze output
[paste full output]

## Deviations from plan
[list any, or "None"]

## Warnings remaining
[list any flutter analyze warnings, or "None"]
```
