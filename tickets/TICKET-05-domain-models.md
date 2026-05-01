# TICKET-05 — Domain Models: FixtureRow and FixturePartRow

**Phase:** 3 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. Changes are field additions/removals/renames with no logic changes.  
**Depends on:** TICKETS 02–04 (build_runner must have run so generated companions exist)  
**Blocks:** TICKET-06 (watchRows query uses these classes)

---

## Goal

Update `FixturePartRow` and `FixtureRow` in `fixture_repository.dart` to match the new schema. No logic changes — only the data shape.

---

## File to Read First

`papertek/lib/repositories/fixture_repository.dart` — lines 1–101 (the two data classes).

---

## Changes to `FixturePartRow` (lines 8–38)

**Rename field:** `address` → `dimmer`  
**Add fields:**
```dart
final String? address;   // DMX address (new)
final String? wattage;   // moved from fixture level
```

**Update constructor** to include the new fields with `this.address` and `this.wattage` (both nullable, default null).

Final field list: `id, partOrder, partName, channel, dimmer, address, wattage, circuit, ipAddress, subnet, macAddress, ipv6, color, gobo, accessories`

---

## Changes to `FixtureRow` (lines 40–101)

**Rename fields:**
- `function` → `purpose`
- `focus` → `area`

**Change type:**
- `unitNumber: int?` → `unitNumber: String?`

**Remove fields entirely:**
- `wattage` — no replacement, no convenience accessor
- `flagged`

**Add field:**
- `address: String?` — convenience accessor reading the intensity part's DMX address (mirrors how `dimmer` works currently)

**Update constructor** accordingly. The `required this.flagged` becomes just gone. The `wattage` parameter is removed.

**Update `isMultiPart` getter** — no change needed, it reads `parts.length`.

---

## Important

The comment on line 73 currently reads:
```dart
final String? dimmer;   // raw address from intensity part (fixture_parts.address)
```
Update it to:
```dart
final String? dimmer;   // physical dimmer from intensity part (fixture_parts.dimmer)
```
And add for the new field:
```dart
final String? address;  // DMX address from intensity part (fixture_parts.address)
```

---

## Verify

After this ticket, `FixtureRow` and `FixturePartRow` compile cleanly. The `watchRows()` method below them will have errors — those are fixed in TICKET-06.
