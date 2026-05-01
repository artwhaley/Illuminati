# TICKET-07 — Repository: Mutation Method Updates

**Phase:** 4 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. Changes are mechanical renames and a new method. No logic changes.  
**Depends on:** TICKET-06  
**Blocks:** TICKET-09 (ColumnSpec onEdit callbacks reference these methods)

---

## Goal

Update all fixture mutation methods in `FixtureRepository` to use new field names, remove `toggleFlag`, and add the split dimmer/address and part-level wattage methods.

---

## File to Read First

`papertek/lib/repositories/fixture_repository.dart` — lines 469–600. Read all `update*` and `toggleFlag` methods. Also understand the `_updateField` and `_updatePartField` helper patterns.

---

## Changes

### Remove Entirely
```dart
Future<void> toggleFlag(int id) async { ... }
```
Delete the entire method body and declaration.

### Rename Methods (internal rename — no wrapper)

```dart
// OLD:
Future<void> updateFunction(int id, String? fn) => _updateField(
    id, 'function', fn, (f) => f.function, (v) => FixturesCompanion(function: Value(v)));

Future<void> updateFocus(int id, String? focus) => _updateField(
    id, 'focus', focus, (f) => f.focus, (v) => FixturesCompanion(focus: Value(v)));

// NEW:
Future<void> updatePurpose(int id, String? purpose) => _updateField(
    id, 'purpose', purpose, (f) => f.purpose, (v) => FixturesCompanion(purpose: Value(v)));

Future<void> updateArea(int id, String? area) => _updateField(
    id, 'area', area, (f) => f.area, (v) => FixturesCompanion(area: Value(v)));
```

### Update `updateUnitNumber` Signature

```dart
// OLD:
Future<void> updateUnitNumber(int id, int? unitNumber) => _updateField(
    id, 'unit_number', unitNumber, (f) => f.unitNumber, (v) => FixturesCompanion(unitNumber: Value(v)));

// NEW:
Future<void> updateUnitNumber(int id, String? unitNumber) => _updateField(
    id, 'unit_number', unitNumber, (f) => f.unitNumber, (v) => FixturesCompanion(unitNumber: Value(v)));
```

### Remove `updateWattage` on Fixtures

Delete:
```dart
Future<void> updateWattage(int id, String? wattage) => _updateField(
    id, 'wattage', wattage, (f) => f.wattage, (v) => FixturesCompanion(wattage: Value(v)));
```

### Split `updatePartAddress` into Two Methods

The existing `updatePartAddress` was writing to the dimmer (old `address` column). Replace it with:

```dart
Future<void> updatePartDimmer(int fixtureId, int partOrder, String? dimmer) =>
    _updatePartByOrder(fixtureId, partOrder, 'dimmer', dimmer,
        (p) => p.dimmer, (v) => FixturePartsCompanion(dimmer: Value(v)));

Future<void> updatePartAddress(int fixtureId, int partOrder, String? address) =>
    _updatePartByOrder(fixtureId, partOrder, 'address', address,
        (p) => p.address, (v) => FixturePartsCompanion(address: Value(v)));
```

*(Use whatever internal helper pattern `updatePartCircuit` currently uses — replicate exactly.)*

### Add Intensity-Level Dimmer and Address Methods

Pattern these exactly after the existing `updateIntensityIp`, `updateIntensitySubnet`, etc.:

```dart
Future<void> updateIntensityDimmer(int fixtureId, String? dimmer) =>
    _updateIntensityField(fixtureId, 'dimmer', dimmer, (p) => p.dimmer,
        (v) => FixturePartsCompanion(dimmer: Value(v)));

Future<void> updateIntensityAddress(int fixtureId, String? address) =>
    _updateIntensityField(fixtureId, 'address', address, (p) => p.address,
        (v) => FixturePartsCompanion(address: Value(v)));
```

### Add Part-Level Wattage Method

```dart
Future<void> updatePartWattage(int fixtureId, int partOrder, String? wattage) =>
    _updatePartByOrder(fixtureId, partOrder, 'wattage', wattage,
        (p) => p.wattage, (v) => FixturePartsCompanion(wattage: Value(v)));
```

---

## Verify

All mutation methods compile. No references to `toggleFlag`, `updateFunction`, `updateFocus`, or fixture-level `updateWattage` remain in the repository file.
