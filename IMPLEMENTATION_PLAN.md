# PaperTek — Implementation Plan

This plan aligns with [SPEC.md](SPEC.md) (local schema, revision rules, file format). Each step ends with a **"Verify"** block — what you should be able to do in the running app (or in a test harness) to confirm the step worked before moving on. Steps within a phase are sequential. Phases are sequential.

## Definition of Done for Each Step

- The listed **Verify** action passes in a human-testable way (app UI, DB Browser/SQLite shell, generated file, or two-account Supabase check as applicable).
- New behavior has at least one focused automated test when it touches repositories, migrations, revision logic, imports, or reports.
- UI code does not call Drift mutations directly; persisted writes go through repositories.
- If a step reveals that a dependency cannot meet the bar (grid, report engine, RLS shape), stop and decide before building more on top of it.

---

## Phase 0: Project Scaffold

### Step 0.1 — Flutter project + dependencies

- `flutter create` with desktop (Windows, macOS, Linux) and mobile (iOS, Android) targets.
- Add dependencies to `pubspec.yaml`: `drift`, `sqlite3_flutter_libs`, `riverpod` / `flutter_riverpod`, `syncfusion_flutter_datagrid`, `google_fonts`, `window_manager`, `path_provider`, `printing` (and whatever the Phase 7 report **spike** picks for HTML→print/PDF, e.g. `webview` / `webview_windows` or platform print — **do not** treat `pdf` as the only report stack; see Phase 7).
- Set up directory structure: `lib/database/`, `lib/repositories/`, `lib/services/`, `lib/features/`, `lib/providers/`, `lib/ui/`, `lib/ui/widgets/`, `test/`.
- Configure `window_manager` for desktop: minimum window size, title bar, dark chrome.
- Wire up a `ProviderScope` at root, bare `MaterialApp` with the dark theme from the UI mockup.

**Verify:** App launches on Windows. Dark window with the app title "PaperTek". No crash. `flutter run -d windows` works clean.

### Step 0.2 — Architecture guardrails

- Establish the boundaries from [SPEC — Architecture Boundaries](SPEC.md#architecture-boundaries):
  - Drift tables/migrations and raw SQL live in `lib/database/`.
  - Repositories own app-level writes and transactions (`TrackedWriteRepository`, fixture/template repository, import service, report query service, operational notes/maintenance repository).
  - Riverpod providers/controllers call repositories.
  - Widgets call providers/controllers and never call Drift mutations directly.
- Add a short `README.md` or `docs/ARCHITECTURE.md` with the rule: **no raw database writes from UI**.
- Create one placeholder repository test to make the test pattern obvious.

**Verify:** A new developer can identify where to put a table, a repository method, a provider, and a widget. A repository test runs with `dart test` even before full features exist.

---

## Phase 1: Local Database — Built Up In Layers

Each step adds one migration (one Drift schema version bump). This way if a migration breaks, you know exactly which table caused it.

### Step 1.1 — Drift setup + show_meta table (Migration 1)

- Create `database.dart` with the Drift `LazyDatabase` opener. File stored via `path_provider` as `<show_name>.papertek`.
- Define `show_meta` table per spec (show_name, company, org_id, producer, designer, designer_user_id, design_business, ME, ME_id, AME, AME_id, venue, opening_date, closing_date, mode, **cloud_id**, **schema_version**).
  - `cloud_id` is nullable TEXT — set when first linked to cloud, unused until Phase 8 but adding it now avoids a mid-flight migration.
  - `schema_version` is required and mirrors SQLite `PRAGMA user_version` / Drift `schemaVersion`; `user_version` is the authoritative migration gate.
- Add `users_local` table (user_id TEXT PK, display_name, avatar_url, last_seen).
- Write a Riverpod provider that creates/opens a database and exposes it.
- Seed one `show_meta` row on new-file creation (show_name and producer required).
- **Set up in-memory test database:** Create `test/database_test.dart`. Write a helper that opens a Drift database against an in-memory SQLite connection (use `NativeDatabase.memory()`). Add a smoke test that opens the DB, inserts a `show_meta` row, and reads it back. This test harness will be extended in every subsequent step.

**Verify:** Launch app. A `.papertek` file appears on disk. Open it in DB Browser for SQLite — `show_meta` table exists with correct columns including `cloud_id` and `schema_version`; SQLite `PRAGMA user_version` equals the app schema version. `users_local` table exists. `dart test` passes with the in-memory smoke test.

### Step 1.2 — Venue infrastructure tables (Migration 2)

- `lighting_positions` — name (UNIQUE), trim, from_plaster_line, from_center_line.
- `circuits` — name (UNIQUE), dimmer, capacity.
- `channels` — name (UNIQUE), **notes TEXT**.
- `addresses` — name (UNIQUE), type, channel (soft-link).
- `dimmers` — name (UNIQUE), address, pack, rack, location, capacity.

**Verify:** Open `.papertek` in DB Browser. All five tables exist with correct columns (including `channels.notes`). Manually insert a position row, a channel row, and an address row with that channel's name — confirm the patch-by-channel query (written as a raw Drift query or a Drift view) returns the expected join. Add a test to `database_test.dart` covering the patch query.

### Step 1.3 — Fixture core tables (Migration 3)

- `fixture_types` — name, **wattage TEXT**, part_count, default_parts_json.
- `fixtures` — fixture_type_id (FK), fixture_type (TEXT), position (NOT NULL), unit_number, **wattage TEXT**, **function TEXT**, **focus TEXT**, **flagged INTEGER NOT NULL DEFAULT 0**.
- `fixture_parts` — fixture_id (FK), part_order, part_type (TEXT with CHECK constraint against part_types enum), part_name, channel, address, ip_address, mac_address, subnet, ipv6, extras_json. UNIQUE(fixture_id, part_order).
- `part_types` CHECK constraint values: intensity, gel, x, y, x_high, x_low, y_high, y_low, gobo, gobo_feature, color_feature.
- Add table-level helpers/queries needed by later repositories. Avoid app-level fixture CRUD outside repositories; revision-aware create/update/delete comes in Step 1.7.

**Verify:** In `database_test.dart`: insert fixture type rows and fixture/part rows via low-level test helpers. Confirm `fixture_parts` relationships, copied `fixtures.wattage`, and CHECK failure for an invalid `part_type`. App-level fixture creation through templates is verified again in Step 1.7 / 4.2.

### Step 1.4 — Attachable tables (Migration 4)

- `gels` — color (NOT NULL), fixture_id (FK → fixtures.id), **fixture_part_id (INTEGER, nullable FK → fixture_parts.id)**, size, maker.
- `gobos` — gobo_number (NOT NULL), fixture_id (FK), **fixture_part_id (INTEGER, nullable FK → fixture_parts.id)**, size, maker.
- `accessories` — name (NOT NULL), fixture_id (FK).
- `work_notes` — body (NOT NULL), user_id (NOT NULL), timestamp (NOT NULL), fixture_id (nullable FK), position (TEXT soft-link).
- `maintenance_log` — fixture_id (FK, NOT NULL), description (NOT NULL), user_id (NOT NULL), timestamp (NOT NULL), resolved (INTEGER NOT NULL DEFAULT 0).

**Verify:** In `database_test.dart`: insert a fixture, attach 2 gels (one with fixture_part_id set, one without), 1 gobo, 3 accessories. Query back: fixture has 2 gels, 1 gobo, 3 accessories. Confirm repository validation rejects a gel/gobo whose `fixture_part_id` belongs to a different `fixture_id`. Delete the fixture — confirm CASCADE deletes children. Insert a work note linked to that fixture. Insert a maintenance log entry.

### Step 1.5 — Custom fields + reports meta (Migration 5)

- `custom_fields` — name, data_type, display_order.
- `custom_field_values` — fixture_id (FK), custom_field_id (FK), value.
- `reports` — template blob (columns, sort, filter, grouping, PDF layout JSON).

**Verify:** Create a custom field "Color Temp" (type: text). Assign value "3200K" to a fixture. Query it back. Confirm the reports table exists (no data yet — just structural).

### Step 1.6 — Revision + commit tables (Migration 6)

Per [SPEC — Revision-system tables and Revision operations](SPEC.md): `revisions` includes **`operation`** (`update` | `insert` | `delete` | `import_batch`), **`batch_id`** (nullable TEXT, groups bulk actions), and nullable **`field_name`**, **`old_value`**, **`new_value`** with semantics by operation. **`old_value` / `new_value` are JSON text**; a real null field is stored as JSON `null`, while SQL NULL means "not applicable." **`target_id`** may use a sentinel for `import_batch` if documented. Add a **CHECK** or validate in the repository so each `operation` has a consistent set of field snapshots. `commits` unchanged: user_id, timestamp, notes.
- Tables only; Step 1.7 introduces the app-wide write path.

**Verify:** Tables exist in DB Browser. In `database_test.dart`: insert sample rows for an `update`, an `insert`, and a `delete` revision, including one `update` where old or new value is JSON `null`. Manually insert a commit, attach commit_id. Query pending `update` revisions. Optional: one `import_batch` row with `batch_id` shared with mock `insert` rows.

### Step 1.7 — Tracked write layer (revisions wired **early**; Phase 5 completes the UX)

Introduce a single **mutation API** (e.g. `ShowDataStore` / `TrackedWriteRepository`) used by *all* code that changes data. It must support **all** of:

- **Scope rule:** this repository is for revision-tracked design/show data only (see [SPEC — Revision scope](SPEC.md#revision-scope)). Operational logs (`work_notes`, `maintenance_log`) and operational flags use their own repositories and do not enter the supervisor queue by default.
- **`updateField` / `setField`** — field-level: read `oldValue`, `UPDATE` the live row, `INSERT` `revisions` with `operation = update`, `field_name` set, `status = 'pending'`.
- **`insertRow`** — create a row, then `INSERT` with `operation = insert`, `new_value` = JSON snapshot (fixture + created parts as designed), `old_value` NULL, `field_name` NULL.
- **`deleteRow`** — capture `old_value` JSON snapshot (for fixtures: [SPEC cascade policy](SPEC.md#cascade-deletes) — one revision for the fixture with summarized children, not necessarily one revision per part), `DELETE` with cascade, `INSERT` with `operation = delete`, `new_value` NULL.
- **Clone** — implement as one or more **`insertRow`** calls with the same pattern (optional provenance in snapshot later).

`beginImportBatch` / `endImportBatch` (or equivalent) return a shared **`batch_id`**: inside the batch, perform fixture creates in **one or a few transactions**; attach **`insert`** (and optional single **`import_batch`**) revisions sharing `batch_id` per [SPEC](SPEC.md#bulk-import-and-revisions). Large files may use a **background isolate** for parsing + DB work; document the choice.

- No business logic should call Drift for tracked entities **outside** this layer (except tests via the same API).
- `user_id` can be a hardcoded `"local-user"` until auth exists.
- **Not in this step yet:** yellow/red styling, review queue, supervisor commit, multi-user conflict UI, session undo (Phase 5).

**Verify:** In `database_test.dart`: (1) `updateField` on a `fixtures` design field or venue column — one `update` revision. (2) `insertRow` a fixture — one `insert` revision, snapshot in `new_value`. (3) `deleteRow` that fixture — one `delete` revision, `old_value` present. (4) Operational note insert does **not** create a supervisor revision. (5) Optional: mock `beginImportBatch` with two inserts sharing `batch_id` + one `import_batch` summary.

---

## Phase 2: Show Metadata UI

**Convention from here on:** any UI that saves revision-tracked show/design data uses the **tracked write layer** from Step 1.7 (not raw Drift). Operational features use named repositories too, but do not create supervisor revisions unless explicitly called out.

### Step 2.1 — New Show flow + schema version gate

- On app launch, show a start screen: "New Show" and "Open Show".
- "New Show" dialog: requires show_name and producer. Creates a new `.papertek` file. Sets SQLite `PRAGMA user_version` / Drift schemaVersion and mirrors it to `show_meta.schema_version`.
- "Open Show" file picker: opens an existing `.papertek` file. On open, read SQLite `user_version` **before** relying on app tables:
  - If older than current: run Drift forward migrations, update `user_version`, then mirror to `show_meta.schema_version`.
  - If newer than current: show blocking error dialog ("This file requires a newer version of PaperTek") and abort open. Never modify the file.
- Wire the database provider to the opened file. Only one show open at a time.

**Verify:** Launch app. Create new show "Hamlet". File appears on disk with `.papertek` extension. Close app. Relaunch. Open the file — show loads. Manually edit SQLite `user_version` in DB Browser / SQLite shell to a future value (e.g. 999). Try to open — app shows an error and does not open or modify the file.

### Step 2.2 — Show metadata editor (the "Show" tab — metadata section)

- Build the Show tab metadata section: form fields for every `show_meta` column.
- Two-way bind to the database: load on open, save on field blur or explicit save button.
- Designer / ME / AME user-ID fields are plain text for now (cloud user lookup comes later).

**Verify:** Open a show. Go to Show tab. Edit designer name, venue, dates. Close and reopen — values persist.

### Step 2.3 — CSV / Lightwright import

- "Import Fixtures from CSV" action (in File menu and on the Show tab's venue section).
- Step 1: User selects a CSV file. App reads headers and shows a column-mapping UI (PaperTek field → CSV column). Pre-populate common Lightwright column names automatically (Chan, Dimmer, Circuit, Position, Unit, Type, Color, Gobo, Function, Focus, Notes, Wattage).
- Step 2: User confirms mapping, optionally saves it as a named preset for future imports.
- Step 3: App imports rows. Each row creates a fixture (and expands parts from the mapped fixture_type, or creates a bare fixture if the type is unrecognized). Fields that have no mapping are ignored with a per-row warning. Venues records (positions, circuits) are auto-created from values found in the CSV if they don't already exist.
- Step 4: Show an import summary: X fixtures created, Y positions auto-created, Z rows skipped with warnings.
- **Revisions and performance (required):** use **`beginImportBatch` / `endImportBatch`** (or equivalent) from the tracked write layer (Step 1.7) per [SPEC — Bulk import and revisions](SPEC.md#bulk-import-and-revisions): assign one **`batch_id`**, run fixture creates in **one or a few large transactions**, optionally in a **background isolate** for large files so the UI does not freeze. Revisions: at minimum one **`import_batch`** summary row (JSON: source path, row counts, optional id list) plus one **`insert`** per created fixture (all sharing `batch_id`) unless the team chooses a leaner story and documents it. Avoid one scalar **`update` revision per cell** for imports. Document the chosen strategy in a code comment.
- "Pending" semantics: imported rows are subject to the same supervisor review model as hand edits, unless the product later adds a "bypass review for my own import" (not in v1).

**Verify:** Export a sample hookup from Lightwright (or create a CSV with ~50+ rows). Import; progress is acceptable; DB shows **one batch_id** and auditable `insert`/`import_batch` rows. Smaller import still correct. Import summary and preset persist.

---

## Phase 3: Venue Data UI (Show Tab — Venue Sub-section)

All venue mutating actions use the **tracked write layer** (Step 1.7) so renames and venue edits create revision rows like fixture edits.

### Step 3.1 — Positions editor

- A sub-section within the Show tab: list of lighting positions.
- Add / edit / delete positions. Inline editing in a simple data table.
- Position name uniqueness enforced (show error on duplicate).

**Verify:** Add "1st Electric", "2nd Electric", "Balcony Rail". Edit trim on "1st Electric". Delete "2nd Electric". Reopen — two positions remain with correct data.

### Step 3.2 — Circuits, channels, addresses, dimmers editors

- Same pattern as positions: one editable list per venue table, all within the Show tab venue sub-section.
- Addresses show a channel dropdown (populated from channels table) — demonstrates the soft-link.
- Dimmers show an address dropdown.
- Circuits show a dimmer dropdown.

**Verify:** Create 3 channels. Create 3 addresses, assign channels to 2 of them. View patch-by-channel — 2 channels show addresses, 1 shows unpatched. Patch-by-address — 2 addresses show channels, 1 shows unpatched.

### Step 3.3 — Venue export/import

- "Export venue data" button: writes a JSON blob to disk (positions, circuits, channels, addresses, dimmers).
- "Import venue data": reads the JSON, populates venue tables (available on Show tab and during new show creation).

**Verify:** Create show A with full venue setup. Export. Create show B. Import venue JSON into B. All positions, circuits, etc. appear in B.

---

## Phase 4: Fixture Grid — The Main Spreadsheet

### Step 4.0 — Fixture type (template) library **[DONE]**

- UI to create, edit, and delete `fixture_types` (name, wattage, part_count, `default_parts_json` editor or simplified part builder). Accessible from a logical place (e.g. Show tab section, or Spreadsheet **Types…** / settings).
- **On every form that saves a `fixture_type`:** show the spec’s required copy, e.g. *"Changes apply to new fixtures only. Existing instruments in this show are not updated when you save this template."* Optional: link to help explaining clone vs. batch edit in the grid.
- Saving a type does not touch `fixtures` rows; only new fixture creation paths read the template.

**Verify:** Edit a type’s part count. Existing fixtures in the show unchanged. Add a new fixture of that type — it uses the new part layout. The disclaimer is visible and readable without scrolling past it.

Grid work in this phase assumes **Add fixture**, **clone**, **delete**, and cell edits all use the **tracked write layer** with **`insert` / `update` / `delete`** revisions per [SPEC](SPEC.md#revision-operations). Tests in 4.2+ should assert representative revision rows for create, delete, clone, and field update.

### Step 4.1 — Syncfusion DataGrid evaluation + basic fixture list

- Wire Syncfusion DataGrid to a Drift query that joins fixtures → fixture_parts (part_order = 0 for the primary/intensity part) → position name.
- Display columns: channel, dimmer, circuit, position, unit #, instrument type, wattage, color (from gels), gobo (from gobos), function, focus, flagged, notes.
- Read-only for now. Populate with seed data from the UI mockup's sample instruments.
- **Evaluate at this step:** (a) expandable child rows for multi-part fixtures — can Syncfusion DataGrid show parent rows with independently-editable child rows? (b) inline cell editing feel, (c) column resizing, (d) horizontal + vertical virtualization for 5000+ rows. If any of these fail to meet expectations, swap to PlutoGrid or custom widget **now**, before building editing on top of it.

**Verify:** Launch app. The spreadsheet shows fixture rows with correct data in all columns including wattage, function, focus, flagged. Horizontal scroll works. Columns resize. Sorting by column header works. Multi-part fixture expandability is confirmed or an alternative grid strategy is chosen. **This is the grid evaluation gate — no further grid work until this is settled.**

### Step 4.2 — Fixture CRUD in the grid

- Add Fixture button: opens a dialog, picks fixture type (from fixture_types), picks position (from lighting_positions), sets unit number. Creates fixture + parts from template. `wattage` copied from fixture_type — emits **`insert`** revision(s) per [SPEC](SPEC.md#revision-operations).
- Clone Fixture: duplicates the selected fixture and its parts/gels/gobos/accessories — treat as **insert** snapshot(s) for the new copy.
- Delete Fixture: removes fixture and cascading children — one **`delete`** revision with snapshot per cascade policy, not a fake field update. **Delete button in both sidebar and right-click context menu on a grid row.**
- Inline cell editing: double-click a cell, edit, blur to save. Every save: **`update`** revision rows via the **tracked write layer** (Step 1.7).

**Verify:** Add, clone, delete (from sidebar and right-click), and edit. In DB Browser: at least one row each with `operation` = `insert`, `update`, and `delete` (clone = `insert`). Data persists after restart.

### Step 4.3 — Gels, gobos, accessories in the sidebar **[DONE]**

- Sidebar properties panel (from UI mockup) shows selected fixture's details.
- Gel sub-section: add/remove gels. Shows color, size, maker. For single-part fixtures, gel links to fixture only. For multi-part fixtures, allow selecting which part the gel belongs to (sets `fixture_part_id`).
- Gobo sub-section: add/remove gobos. Same per-part logic as gels.
- Accessories sub-section: add/remove accessories.
- Grid columns for color and gobo pull from the first gel/gobo attached to the fixture (display logic — multiple gels show as comma-separated or "R02 +2").

**Verify:** Select a fixture. Add gel "R02", gel "L201". Sidebar shows both. Grid color column shows "R02, L201". Remove one. Add a gobo "R77735". Add accessory "Top Hat". All persist across restart. For a 3-cell cyc, add a gel to cell 2 specifically — confirm `fixture_part_id` is set on that gel row.

### Step 4.4 — Multi-part fixture display

- Fixtures with part_count > 1 render as expandable rows in the grid: parent row (fixture info) + child rows (one per part, showing channel, address, etc.).
- Flat mode toggle: expands all multi-part fixtures to one row per part.
- Create a 3-cell cyc fixture type to test with.

**Verify:** Add a 3-cell cyc fixture. Grid shows it collapsed (1 row). Expand — 3 child rows appear with independent channel/address fields. Toggle flat mode — all multi-part fixtures expand inline.

### Step 4.5 — Toolbar: search, sort, filter

- Search box: filters grid rows as you type (matches across all visible columns).
- Sort: click column header to sort asc/desc.
- Filter: filter chips per column (e.g. filter by position = "1st Electric").

**Verify:** With 20+ fixtures loaded, search for "VL3500" — only matching rows show. Filter by position — chip appears, grid filters. Clear filter — all rows return. Sort by channel — rows reorder.

---

## Phase 5: Revision Engine (complete the **experience**; tracking already in Step 1.7)

**Prerequisite:** All revision-tracked mutation paths (Phases 2–4) already use the tracked write layer, so this phase adds **UI and workflow**, not a rewrite of data access.

### Step 5.1 — Grid and session integration for revisions

- **Yellow / red row highlights** in the fixture grid: derive from `revisions` where `status = 'pending'` (and conflict rules in Step 5.5).
- Audit revision-tracked mutation paths (venue, fixture types, fixtures, parts, gels, gobos, accessories, custom field values, import) and fix any direct database writes. Operational notes/maintenance stay outside the supervisor queue by design.
- **Session undo stack (hook-up):** each tracked edit from Step 1.7 should optionally push a frame onto the in-memory stack consumed by Step 5.2 (or introduce the stack in 5.2 and backfill hook-up there—implementation choice, but avoid duplicate revision inserts).

**Verify:** Edit a fixture's channel. Row turns **yellow** (not just a DB row—visible in the grid). Open the `.papertek` file in DB Browser — revision rows match expectations. Edit a second field — still yellow, two pending revisions. Add a work note — no yellow fixture row and no supervisor revision. No direct DB writes for fixture edits in app code.

### Step 5.2 — Undo / Redo (session-local)

- Maintain an in-memory undo stack (up to 50 operations) and redo stack.
- Ctrl+Z: pop from undo stack and undo by `operation`: `update` restores `old_value`; `insert` removes created rows; `delete` restores from snapshot. Remove the pending `revisions` row and push to redo stack.
- Ctrl+Y / Ctrl+Shift+Z: pop from redo stack, re-apply the operation, re-insert the `revisions` row with the same operation semantics.
- Any new manual edit clears the redo stack.
- Stack is cleared on supervisor commit (committed = permanent).
- Users can only undo their own pending revisions. Attempting to undo past another user's revision is blocked with a message.

**Verify:** Edit fixture channel to "101". Undo — channel reverts, revision row gone. Redo — channel is "101" again, revision row re-created. Add fixture, undo — fixture disappears and insert revision gone. Delete fixture, undo — fixture restored from snapshot. Make 5 edits, undo all 5 — row returns to original state with no pending revisions.

### Step 5.3 — Revision history viewer

- Click a highlighted row to open a revision detail panel.
- Shows: committed state (values at last commit), list of pending revisions with user, timestamp, operation, and old → new (or JSON snapshot summary for insert/delete/import).
- Read-only view for now.

**Verify:** Make 3 edits to different fields on one fixture. Open the detail panel — all 3 revisions listed. Values match what you changed.

### Step 5.4 — Supervisor commit flow (approve vs reject per [SPEC — Rejection and history](SPEC.md#rejection-and-history))

- Commit button (supervisor action): opens the review queue. Completing a batch creates one `commits` row and then updates each included revision.
- Review queue shows all rows with pending revisions, grouped by fixture.
- **Approve** → set revision `status = "committed"`, `commit_id` = this batch. For **`update`**, live data match `new_value` (or supervisor in-place fix). For **`insert`** / **`delete`**, apply means the add or removal is accepted as the official story. For **batched** **import** rows sharing `batch_id`, approve the whole set consistently.
- **Reject** (by `operation`) per [Rejection and history](SPEC.md#rejection-and-history): **`update`** — restore field from `old_value`; **`insert`** — remove added rows; **`delete`** — re-insert from `old_value` snapshot. Always **UPDATE** the `revisions` row to `rejected` + `commit_id` — **never DELETE** the revision. **import_batch** / many **`insert`**: rejecting may roll back the full batch; revision rows for that batch must still tell the *attempted* story. Same `commit_id` links the batch.
- After the batch, highlights for settled items clear. Undo stack is cleared.
- For conflict "pick a winner" (Step 5.5): the **losing** revision(s) are **`rejected`** with the same data-restore rules so history lists what was not chosen.

**Verify:** Reject: (1) a field **update** — value restored, revision row `rejected`; (2) a pending **insert** — row removed, insert revision `rejected` if the product includes single-fixture review. DB Browser shows `commit_id` on all. Batch import reject covered per chosen batch policy. Approved rows: `status = committed`.

### Step 5.5 — Multi-user conflict detection (simulated)

- Allow setting the active user_id (a dev-mode dropdown, or a settings field).
- Switch to "User B", edit the same field that "User A" edited (both pending). Row turns red.
- Supervisor commit view shows conflicting revisions side by side, lets supervisor pick winner.

**Verify:** As User A, edit fixture channel to 101. Switch to User B, edit same fixture channel to 999. Row is red. Open review queue — conflict shown. Pick User A's value. Fixture channel = 101. User B’s revision is **`rejected`** (row retained with `new_value` = 999, `old_value` preserved, `commit_id` set) so history still tells the full story, not a silent delete.

---

## Phase 6: Work Notes + Maintenance UI

### Step 6.1 — Work Notes tab

- List of all work notes, sorted by timestamp descending.
- Add note: text field + timestamp auto-filled, optional fixture/position link via search.
- Edit / delete own notes.
- Filter by fixture or position (click a fixture in the grid → "View Notes" takes you here filtered).

**Verify:** Add 3 notes; one linked to a fixture, one linked to a position, one free-standing. All appear in the list. Filter by the fixture — only the linked note shows. Delete one. Persist across restart.

### Step 6.0 — Flagging from the grid

- Right-click (or toolbar action) on a fixture row: "Flag for Attention" — sets `fixtures.flagged = 1`, highlights row. "Log Maintenance" — opens a quick-entry dialog to add a `maintenance_log` row.
- Flagged rows show a visual indicator in the grid (e.g. a small icon or row tint).
- Clearing a flag from the Maintenance tab (marking the maintenance log resolved) updates `fixtures.flagged = 0`.
- These actions use an **operational maintenance repository**, not the supervisor-tracked revision queue (see [SPEC — Revision scope](SPEC.md#revision-scope)).

**Verify:** Flag a fixture from the grid. Row shows indicator. Go to Maintenance tab — fixture appears in unresolved list. Resolve it from Maintenance tab. Return to grid — flag indicator is gone. DB Browser shows maintenance rows / flag changes, but no supervisor `revisions` rows for operational-only actions.

### Step 6.2 — Maintenance tab

- Unresolved items list: all fixtures where `flagged = 1`, plus all `maintenance_log` rows where `resolved = 0`.
- Per-fixture history: tap a fixture to see all its maintenance log entries.
- Resolve action: marks `maintenance_log.resolved = 1`, clears `fixtures.flagged`.
- Log new issue: creates a `maintenance_log` row (and optionally sets `fixtures.flagged = 1`).

**Verify:** Flag two fixtures. Both appear in Maintenance tab unresolved list. Resolve one — disappears from the list, `flagged` clears in the grid. Add a maintenance note to the other — appears in its history. Persist across restart.

---

## Phase 7: Reports (Lightwright-level bar; layout-first, not imperative `pdf` only)

Align with [Reports in SPEC](SPEC.md#reports): one **spike** before the "real" hookup ships; prove grouping, page breaks, and print-quality typography.

### Step 7.0 — Technology spike (lock the stack)

- **Goal:** Choose the HTML→PDF / print pipeline for desktop (and note constraints for future mobile), e.g. WebView + print, embed Chromium, or another engine—decision recorded in a short `docs/` note or a comment in `pubspec.yaml` + one prototype screen.
- **Out of scope for the spike:** Every built-in report; only prove **one** non-trivial layout (a multi-page table with a repeated header, one group key such as "position" with a group header and acceptable breaks).
- Explicitly **reject** relying solely on the Dart `pdf` package for full Lightwright-style hookup sheets *unless* the spike proves it can be maintained; otherwise reserve `pdf` for tiny outputs only.

**Verify:** Running the spike app/screen: generates a **preview** the team is willing to call "on the path to pro paper." Document the chosen approach and any platform follow-ups (Windows first).

### Step 7.1 — Channel hookup (first production template)

- Data: full channel hookup query from local SQLite (channel, dimmer, circuit, position, unit, type, wattage, color, gobo, function, focus, notes — as in spec and grid).
- **Render** using the Step 7.0 stack: HTML+CSS (print styles), or the chosen engine; include header/footer with `{page}` / `{total}` or equivalent, sensible margins, fonts.
- In-app **preview** and **Save PDF** + **Print** (via `printing` or platform dialog).
- If something is infeasible in v1 (e.g. a perfect "keep this row with next group title"), document as a follow-up; do not ship a visibly broken hookup for production use.

**Verify:** With 20+ fixtures in varied positions, PDF looks **professional** at a zoomed print size (readability, alignment, no clipped text). Grouping/headers behave as designed. Stakeholder pass: "acceptable next to a Lightwright export" as the qualitative bar (not pixel-identical).

### Step 7.2 — Additional built-in reports + custom template storage

- Instrument schedule, dimmer schedule — same **rendering pipeline** as 7.1, not a second ad-hoc system.
- Custom report builder: column pick, sort, filter, grouping; persist to `reports` table as JSON compatible with the chosen template engine.
- Header/footer editor connects to the same token and layout system as built-ins.

**Verify:** Create a custom report (position, channel, color, grouped by position). PDF matches the builder. Save template, restart app, reload — same output. All three built-ins (hookup, instrument, dimmer) work through the **same** code path as the spike.

---

## Phase 8: Polish

### Step 8.1 — Custom fields in the grid

- Settings UI to create/reorder custom fields.
- Custom field columns appear dynamically in the grid (after built-in columns).
- Editable inline like built-in fields. Revision-tracked.

**Verify:** Create custom field "Color Temp" (text). It appears as a new column. Edit a value. Yellow highlight. Commit. Persists.

### Step 8.2 — Soft-link validation + resolution panel

- Per-field validation mode setting (none / warn / strict).
- Warn mode: non-matching soft-links get an orange underline.
- Strict mode: field becomes a dropdown limited to venue records.
- Resolution panel (in Show tab): lists all mismatches, offers bulk-fix actions.

**Verify:** Set position validation to "warn". Type a nonexistent position on a fixture — orange underline. Switch to "strict" — only valid positions in dropdown. Import fixtures with bad positions. Resolution panel lists them.

### Step 8.3 — Rename propagation

- Rename a position in the Show tab venue section. Dialog: "Rename all fixtures referencing '1st Electric' to '1E'?" Yes → bulk update via revision system.

**Verify:** Rename "1st Electric" → "1E". All fixtures update. Revisions table has one row per affected fixture. Undo via reject in review queue.

### Step 8.4 — Keyboard shortcuts, theming, window polish

- Keyboard shortcuts: Ctrl+N (new), Ctrl+O (open), Ctrl+S (save/commit), Ctrl+Z (undo), Ctrl+Y (redo), arrow keys in grid, Enter to edit cell, Escape to cancel, Tab to next cell.
- Theme refinement: match the UI mockup colors, fonts (DM Sans, JetBrains Mono).
- Bottom nav bar, status bar per mockup.

**Verify:** Navigate the grid entirely by keyboard. Ctrl+N creates a new show. Ctrl+Z / Ctrl+Y work. Theme matches the mockup screenshot.

---

## Phase 9: Cloud — Supabase (separate from local app)

### Step 9.1 — Supabase project + auth tables

- Create Supabase project.
- Migration 1: `profiles` table (extends auth.users with display_name, avatar_url).
- Migration 2: `personal_workspaces` (user_id, storage_quota, created_at).
- Wire up Supabase Auth in the Flutter app: sign up, sign in, sign out. Store session.
- **No RLS yet.** Auth only.

**Verify:** Sign up in the app. Check Supabase dashboard — user exists. Sign out, sign in again. Profile row created.

### Step 9.2 — Org tables (no RLS yet)

- Migration 3: `organizations` (name, slug, billing refs).
- Migration 4: `organization_members` (user_id, org_id, role, invited_at, accepted_at).
- Migration 5: `organization_subscriptions` (org_id, plan, status, dates).
- Basic Flutter UI: create org, invite member (by email), accept invite.

**Verify:** Create an org. Invite a second account. Second account sees invite, accepts. Both are members in the dashboard. Subscription row exists (status: trialing or similar).

### Step 9.3 — Cloud show tables (no RLS yet)

- Migration 6: `cloud_shows` (org_id or personal_workspace_id, show_id UUID — sourced from `show_meta.cloud_id`, metadata JSON, latest_snapshot_path, revision_cursor, snapshot_cursor).
- Migration 7: `show_permissions` (org_id, show_id, user_id, can_read, can_edit, can_approve, can_manage).
- Migration 8: `cloud_revisions` (show_id, mirrored structure of local revisions + sync metadata).
- Migration 9: `cloud_commits` (show_id, mirrored structure of local commits).
- Migration 10: `snapshots` (show_id, storage_path, created_at, created_by, revision_cursor).

**Verify:** Manually insert a cloud_show row via Supabase dashboard (using a `cloud_id` UUID from a local show). Insert a show_permission row. Query — returns correctly. No RLS blocking anything yet (that's intentional — we test the schema in the open before locking it down).

### Step 9.4 — RLS policies (applied incrementally)

Apply RLS in small batches, testing after each:

- **Batch A:** `profiles` — users can read any profile, update only their own.
- **Batch B:** `personal_workspaces` — user can only see/edit their own.
- **Batch C:** `organizations` + `organization_members` — members can read their org, only owners/admins can update. Members can read member list.
- **Batch D:** `organization_subscriptions` — read by org members, write by org owners.
- **Batch E:** `cloud_shows` + `show_permissions` — gated by org membership + show permission rows.
- **Batch F:** `cloud_revisions` + `cloud_commits` + `snapshots` — gated by show access (can_read for viewing, can_edit for pushing revisions, can_approve for committing).

**Verify (after each batch):** Test with two users. User A should see their data. User B should NOT see User A's data. Try an unauthorized update — should fail. Use Supabase's SQL editor to run queries as each user role and confirm policies hold.

### Step 9.5 — Sync engine

- Background sync when the show is linked to cloud and the app is online (use a **configurable** interval; tune for reliability—exact timing is not a product guarantee in v1).
- Push: unsynced local revisions → `cloud_revisions`.
- Pull: remote revisions since last cursor → local SQLite. Apply to data tables, apply highlights.
- Committed state: remote commits apply locally, clear highlights.
- **Snapshot upload (with optimistic locking):** Before uploading, send the local `revision_cursor` to the server. Server accepts the snapshot only if `cloud_shows.revision_cursor` matches — meaning no other client uploaded a newer snapshot in the interim. On mismatch, client re-syncs (pulls latest revisions) and retries.
- Snapshot download for new user joining a show: download latest snapshot, then pull incremental revisions from `snapshots.revision_cursor` to present.
- Optional: lightweight nudge to sync (Realtime or periodic poll) — not required for correctness. **No** presence cursors or "who is editing which cell" in v1.

**Verify:** Open the same show on two devices (or two instances with different user accounts). Edit a fixture on device A; after sync runs, device B shows the change with the expected **pending** highlight. Commit on device A; device B eventually reflects **committed** and highlights clear. Test snapshot conflict: two clients race — second upload rejected per optimistic locking rules.

---

## Phase 10: Social stubs

### Step 10.1 — Social table migrations (no UI)

- `conversations`, `messages`, `user_connections` tables in Supabase.
- RLS: messages visible to conversation participants, connections visible to involved users.

**Verify:** Tables exist. RLS blocks cross-user reads. No UI — this is just schema prep.

---

## Phase 11: Mobile

Deferred — separate planning phase once desktop is solid.
