# Fixture Parts Rework Plan

## Purpose

Unify fixture data modeling so that gels, gobos, and accessories are always
owned by a `fixture_part`, not by a fixture-level scalar field or by a
`fixture_parts` row whose `part_type` doubles as a tag. Spreadsheet/sidebar
edits go through a small collection editor; reports render the aggregated
display string read-only.

This document is implementation-ready and broken into execution tickets.

---

## Pre-flight assumption (locked)

**There is no production data to preserve.** The repo is in pre-release
development with placeholder data. The migration ladder is replaced with a
fresh schema; the user will create a new `.papertek` show file after the
rework lands. Do **not** write conditional `onUpgrade` blocks for this rework.
Update `onCreate` and bump `currentSchemaVersion` to a new baseline.

---

## Final Decisions (locked)

1. **Ownership model**
   - Gel, gobo, and accessory rows belong to a `fixture_part`.
   - `fixture_part_id` is required (NOT NULL) on all three tables.
   - `fixture_id` stays on all three tables (denormalized for query/filter
     convenience). Repository writes enforce
     `item.fixture_id == fixture_parts.fixture_id`.
   - FK action: `ON DELETE CASCADE` from `fixture_part_id`. (Deleting a part
     deletes its attachments. Deleting a fixture cascades through parts.)

2. **Fixture model**
   - Every fixture has at least one part (one `intensity` part is created with
     the fixture).
   - `fixtures.accessories` (TEXT column) is **removed**. Accessory data lives
     only in the `accessories` table.
   - `fixture_parts.part_type` CHECK constraint drops `'gel'` and `'gobo'`.
     Allowed values become:
     `'intensity', 'x', 'y', 'x_high', 'x_low', 'y_high', 'y_low',
      'gobo_feature', 'color_feature'`.
     (`*_feature` values represent mover-internal wheels — distinct from the
      show-applied gel/gobo collections introduced here.)

3. **Sort order within a collection**
   - Add `sort_order REAL NOT NULL DEFAULT 0` to `gels`, `gobos`,
     `accessories` (same float-midpoint pattern as `fixtures.sort_order`).
   - Display order: `(fixture_part.part_order asc, sort_order asc, id asc)`.

4. **UI behavior**
   - Spreadsheet/report cells show the compact display string by default,
     e.g. `R42 + R132`.
   - Editing a `color`/`gobo`/`accessories` cell opens a collection editor
     (popover or modal — see Ticket 4 blocker).
   - Sidebar uses the same component for the same fields.
   - Single-part fixtures: editor auto-targets that one part; no part selector
     shown.
   - Multi-part fixtures: aggregate-mode editor groups rows by part, with
     "add to part" pickers per section. Child-row edits scope to one part.

5. **Report behavior**
   - Report field catalog has a single `gobo` field (no `gobo1`/`gobo2`).
   - `color`, `gobo`, `accessories` render as concatenated display strings.
   - Empty collections render as the empty string (`""`), never `null` and
     never placeholder text.

6. **Display formatting**
   - Separator: `" + "` (space, plus, space).
   - The collection's primary string only — `gels.color`, `gobos.gobo_number`,
     `accessories.name`. `size` and `maker` columns stay in the schema unused
     for now; reserved for a future specialized-reports feature.

7. **Duplicates**
   - Allowed. Do not deduplicate automatically.

8. **Revision behavior**
   - Collection CRUD goes through `TrackedWriteRepository`.
   - The collection editor's "Apply" press wraps changes in a single
     `beginBatchFrame/endBatchFrame` (one undo step per editor session,
     matching the pattern already used by `addFixtureFromDraft`).
   - Add `gels`, `gobos`, `accessories` to `kRevisionTrackedTables` in
     `revision_sql_guard.dart`, and extend
     `TrackedWriteRepository._getUpdateSet` to handle them.

9. **Template compatibility**
   - Renderer-side translation only. On render, any `fieldKey` of `gobo1` or
     `gobo2` resolves to the new aggregated `gobo` field.
   - Saved template JSON is **not** rewritten on load.
   - Seeded defaults (`report_template_defaults.dart` and
     `kStackedColumns['stack_color_template']` in `report_field_registry.dart`)
     are updated to use `gobo`.

10. **Importer**
    - Out of scope for the core rework; covered by its own ticket
      (Ticket 7) so the user's planned importer rewrite has a clear contract
      to land against. Keep the LightWright detector recognizing `gobo`,
      `gobo1`, `gobo2` as source columns; route all of them into the single
      gobo collection on the fixture's primary part.

---

## Target Schema

### Tables added/changed

```
gels
  id              INTEGER PK AUTOINCREMENT
  fixture_id      INTEGER NOT NULL  REFERENCES fixtures(id)        ON DELETE CASCADE
  fixture_part_id INTEGER NOT NULL  REFERENCES fixture_parts(id)   ON DELETE CASCADE
  color           TEXT    NOT NULL
  size            TEXT    NULL                       -- reserved for future use
  maker           TEXT    NULL                       -- reserved for future use
  sort_order      REAL    NOT NULL DEFAULT 0

gobos
  id              INTEGER PK AUTOINCREMENT
  fixture_id      INTEGER NOT NULL  REFERENCES fixtures(id)        ON DELETE CASCADE
  fixture_part_id INTEGER NOT NULL  REFERENCES fixture_parts(id)   ON DELETE CASCADE
  gobo_number     TEXT    NOT NULL
  size            TEXT    NULL                       -- reserved
  maker           TEXT    NULL                       -- reserved
  sort_order      REAL    NOT NULL DEFAULT 0

accessories
  id              INTEGER PK AUTOINCREMENT
  fixture_id      INTEGER NOT NULL  REFERENCES fixtures(id)        ON DELETE CASCADE
  fixture_part_id INTEGER NOT NULL  REFERENCES fixture_parts(id)   ON DELETE CASCADE
  name            TEXT    NOT NULL
  sort_order      REAL    NOT NULL DEFAULT 0

fixtures
  -- DROP COLUMN: accessories  (TEXT — removed entirely)

fixture_parts
  -- CHECK constraint on part_type updated:
  --   ALLOWED: 'intensity','x','y','x_high','x_low','y_high','y_low',
  --            'gobo_feature','color_feature'
  --   REMOVED: 'gel','gobo'
```

### Indexes

```
CREATE INDEX idx_gels_part        ON gels(fixture_part_id);
CREATE INDEX idx_gels_fixture     ON gels(fixture_id);
CREATE INDEX idx_gobos_part       ON gobos(fixture_part_id);
CREATE INDEX idx_gobos_fixture    ON gobos(fixture_id);
CREATE INDEX idx_acc_part         ON accessories(fixture_part_id);
CREATE INDEX idx_acc_fixture      ON accessories(fixture_id);
```

---

## Application Architecture (post-rework)

### `FixtureRow` shape change

- Remove fields: `gobo1`, `gobo2`.
- Keep: `color`, `accessories` (now aggregated display strings, not raw scalars).
- Add: `gobo` (aggregated display string).
- Per-part display fields for child rows:
  `colorByPart`, `goboByPart`, `accessoriesByPart` keyed by `partId`.

### Read shaping (`FixtureRepository.watchRows`)

- Stop deriving color/gobo from `fixture_parts(part_type in ('gel','gobo'))`.
- Query `gels`, `gobos`, `accessories` joined to `fixture_parts`; aggregate
  per-fixture and per-part using the order rule in Decision 3.

### Mutation routing

- Remove `upsertGelColor`, `upsertGobo`, `updateAccessories` from
  `FixtureRepository`.
- Replace with collection APIs (Ticket 3).
- All writes through `TrackedWriteRepository` per Decision 8.

### Column registry (`column_spec.dart`)

- The `accessories` ColumnSpec stays (id `accessories`), but flips to a
  collection column (read = aggregated display string, edit = launch editor).
- Add `color` and `gobo` ColumnSpec entries — these are the canonical
  surfacings, replacing the `// TEMPORARY WORKAROUND` block in
  `report_field_registry.dart`.
- Remove the `gobo1` and `gobo2` workaround entries from
  `report_field_registry.dart`. After this, `kReportFields` is built purely
  from `kColumns` (the workaround block deletes; the `wattage` workaround
  also goes away if `wattage` is added to `kColumns`, but that's out of
  scope here — leave the `wattage` line if removing it would expand scope).

### Report registry

- Single `gobo` field. `color` and `accessories` already aggregate-shaped.
- Renderer translates legacy `gobo1`/`gobo2` field keys → `gobo` at render
  time (Decision 9).
- Seeded defaults updated.

---

## UX Spec: Collection Editor

Same component used by spreadsheet cell edits and sidebar field edits.

### Modes

1. **Part-scoped mode** (child row context, or single-part fixture)
   - One section, one target part. Add/edit/remove acts on that part.

2. **Aggregate mode** (parent row of a multi-part fixture)
   - Sections grouped by part (`Part 1`, `Part 2`, …).
   - Each section has its own "Add" affordance.
   - Reorder is within-part only in v1. Cross-part move is a delete + add.

### Display

- Non-edit string: `item1 + item2 + item3`.
- Empty collection → empty string.
- Order per Decision 3.

### Apply semantics

- All changes made between editor open and "Apply" land as one batch revision.
- "Cancel" discards all in-flight changes; nothing hits the DB or revisions.

---

## Risk List

1. **DataGrid editor lifecycle for popover.**
   Syncfusion DataGrid's cell-edit lifecycle handles inline editors well but
   has known focus-handoff issues with popovers. If the popover approach
   destabilizes keyboard nav (Tab/Enter/Esc), fall back to a modal dialog
   editor. See Ticket 4 blocker protocol.

2. **`fixture_part_id == fixture_parts.fixture_id` consistency.**
   Enforced in repository write path only. A `CHECK` constraint can't span
   tables, and a trigger adds DB-side complexity. Repository validation is
   the single point of truth; tests must cover it.

3. **`tracked_write_repository` allowlist drift.**
   `revision_sql_guard.kRevisionTrackedTables` is easy to forget. Ticket 1
   includes the update; Ticket 3's tests must include a tracked-write round
   trip per collection table to catch regressions.

4. **`FixtureRow` field removal ripples.**
   `gobo1`/`gobo2`/raw-text `accessories` consumers will break at compile
   time. Treat compile errors as a checklist, not a problem.

---

## Execution Tickets

Each ticket is self-contained. Tests are required. If a required test cannot
be made to pass, stop and ask the user with exact failure details and two
concrete options.

---

## TICKET 1 — Schema rewrite

### Goal
Land the new schema as the project's baseline. No upgrade path; new files only.

### Scope
- `database/tables/attachables.dart`
- `database/tables/fixtures.dart`
- `database/database.dart`
- `services/revision_sql_guard.dart`
- Generated `database.g.dart` (refresh via build_runner)

### Steps
1. Update `Gels`, `Gobos`, `Accessories` table classes:
   - `fixtureId` non-null (already non-null on Gels/Gobos).
   - `fixturePartId` non-null with `onDelete: KeyAction.cascade`.
   - Add `sortOrder` REAL non-null default 0.
   - For `Accessories`: add `fixturePartId`, `sortOrder`. Existing column is
     `name`.
   - For `Gels`: existing column is `color`. Keep `size`/`maker` nullable.
   - For `Gobos`: existing column is `goboNumber`. Keep `size`/`maker` nullable.
2. Update `Fixtures` table:
   - Remove `accessories` column.
3. Update `FixtureParts` CHECK constraint to drop `'gel'`, `'gobo'`.
4. Replace the `onUpgrade` ladder with a clean baseline:
   - Bump `currentSchemaVersion` to a new number (e.g. 21).
   - Collapse / drop the historical migration steps that no longer apply.
     A no-op `onUpgrade` is fine since old files are explicitly abandoned.
     Leave a comment block noting the rework cutover and that earlier
     `.papertek` files are not supported.
5. Add a comment to `FixtureTypes.defaultPartsJson` in `fixtures.dart` warning
   against embedding gel/gobo/accessory defaults there (those must stay in
   the collection tables).
6. Add the indexes listed in "Target Schema".
7. Update `revision_sql_guard.dart`:
   - Add `'gels'`, `'gobos'`, `'accessories'` to `kRevisionTrackedTables`.
8. Update `TrackedWriteRepository._getUpdateSet` to route updates for the
   three new tables.
9. Refresh generated Drift code (`dart run build_runner build`).

### Tests
- Schema test: open a fresh DB, assert tables/columns/indexes match.
- Constraint test: insert a `gels` row with mismatched
  `fixture_id`/`fixture_part_id` → repository validation rejects (added in
  Ticket 3). DB-level FK violation also tested (insert with bogus
  `fixture_part_id` fails).
- Cascade test: deleting a `fixture_part` removes its attachments; deleting a
  `fixtures` row cascades through parts to attachments.
- `fixture_parts` CHECK rejects `part_type='gel'` and `'gobo'`.

### Blocker protocol
None expected. If Drift code generation fights the schema (e.g. CHECK
constraint syntax), report the exact build_runner error and proposed fix.

---

## TICKET 2 — Repository read shaping

### Goal
Switch `FixtureRepository.watchRows` to read from the canonical attachable
tables.

### Scope
- `repositories/fixture_repository.dart`
  - `FixtureRow` (remove `gobo1`/`gobo2`, retype `color`/`accessories`,
    add `gobo`, add maps keyed by `partId`).
  - `FixturePartRow` (add `color`, `gobo`, `accessories` per-part strings).
  - `watchRows` (add the three table reads, build aggregations).

### Steps
1. Extend the `customSelect` `readsFrom:` set to include
   `_db.gels, _db.gobos, _db.accessories`.
2. After loading parts, load the three collections in one pass and bucket by
   `fixturePartId`.
3. For each fixture: aggregate per-part lists into the parent display strings
   using Decision 3 ordering and Decision 6 separator. Per-part maps populate
   `colorByPart`/`goboByPart`/`accessoriesByPart` (keyed by `partId`).
4. Drop the legacy logic that derived color/gobo from `fixture_parts.partName`.
5. Update `addFixtureFromDraft` (Ticket 3 will revise this) — for now, the
   draft fields `color`/`gobo1`/`gobo2` should not write `fixture_parts` rows
   anymore. Park draft writes behind a TODO until Ticket 3 rewires them.

### Tests
- Single-part fixture, one gel: row.color renders `"R02"`.
- Multi-part fixture, gels on part 0 and part 1: aggregated string is
  ordered by part_order then sort_order.
- Empty collection: row.color is `""` (not null).
- Per-part maps: child rows for part 1 read only part 1's items via `partId`.
- `gobo1`/`gobo2` no longer present (compile-time check).

### Blocker protocol
If a downstream UI reads `gobo1`/`gobo2` and removing them causes more than
sidebar/draft to break, list the call sites and ask the user before either
restoring temporary aliases or expanding scope.

---

## TICKET 3 — Collection CRUD repository API

### Goal
Replace ad-hoc upserts with explicit collection APIs.

### Scope
- `repositories/fixture_repository.dart` (new methods)
- `ui/spreadsheet/fixture_draft.dart` (remove `gobo1`/`gobo2`; keep single
  nullable `color`, `gobo`, and `accessories` strings for the "one-of-each"
  new fixture flow).
- `addFixtureFromDraft` rewire

### Steps
1. Add methods (mirror across the three collections):
   - `Future<List<Gel>> listGelsByPart(int partId)`
   - `Future<List<Gel>> listGelsByFixture(int fixtureId)`
   - `Future<int> addGel({required int partId, required String color, double? sortOrder})`
   - `Future<void> updateGel(int id, {String? color})`
   - `Future<void> deleteGel(int id)`
   - `Future<void> reorderGel(int id, double sortOrder)`
   - …and the same set for gobos (`goboNumber`) and accessories (`name`).
2. Each write resolves `fixture_id` from the part and validates the part
   exists (StateError on mismatch). All writes go through the appropriate
   `TrackedWriteRepository` helper (`insertRow` / `updateField` / `deleteRow`).
3. Add a public `runCollectionEdit(VoidCallback session)` helper that wraps
   a `beginBatchFrame('Edit collection')` / `endBatchFrame()` so the editor
   can submit one undo step per Apply (Decision 8).
4. Rewrite `addFixtureFromDraft`:
   - Insert fixture, insert intensity part.
   - For initial color/gobo/accessory lists in the draft, call the new add
     methods on the intensity part inside the existing batch frame.

### Tests
- CRUD per collection (round trip).
- Mismatch rejection: passing a `partId` whose `fixture_id` differs from the
  caller-provided `fixtureId` (when API surface includes both) throws.
- `runCollectionEdit` produces exactly one revision per session, with the
  correct number of child operations under the frame.
- Cascade: deleting a part removes its attachments; revision rows reflect
  the part-delete (not N attachment deletes).

### Blocker protocol
If batch-frame nesting interacts badly with existing tracked-write call
sites (e.g. a delete-part-then-undo replays a frame that no longer
references existing attachments), capture the exact revision sequence and
ask before changing batch-frame semantics.

---

## TICKET 4 — Spreadsheet column system

### Goal
Make `color`, `gobo`, `accessories` first-class collection columns.

### Scope
- `ui/spreadsheet/column_spec.dart`
- `ui/spreadsheet/fixture_data_source.dart` (cell edit dispatch)
- Whatever cell-editor wiring opens custom editors today

### Steps
1. Add `color` and `gobo` ColumnSpec entries:
   - `id`/`dbField`: `color` / `gobo` (no DB field — these are virtual; set
     `dbField: null`).
   - `getValue`: returns aggregated display string from `FixtureRow`.
   - New optional flag on `ColumnSpec`: `bool isCollection`. When true, the
     grid's edit handler launches the collection editor instead of the
     scalar text editor.
2. Convert the existing `accessories` ColumnSpec to `isCollection: true`.
   Drop its `dbField: 'accessories'` (the column no longer exists), set
   `dbField: null`.
3. Remove the `// TEMPORARY WORKAROUND` block in `report_field_registry.dart`
   for `color`, `gobo1`, `gobo2`. (Leave `wattage` alone — out of scope.)
4. Wire cell-edit dispatch: when `spec.isCollection`, open the editor
   (Ticket 5) targeting the right scope (parent → aggregate, child → part).

### Tests
- `kColumns` contains `color`, `gobo`, `accessories`, all `isCollection`.
- `gobo1`/`gobo2` are absent from `kReportFields`.
- Grid interaction test: clicking a collection cell opens the editor stub;
  clicking a non-collection cell opens the scalar editor.

### Blocker protocol
If Syncfusion's cell-edit lifecycle won't host a stable popover (focus
escape, premature commit, double-edit), fall back to a modal dialog. Report
which lifecycle hook fails and propose dialog as the v1 surface.

---

## TICKET 5 — Collection editor component

### Goal
A reusable widget that handles part-scoped and aggregate editing.

### Scope
- New widget under `ui/spreadsheet/widgets/` (or a new
  `ui/widgets/collection_editor/` if it grows).
- Sidebar wiring: replace the inline accessories TextField at
  `ui/spreadsheet/widgets/sidebar.dart:406-408` with a launcher that opens
  the editor in part-scoped mode (single-part fixture) or aggregate mode
  (multi-part).
- Same launcher used by the spreadsheet from Ticket 4.

### Steps
1. Build the widget:
   - Props: `fixtureId`, `kind` (gel/gobo/accessory), optional `partId` for
     part-scoped, list of parts for aggregate, repo handle.
   - Renders sectioned list (one section if part-scoped).
   - Add/edit/remove/reorder controls per row.
   - Apply / Cancel buttons.
2. On Apply: call `repo.runCollectionEdit(() async { ... })`, performing
   the diff between original snapshot and current state inside the batch
   frame.
3. Single-part fixtures auto-target the one part; aggregate UI is suppressed.
4. Keyboard: Enter commits a field edit, Esc cancels the active row,
   Cmd/Ctrl+Enter triggers Apply, Esc on the editor itself triggers Cancel.

### Tests
- Widget tests for add/edit/remove/reorder in part-scoped mode.
- Aggregate mode: add to part 1 from the parent row, verify only part 1
  receives the row.
- Apply produces one revision; Cancel produces zero.
- Cancel after edits: DB unchanged.

### Blocker protocol
If aggregate mode UX is unclear, ask user for one of:
- grouped inline list per part (current spec), or
- single-part-at-a-time with a part dropdown header.

---

## TICKET 6 — Reports field registry and template renderer

### Goal
Single `gobo` field, render-time legacy translation.

### Scope
- `features/reports/report_field_registry.dart`
- `features/reports/report_template_defaults.dart`
- `features/reports/template_renderer.dart`

### Steps
1. After Ticket 4, `kReportFields` now contains `color`, `gobo`, `accessories`
   (sourced from `kColumns`) and no `gobo1`/`gobo2`.
2. Update seeded defaults: `kStackedColumns['stack_color_template']` uses
   `['color', 'gobo']` instead of `['color', 'gobo1']`.
   Audit `report_template_defaults.dart` for any other `gobo1`/`gobo2`
   references and replace them.
3. Add a render-time translation in the template renderer's field-key
   resolution: `gobo1` and `gobo2` both resolve to the `gobo` field.
   Saved template JSON is not modified; the translation only happens at
   rendering / picker resolution.
4. If a template has both a `gobo1` column and a `gobo2` column (the
   stacked-column legacy case), each renders the same aggregated string.
   This is acceptable v1 behavior; document the duplication in the renderer
   so future cleanup can collapse it.

### Tests
- Registry: `gobo` present, `gobo1`/`gobo2` absent.
- Renderer: a saved template referencing `gobo1` produces the same output
  as one referencing `gobo`.
- Seeded defaults snapshot: `stack_color_template.fieldKeys == ['color','gobo']`.

### Blocker protocol
None expected.

---

## TICKET 7 — Importer compatibility (placeholder)

### Goal
Hold the line on imports until the importer rewrite. Existing CSV import
must produce data in the new shape, even if the broader importer redesign
is pending.

### Scope
- `services/import/import_service.dart`
- `services/import/lightwright_column_detector.dart`
- `services/import/csv_field_definitions.dart`

### Steps
1. `import_service.dart:244-250` (and surrounding color/gobo writes): stop
   inserting `fixture_parts(part_type='gel'|'gobo')` rows. Insert into
   `gels`/`gobos` tied to the new fixture's intensity part. Wrap per-fixture
   imports in a batch frame.
2. `lightwright_column_detector.dart`: still recognize `gobo`, `gobo1`,
   `gobo2` source columns. Keep `PaperTekImportField.gobo1`/`gobo2` as
   detector targets but route them through the same downstream "add gobo"
   call. Optionally add a `PaperTekImportField.gobo` target for files using
   a single column.
3. `csv_field_definitions.dart`: update labels/descriptions to reflect that
   gobo1/gobo2 are CSV column hints, not stored shape.
4. Accessories import: if any current path writes `fixtures.accessories`,
   rewrite it to add `accessories` rows on the intensity part. (Search for
   `accessories:` setters in `import_service.dart` before assuming there are
   none.)

### Tests
- CSV import fixture creates `gels`/`gobos`/`accessories` rows on the
  intensity part with the expected values.
- Importing a CSV with both `Gobo 1` and `Gobo 2` columns produces two
  `gobos` rows on the same part.
- Imported fixture's `FixtureRow.gobo` aggregates both values in detection
  order.

### Blocker protocol
If the importer's existing structure makes the rewrite invasive, draw the
line at "fixtures still create correctly with at least one part, and any
gel/gobo/accessory data lands in the new tables." Anything beyond that
defers to the upcoming importer rewrite.

---

## TICKET 8 — Cleanup and validation

### Goal
Remove dead code; verify the system end-to-end.

### Scope
- All call sites of removed APIs (`upsertGelColor`, `upsertGobo`,
  `updateAccessories`).
- `FixtureRow.gobo1` / `gobo2` consumers (compile-time hits).
- The `partType in ('gel','gobo')` reads anywhere in the codebase.
- Final manual sweep.

### Steps
1. Delete `upsertGelColor` and `upsertGobo` from `FixtureRepository`.
2. Delete `updateAccessories`. The sidebar text field is replaced in
   Ticket 5; the column edit handler is replaced in Ticket 4.
3. Search for `partType.equals('gel')` / `partType.equals('gobo')` —
   should be zero hits after Ticket 2/3. If any remain, they are bugs.
4. Search for `\.gobo1\b` / `\.gobo2\b` / `\.accessories =` raw-text
   writes — should be zero hits.
5. Run full test suite. Manual checklist:
   - Add fixture → set color/gobo/accessories on its part → spreadsheet,
     sidebar, and report all show consistent display strings.
   - Multi-part fixture (e.g. 4-cell cyc) with gels per part: aggregate
     parent-row string is ordered correctly; child rows are part-scoped.
   - Undo an Apply → all collection changes from that session revert as one
     step.
   - Delete a part → its attachments disappear; one revision recorded.
   - Delete a fixture → entire chain cascades; revision is the fixture
     soft-delete (existing behavior).
   - Open and render a saved template that uses `gobo1` → renders correctly
     via the legacy translator.

### Blocker protocol
If a manual case fails, report the exact reproducer with the failing
expectation and stop before any workaround merges.

## Implementation Decisions (Closed)
1. **Per-part identity** — Use `partId` for keying maps in `FixtureRow`. It is
   stable across reorders.
2. **`FixtureDraft` shape** — Keep it simple: single nullable `String?` for
   `color`, `gobo`, and `accessories`. This covers the 90% case for manual
   entry. Constructor should remain flexible/nullable.
3. **`defaultPartsJson`** — Added a warning to the table definition to ensure
   attachables are never embedded in the fixture-type template.
4. **FTS & Drift CHECK** — Confirmed; no blockers.
