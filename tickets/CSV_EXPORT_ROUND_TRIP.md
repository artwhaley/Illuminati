# CSV export for fixture-data recovery and migration

## Status

Specification only. Implementation requires explicit approval under the project's database-compatibility rule.

## Goal

Export the current show's active fixture data to a human-readable CSV that the existing import workflow can bring into a new show file. This is a recovery and migration aid, not a replacement for the native show-file backup.

## Product behavior

- Add `Export Fixtures to CSV...` near the existing fixture import action.
- Export every active fixture in the show, independent of search, sorting, grouping, hidden columns, or current selection.
- Use one CSV row per intensity part. A single-part fixture produces one row; multipart fixtures repeat fixture-level values on each part row.
- Use the canonical spreadsheet/import column labels and include all supported built-in import fields.
- Include current custom fields by their displayed names.
- Save through the platform file picker, defaulting to a sanitized show name plus date, with a `.csv` extension.
- Write UTF-8 with a header row and RFC 4180-style quoting. Preserve embedded commas, quotes, and line breaks.
- Show a success message with fixture and row counts. Show a visible, actionable error if generation or writing fails.
- Export is read-only: it must not create revisions, mark the show dirty, alter autosave state, or mutate the database.

## Round-trip contract

The export must be accepted by the app's importer without manual header renaming. A round trip into an empty show must preserve all data currently supported by both the spreadsheet model and importer:

- fixture-level position, unit, type, purpose, area, and other importable fields;
- per-part channel, dimmer, address, circuit, wattage, network fields, and notes;
- gel/color, gobo, and accessory values represented in the delimiter form already understood by the importer;
- multipart grouping and part order;
- custom-field definitions/values, once importer support for custom columns is explicitly confirmed or added.

The exporter must not include internal database IDs as import keys. IDs are file-local implementation details and will be regenerated in the destination show.

## Known compatibility gaps to resolve before implementation

The current importer groups rows using `(position, unit, fixture type)`, ignores its multipart decision model, and does not currently establish a complete custom-field round-trip contract. Those limitations mean an exporter alone cannot honestly promise lossless migration. Before implementation, decide and test:

1. whether identical grouping keys can represent distinct fixtures;
2. how multipart identity and part order are encoded without changing the database schema;
3. whether custom fields are created by name during import or omitted with a prominent warning;
4. which collection and status fields the importer can faithfully reconstruct;
5. whether rows without a position should remain exportable/importable (the current importer skips them).

Version 1 may ship as `Export Fixtures to CSV` only after its supported/unsupported fields are listed in the export confirmation. Do not label it a full backup or lossless migration unless the round-trip tests prove that claim.

## Implementation shape (schema-neutral)

- Add a pure CSV encoder service that accepts `FixtureRow` plus the canonical `ColumnSpec` list and returns bytes/text.
- Keep file-picker and user messaging code in the UI/action layer.
- Derive headers and values from `ColumnSpec` where possible so import aliases and export labels cannot silently drift.
- No schema version bump, migration, new table, or stored export metadata.

## Acceptance tests

- Empty show, one fixture, quoted/multiline text, Unicode, nulls, and delimiter characters.
- Single-part and multipart fixtures preserve per-part values and order after export/import.
- Multiple gels, gobos, and accessories survive round trip.
- Two fixtures with the same position/unit/type do not merge accidentally.
- Orphaned/no-position fixtures have an intentional, tested outcome.
- Custom fields have an intentional, tested outcome.
- Hidden columns, filters, and grouping do not omit show data.
- Export causes zero database writes and zero revisions.
- A failed/cancelled save leaves the show unchanged and reports the correct result.

