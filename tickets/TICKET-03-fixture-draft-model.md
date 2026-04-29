# TICKET-03: Define `FixtureDraft` Model

## Context
The new "Add Fixture" mode uses a draft object to hold field values before inserting into the
database. We need a typed model for this — not a raw `Map<String, String?>` — so that the
sidebar editor, the controller, and the repository all have a consistent, safe contract.

### File to create
- `papertek/lib/ui/spreadsheet/fixture_draft.dart`

### Reference: `FixtureRow` fields (from `fixture_repository.dart`)
These are the fields on `FixtureRow`. Draft covers only the **editable** ones:
- `String? channel`        (intensity part)
- `String? dimmer`         (intensity part — maps to `address`)
- `String? circuit`        (intensity part)
- `String? position`       (fixture-level)
- `int? unitNumber`        (fixture-level)
- `String? fixtureType`    (fixture-level)
- `String? wattage`        (fixture-level)
- `String? color`          (gel part — `partName`)
- `String? gobo1`          (gobo part 0)
- `String? gobo2`          (gobo part 1)
- `String? function`       (fixture-level)
- `String? focus`          (fixture-level)
- `String? accessories`    (fixture-level)
- `String? ipAddress`      (intensity part)
- `String? subnet`         (intensity part)
- `String? macAddress`     (intensity part)
- `String? ipv6`           (intensity part)

### Reference: `kColumns` column IDs (from `column_spec.dart`)
The editable column IDs are: `chan`, `dimmer`, `circuit`, `position`, `unit`, `type`,
`function`, `focus`, `accessories`, `ip`, `subnet`, `mac`, `ipv6`.
Read-only columns are: `hung`, `patch`, `focused`, `notes`.
The `#` row-number column has no draft relevance.

---

## Task

Create `papertek/lib/ui/spreadsheet/fixture_draft.dart` with the following content:

```dart
import '../../repositories/fixture_repository.dart';
import 'column_spec.dart';

/// A mutable draft of a fixture being composed in the "Add Fixture" sidebar.
///
/// The [mask] is a set of column IDs that were selected for prefill from a
/// donor row. Fields not in the mask are left null even when a donor exists.
class FixtureDraft {
  // ── Fixture-level fields ────────────────────────────────────────────────────
  String? position;
  int?    unitNumber;
  String? fixtureType;
  String? wattage;
  String? function;
  String? focus;
  String? accessories;

  // ── Intensity-part fields ───────────────────────────────────────────────────
  String? channel;
  String? dimmer;    // stored as `address` in fixture_parts
  String? circuit;
  String? ipAddress;
  String? subnet;
  String? macAddress;
  String? ipv6;

  // ── Other-part fields ───────────────────────────────────────────────────────
  String? color;   // gel part
  String? gobo1;
  String? gobo2;

  // ── Factory: empty draft ────────────────────────────────────────────────────
  FixtureDraft();

  // ── Factory: prefill from donor using mask ──────────────────────────────────
  factory FixtureDraft.fromDonor(FixtureRow donor, Set<String> mask) {
    final d = FixtureDraft();
    if (mask.contains('position'))    d.position    = donor.position;
    if (mask.contains('unit'))        d.unitNumber  = donor.unitNumber;
    if (mask.contains('type'))        d.fixtureType = donor.fixtureType;
    if (mask.contains('wattage'))     d.wattage     = donor.wattage;
    if (mask.contains('function'))    d.function    = donor.function;
    if (mask.contains('focus'))       d.focus       = donor.focus;
    if (mask.contains('accessories')) d.accessories = donor.accessories;
    if (mask.contains('chan'))        d.channel     = donor.channel;
    if (mask.contains('dimmer'))      d.dimmer      = donor.dimmer;
    if (mask.contains('circuit'))     d.circuit     = donor.circuit;
    if (mask.contains('ip'))          d.ipAddress   = donor.ipAddress;
    if (mask.contains('subnet'))      d.subnet      = donor.subnet;
    if (mask.contains('mac'))         d.macAddress  = donor.macAddress;
    if (mask.contains('ipv6'))        d.ipv6        = donor.ipv6;
    // color/gobo not surfaced as direct kColumns IDs in the editable spec;
    // skip for now — add if column IDs are added later.
    return d;
  }

  /// After a successful insert with [continueAdding] = true, advance
  /// fields that should auto-increment and clear fields that should reset.
  ///
  /// - unitNumber is incremented if non-null.
  /// - channel, dimmer, circuit are cleared (they are almost always unique per fixture).
  void advanceForContinue() {
    if (unitNumber != null) unitNumber = unitNumber! + 1;
    channel = null;
    dimmer  = null;
    circuit = null;
  }
}
```

### Notes
- `wattage` exists on `FixtureRow` and `fixture_repository.dart` but is **not** currently in
  `kColumns` in `column_spec.dart`. Include the field in the draft model anyway — it will not
  be masked/shown in the picker until a column spec is added for it, but having it in the draft
  costs nothing and avoids future refactoring.
- Do not import `kColumns` or anything Flutter-widget-related in this file. It is a pure data
  class.

---

## Verification / Tests

Run `flutter analyze` — zero errors.

Unit test (add to `test/` directory as `fixture_draft_test.dart`):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/ui/spreadsheet/fixture_draft.dart';
import 'package:papertek/repositories/fixture_repository.dart';

void main() {
  group('FixtureDraft', () {
    final donor = FixtureRow(
      id: 1, position: 'Balcony Rail', unitNumber: 5,
      fixtureType: 'Source Four', flagged: false, patched: false,
      sortOrder: 1.0, hung: false, focused: false,
      channel: '42', dimmer: '42/5',
    );

    test('empty() creates all-null draft', () {
      final d = FixtureDraft();
      expect(d.position, isNull);
      expect(d.channel, isNull);
    });

    test('fromDonor copies only masked fields', () {
      final d = FixtureDraft.fromDonor(donor, {'position', 'type'});
      expect(d.position, 'Balcony Rail');
      expect(d.fixtureType, 'Source Four');
      expect(d.channel, isNull); // chan not in mask
      expect(d.unitNumber, isNull); // unit not in mask
    });

    test('advanceForContinue increments unitNumber and clears patch fields', () {
      final d = FixtureDraft.fromDonor(donor, {'unit', 'chan', 'dimmer'});
      d.advanceForContinue();
      expect(d.unitNumber, 6);
      expect(d.channel, isNull);
      expect(d.dimmer, isNull);
    });
  });
}
```
