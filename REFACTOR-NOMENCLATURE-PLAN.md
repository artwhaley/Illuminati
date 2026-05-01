# Nomenclature & Schema Refactor — Plan Overview

**Status:** Ready for execution  
**Schema version:** 21 → 22  
**Execution model:** Sonnet orchestrates; delegates mechanical subtasks to Haiku subagents

---

## Goal

Standardize all field names and column identifiers throughout the application — from database schema to domain models to UI — and introduce a user-editable field name system so names like "Instrument" can be changed per-show without code changes.

---

## Guiding Principles

- **ColumnSpec is the single source of truth.** Every layer (spreadsheet, reports, info panel, sidebar) reads display names from `ColumnSpec.label`. No parallel registries.
- **No convenience accessors that mask incomplete data.** Wattage moves to parts; there is no fixture-level wattage rollup.
- **No backwards-compat shims.** Rename methods directly. Let compile errors guide cleanup.
- **The migration is the contract.** Data integrity is not a concern for existing test files. Schema correctness is.

---

## Field Name Changes

| Context | Old | New |
|---------|-----|-----|
| DB column | `fixtures.function` | `fixtures.purpose` |
| DB column | `fixtures.focus` | `fixtures.area` |
| DB column | `fixtures.unit_number` type | `INTEGER` → `TEXT` |
| DB column | `fixtures.wattage` | **removed** (moved to parts) |
| DB column | `fixtures.flagged` | **removed** |
| DB column | `fixture_parts.address` | renamed to `fixture_parts.dimmer` |
| DB column (new) | — | `fixture_parts.address` (DMX address) |
| DB column (new) | — | `fixture_parts.wattage` |
| DB table (new) | — | `field_names` (user-editable display names) |
| ColumnSpec id | `type` | `instrument` |
| ColumnSpec id | `function` | `purpose` |
| ColumnSpec id | `focus` | `area` |
| ColumnSpec id | `patch` | `patched` |
| ColumnSpec label | `U#` | `Unit` (default, user-editable) |
| ColumnSpec label | `FIXTURE TYPE` | `Instrument` (default, user-editable) |
| ColumnSpec label | `PURPOSE` | `Purpose` (default, user-editable) |
| ColumnSpec label | `FOCUS AREA` | `Area` (default, user-editable) |
| ColumnSpec label | `ADDRESS` | split into `Dimmer` + `Address` |

---

## Default Field Names (stored in `field_names` table)

| field_id | display_name |
|----------|-------------|
| instrument | Instrument |
| unit | Unit |
| purpose | Purpose |
| area | Area |
| dimmer | Dimmer |
| address | Address |
| channel | Channel |
| circuit | Circuit |
| wattage | Wattage |
| color | Color |
| gobo | Gobo |
| accessories | Accessories |
| position | Position |
| notes | Notes |

---

## Execution Phases

### Phase 1 — Database Migration (TICKET-01)
- Bump schema version to 22
- Rename columns in SQL
- Add new columns
- Migrate wattage data from fixtures → intensity parts
- Create `field_names` table with defaults
- Rebuild FTS5 virtual table and triggers with new column names

### Phase 2 — Drift Table Definitions (TICKETS 02–04)
- Update `Fixtures` table class: remove `wattage`, `flagged`, `function`, `focus`; add `purpose`, `area`; change `unitNumber` to `TextColumn`
- Update `FixtureParts` table class: rename `address` → `dimmer`; add `address`, `wattage`
- Add new `FieldNames` table class

*After these changes: run `dart run build_runner build`. The generated compile errors are the checklist for remaining work.*

### Phase 3 — Domain Models (TICKET-05)
- `FixturePartRow`: rename `address` → `dimmer`; add `address`, `wattage`
- `FixtureRow`: rename `function` → `purpose`, `focus` → `area`; change `unitNumber: int?` → `String?`; remove `wattage`, `flagged`; add `address` convenience accessor

### Phase 4 — Repository (TICKETS 06–08)
- Update `watchRows()` query to reflect new schema
- Rename mutation methods: `updateFunction` → `updatePurpose`, `updateFocus` → `updateArea`
- Update `updateUnitNumber` signature to `String?`
- Remove `updateWattage` on fixtures; add `updatePartWattage(fixtureId, partOrder, value)`
- Split `updatePartAddress` → `updatePartDimmer` + `updatePartAddress`
- Add `updateIntensityDimmer` + `updateIntensityAddress`
- Remove `toggleFlag`
- Add `FieldNameRepository` (CRUD for `field_names` table)

### Phase 5 — ColumnSpec (TICKETS 09–10)
- Rename column IDs and default labels per the table above
- Change `label` from `final String` to `String` (mutable)
- Add `final String defaultLabel` (the hardcoded default)
- Split `dimmer` column into two: `dimmer` + `address`
- Move `wattage` to `isPartLevel: true`; update `getValue` to read from first intensity part; add `getPartValue`
- Remove `patch` column; replace with `patched` (same id as dbField)
- Add `FieldNameNotifier` (Riverpod): loads `field_names` from DB on init, applies overrides to `kColumns`, notifies watchers on change

### Phase 6 — DataSource (TICKET-11)
- Update all `FixtureRow` field references
- Fix unit_number sort comparator for alphanumeric `String?` (natural: 1 < 1a < 1b < 2)
- Add `address` column display (part-level)
- Remove any `flagged` references

### Phase 7 — Report Field Registry (TICKET-12)
- Update `kStackedColumns` field key arrays: `['type','wattage']` → `['instrument','wattage']`, `['function','focus']` → `['purpose','area']`
- Update `getPartFieldValue` switch cases: `'dimmer'` reads `part.dimmer`, add `'address'` reads `part.address`
- Labels now flow from `kColumns` automatically

### Phase 8 — Maintenance Tab (TICKET-13)
- **Keep:** Edit Review tab (entire tab, untouched)
- **Keep:** Maintenance Log tab structure, `MaintenanceLog` table display, resolve buttons
- **Remove:** All code referencing `flaggedFixturesProvider`, flagged fixture display, flag-related UI
- Remove `flaggedFixturesProvider` from `show_provider.dart`

### Phase 9 — Remaining UI References (TICKET-14)
- Search for and update: `fixture.function`, `fixture.focus`, `fixture.flagged`, `fixture.wattage`, `part.address` (as dimmer), `ColumnSpec` id strings in preset serialization
- Add ID migration map in preset loader for old column IDs

### Phase 10 — Importer (TICKET-15)
- Rename enum values: `function` → `purpose`, `focus` → `area`  
- Add `address` enum value (DMX address)
- Retain variant strings: 'function', 'purpose', 'use' all map to `purpose`; 'focus', 'area' both map to `area`
- `dimmer` variants → `dimmer`; add DMX address variants → `address`
- gobo1/gobo2 unchanged

---

## Key Files

| File | Role |
|------|------|
| `papertek/lib/database/database.dart` | Migration logic, FTS5 setup |
| `papertek/lib/database/tables/fixtures.dart` | Drift table definitions |
| `papertek/lib/repositories/fixture_repository.dart` | Domain models + data access |
| `papertek/lib/ui/spreadsheet/column_spec.dart` | Single source of truth for columns |
| `papertek/lib/ui/spreadsheet/fixture_data_source.dart` | Spreadsheet data binding |
| `papertek/lib/features/reports/report_field_registry.dart` | Report field derivation |
| `papertek/lib/ui/maintenance/maintenance_tab.dart` | Revision + maintenance log UI |

---

## Risks

- **FTS5 triggers** are hand-written SQL. The migration must drop and recreate them with `purpose`/`area` column names.
- **Preset serialization** stores column IDs as strings. Old presets referencing `'function'`, `'focus'`, `'type'`, `'patch'` need a migration mapping in the preset loader.
- **`cloneFixture` and `addFixtureFromDraft`** in `fixture_repository.dart` reference old field names directly — these are not covered by Drift regeneration and must be updated manually.
- **Natural sort for `unit_number`**: comparator must handle alphanumeric suffixes. `"1a"` sorts after `"1"` but before `"2"`. Extract leading integer, then compare suffix alphabetically.
- **`FixtureDraft`** class likely references `function`, `focus`, `wattage` — must be updated in sync with the repository.
