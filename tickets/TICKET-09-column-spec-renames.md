# TICKET-09 — ColumnSpec: Rename IDs, Labels, Split dimmer/address, Move wattage

**Phase:** 5 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. Changes are mechanical substitutions within `kColumns`. No logic changes.  
**Depends on:** TICKET-07 (new repository method names must exist before updating `onEdit` callbacks)  
**Blocks:** TICKET-10, TICKET-11, TICKET-12

---

## Goal

Update `kColumns` in `column_spec.dart` to use new field IDs, default labels, DB field names, and repository method names. Also make `label` mutable to support TICKET-10.

---

## File to Read First

`papertek/lib/ui/spreadsheet/column_spec.dart` — full file (372 lines).

---

## Step 1: Make `label` Mutable

In the `ColumnSpec` class definition, change:
```dart
final String label;
```
to:
```dart
final String defaultLabel;
String label;  // mutable; overridden at runtime by FieldNameNotifier
```

Update the constructor parameter from `required this.label` to `required this.defaultLabel` and add `String? label` with initialization:
```dart
ColumnSpec({
  ...
  required this.defaultLabel,
  String? label,
  ...
}) : label = label ?? defaultLabel;
```

Update the `ColumnSpec.custom` factory to pass `defaultLabel: name.toUpperCase()` (was `label:`).

Update `kColLabels` map at the bottom — it reads `c.label` which is now the mutable value, so it stays correct.

---

## Step 2: Update Each Column in `kColumns`

Apply these changes (all in `column_spec.dart` starting at line 107):

### `chan` — no ID change, update param name only
Change `label:` → `defaultLabel:` (value stays `'CHAN'`)

### `dimmer` — rename, split, update
Replace the single `dimmer` ColumnSpec with **two** ColumnSpecs:

```dart
ColumnSpec(
  id: 'dimmer',
  defaultLabel: 'Dimmer',
  dbField: 'dimmer',
  defaultWidth: 80.0,
  section: ColumnSection.patch,
  getValue: (f) => f.dimmer,
  isPartLevel: true,
  getPartValue: (f, p) => p.dimmer,
  onEdit: (id, val, repo, {partOrder, customRepo}) => partOrder != null
      ? repo.updatePartDimmer(id, partOrder, val)
      : repo.updateIntensityDimmer(id, val),
),
ColumnSpec(
  id: 'address',
  defaultLabel: 'Address',
  dbField: 'address',
  defaultWidth: 80.0,
  section: ColumnSection.patch,
  getValue: (f) => f.address,
  isPartLevel: true,
  getPartValue: (f, p) => p.address,
  onEdit: (id, val, repo, {partOrder, customRepo}) => partOrder != null
      ? repo.updatePartAddress(id, partOrder, val)
      : repo.updateIntensityAddress(id, val),
),
```

### `circuit` — no ID change, update param name only
Change `label:` → `defaultLabel:`

### `position` — no ID change, update param name only

### `unit` — update label default
```dart
id: 'unit',
defaultLabel: 'Unit',   // was 'U#'
```
Update `getValue` — was `f.unitNumber?.toString()`, now `f.unitNumber` (already a `String?`, no cast needed).  
Update `onEdit` — was `int.tryParse(val ?? '')`, now just `val`:
```dart
onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateUnitNumber(id, val),
```
Remove `isNumeric: true` — unit numbers are now alphanumeric text.

### `type` → `instrument`
```dart
id: 'instrument',
defaultLabel: 'Instrument',   // was 'FIXTURE TYPE'
dbField: 'fixture_type',      // unchanged
```
`getValue`, `getPartValue`, `onEdit` are unchanged.

### `wattage` — move to part-level
```dart
id: 'wattage',
defaultLabel: 'Wattage',
dbField: 'wattage',
defaultWidth: 80.0,
section: ColumnSection.fixture,
isPartLevel: true,
getValue: (f) => f.parts
    .where((p) => p.wattage != null)
    .map((p) => p.wattage!)
    .join(' / '),   // show all parts' wattages on parent row, separated
getPartValue: (f, p) => p.wattage,
onEdit: (id, val, repo, {partOrder, customRepo}) =>
    repo.updatePartWattage(id, partOrder ?? 0, val),
```

### `function` → `purpose`
```dart
id: 'purpose',
defaultLabel: 'Purpose',    // was 'PURPOSE'
dbField: 'purpose',         // was 'function'
getValue: (f) => f.purpose, // was f.function
onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updatePurpose(id, val),
```

### `focus` → `area`
```dart
id: 'area',
defaultLabel: 'Area',       // was 'FOCUS AREA'
dbField: 'area',            // was 'focus'
getValue: (f) => f.area,    // was f.focus
onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateArea(id, val),
```

### `accessories`, `color`, `gobo` — update param name only
Change `label:` → `defaultLabel:` on each.

### Network columns (`ip`, `subnet`, `mac`, `ipv6`) — update param name only

### Status columns (`hung`, `focused`) — update param name only

### `patch` → `patched`
```dart
id: 'patched',    // was 'patch'
defaultLabel: 'Patched',
dbField: 'patched',
```

### `notes` — update param name only

---

## Step 3: Update Derived Maps

The maps at the bottom derive from `kColumns` and will automatically reflect the changes. No manual edits needed for `kColumnById`, `kColumnByDbField`, `kDefaultColumnOrder`, `kDefaultWidths`, `kColLabels`.

---

## Verify

`column_spec.dart` compiles. Check that `kColumnById['purpose']` and `kColumnById['area']` and `kColumnById['instrument']` resolve. `kColumnById['function']`, `kColumnById['focus']`, `kColumnById['type']` should no longer exist.
