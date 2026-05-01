# TICKET-03 — Drift Table Definition: FixtureParts

**Phase:** 2 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. Small file, mechanical changes.  
**Depends on:** TICKET-01  
**Blocks:** TICKET-05, build_runner regeneration

---

## Goal

Update the `FixtureParts` Drift table class in `papertek/lib/database/tables/fixtures.dart` to match the v22 schema.

---

## File to Read First

`papertek/lib/database/tables/fixtures.dart` — full file (55 lines). Focus on the `FixtureParts` class starting at line 34.

---

## Exact Changes to `FixtureParts` class

**Rename the `address` column** (line 43) from:
```dart
TextColumn get address => text().nullable()();
```
to:
```dart
TextColumn get dimmer => text().nullable()();
```

**Add two new columns** after `dimmer`:
```dart
TextColumn get address => text().nullable()();
TextColumn get wattage => text().nullable()();
```

The `customConstraints` override at the bottom stays unchanged.

---

## Result

`FixtureParts` column order in the soft-links section should be:
```
channel, dimmer, address, wattage, circuit, ipAddress, macAddress, subnet, ipv6, extrasJson, deleted
```

---

## Verify

Run `dart run build_runner build` after both TICKET-02 and TICKET-03 are done. Compile errors from referencing files are expected and tracked by later tickets.
