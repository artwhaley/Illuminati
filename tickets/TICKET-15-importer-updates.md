# TICKET-15 — Importer: Field Enum and Detector Updates

**Phase:** 10 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. Changes are enum renames and variant string additions.  
**Depends on:** TICKET-07 (repository method names), TICKET-09 (column IDs)  
**Blocks:** Nothing — importer will get a full rewrite soon; this is minimum viable sync

---

## Goal

Keep the importer compiling and functional against the new schema. Rename internal enum values to match the new field names. Retain broad variant matching so existing CSV files continue to import correctly.

---

## Files to Read First

1. Find and read the importer's field definition enum (likely `papertek/lib/features/import/csv_field_definitions.dart`)
2. Find and read the column detector (likely `papertek/lib/features/import/lightwright_column_detector.dart`)
3. Find the import logic that maps detected fields to repository calls — it will reference old method names

---

## Changes in `csv_field_definitions.dart`

Rename enum values:
- `function` → `purpose`
- `focus` → `area`

Add new enum value:
- `address` (for DMX address — distinct from `dimmer`)

Update any `displayName` and `hint` metadata strings to match:
- `purpose` → display: 'Purpose', hint: 'Function / Use'
- `area` → display: 'Area', hint: 'Focus Area / Zone'  
- `address` → display: 'Address', hint: 'DMX Address'

---

## Changes in `lightwright_column_detector.dart`

**`purpose` field** (was `function`) — keep all existing variants AND add new ones:
```
'function', 'purpose', 'use', 'use/function', 'func'
```

**`area` field** (was `focus`) — keep all existing variants AND add new ones:
```
'focus', 'area', 'foc', 'focus point', 'focus area'
```

**`dimmer` field** — keep all existing variants:
```
'dimmer', 'dim', 'dmr', 'dimmable', 'dimmer#', 'dim#'
```

**Add `address` field** detection:
```
'address', 'dmx', 'dmx address', 'dmx addr', 'universe/address'
```

**gobo1 / gobo2** — unchanged.

---

## Changes in Import Logic

Find wherever the import maps `PaperTekImportField` values to repository calls or `FixtureDraft` fields. Update:
- `PaperTekImportField.function` → `PaperTekImportField.purpose`
- `PaperTekImportField.focus` → `PaperTekImportField.area`
- `draft.function =` → `draft.purpose =`
- `draft.focus =` → `draft.area =`
- Any call to `repo.updateFunction` → `repo.updatePurpose`
- Any call to `repo.updateFocus` → `repo.updateArea`

Also update `FixtureDraft` field assignments for wattage — wattage now lives on the part, not the fixture. When importing wattage, it should go to `draft.wattage` (which is now part-level per TICKET-06).

---

## Verify

- Import of a Lightwright CSV with 'Function', 'Focus', and 'Dimmer' columns maps correctly
- Import of a CSV with 'Purpose' and 'Area' column headers also maps correctly  
- No compile errors referencing old enum values `PaperTekImportField.function` or `.focus`
- `gobo1` and `gobo2` still import successfully
