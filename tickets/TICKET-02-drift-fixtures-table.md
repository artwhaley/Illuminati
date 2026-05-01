# TICKET-02 — Drift Table Definition: Fixtures

**Phase:** 2 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. File is small and changes are mechanical.  
**Depends on:** TICKET-01 (migration SQL must be written first so Haiku can see the target schema)  
**Blocks:** TICKET-05 (domain models), build_runner regeneration

---

## Goal

Update `papertek/lib/database/tables/fixtures.dart` so the `Fixtures` Drift table class matches the v22 schema.

---

## File to Read First

`papertek/lib/database/tables/fixtures.dart` — full file (55 lines).

---

## Exact Changes to `Fixtures` class

**Remove these columns entirely:**
- `TextColumn get wattage` (line 20)
- `TextColumn get function` (line 21)
- `TextColumn get focus` (line 22)
- `IntColumn get flagged` (line 23)

**Add these columns (insert after `position`):**
```dart
TextColumn get purpose => text().nullable()();
TextColumn get area => text().nullable()();
```

**Change `unitNumber` column type** (line 19) from:
```dart
IntColumn get unitNumber => integer().nullable()();
```
to:
```dart
TextColumn get unitNumber => text().nullable()();
```

The `FixtureTypes` class is **not touched** — it has its own `wattage` field that belongs there (type-level default wattage, not fixture-level).

---

## Result

Final `Fixtures` class column order should be:
```
id, fixtureTypeId, fixtureType, position, unitNumber (TextColumn), 
purpose, area, sortOrder, hung, focused, patched, deleted
```

---

## Verify

Run `dart run build_runner build`. It will produce compile errors in files that reference the removed fields — this is expected and is the checklist for tickets 03–15. Do not fix those errors in this ticket.
