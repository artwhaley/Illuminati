# PaperTek Code Atlas (Geographic + Functional)

## Quick Orientation

- **App entry and shell**
  - `papertek/lib/ui/app.dart`
  - `papertek/lib/ui/main_shell.dart`
- **State wiring**
  - `papertek/lib/providers/show_provider.dart`
- **Persistence**
  - `papertek/lib/database/database.dart`
  - `papertek/lib/database/tables/*`
- **Domain logic**
  - `papertek/lib/repositories/*`
- **Feature UIs**
  - `papertek/lib/ui/show_tab.dart`
  - `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart`
  - `papertek/lib/ui/positions/*`

---

## Root and Core Folders

### `papertek/lib/ui`

- **Purpose**: user-facing screens, visual composition, interaction flow.
- **Key files**:
  - `app.dart`: app theme and root screen switch by DB-open state.
  - `main_shell.dart`: top-level nav/menu and tab body selection.
  - `start_screen.dart`: show file creation/open entry point.
  - `show_tab.dart`: show metadata and venue/positions interface.
  - `spreadsheet/spreadsheet_tab.dart`: fixture grid + sidebar editing experience.

### `papertek/lib/providers`

- **Purpose**: dependency graph and reactive stream wiring.
- **Key file**:
  - `show_provider.dart`: creates all repo providers and stream providers from active DB.
- **Functional role**:
  - Central "bus" between UI and repository layers.

### `papertek/lib/repositories`

- **Purpose**: domain-specific query and write APIs.
- **Key files**:
  - `fixture_repository.dart`: fixture row watch stream, fixture/part updates, add/clone/delete.
  - `show_meta_repository.dart`: show metadata updates.
  - `venue_repository.dart`: channels/addresses/dimmers/circuits reads.
  - `position_repository.dart`: lighting positions/groups.
  - `tracked_write_repository.dart`: write tracking/versioning support.

### `papertek/lib/database`

- **Purpose**: schema, migrations, DB opening strategy.
- **Key files**:
  - `database.dart`: Drift DB declaration, table list, migration strategy, schema version.
  - `tables/*.dart`: each table definition.

---

## Functional Map (Who Talks to Who)

## UI -> Providers -> Repositories -> DB

- **Spreadsheet flow**
  - `SpreadsheetTab` watches `fixtureRowsProvider`.
  - `fixtureRowsProvider` uses `fixtureRepoProvider.watchRows()`.
  - `FixtureRepository.watchRows()` reads `fixtures` + `fixture_parts`.
  - Edit actions route through `_onEdit(...)` back into repository write methods.

- **Show metadata flow**
  - `ShowTab` watches `currentShowMetaProvider`.
  - Writes go through `showMetaRepoProvider`.

- **Venue/positions flow**
  - UI tabs in `ui/positions` use stream providers from `show_provider.dart`.
  - Backed by `position_repository.dart` and `venue_repository.dart`.

---

## Spreadsheet Area: Internal Geography

### `papertek/lib/ui/spreadsheet/spreadsheet_tab.dart`

- **What it owns**
  - Column metadata and layout controls.
  - Grid data source classes.
  - Edit lifecycle handling.
  - Sidebar rendering and sync.
  - Search/filter + column visibility + resize + drag order.

- **Core classes**
  - `_SpreadsheetTabState`: orchestrates providers, selection, toolbar actions, context menu.
  - `_MinimalFixtureSource` (active/stable path): builds rows (including multipart child rows), handles edit submission, filtering, and visual style.
  - `_FixtureDataSource` (legacy/alternate path): richer source with similar responsibilities.

- **Key communication points**
  - Incoming data: `fixtureRowsProvider.stream`.
  - Outgoing edits: `_onEdit(...)` -> `FixtureRepository` updates.
  - Sidebar sync: row/cell activation updates selected fixture + column.

---

## Database Geography by Concern

### Show/Meta

- `tables/show_meta.dart`
- `repositories/show_meta_repository.dart`
- `providers/currentShowMetaProvider`

### Fixtureing

- `tables/fixtures.dart` (`fixture_types`, `fixtures`, `fixture_parts`)
- `repositories/fixture_repository.dart`
- `providers/fixtureRowsProvider`
- `ui/spreadsheet/spreadsheet_tab.dart`

### Venue/Patch Infrastructure

- `tables/venue.dart`
- `repositories/venue_repository.dart`
- `providers/channelsProvider`, `addressesProvider`, `dimmersProvider`, `circuitsProvider`

### Positions

- `repositories/position_repository.dart`
- `ui/positions/*`

---

## "If I Need To Change X, Go Here"

- **Add new fixture field shown in spreadsheet**
  1. Add DB column/migration in `tables/fixtures.dart` or `tables/fixtures.dart` (`fixture_parts`) + `database.dart`.
  2. Expose in `FixtureRow` + `watchRows()` mapping.
  3. Add edit method in `FixtureRepository` if needed.
  4. Wire column and edit routing in `spreadsheet_tab.dart`.

- **Change fixture create/clone defaults**
  - `FixtureRepository.addFixture()` and `FixtureRepository.cloneFixture()`.

- **Adjust grid behaviors (sort/filter/drag/resize/sidebar sync)**
  - `spreadsheet_tab.dart` (`_SpreadsheetTabState`, data source classes).

- **Change top-level app/tab structure**
  - `main_shell.dart`.

- **Change providers and data dependencies**
  - `show_provider.dart`.

---

## Current Technical Debt / Hotspots

- `spreadsheet_tab.dart` is feature-dense and now carries multiple source patterns.
- Multipart fixture behavior is powerful but increases edit-routing complexity.
- Legacy source class + active minimal source coexist; eventual consolidation would reduce maintenance risk.

---

## Recommended Next Documentation Add-ons

- A field-level "ownership matrix" (column -> table -> repository method -> UI control).
- ADR for spreadsheet stabilization decisions and why edit lifecycle is structured as it is.
- A migration checklist template for any future schema version bump.
