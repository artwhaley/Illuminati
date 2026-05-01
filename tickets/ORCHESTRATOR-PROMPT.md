# Orchestrator Prompt — Nomenclature & Schema Refactor

You are executing a carefully planned refactor of a Flutter/Drift application (PaperTek, a lighting design tool). Read this prompt fully before touching any code.

---

## Your Role

You are the **orchestrating agent**. You execute tickets in order, make judgment calls, and delegate mechanical subtasks to Haiku subagents via the Agent tool with `subagent_type: general-purpose, model: haiku`. You do not skip steps, do not combine tickets unless explicitly marked safe to do, and do not make changes beyond the scope of each ticket.

---

## Start Here

Read these two documents before executing any ticket:

1. `REFACTOR-NOMENCLATURE-PLAN.md` (project root) — the full plan overview with all field name changes, risks, and phase descriptions
2. `tickets/TICKET-01-schema-migration-v22.md` through `tickets/TICKET-15-importer-updates.md` — the complete ticket set

Then execute tickets in order: 01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 11 → 12 → 13 → 14 → 15.

---

## Delegation Rules

Each ticket is marked with an **Executor** field:
- **Executor: Sonnet** — you handle this ticket yourself
- **Executor: Haiku** — delegate to a Haiku subagent via Agent tool

When delegating to Haiku:
- Give the subagent the ticket content verbatim plus the relevant file contents it needs to read
- Be explicit: tell it what file to edit, what exact substitutions to make, and that it should make NO other changes
- After the subagent returns, verify its work by reading the changed file yourself before proceeding
- If the subagent's output is wrong, fix it yourself rather than re-delegating

**Never run two subagents in parallel on the same file or on files with dependencies.** Parallel subagents are only safe when their target files are completely independent.

---

## After Each Ticket

Before moving to the next ticket:
1. Confirm the changed files compile (run `flutter analyze` or `dart run build_runner build` as appropriate)
2. Note any unexpected compile errors — they may indicate the ticket missed a reference
3. Check the ticket's **Verify** section and confirm those conditions are met

After TICKET-04, run `dart run build_runner build` to regenerate Drift code. The resulting compile errors are your checklist — every file that fails is a reference site that a later ticket must fix.

---

## Critical Risks — Read Before Starting

These items will cause subtle bugs if missed:

1. **FTS5 triggers** (TICKET-01): The migration must drop ALL three triggers (`fixtures_after_insert`, `fixtures_after_update`, `fixture_parts_after_update`) and the `fixtures_fts` virtual table, then call `_createFts5Table()` to recreate them with `purpose`/`area` column names. If this is incomplete, search will silently break.

2. **`cloneFixture` and `addFixtureFromDraft`** (TICKET-06): These methods build `FixturesCompanion` and `FixturePartsCompanion` with explicit field names. Drift regeneration will NOT catch these — they are not covered by type checking until the companion field names change. Read every `FixturesCompanion(...)` and `FixturePartsCompanion(...)` call in `fixture_repository.dart` manually.

3. **`FixtureDraft`** (TICKET-06): This class is used in `addFixtureFromDraft`. It likely has `function`, `focus`, and `wattage` fields. Update it in sync with the repository.

4. **Preset serialization** (TICKET-14): `SpreadsheetViewPresets` store column IDs as strings. Old presets with `'function'`, `'focus'`, `'type'`, `'patch'` will silently fail to load columns. Add the ID migration map before declaring the ticket done.

5. **Maintenance tab** (TICKET-13): The file has two tabs. The Edit Review tab must be completely untouched. Only remove code that references `flaggedFixturesProvider` and the flagged fixture display. Read the full file before making any edits.

6. **`isNumeric` on unit column** (TICKET-09): Unit number is now alphanumeric text. Remove `isNumeric: true` from the `unit` ColumnSpec. Any downstream code that uses this flag to determine input type must show a text keyboard, not a numeric one.

---

## Definition of Done

The refactor is complete when:
- `flutter analyze` returns zero errors on the `papertek/` directory
- The spreadsheet renders with columns: Dimmer, Address (both separate), Instrument, Unit, Purpose, Area
- Column headers show the new default names from the `field_names` table
- The maintenance tab shows Edit Review and Maintenance Log; no flagged fixture UI
- Importing a CSV with 'Function' and 'Focus' headers maps to the correct fields
- A fresh `.papertek` file opens on schema version 22 without migration errors
