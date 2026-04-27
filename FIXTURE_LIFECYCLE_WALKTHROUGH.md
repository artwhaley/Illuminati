# Fixture Lifecycle Walkthrough

## 1) Create Fixture

```mermaid
sequenceDiagram
  participant U as User
  participant UI as SpreadsheetTab
  participant RP as fixtureRepoProvider
  participant R as FixtureRepository
  participant DB as Drift DB
  participant S as fixtureRowsProvider stream

  U->>UI: Click "Add Fixture"
  UI->>RP: read fixtureRepoProvider
  UI->>R: addFixture(afterSortOrder?)
  R->>DB: insert fixtures row
  R->>DB: insert default intensity fixture_part (part_order=0)
  DB-->>S: stream emits updated fixtures
  S-->>UI: fixtureRowsProvider updates rows
  UI-->>U: new fixture appears in grid/sidebar
```

### Create path details

- Entry point: spreadsheet action button (`_addFixture`).
- Repository allocates `sort_order` intelligently (append or midpoint insertion).
- New fixture always gets baseline intensity part row for immediate editability.
- Reactive stream update is the source of truth for UI refresh.

---

## 2) Clone Fixture

```mermaid
sequenceDiagram
  participant U as User
  participant UI as SpreadsheetTab
  participant R as FixtureRepository
  participant DB as Drift DB
  participant S as fixtureRowsProvider

  U->>UI: Clone selected fixture
  UI->>R: cloneFixture(sourceId)
  R->>DB: copy fixture row (new id, adjusted sort_order)
  R->>DB: copy all fixture_parts rows
  DB-->>S: stream emits updated list
  S-->>UI: grid/sidebar refresh with clone
```

### Clone specifics

- Copies fixture-level and all part-level data.
- Unit number may auto-increment when present.
- Preserves patch/network part data in clone.

---

## 3) Edit Fixture (Grid Cell)

```mermaid
sequenceDiagram
  participant U as User
  participant G as SfDataGrid
  participant DS as DataGridSource
  participant UI as SpreadsheetTab._onEdit
  participant R as FixtureRepository
  participant DB as Drift DB
  participant S as fixtureRowsProvider

  U->>G: Double-click editable cell
  G->>DS: buildEditWidget(...)
  U->>G: Type value + Enter
  G->>DS: onCellSubmit(...)
  DS->>UI: onCellEditCommit(fixture,col,value,partOrder?)
  UI->>R: route by column and part context
  R->>DB: update fixtures or fixture_parts
  DB-->>S: stream emits update
  S-->>UI: grid/sidebar sync to latest row
```

### Edit routing rules

- **Fixture-level fields** (`position`, `unit`, `type`, `function`, `focus`, `accessories`) -> `fixtures`.
- **Patch/network fields** (`chan`, `dimmer/address`, `circuit`, `ip`, `subnet`, `mac`, `ipv6`) -> `fixture_parts`.
- **Multipart rows**
  - Parent row = fixture-level context.
  - Child row = part-specific updates (uses `partOrder`).

---

## 4) Toggle Status Booleans

```mermaid
sequenceDiagram
  participant U as User
  participant UI as Grid checkbox/interaction
  participant R as FixtureRepository
  participant DB as Drift DB
  participant S as fixtureRowsProvider

  U->>UI: Toggle patch/hung/focused
  UI->>R: setPatched/setHung/setFocused
  R->>DB: write int flag (0/1)
  DB-->>S: stream emits update
  S-->>UI: status visuals refresh
```

---

## 5) Delete Fixture

```mermaid
sequenceDiagram
  participant U as User
  participant UI as SpreadsheetTab
  participant R as FixtureRepository
  participant DB as Drift DB
  participant S as fixtureRowsProvider

  U->>UI: Delete fixture (context/sidebar)
  UI->>UI: Confirm dialog
  UI->>R: deleteFixture(id)
  R->>DB: delete fixtures row
  DB->>DB: cascade delete fixture_parts
  DB-->>S: stream emits update
  S-->>UI: grid/sidebar selection clears and refreshes
```

---

## Lifecycle Reliability Notes

- Stream updates are intentionally deferred during active grid edit to avoid collapsing editor state.
- Selection and sidebar sync are updated from grid focus/tap activation paths.
- Column visibility/ordering and UI state are maintained separately from persisted fixture data.
