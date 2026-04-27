# PaperTek Schema Deep Dive

## Core Fixture ERD

```mermaid
erDiagram
  FIXTURE_TYPES ||--o{ FIXTURES : "fixture_type_id"
  FIXTURES ||--o{ FIXTURE_PARTS : "fixture_id (cascade delete)"

  FIXTURE_TYPES {
    int id PK
    text name
    text wattage
    int part_count
    text default_parts_json
  }

  FIXTURES {
    int id PK
    int fixture_type_id FK nullable
    text fixture_type nullable
    text position nullable
    int unit_number nullable
    text wattage nullable
    text function nullable
    text focus nullable
    int flagged default 0
    real sort_order default 0
    text accessories nullable
    int hung default 0
    int focused default 0
    int patched default 0
  }

  FIXTURE_PARTS {
    int id PK
    int fixture_id FK
    int part_order
    text part_type
    text part_name nullable
    text channel nullable
    text address nullable
    text circuit nullable
    text ip_address nullable
    text mac_address nullable
    text subnet nullable
    text ipv6 nullable
    text extras_json nullable
    "UNIQUE(fixture_id, part_order)"
  }
```

## Table Intent

- **`fixture_types`**
  - Fixture archetypes/templates.
  - Supports default part metadata through JSON.

- **`fixtures`**
  - Fixture-level identity and high-level metadata.
  - Contains ordering (`sort_order`) and status flags (`patched`, `hung`, `focused`, `flagged`).

- **`fixture_parts`**
  - Part-level patch/network identity (intensity and other part types).
  - Enables multipart fixtures where each part carries independent channel/address/network fields.

## Constraints and Invariants

- `fixture_parts.fixture_id` uses cascade delete from parent fixture.
- `UNIQUE(fixture_id, part_order)` guarantees deterministic part indexing.
- `part_type` check constraint bounds allowed values.
- `sort_order` is real-valued, enabling midpoint insertion without mass reindexing.

## Soft Links vs Hard Links

- Hard FK: `fixtures.fixture_type_id -> fixture_types.id`.
- Soft-link behavior in code uses plain text fields in places (e.g., positional naming), enabling flexibility at cost of referential strictness.

## Migration History (Current: v12)

- `schemaVersion => 12` in `database.dart`.
- Key fixture-related migration steps:
  - v10: add `fixtures.sort_order`, seed from id.
  - v11: add `fixtures.accessories`, `fixtures.hung`, `fixtures.focused`.
  - v12: add `fixtures.patched`, add `fixture_parts.circuit`, seed patched from existing intensity channel/address data.

## Data Access Shape (as surfaced to UI)

- Repository model `FixtureRow` combines:
  - fixture-level fields from `fixtures`
  - derived/selected part-level fields from `fixture_parts`
  - optional `parts` list for multipart display/editing.

## Risk and Maintenance Notes

- Sorting, filtering, and edit routing depend on consistent column-name mappings.
- Multipart behavior increases complexity: parent vs child row edit paths should remain explicit.
- If adding new fixture fields, define whether they are:
  - fixture-level (belongs in `fixtures`)
  - part-level (belongs in `fixture_parts`)
  - derived-only (no storage).
