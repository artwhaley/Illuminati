# TICKET-11 — DataSource: Field References and Unit Sort

**Phase:** 6 of 10  
**Executor:** Sonnet, with Haiku delegation for mechanical find-and-replace passes  
**Delegation:** Sonnet reads the file first, identifies all reference sites, then delegates a targeted find-and-replace to Haiku for the mechanical renames. Sonnet handles the sort comparator update itself.  
**Depends on:** TICKET-09 (ColumnSpec IDs), TICKET-05 (FixtureRow field names)  
**Blocks:** TICKET-14

---

## Goal

Update `fixture_data_source.dart` to use new field names on `FixtureRow` and `FixturePartRow`, fix the `unitNumber` sort comparator for alphanumeric `String?` values, and add `address` as a part-level display field.

---

## File to Read First

`papertek/lib/ui/spreadsheet/fixture_data_source.dart` — full file.

---

## Mechanical Renames (Delegate to Haiku)

Brief Haiku with the exact substitutions; it should not make any other changes:

| Find | Replace |
|------|---------|
| `f.function` / `row.function` / `fixture.function` | `f.purpose` / `row.purpose` / `fixture.purpose` |
| `f.focus` / `row.focus` / `fixture.focus` | `f.area` / `row.area` / `fixture.area` |
| `f.flagged` / `row.flagged` / `fixture.flagged` | **Remove** the reference entirely (and any conditional logic that branches on it) |
| `p.address` when used as "dimmer" | `p.dimmer` |
| Column ID string `'function'` | `'purpose'` |
| Column ID string `'focus'` | `'area'` |
| Column ID string `'type'` | `'instrument'` |
| Column ID string `'patch'` | `'patched'` |

---

## Sort Comparator Update (Sonnet handles this)

Find the `compare` method or wherever `unitNumber` is used in sorting. Currently it likely treats unit number as an integer or calls `int.tryParse`. 

Replace with an alphanumeric natural sort for `String?`:

```dart
// Natural sort for alphanumeric unit numbers: 1 < 1a < 1b < 2
int _compareUnitNumbers(String? a, String? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;   // nulls sort last
  if (b == null) return -1;

  // Extract leading integer prefix and alphabetic suffix
  final re = RegExp(r'^(\d+)(.*)$');
  final mA = re.firstMatch(a.trim());
  final mB = re.firstMatch(b.trim());

  if (mA == null && mB == null) return a.compareTo(b);
  if (mA == null) return 1;
  if (mB == null) return -1;

  final numA = int.parse(mA.group(1)!);
  final numB = int.parse(mB.group(1)!);
  if (numA != numB) return numA.compareTo(numB);
  return mA.group(2)!.compareTo(mB.group(2)!);
}
```

Wire this into the sort comparator wherever `unit` / `unit_number` is the sort column.

---

## Add `address` Column Display

The `address` column is new. If `fixture_data_source.dart` has any switch/case or if-chain that handles columns by ID, add `'address'` cases parallel to however `'dimmer'` is handled. Both are part-level fields; the display logic is identical — show part value for child rows, show intensity part value for parent rows.

---

## Verify

Spreadsheet compiles and renders. Unit numbers like `"1a"`, `"2"`, `"10b"` sort correctly. No references to `f.flagged`, `f.function`, `f.focus`, `f.wattage` remain.
