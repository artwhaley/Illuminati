# PaperTek — Architecture Boundaries

## Layer rules

| Layer | Lives in | Rule |
|---|---|---|
| **Database** | `lib/database/` | Drift tables, migrations, generated code, raw queries. No widget state or supervisor logic. |
| **Repository / domain** | `lib/repositories/` | The only layer that performs app-level writes. Owns transactions and invariants. |
| **State** | `lib/providers/` | Riverpod providers/controllers expose view state. Call repositories; never pass mutable Drift objects to widgets. |
| **UI** | `lib/ui/` | Widgets render state and call provider commands. **No direct Drift insert/update/delete.** |
| **Services** | `lib/services/` | Supabase sync, CSV import parsing, report rendering, file I/O. Called by repositories/controllers, not widget code. |

## The cardinal rule

> If a change affects persisted show data, it goes through a named repository method with a test. Direct SQL from UI is a bug.

## Key repositories

- `TrackedWriteRepository` — revision-aware writes for all design/show data (fixtures, venue, show_meta, etc.)
- `OperationalRepository` — work notes, maintenance log, flags — not supervisor-reviewed.
- `ShowFileService` — create/open `.papertek` files, schema version gate.
- `ImportService` — CSV/Lightwright import, batch transactions.
- `ReportQueryService` — read-only queries for report generation.
