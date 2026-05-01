# TICKET-01 — Database Migration v21 → v22

**Phase:** 1 of 10  
**Executor:** Sonnet  
**Delegation:** None — requires full context of existing migration pattern and FTS5 SQL  
**Blocks:** All subsequent tickets

---

## Goal

Write the complete v22 migration in `database.dart`. This is the foundation for everything else. Get the SQL exactly right here and the rest of the refactor is mechanical.

---

## Files to Read First

1. `papertek/lib/database/database.dart` — full file. Understand `_createFts5Table()`, `onUpgrade`, and the `_tryAddColumn` helper pattern.
2. `papertek/lib/database/tables/fixtures.dart` — current `Fixtures` and `FixtureParts` table definitions.

---

## Changes

### 1. Bump schema version

In `database.dart` line 93:
```dart
static const currentSchemaVersion = 22;  // was 21
```

### 2. Add migration block in `onUpgrade`

Inside the `onUpgrade: (m, from, to) async` callback, after the existing `if (from < 21)` block, add:

```dart
if (from < 22) {
  // ── Fixtures table ──────────────────────────────────────────────────

  // Rename function → purpose
  await customStatement('ALTER TABLE fixtures RENAME COLUMN function TO purpose;');
  
  // Rename focus → area
  await customStatement('ALTER TABLE fixtures RENAME COLUMN focus TO area;');
  
  // unit_number stays named unit_number; type is effectively TEXT now
  // (SQLite stores the integers as text automatically when read as TextColumn)
  
  // ── FixtureParts table ──────────────────────────────────────────────

  // Rename address → dimmer (the old address field contained dimmer data)
  await customStatement('ALTER TABLE fixture_parts RENAME COLUMN address TO dimmer;');
  
  // Add address column (DMX address — new, starts empty)
  await _tryAddColumn(m, fixtureParts, fixtureParts.address);
  
  // Add wattage column (moved from fixtures)
  await _tryAddColumn(m, fixtureParts, fixtureParts.wattage);
  
  // Migrate wattage from fixtures → intensity parts
  await customStatement('''
    UPDATE fixture_parts
    SET wattage = (
      SELECT wattage FROM fixtures WHERE fixtures.id = fixture_parts.fixture_id
    )
    WHERE part_type = 'intensity' AND deleted = 0;
  ''');
  
  // ── field_names table ───────────────────────────────────────────────
  
  await customStatement('''
    CREATE TABLE IF NOT EXISTS field_names (
      field_id TEXT PRIMARY KEY,
      display_name TEXT NOT NULL
    );
  ''');
  
  await customStatement('''
    INSERT OR IGNORE INTO field_names (field_id, display_name) VALUES
      ('instrument', 'Instrument'),
      ('unit', 'Unit'),
      ('purpose', 'Purpose'),
      ('area', 'Area'),
      ('dimmer', 'Dimmer'),
      ('address', 'Address'),
      ('channel', 'Channel'),
      ('circuit', 'Circuit'),
      ('wattage', 'Wattage'),
      ('color', 'Color'),
      ('gobo', 'Gobo'),
      ('accessories', 'Accessories'),
      ('position', 'Position'),
      ('notes', 'Notes');
  ''');
  
  // ── Rebuild FTS5 ────────────────────────────────────────────────────
  // Column renames invalidate the old triggers. Drop everything and recreate.
  
  await customStatement('DROP TRIGGER IF EXISTS fixtures_after_insert;');
  await customStatement('DROP TRIGGER IF EXISTS fixtures_after_update;');
  await customStatement('DROP TRIGGER IF EXISTS fixture_parts_after_update;');
  await customStatement('DROP TABLE IF EXISTS fixtures_fts;');
  
  await _createFts5Table();
}
```

### 3. Update `_createFts5Table()`

Replace all references to `function` and `focus` with `purpose` and `area`:

- Virtual table definition: `purpose, area` (was `function, focus`)
- Initial population INSERT: `f.purpose, f.area` (was `f.function, f.focus`)
- INSERT column lists: `purpose, area` throughout
- All three trigger bodies: `new.purpose, new.area` and `f.purpose, f.area`

The method signature and structure stay identical — only the two column names change.

### 4. Add `FieldNames` to `@DriftDatabase` tables list

In the `@DriftDatabase(tables: [...])` annotation, add `FieldNames` to the list (add after `SpreadsheetViewPresets` in the Migration 14+ section). This requires the `FieldNames` table class to exist first — see TICKET-04. If doing these tickets in order, add the import and table reference after TICKET-04 is complete.

---

## Verify

- `dart run build_runner build` completes without schema mismatch errors
- Opening a fresh `.papertek` file creates all tables including `field_names`
- A v21 file opened after this migration has `purpose`, `area`, `dimmer` columns in the correct tables

---

## Handoff Notes for TICKET-02

The Fixtures Drift table definition must now remove `wattage`, `flagged`, `function`, `focus` and add `purpose`, `area`. The `unitNumber` column stays named `unit_number` in SQL but changes to `TextColumn` in Dart.
