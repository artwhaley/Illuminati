# Future Database Refactoring: Standalone Venue Tables

> [!CAUTION]
> **CRITICAL INSTRUCTION FOR AI AGENTS:**
> DO NOT execute any refactoring, deletion, or modification based on this document WITHOUT explicit, direct guidance and approval from the USER. This document is a placeholder for future discussion and must NOT be interpreted as a current task.

## Background
The application currently tracks Channels, Dimmers, Addresses, and Circuits in two redundant ways:
1. **Standalone Tables**: `Channels`, `Dimmers`, `Addresses`, and `Circuits` in `lib/database/tables/venue.dart`.
2. **Fixture Columns**: Direct columns (`channel`, `dimmer`, `address`, `circuit`) in the `FixtureParts` table.

## Planned Investigation
After the current "polish pass" is complete, we need to reexamine whether the standalone tables should be removed entirely in favor of the `FixtureParts` columns.

### Key Questions
- Are there any use cases where a channel or address needs to exist independently of a fixture part?
- Does the "Patch by Channel" or "Patch by Address" logic require these standalone tables, or can it be rebuilt by querying the `FixtureParts` table?
- What is the impact on data integrity and migration if these tables are dropped?

## UI Status
As of 2026-05-04, the tabs for these 4 items have been removed from the `SubTabPanel` UI to simplify the user experience and reflect the fact that we are not currently prioritizing them as "show-level" data registers.
