# Importer Rework Plan

## Overview of changes

| File | Action |
|------|--------|
| `column_spec.dart` | Add `importAliases` + `isImportable` to `ColumnSpec` |
| `csv_import_parser.dart` | Rename → `delimited_row_reader.dart`, implement interface, add delimiter detection |
| `lightwright_column_detector.dart` | **Delete** — replaced by `RowMatcher` |
| `csv_field_definitions.dart` | **Delete** — `PaperTekImportField` enum replaced by `ColumnSpec` |
| `import_service.dart` | Consume `Map<ColumnSpec, List<String>>` instead of `Map<PaperTekImportField, int>` |
| `column_mapping_screen.dart` | Wire to `RowMatcher`, update dropdown UX, support multi-header mapping |
| `main_shell.dart` | Update pipeline sequence |
| *(new)* `row_reader.dart` | Abstract `RowReader` interface |
| *(new)* `row_matcher.dart` | Smart alias-based column matching |
| *(new)* `multipart_detection_screen.dart` | Post-mapping multipart review dialog |

---

## Step 1 — Add `importAliases` to `ColumnSpec`

Add two fields to the `ColumnSpec` class:

```dart
final List<String>? importAliases;   // keyword hints for auto-matching
bool get isImportable => !isReadOnly && !isBoolean;  // false for HUNG/Patched/FOCUSED
```

All other steps derive from this. Status columns (HUNG, Patched, FOCUSED) are excluded from import automatically via `isImportable`.

### Approved alias definitions

| Column ID | Label | `importAliases` |
|-----------|-------|----------------|
| chan | CHAN | `channel, chan, ch, ch#` |
| dimmer | Dimmer | `dimmer, dim, dim#, dimmer number, dimmer no, dimmer #` |
| address | Address | `address, addr, dmx address, dmx addr, dmx#, u address, start address, dmx start` |
| circuit | CIRCUIT | `circuit, circuit number, circuit no, ckt, ckt#, circuit name` |
| position | POSITION | `position, pos, electric, location, batten, pipe, lighting position` |
| unit | Unit | `unit, unit number, unit no, unit#, instrument number` |
| instrument | Instrument | `instrument, instrument type, fixture type, type, luminaire, instrument name` |
| wattage | Wattage | `wattage, watts, watt, wattage (w), load` |
| purpose | Purpose | `purpose, use, function, system` |
| area | Area | `area, focus, focus area, focus point, target, zone, scene` |
| accessories | ACCESSORIES | `accessories, accessory, acc, hardware, top hat, barndoor, add-ons` |
| color | COLOR | `color, colour, gel, filter, gel color, gel colour, media, color filter` |
| gobo | GOBO | `gobo, gobo 1, gobo1, pattern, template` |
| ip | IP ADDRESS | `ip, ip address, ip addr, ipv4, network address, ip4` |
| subnet | SUBNET | `subnet, subnet mask, mask, netmask, network mask` |
| mac | MAC ADDRESS | `mac, mac address, mac addr, hardware address, physical address` |
| ipv6 | IPV6 | `ipv6, ipv6 address, ip6, ipv6 addr` |
| notes | NOTES | `notes, note, comment, comments, remarks, description` |
| hung | HUNG | *(not importable — status field)* |
| patched | Patched | *(not importable — status field)* |
| focused | FOCUSED | *(not importable — status field)* |

---

## Step 2 — `RowReader` interface + `DelimitedRowReader`

**New file:** `lib/services/import/row_reader.dart`

```dart
abstract class RowReader {
  Future<List<String>> readHeaders(String path);
  Future<List<Map<String, String>>> readRows(String path);
}
```

**New file:** `lib/services/import/delimited_row_reader.dart` (replaces `csv_import_parser.dart`)

Delimiter detection strategy:
1. Check file extension (`.csv` → try comma first, `.txt`/`.tsv` → try tab first).
2. Count occurrences of `\t`, `,`, `;`, `|` in the first line.
3. The delimiter with the highest count (above a minimum threshold) wins.
4. Tie-break: tab > comma > semicolon > pipe.

Output: `List<Map<String, String>>` — each row is a flat map of `{columnHeader → cellValue}`. Blank rows are silently skipped.

Replaces `CsvImportParser` entirely.

---

## Step 3 — `RowMatcher`

**New file:** `lib/services/import/row_matcher.dart`

```dart
class MatchSuggestion {
  final String importHeader;
  final int score;       // 0–100
  final bool isExact;
}

class RowMatcher {
  // Returns, per ColumnSpec, all import headers ranked by match score.
  Map<ColumnSpec, List<MatchSuggestion>> suggest(List<String> importHeaders);
}
```

**Scoring algorithm:**

1. Normalize both the import header and each alias: lowercase, trim, collapse whitespace.
2. **Exact match** (normalized header == alias) → score 100.
3. **Contains match** (normalized header contains alias, or alias contains header) → score 60 + length bonus.
4. **Word overlap** (how many alias words appear in the header) → score proportional to overlap fraction.
5. Score below 30 → no suggestion.

Returns per `ColumnSpec`: sorted list of `MatchSuggestion` for every import header that scored above threshold. The top suggestion per column drives the pre-fill.

**Replaces and deletes:** `lightwright_column_detector.dart` and `csv_field_definitions.dart`.

---

## Step 4 — Update `ColumnMappingScreen` (with multi-header mapping)

**File:** `lib/ui/import/column_mapping_screen.dart`

### Key type change

The mapping type is now `Map<ColumnSpec, List<String>>` — each column can have **zero, one, or many** import headers assigned to it. This replaces the old `Map<PaperTekImportField, int?>`.

### Why multiple headers per column?

Users may need to point two import columns at one PaperTek column. Examples:
- Vectorworks exports "Gobo 1" and "Gobo 2" as separate columns → both map to **GOBO**.
- Some exports have "Color 1" and "Color 2" → both map to **COLOR**.
- Any two text columns mapped to a non-collection field → values concatenate with ` + `.

### UI for multi-header mapping

Each column row in the mapping screen shows its currently-assigned headers as removable chips. A dropdown below the chips lets the user add another header. There is no hard limit on how many headers can be assigned to one column. A header already assigned elsewhere is still selectable (same header can feed two different columns if the user wants that).

Auto-fill from `RowMatcher`:
- Each column is pre-filled with its top-scoring suggestion as the first chip.
- The dropdown still shows: [other suggestions above threshold] → divider → [all import headers].

Position field still required before Import is enabled.

---

## Step 5 — Value combination rules in `ImportService`

**File:** `lib/services/import/import_service.dart`

### Mapping type

`importRows` accepts:
- `List<Map<String, String>>` — parsed rows from `DelimitedRowReader`
- `Map<ColumnSpec, List<String>>` — confirmed column mapping from UI

### Combining multiple input headers → one output column

When a column has N assigned import headers, collect all N cell values from the current row, then apply:

**Collection columns** (`isCollection: true` — COLOR, GOBO, ACCESSORIES):
1. For each assigned header value, split on common multi-value separators: `+`, `,`, `/`, `;`.
2. Trim each token and drop empties and no-color sentinels (`n/c`, `nc`, `open`, `none`, `-`).
3. Combine all tokens from all headers into a flat list.
4. Each token becomes one entry in the collection table (gel record, gobo record, accessory record).

Example: headers "Gobo 1" = `"B size"`, "Gobo 2" = `"Frost"` → gobo entries: `["B size", "Frost"]`.
Example: header "Color" = `"R32 + L132"` → gel entries: `["R32", "L132"]`.

**Non-collection columns** (all other fields):
1. Collect non-empty values from all assigned headers.
2. Join with ` + `.

Example: two "Notes" columns mapped together: `"Practical"` + `"Check focus"` → `"Practical + Check focus"`.

### Fixture-level vs. part-level routing

For Vectorworks multipart imports (one row per part):
- `isPartLevel: false` fields → stored on the parent `Fixture` (first non-null value in the group wins).
- `isPartLevel: true` fields → stored on the `FixturePart` for that row.

`NormalizedRow` and `PaperTekImportField` are deleted. The service works directly with the raw row maps and `ColumnSpec` metadata.

---

## Step 6 — Multipart Detection + Review Dialog

**New file:** `lib/ui/import/multipart_detection_screen.dart`

Appears between column mapping confirmation and the actual import write.

**Detection logic:**

1. Group rows by `(position_value, unit_number_value)`.
2. Any group with 2+ members = candidate.
3. Assign confidence:
   - **High**: mapped column values show clear part indicators (1/2/3, A/B/C, suffixes like `1a`/`1b`).
   - **Medium**: duplicate position+unit with no part indicator column present.
   - **Low**: position matches but unit numbers are similar (e.g., `101` and `101A`).

**Dialog UX:**

- Header: "Possible multipart fixtures detected"
- Table: one row per candidate group — Position | Unit# | Rows | Confidence | Action.
- Action dropdown per group: **Merge as multipart** / **Import as separate fixtures** / **Skip these rows**.
- Bulk buttons: "Merge all" / "Keep all separate."
- If zero candidates detected, skip this dialog entirely.

---

## Step 7 — Update `main_shell.dart`

New `_importFixtures` method (replacing `_importCsv`):

```
1. File picker (*.csv, *.txt, *.tsv)
2. DelimitedRowReader.readHeaders(path)
3. RowMatcher.suggest(headers) → initial mapping
4. Show ColumnMappingScreen → user confirms mapping
5. DelimitedRowReader.readRows(path) with confirmed mapping
6. Run multipart detection on parsed rows
7. If candidates found → show MultipartDetectionScreen → get user decisions
8. ImportService.importRows(rows, mapping, multipartDecisions)
9. Show ImportSummaryDialog
```

---

## Step 8 — Delete dead files

- `lib/services/import/csv_field_definitions.dart`
- `lib/services/import/lightwright_column_detector.dart`

---

## Implementation order

1. Step 1 — aliases added to ColumnSpec
2. Step 2 — RowReader interface + DelimitedRowReader
3. Steps 3 & 5 — RowMatcher and ImportService contract update (parallel, independent)
4. Step 4 — ColumnMappingScreen update (needs Steps 2, 3)
5. Step 6 — MultipartDetectionScreen (needs Steps 4, 5)
6. Step 7 — main_shell.dart wiring (needs all prior)
7. Step 8 — cleanup
