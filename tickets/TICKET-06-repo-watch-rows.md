# TICKET-06 — Repository: Update watchRows Query

**Phase:** 4 of 10  
**Executor:** Sonnet  
**Delegation:** None — the `watchRows` query assembles FixtureRow from raw Drift objects and requires careful mapping. Haiku may miss subtle field pairing.  
**Depends on:** TICKET-05 (FixtureRow/FixturePartRow must be updated first)  
**Blocks:** TICKET-07

---

## Goal

Update the `watchRows()` method in `FixtureRepository` so it builds `FixtureRow` and `FixturePartRow` instances using the new schema fields. Also update `addFixture`, `addFixtureFromDraft`, and `cloneFixture` which contain inline `FixturesCompanion` / `FixturePartsCompanion` calls referencing old field names.

---

## File to Read First

`papertek/lib/repositories/fixture_repository.dart` — lines 111–467. Read the full `watchRows`, `addFixture`, `addFixtureFromDraft`, and `cloneFixture` methods.

Also read `papertek/lib/ui/spreadsheet/fixture_draft.dart` — this class likely has `function`, `focus`, `wattage`, `flagged` fields that need parallel updates.

---

## Changes in `watchRows()` (approx lines 111–244)

In the `return FixtureRow(...)` call (around line 200):

1. Replace `function: f.function` → `purpose: f.purpose`
2. Replace `focus: f.focus` → `area: f.area`
3. Replace `wattage: f.wattage` → *(remove entirely)*
4. Replace `flagged: f.flagged != 0` → *(remove entirely)*
5. Replace `unitNumber: f.unitNumber` — type is now `String?`, no cast needed (Drift TextColumn returns `String?`)
6. Add `address: intensityPart?.address` (new field)

In the `parts: fParts.map((p) => FixturePartRow(...))` block:

1. Replace `address: p.address` → `dimmer: p.dimmer`
2. Add `address: p.address`
3. Add `wattage: p.wattage`

---

## Changes in `addFixture()` (approx line 268)

Remove `flagged: const Value(0)` from the `FixturesCompanion` insert. The column no longer exists.

---

## Changes in `addFixtureFromDraft()` (approx line 292)

In the `FixturesCompanion` insert:
- Replace `function: Value(draft.function)` → `purpose: Value(draft.purpose)`
- Replace `focus: Value(draft.focus)` → `area: Value(draft.area)`
- Remove `wattage: Value(draft.wattage)`
- Remove `flagged: const Value(0)`

In the `FixturePartsCompanion` insert:
- Replace `address: Value(draft.dimmer)` → `dimmer: Value(draft.dimmer)`
- Add `wattage: Value(draft.wattage)` (wattage is now on the part)

---

## Changes in `cloneFixture()` (approx line 358)

In the `FixturesCompanion` insert:
- Replace `function: Value(source.function)` → `purpose: Value(source.purpose)`
- Replace `focus: Value(source.focus)` → `area: Value(source.area)`
- Remove `wattage: Value(source.wattage)`
- Remove `flagged: const Value(0)`
- Remove `unitNumber: Value(source.unitNumber != null ? source.unitNumber! + 1 : null)` — unit number is now a String, so the `+ 1` is invalid. Replace with: `unitNumber: Value(source.unitNumber)` (clone gets the same unit number; user can edit it)

In the `FixturePartsCompanion` insert (inside the parts loop):
- Replace `address: Value(part.address)` → `dimmer: Value(part.dimmer)`
- Add `address: Value(part.address)`
- Add `wattage: Value(part.wattage)`

---

## Changes in `FixtureDraft`

Read `papertek/lib/ui/spreadsheet/fixture_draft.dart`. Update it to:
- Rename `function` → `purpose`
- Rename `focus` → `area`
- Add `wattage` (String?) — wattage now lives on the draft at the part level
- Remove any `flagged` field

---

## Verify

`watchRows`, `addFixture`, `addFixtureFromDraft`, `cloneFixture` all compile without errors. `FixtureRow` and `FixturePartRow` are constructed correctly. The remaining compile errors will be in the repository's mutation methods (TICKET-07) and in UI files.
