# PaperTek — Architecture Spec

## What It Is

Theatrical lighting data manager (Lightwright competitor). Desktop-first, offline-first. Paid standalone app with no subscription required for individual use. Optional org-billed cloud subscription for collaboration and sync. Differentiator: git-lite revision tracking with supervisor approval workflow.

## Platforms

- **Desktop:** Windows, macOS, Linux — Flutter, spreadsheet-centric layout
- **Mobile:** Android, iOS — Flutter, card/list adaptive layout
- One codebase, adaptive UI per form factor.

## Stack

- **Flutter + Dart** — all platforms
- **Drift** (SQLite ORM) — local database, one `.papertek` file per show
- **Riverpod** — state management
- **Syncfusion DataGrid** — primary data table widget (free community license <$1M revenue)
- **Supabase** — auth, Postgres, Storage, Realtime
- **Reports / PDF** — see [Reports](#reports) below. Output must meet a **Lightwright-level bar** (professional typography, layout, headers/footers, grouping, intelligent page breaks). The implementation uses **HTML + CSS (print media)** rendered to PDF or platform print, or an equivalent templating + engine stack chosen during a design spike—**not** the imperative `pdf` package as the primary long-term path for full hookup sheets. The `printing` package remains for system print and preview where appropriate.
- **speech_to_text** — on-device dictation (future)

---

## Architecture Boundaries

PaperTek should stay modular enough that database, sync, reports, and UI can evolve independently. The app is organized around clear ownership boundaries:

- **Database layer** — Drift table definitions, migrations, generated companions, low-level queries, and schema tests. This layer knows SQLite, but it does **not** know widget state or supervisor workflow.
- **Repository / domain layer** — the only layer allowed to perform app-level writes. Includes `TrackedWriteRepository` (revision-aware design data), show file open/create services, fixture/template repositories, import services, report query services, and operational log repositories. This layer owns transactions and invariants.
- **State layer** — Riverpod providers/controllers expose view state and commands to UI. Providers call repositories; providers do **not** hand raw Drift objects to widgets for mutation.
- **UI layer** — Flutter widgets and grids. Widgets render state and call provider commands. They do **not** call Drift `insert`, `update`, or `delete` directly.
- **Integration services** — Supabase sync, report rendering, CSV import parsing, and file IO. These services are called by repositories/controllers, not directly from ad hoc widget code.

**Rule of thumb:** if a change affects persisted show data, it goes through a named repository method with a test. Direct SQL from UI is a bug.

---

## Local Data Model (SQLite — one file per show)

All tables below live in a single `.papertek` SQLite file. One file = one show.

### show_meta

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| show_name | TEXT NOT NULL | * Required |
| company | TEXT | |
| org_id | TEXT | Optional — links to cloud org if synced |
| producer | TEXT | * Required |
| designer | TEXT | |
| designer_user_id | TEXT | FK to local user cache / cloud user, nullable |
| design_business | TEXT | |
| master_electrician | TEXT | |
| master_electrician_user_id | TEXT | Nullable |
| asst_master_electrician | TEXT | |
| asst_master_electrician_user_id | TEXT | Nullable |
| venue | TEXT | |
| opening_date | TEXT | ISO 8601 date |
| closing_date | TEXT | ISO 8601 date |
| mode | TEXT | e.g. "tech", "previews", "performance" |
| cloud_id | TEXT | UUID, nullable — set when the show is first linked to cloud sync |
| schema_version | INTEGER NOT NULL | Human-readable mirror of SQLite `PRAGMA user_version` / Drift schemaVersion; used for display/debugging, while `user_version` is the authoritative migration gate |

`cloud_id` is generated on first cloud link and never changes. It is the stable identifier for the show in Supabase. Added in Migration 1 even though unused until Phase 8, to avoid a schema migration mid-flight.

User-ID fields resolve to real profiles when the app is online and the referenced user exists in the PaperTek user database. Offline, they display cached names from `users_local`.

---

### lighting_positions

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| name | TEXT NOT NULL UNIQUE | e.g. "1st Electric", "Balcony Rail" |
| trim | TEXT | Trim height — stored as string (e.g. "22'-6\"") |
| from_plaster_line | TEXT | Distance from PL |
| from_center_line | TEXT | Distance from CL |

Every fixture must reference a position. Positions live inside the show file and are managed from the **Show tab** (venue sub-section). See Venue Data below.

---

### circuits

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| name | TEXT NOT NULL UNIQUE | e.g. "2-015" |
| dimmer | TEXT | Soft-link to dimmers.name — optional hard-wire mapping |
| capacity | TEXT | e.g. "2.4kW" |

Circuits are venue infrastructure — the permanent wiring endpoint at a position. Optional table; shows without circuit infrastructure skip this.

---

### addresses

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| name | TEXT NOT NULL UNIQUE | e.g. "1/001", "U2.101" — the DMX address label |
| type | TEXT | e.g. "DMX", "sACN", "Art-Net" |
| channel | TEXT | Soft-link to channels.name — system-level patch (see Patch Authority below) |

An address is a protocol-level control point (a DMX slot, an sACN universe/address, etc).

---

### channels

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| name | TEXT NOT NULL UNIQUE | The channel label as the designer sees it — e.g. "101", "A5" |
| notes | TEXT | Optional designer note on this channel |

Channels are the designer's logical control handles. A channel can drive many addresses (one-to-many via `addresses.channel` soft-link). The two patch views below expose the relationship from both directions.

**Patch views (virtual — rendered as queries, not stored tables):**

- **patch_by_channel** — LEFT JOIN channels → addresses ON addresses.channel = channels.name. Shows every channel with its assigned address(es). Channels with no address appear as unpatched.
- **patch_by_address** — LEFT JOIN addresses → channels ON addresses.channel = channels.name. Shows every address with its assigned channel. Addresses with no channel appear as unpatched.

These are read-only convenience views for the Patch tab UI. Edits go through the `addresses` table (set/clear the `channel` column).

### Patch Authority

The channel and address assignments on a fixture appear in two places:

1. **`fixture_parts.channel` / `fixture_parts.address`** — per-instrument patch. The authoritative record for what a specific physical instrument is connected to. This is what drives the hookup sheet and per-fixture display.
2. **`addresses.channel`** — system-level patch. Describes what the address space looks like in aggregate, independent of which instrument is plugged in. Used for the Patch tab views.

These two can legitimately diverge (e.g., an address is assigned to a channel in the system patch but no instrument is currently connected to it). This is intentional — they represent different perspectives on the same physical system. Validation can optionally warn when they conflict.

---

### dimmers

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| address | TEXT | Soft-link to addresses.name — the address this dimmer responds to |
| name | TEXT NOT NULL UNIQUE | e.g. "2-15", "D42" |
| pack | TEXT | Portable dimmer pack identifier |
| rack | TEXT | Fixed rack identifier |
| location | TEXT | Physical location description |
| capacity | TEXT | e.g. "2.4kW", "1.2kW" |

Dimmers sit between addresses and circuits in the signal chain. A dimmer receives a control address and feeds power to a circuit. Optional table — LED-only shows or shows without dimmable infrastructure may skip this.

---

### fixture_types (templates)

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| name | TEXT NOT NULL | e.g. "Source Four 36°", "VL3500 Spot" |
| wattage | TEXT | e.g. "575W", "750W", "LED" — lamp type / power draw |
| part_count | INTEGER DEFAULT 1 | How many parts this type produces |
| default_parts_json | TEXT | JSON array defining default part layout — part type, ordering, default parameter roles. Expanded into `fixture_parts` rows when a fixture of this type is created. Users can override per-instance. |

`wattage` is a type-level attribute — all instances of "Source Four 36°" share the same wattage. It is denormalized onto `fixtures.wattage` at creation time to allow per-instance overrides (e.g. a retrofit lamp).

#### Fixture type (template) editor — user-facing copy

Editing a row in `fixture_types` (name, wattage, `default_parts_json`, part count) defines how **new** instruments are **spawned** when a user adds a fixture of that type. It does **not** retroactively change fixtures already in the show document. The template editor (wherever it lives in the app — e.g. Show tab, or a "Fixture types" dialog) **must** show short, visible copy on the form, for example: **"Changes here apply to new fixtures only. Existing instruments in this show are not updated."** A separate, explicit future action (e.g. "Apply this template to selected fixtures") would be a distinct workflow with its own confirmation, not a side effect of saving a template.

---

### fixtures

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto — the universal FK target for gels, gobos, accessories, parts |
| fixture_type_id | INTEGER | FK → fixture_types.id |
| fixture_type | TEXT | Denormalized type name for display / offline resilience |
| position | TEXT NOT NULL | Soft-link to lighting_positions.name |
| unit_number | INTEGER | Unit number within the position |
| wattage | TEXT | Denormalized from fixture_type at creation; overridable per-instance |
| function | TEXT | Designer's label for this instrument's purpose — e.g. "Down Lt Wash", "Breakup" |
| focus | TEXT | Focus position notes — e.g. "CS", "USL", "Door Special" |
| flagged | INTEGER NOT NULL DEFAULT 0 | Boolean (0/1) — marks instrument as needing attention |

A fixture is a single physical lighting instrument hung on a position. It is the core entity — everything else (parts, gels, gobos, accessories) hangs off it.

Channel, address, dimmer, circuit, and all parameter data live on **fixture_parts**, not here. A conventional fixture has one part; a multi-cell or moving light has many. This keeps the model uniform: fixture → parts is always the path to control data.

---

### fixture_parts

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| fixture_id | INTEGER NOT NULL | FK → fixtures.id |
| part_order | INTEGER NOT NULL | Display/sort index within the fixture (0-based) |
| part_type | TEXT | CHECK constraint against part_types enum — e.g. "intensity", "gobo", "color_feature" |
| part_name | TEXT | User-facing label — e.g. "Dimmer", "Color Wheel 1", "Strobe Cell A" |
| channel | TEXT | Soft-link to channels.name |
| address | TEXT | Soft-link to addresses.name |
| ip_address | TEXT | For network-controlled fixtures |
| mac_address | TEXT | |
| subnet | TEXT | |
| ipv6 | TEXT | |
| extras_json | TEXT | JSON catch-all for future edge-case parameters |

This is where the multi-cell / moving-light / composite model lives. A Source Four 36° gets one part (intensity). A VL3500 gets parts for intensity, pan/tilt, color, gobo wheels, etc. A 3-cell cyc strip gets three parts (one per cell), each with its own channel, dimmer, and gel.

**UNIQUE constraint:** (fixture_id, part_order).

---

### part_types (enum-like reference)

Enforced as a **CHECK constraint** on `fixture_parts.part_type` rather than a separate lookup table — simpler, no JOIN required.

| Value | Description |
|---|---|
| intensity | Brightness / dimmer control |
| gel | Color filter slot |
| x | Pan axis |
| y | Tilt axis |
| x_high | Pan coarse |
| x_low | Pan fine |
| y_high | Tilt coarse |
| y_low | Tilt fine |
| gobo | Gobo wheel |
| gobo_feature | Gobo rotation / index sub-parameter |
| color_feature | Color wheel / CMY / CTO sub-parameter |

Extensible — new values require a schema migration to add them to the CHECK constraint, which is intentional (they are a controlled vocabulary).

---

### gels

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| color | TEXT NOT NULL | e.g. "R02", "L201" |
| fixture_id | INTEGER NOT NULL | FK → fixtures.id |
| fixture_part_id | INTEGER | FK → fixture_parts.id, nullable — use for multi-part fixtures where gel is per-cell |
| size | TEXT | e.g. "7.5\"", "10\"" |
| maker | TEXT | e.g. "Roscolux", "Lee" |

**Cardinality:** Many gels → one fixture (or one fixture part). For conventional single-part fixtures, set only `fixture_id`. For multi-cell instruments (cyc strips, multi-cell LED), set both `fixture_id` and `fixture_part_id` to assign the gel to a specific cell. Each gel row is an individually tracked physical cut.

**Invariant:** if `fixture_part_id` is set, that part must belong to the same `fixture_id`. Enforce in repository tests (or with composite constraints if the final Drift schema supports it cleanly).

---

### gobos

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| gobo_number | TEXT NOT NULL | e.g. "R77735", "G245" |
| fixture_id | INTEGER NOT NULL | FK → fixtures.id |
| fixture_part_id | INTEGER | FK → fixture_parts.id, nullable — use for moving lights with multiple gobo wheels |
| size | TEXT | e.g. "B-size", "M-size" |
| maker | TEXT | e.g. "Rosco", "Apollo" |

**Cardinality:** Same as gels — many gobos → one fixture/part, individually tracked.

**Invariant:** if `fixture_part_id` is set, that part must belong to the same `fixture_id`.

---

### accessories

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| name | TEXT NOT NULL | e.g. "Top Hat", "Barndoor", "Safety Cable" |
| fixture_id | INTEGER NOT NULL | FK → fixtures.id |

**Cardinality:** Many accessories → one fixture, one fixture per accessory row. Multiple fixtures can have accessories with the same name (each is its own row). Enables count-by-name queries for shopping lists and load-in prep.

---

### custom_fields / custom_field_values

| Table | Column | Type | Notes |
|---|---|---|---|
| **custom_fields** | id | INTEGER PK | |
| | name | TEXT NOT NULL | User-visible column name |
| | data_type | TEXT | "text", "number", "boolean", "date" |
| | display_order | INTEGER | Sort position in grid |
| **custom_field_values** | id | INTEGER PK | |
| | fixture_id | INTEGER NOT NULL | FK → fixtures.id |
| | custom_field_id | INTEGER NOT NULL | FK → custom_fields.id |
| | value | TEXT | All values stored as text, cast on read |

User-defined columns on the fixtures table. Rendered dynamically alongside built-in columns in the grid and available in reports.

---

### work_notes

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| body | TEXT NOT NULL | Note content |
| user_id | TEXT NOT NULL | Who wrote it |
| timestamp | TEXT NOT NULL | ISO 8601 |
| fixture_id | INTEGER | Optional FK → fixtures.id — pin a note to a specific instrument |
| position | TEXT | Optional soft-link to lighting_positions.name — pin a note to a position |

Work notes are the running log of the production — work calls, notes from tech, reminders, callouts. Displayed in the Work Notes tab, sorted by timestamp descending. Optional fixture/position links make notes searchable by context.

---

### maintenance_log

| Column | Type | Notes |
|---|---|---|
| id | INTEGER PK | Auto |
| fixture_id | INTEGER NOT NULL | FK → fixtures.id |
| description | TEXT NOT NULL | What happened / what was done |
| user_id | TEXT NOT NULL | Who logged it |
| timestamp | TEXT NOT NULL | ISO 8601 |
| resolved | INTEGER NOT NULL DEFAULT 0 | Boolean (0/1) |

Tracks maintenance events and outstanding issues per instrument. The Maintenance tab shows all unresolved items (resolved = 0) and the history for any selected fixture. Adding a maintenance log entry for a flagged fixture and marking it resolved automatically clears the `fixtures.flagged` flag.

---

### Revision-system tables

| Table | Column | Type | Notes |
|---|---|---|---|
| **revisions** | id | INTEGER PK | |
| | operation | TEXT NOT NULL | See [Revision operations](#revision-operations) — `update`, `insert`, `delete`, or `import_batch` (summary row for a bulk import; optional depending on [Bulk import and revisions](#bulk-import-and-revisions)) |
| | target_table | TEXT NOT NULL | "fixtures", "fixture_parts", "gels", etc. |
| | target_id | INTEGER | PK of the row; for a pure **insert** (pending) use the new row’s id once inserted; for **import_batch** summary may be 0 or a sentinel with payload only in `new_value` (implementation choice) |
| | field_name | TEXT | **Update:** required — column that changed. **Insert / delete / import_batch:** NULL (or a sentinel `*` in code — not a real column) |
| | old_value | TEXT | JSON-encoded value/snapshot. **Update:** previous scalar value (including JSON `null` if the field was null). **Insert:** SQL NULL / not applicable. **Delete:** JSON snapshot of the removed row (or subtree — see [Cascade deletes](#cascade-deletes)) before delete. **import_batch:** SQL NULL / prior state N/A |
| | new_value | TEXT | JSON-encoded value/snapshot. **Update:** attempted scalar value (including JSON `null` if setting a field null). **Insert:** JSON snapshot of the created row (and any expanded children created in the same transaction, if not modeled separately). **Delete:** SQL NULL / not applicable. **import_batch:** JSON summary, e.g. `source_file`, `row_count`, `fixture_ids[]`, or hash — enough to record *that* the import happened |
| | batch_id | TEXT | Optional UUID (or similar) — ties many revision rows to one [bulk / batch](#bulk-import-and-revisions) action (e.g. one CSV import) |
| | user_id | TEXT NOT NULL | Who made the edit |
| | timestamp | TEXT NOT NULL | ISO 8601 |
| | status | TEXT NOT NULL | "pending" (awaiting review), "committed" (change approved), "rejected" (change declined—row kept for history; see [Rejection and history](#rejection-and-history)) |
| | commit_id | INTEGER | FK → commits.id — set when a supervisor **commits** a review batch; both **committed** and **rejected** revisions in that batch get the same `commit_id` (see below) |
| **commits** | id | INTEGER PK | |
| | user_id | TEXT NOT NULL | Supervisor who ran the review (the commit batch) |
| | timestamp | TEXT NOT NULL | |
| | notes | TEXT | Optional commit message |

**Value encoding:** `old_value` and `new_value` store JSON text, not raw display strings. A real null field value is stored as the JSON literal `null` (text), while SQL NULL means "not applicable for this operation." This avoids ambiguity for nullable fields.

**Constraint (recommended):** CHECK that `operation` and the presence of `field_name` / `old_value` / `new_value` are consistent (e.g. `update` requires `field_name` and applicable JSON values, even if the JSON value is `null`; `delete` uses `old_value` snapshot and SQL NULL `new_value`; `insert` uses SQL NULL `old_value` and `new_value` snapshot).

Every **mutation** to tracked data creates at least one revision row (or [bulk summary + grouped rows](#bulk-import-and-revisions) for imports). The data tables are **updated in place** while work is **pending** as described under [Revision operations](#revision-operations). A **rejected** field-level **update** is **not** deleted: the live field is **restored** from `old_value`, the row is `rejected` and linked to `commit_id` — see [Rejection and history](#rejection-and-history). **Insert**/**delete** rejections are handled the same in principle: reject restores prior state (re-insert or skip delete) using the stored snapshot, and the revision row stays. See [Revision Engine](#revision-engine).

For **update**-only rows, `target_table` + `target_id` + `field_name` still identifies the change. For **insert**/**delete**, the row is identified by `target_table` + `target_id` with `operation`.

---

### Other local tables

- **reports** — Saved report templates (columns, sort, filter, grouping, PDF layout settings). Built-in templates (channel hookup, instrument schedule, dimmer schedule) are hard-coded in the app; only custom templates are saved here.
- **users_local** — Cached user identities for offline display (user_id, display_name, avatar_url, last_seen).

---

## Venue Data

Venue data lives **inside the show file**, not in a separate file. It is managed from a sub-section of the **Show tab** — not a separate top-level tab. Creating a new show starts with filling in the Show tab, which includes a venue sub-section — either blank or populated by importing venue data from a previous show.

### What "venue data" includes
- **Positions** (`lighting_positions`) — must be defined; every fixture needs a position.
- **Circuits** (`circuits`) — optional. Venue wiring infrastructure.
- **Dimmers** (`dimmers`) — optional. Dimmer packs/racks at the venue.
- **Addresses** (`addresses`) — optional. DMX/sACN/Art-Net address space.

### Soft-link behavior
Fixture fields like dimmer and circuit are always stored as plain strings. When the venue sub-section has matching records defined, those strings resolve to rich records for autocomplete, tooltips, and optional validation. Validation level is configurable per field: none (accept anything), warn (highlight non-matching values), or strict (dropdown only).

### Venue export/import
Venue data can be exported as a JSON blob and imported into another show file to quickly transfer a venue setup. This is a convenience feature, not a separate file format — the canonical venue data always lives in the show file.

### Lightwright / CSV import
A structured CSV import (mapping to PaperTek columns) allows users to import fixture data from Lightwright exports or any tabular source. Column mapping is user-configured on first import and saveable as a preset. Fields that don't map cleanly are imported to `extras_json` or skipped with a warning. This is the primary migration path for users moving from Lightwright. Data writes and revision records follow [Bulk import and revisions](#bulk-import-and-revisions) (batched transactions, `batch_id`, optional `import_batch` summary row) so large imports do not perform thousands of unrelated single-field revision writes on the main thread.

### Rename propagation
Renaming a venue record (e.g. a position) offers a bulk-rename prompt against matching fixture values. The rename flows through the revision system like any other edit.

### Soft-link resolution panel
A panel accessible from the Show tab for resolving soft-link mismatches — fixtures referencing dimmer/circuit strings that don't match any venue record. Useful after import or after venue edits.

---

## Revision Engine

### Revision scope

The revision engine is for **reviewable show/design data**, not every persisted preference or operational note.

**Supervisor-reviewed / revision-tracked by default:**

- Show metadata that affects the document identity or paperwork (`show_meta` fields except local sync-only internals such as `schema_version`).
- Venue/setup records: `lighting_positions`, `circuits`, `channels`, `addresses`, `dimmers`.
- Plot and fixture data: `fixture_types`, `fixtures` design fields, `fixture_parts`, `gels`, `gobos`, `accessories`.
- Custom field definitions and fixture custom field values.

**Operational / not supervisor-reviewed by default:**

- `work_notes` and `maintenance_log` rows. They already carry `user_id` and `timestamp`; their history is their own log, not the supervisor revision queue.
- `users_local`, local sync cursors, cached identity data, UI settings, report template drafts, and other local app metadata.
- `fixtures.flagged` is an operational status flag. It is controlled by maintenance/workflow repositories, not by the supervisor commit queue, unless the product later decides flags are reviewable plot data.

All writes still go through repositories. "Not revision-tracked" does **not** mean "write from UI directly"; it means the repository uses an operational transaction path instead of creating `revisions` rows.

### Tracked writes (implementation)

As soon as the database supports the `revisions` table, **all app mutations** that change tracked data (fixtures, parts, gels, venue renames, etc.) go through a single **tracked write** layer (repository). The public API is **not** only `setField` for scalar updates — it also includes **insert row**, **delete row** (and clone as insert-with-provenance), each emitting revision rows with the correct `operation` (see [Revision operations](#revision-operations)). The UI in Phases 2–4 is built on this layer from the start. Supervisor review, conflict resolution, and undo stack behavior are completed in a later phase, but the audit trail and `pending` rows exist from the first edit.

### Revision operations

| `operation` | `field_name` | `old_value` | `new_value` | Meaning |
|---|---|---|---|---|
| `update` | column name | previous | attempted | Field-level change on an existing row (the original design). |
| `insert` | NULL | NULL | JSON snapshot of the new row (and metadata if one row encodes a whole fixture + parts) | A row was **created** (e.g. new fixture, new gel, row from CSV). |
| `delete` | NULL | JSON snapshot before delete | NULL | A row was **removed** (e.g. delete fixture). Reject restores from `old_value`. |
| `import_batch` | NULL | NULL | JSON summary of the import (file name, row counts, optional list of created ids) | Optional **one row per import** to anchor a [bulk import](#bulk-import-and-revisions); may be used with many `insert` rows sharing the same `batch_id`. |

**Clone** is modeled as one or more **`insert`** revisions (and linked child rows as needed), with optional notes in the snapshot or a future `provenance` key in JSON — not a separate `operation` unless the product later adds one.

### Cascade deletes

When a **fixture** is deleted, dependent rows (parts, gels, gobos, accessories) are removed by FK `ON DELETE CASCADE` (or app-level cascade). The **default** audit policy: emit **one** `delete` revision for the **fixture** with `old_value` = a JSON object that **includes a denormalized summary** of removed children (ids and key fields) so history shows *what left the show* without requiring a separate `delete` revision for every part row. If the product later needs per-part dispute in review, child-level `delete` rows can be added; v1 does not require it.

### Bulk import and revisions

Importing hundreds of rows from Lightwright/CSV must not require **O(rows × fields)** separate `update` revisions or thousands of tiny transactions on the UI thread. The write layer should support a **batch** (e.g. `beginImportBatch` / `endImportBatch` or a single call with a `batch_id`):

- Perform data writes in **one or a few large transactions** (optionally in a **background isolate** for very large files — document as an implementation choice).
- **Revision strategy (choose per product pass):** (a) **one `import_batch` summary row** plus one **`insert` per created fixture** (O(n) revisions, still tractable) sharing `batch_id`; or (b) **summary + minimal insert rows** if full per-fixture review is not required; or (c) **per-field** revisions for imports only if the team accepts the cost and runs import off-thread. The spec requires the **import event** to be auditable; the exact granularity is recorded in the implementation plan.
- The same `batch_id` groups all `revisions` from that import for the supervisor queue and history (“Import from `hookup.csv` — 500 fixtures”).

### How edits work
1. Every change creates at least one `revisions` row with `operation`, `target_table`, `target_id`, and the appropriate `field_name` / `old_value` / `new_value` per the table above, plus `user_id`, `timestamp`, `status`.
2. For **`update`**: the target table is **updated in place** while **pending**; live value reflects the **attempt** (`new_value`). After a supervisor **rejects** that revision, the field is **restored** to `old_value` (see [Rejection and history](#rejection-and-history)); the row stays `rejected`. For **`insert`/`delete`**, see [Rejection and history](#rejection-and-history) for restoring prior document state; snapshots drive undo of inserts/deletes.
3. Rows changed since the last commit are highlighted: **yellow** = uncommitted changes, no conflicts. **Red** = conflicting revisions where applicable (primarily same **field** on `update` — see [Conflict handling](#conflict-handling)).
4. Any user can click into a highlighted row to see: the committed state, and relevant revisions. They can view other users' revisions but cannot edit them. They can push their own revision from this view.
5. For `update`, if a new revision is non-conflicting (different field than existing pending revisions on that entity), the row may stay yellow. If it conflicts (same field, same row), last-in may take precedence for display and the row turns red. Inserts/deletes have their own conflict rules if two users create/delete the same id (rare — implementation-defined).

### Undo / Redo (session-local)
Within a session, individual users can undo their own **pending** edits (Ctrl+Z / Ctrl+Y) **before** a supervisor has processed them. Undo is operation-aware:

- **`update`** — restore the field to `old_value`, remove the pending revision row.
- **`insert`** — remove the created row(s), remove the pending revision row.
- **`delete`** — restore the deleted row/subtree from `old_value`, remove the pending revision row.
- **`import_batch`** — not required for Ctrl+Z in v1; imports should have an explicit cancel/rollback affordance while the import is running, and supervisor rejection covers post-import rollback.

Session undo is a pre-review correction by the same author. It is different from supervisor **rejection**, which keeps the row as `rejected` history. The undo stack is in-memory only — it is cleared on restart and on supervisor commit. Users cannot undo revisions made by other users. The undo stack holds up to 50 operations per session.

### Supervisor commit flow
1. Supervisor opens the review queue. Yellow rows are clean — just approve or reject. Red rows need attention — supervisor sees all conflicting revisions for that field and picks the winner (or edits in place).
2. The supervisor **commits** a review **batch** (a single `commits` row). For every pending revision in that batch:
   - **Approve** → `status = "committed"`, `commit_id` set, live data already match `new_value` (or supervisor adjusted in place, which may add new revision rows as needed). The approved change is part of the document’s *official* state going forward.
   - **Reject** → see [Rejection and history](#rejection-and-history) below. Highlights for settled rows clear.
3. Full history is browsable by commit, including both accepted and rejected attempts.

### Rejection and history

**What “reject” means in the data layer**

- The **proposed** change is recorded in the `revisions` row per `operation`. For a field **`update`**: `old_value` → `new_value`, `user_id` = author, `status` = `"pending"` while under review.
- If the supervisor **rejects** a field-level **`update`**:
  1. The **live** row in the target table is **updated to restore** the field to `old_value` (i.e. the pre-attempt / last-committed value, captured when the edit was first made). The document is returned to a consistent, non-pending state for that field.
  2. The same `revisions` row is **updated**, not removed: set `status = "rejected"` and `commit_id` to the supervisor’s current `commits.id`. The row remains **permanent** history: *attempt* → *declined* → *reverted*.

- If the supervisor **rejects** an **`insert`**: the created row (and any cascade-expanded children) is **removed** to roll back the addition; the `revisions` row (with `operation = insert` and the stored snapshot) is set to `rejected` and `commit_id` is set so history still shows that an add was attempted and then declined.

- If the supervisor **rejects** a **`delete`**: the row is **restored** from the JSON in `old_value` (re-insert and re-link children per app logic, or use DB restore from snapshot); the `revisions` row is `rejected` and linked to `commit_id` — the story is *deletion was proposed, then not approved, document back to prior state*.

- **No deletion of revision rows** to “erase” a bad record in history. Dropping a revision would break the audit trail. The *event* (attempt + outcome) is the story.

**Conflict resolution (pick a winner)**

- Losing options are not discarded without trace: the non-chosen `revisions` (or the superseded ones) are marked `rejected`, linked to the same `commit_id`, and the live data reflect the **chosen** winner’s `new_value` (or supervisor-edited value). The history list still shows what each person proposed and what was not adopted.

**Distinction: session undo (user, before review)**

- [Undo / Redo (session-local)](#undo--redo-session-local) may **remove** a pending revision row before any supervisor **commit**—that is a pre-review correction by the same author, not a supervisor **rejection**. Do not conflate the two: rejection is a reviewed outcome with a permanent `revisions` record of type `rejected` attached to a `commit_id`.

### Conflict handling
For **`update`**: conflict = two pending revisions on the same `target_table` + `target_id` + `field_name` from different users since last commit. Surfaced via red highlight in the working view and in the supervisor review queue. No auto-merge. For **inserts** and **deletes** on the same id (e.g. rare double-delete), the product may define a simple last-wins or block rule — document in the implementation. Two **imports** in flight are not expected in v1; batch revisions group under `batch_id` and one logical review.

---

## File Versioning

Every `.papertek` file uses SQLite `PRAGMA user_version` / Drift `schemaVersion` as the **authoritative** schema gate. `show_meta.schema_version` mirrors that value for display and debugging, but the app must not rely on `show_meta` to decide whether migrations can run because older files may not yet have the latest `show_meta` columns.

On open:

1. Read SQLite `user_version` before depending on app tables.
2. If `user_version` equals the current app schema version — open normally.
3. If `user_version` is older — run Drift forward migrations, update `user_version`, then update `show_meta.schema_version` if the table/column exists after migration.
4. If `user_version` is newer than the app knows about — show a blocking error: "This file was created with a newer version of PaperTek. Please update the app." Do not open. Do not modify the file.

This prevents silent data corruption when an old app version encounters a new schema.

---

## Navigation

The app has five top-level tabs in the bottom nav bar:

| Tab | Contents |
|---|---|
| **Show** | Show metadata form (name, producer, designer, ME, etc.) + venue sub-section (positions, circuits, channels, addresses, dimmers) + soft-link resolution panel |
| **Spreadsheet** | Main fixture grid, toolbar (search/filter/sort), sidebar properties panel |
| **Work Notes** | Chronological log of work notes; add/edit/delete; filter by fixture or position |
| **Maintenance** | Flagged instruments list, per-fixture maintenance history, resolve/log entries |
| **Reports** | Built-in and custom report templates; PDF preview, print, export |

---

## Cloud (optional — org-subscription model)

### Product model
- **Individuals:** Paid app, fully functional standalone. No subscription required. Personal device sync included (see below).
- **Organizations:** Org-level subscription unlocks shared cloud space. Org admins invite members, manage shows, set per-show permissions.
- **Billing:** Per-organization. Pricing model (flat vs per-seat) TBD.

### Personal device sync (non-org)
Every paid user gets a **personal workspace on Supabase** — same sync architecture as org sync, but scoped to a single user. Enables syncing show files between the user's own desktop and mobile devices. Same code path, tiny storage footprint, minimal marginal cost.

### Supabase schema (cloud-side)

- **users** — Supabase Auth for identity. Profile row for display name, avatar.
- **personal_workspaces** — One per user. Storage quota, sync state.
- **organizations** — Name, slug, billing/Stripe references.
- **organization_members** — user_id, org_id, role (owner | admin | member). Invite flow.
- **organization_subscriptions** — Plan, status, dates. Gates cloud sync for org resources.
- **cloud_shows** — org_id (or personal_workspace_id), show_id (= `show_meta.cloud_id` UUID), metadata, latest_snapshot_path, revision_cursor, snapshot_cursor.
- **show_permissions** — org_id, show_id, user_id, permission set (read, edit, approve, manage). Explicit rows for RLS.
- **revisions** — Scoped by show context. Mirrors the local `revisions` shape, including `operation`, nullable `field_name`, JSON `old_value` / `new_value`, `batch_id`, `status`, and `commit_id`. RLS checks membership + permissions.
- **commits** — Scoped by show context.
- **snapshots** — Metadata rows pointing to SQLite files in Supabase Storage. Includes `revision_cursor` at time of snapshot generation.

### Sync

- Background service when the show is linked to cloud and the app is online (interval and triggers are **implementation details**; tune for reliability over perceived latency in early versions).
- **Push:** Unsynced local revisions go to Supabase.
- **Pull:** Remote revisions since last sync come to local SQLite. Data tables updated in place; highlights applied.
- **Committed state:** Remote commits apply locally. Committed = truth.
- **New user joins a show:** Downloads the latest snapshot (a complete SQLite file, generated client-side and uploaded to Storage). Then pulls incremental revisions from that point.
- **Snapshots:** Generated on the client (the app uploads its local SQLite file). Created on share, on invite, and on commit (configurable). Snapshot uploads use optimistic locking: the upload is accepted only if the server's `revision_cursor` matches the cursor in the snapshot metadata. If another user uploaded a newer snapshot in the interim, the upload is rejected and the client re-syncs before retrying.
- Optional: Supabase Realtime or a lightweight poll to **nudge** full sync; not required for core correctness.
- Offline: everything works locally. Sync catches up on reconnect.

### RLS strategy
All cloud tables gated by: authenticated user, membership in relevant org (or ownership of personal workspace), active subscription (org) or valid license (personal), required permission on the specific show.

### Schema parity (Drift and Postgres)

Local Drift schema and cloud Postgres for sync-related tables **must** stay compatible. A **single** shared human-readable spec (this document) is the first source of truth. When a column is added in Drift, add a matching column to the next Supabase migration (or the reverse) in the same PR, and add a one-line **parity note** in the change log. Optional later: codegen from a shared model file if manual drift becomes painful—do not block v1 on a custom generator.

---

## Social Features (stubs only — architecture-ready)

### Why no rework is needed later
- `users` table with profiles exists from day one.
- `organization_members` models group membership.
- `show_permissions` models per-document participant lists.
- Supabase Realtime is already in the stack — same infrastructure carries chat.

### Planned features (future phase)
- **Org chat:** All org members. `messages` table scoped to org_id.
- **Show chat:** Users with access to a specific show. Scoped to org_id + show_id. Participant list derived from show_permissions.
- **Direct messages:** Between any two users. Conversation scoped to two user_ids.
- **Friends list:** `user_connections` table (user_id, friend_id, status). Independent of orgs.

### What ships in v1
- `messages`, `conversations`, `user_connections` tables included in Supabase migrations. No UI yet.
- RLS policies for messages mirror existing membership checks.

---

## Reports

Reports are a **primary product surface**, not a bolt-on. The **visual and structural bar** is: outputs should look and read like what lighting teams expect from professional paper—**in the same league as Lightwright hookups** (legible at a glance, strong hierarchy, clean breaks, sensible running headers, accurate pagination). Building that with imperative, coordinate-based `pdf` widget code for every template does not scale; the product should plan for a **layout-based** pipeline from the start.

### Engine strategy (HTML / print, not raw coordinates)

- **Preferred direction:** **HTML + CSS** (including `@page`, `break-inside`, print margins) for body content, with data filled from a template (Mustache/Handlebars-style, or a thin Dart string builder). Render to:
  - **On desktop:** a **WebView**-based or platform **print to PDF** path, or a dedicated HTML→PDF engine chosen after a small **spike in Phase 7** (evaluate Chromium embed, wkhtmltopdf-style options, and Flutter constraints on each platform).
- **What to avoid for full hookups:** Hand-building multi-page tabular reports only with the Dart `pdf` package (tables, repeated headers, dynamic breaks, and group headers become a long maintenance sink). The `pdf` package may still be used for **simple, narrow** outputs (a one-page summary, a label sheet) if that keeps a dependency small.
- **User-configurable layout:** Header and footer editor — left/center/right zones, custom text, logo, tokens such as `{page}` / `{total}`. **Body** layout: column picks, order, default widths, grouping (e.g. by position) with **explicit break rules** (e.g. "start a new page when position changes" where that matches theatre workflow).
- **Spike (before the first full hookup ships):** Lock the stack: HTML+CSS+engine choice, font embedding, and a single **channel hookup** that proves grouping + headers + page breaks. Only then add instrument schedule and dimmer pack variants.

### Features

- **Built-in templates (in repo):** Channel hookup, instrument schedule, dimmer schedule (and additional sheets as the model grows).
- **Custom templates (saved to `reports` table):** User picks columns, sort, filter, grouping; JSON stores both field selection and **layout** metadata compatible with the chosen engine.
- **Output:** PDF (primary) and **CSV** export; print dialog where the platform allows.
- **Report settings UI:** Form-based editor; **live or near-live preview** (same engine as final PDF where possible) before printing.
- All reports run against **local SQLite** — available offline; cloud does not block reporting.

---

## Dictation (future)

- Default: on-device STT via platform APIs (`speech_to_text` package). Zero cost.
- Optional: cloud STT (Whisper API, ~$0.006/min) as premium org feature.
- No audio storage unless opted in.

---

## Phases

1. **Local Desktop MVP** — Show file CRUD, Show tab (metadata + venue), fixtures table, revision engine, basic reports, CSV import. Windows + Mac.
2. **Review and Polish** — Supervisor review queue with color-coded diff view, history browser, custom fields, keyboard shortcuts, theming, undo/redo, work notes, maintenance tab.
3. **Cloud and Collaboration** — Supabase setup, personal workspaces, org model, sync, permissions, snapshots. Stub social tables.
4. **Mobile** — Adaptive card-based UI, mobile review queue.
5. **Social** — Org chat, show chat, DMs, friends list.
6. **Extras** — Dictation, advanced report builder, venue data sharing via org cloud.

---

## Key Risks

- **Syncfusion DataGrid fit.** Evaluate week 1 with prototype, including expandable child rows for multi-part fixtures. Fallback: PlutoGrid or custom widget.
- **Professional reports.** The Lightwright bar is high. Underestimating PDF/layout engineering is a product risk. Mitigation: [Reports](#reports) — spike HTML/CSS + engine **before** committing a full report suite to a stack that cannot do grouping and page control.
- **Flutter desktop feel.** Target "polished cross-platform" (VS Code/Figma tier), not pixel-perfect native. Use `window_manager` for native chrome.
- **Sync complexity.** Phases 1-2 ship without cloud. Sync is additive.
- **Drift / Postgres drift.** Same schema, two runtimes. Mitigation: [Schema parity](#schema-parity-drift-and-postgres).
- **Revisions for row lifecycle (insert/delete/bulk).** More moving parts than field-only `update` tracking. Mitigation: [Revision operations](#revision-operations) + repository tests; keep import batches off the UI thread.
- **Scale.** Shows are small (<2000 fixtures for most productions; large Broadway/touring shows can reach 5000). Syncfusion DataGrid virtualization must be enabled from day one.

## Costs

- Under $50/month until there are paying orgs.
- Supabase free tier, then $25/month Pro.
- Syncfusion free community license.
- Apple $99/year, Google $25 one-time, Windows signing ~$100/year.
