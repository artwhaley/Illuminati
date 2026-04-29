# TICKET-07: Repository — `addFixtureFromDraft` with Undo Batching

## Context
The new "Add Fixture" flow submits a populated `FixtureDraft` to the database. We need a
repository method that inserts the fixture + all its parts in a single undo frame.

### Prerequisites
- TICKET-03 (`FixtureDraft` model)
- TICKET-04 (controller calls `repo.addFixtureFromDraft`)

### File to modify
- `papertek/lib/repositories/fixture_repository.dart`

---

## Current State

The existing `addFixture()` creates a blank fixture + blank intensity part. The tracked write
repository already has `beginBatchFrame(String desc)` / `endBatchFrame()` at lines 306-317
of `tracked_write_repository.dart`.

---

## Task

### 1. Add import at top of `fixture_repository.dart`
```dart
import '../ui/spreadsheet/fixture_draft.dart';
```

### 2. Add `addFixtureFromDraft` after the existing `addFixture()` method

```dart
/// Inserts a new fixture pre-populated from [draft].
/// All inserts are a single undo frame.
Future<int> addFixtureFromDraft(FixtureDraft draft) async {
  final sort = await _maxSortOrder() + 1.0;
  _tracked.beginBatchFrame('Add fixture');
  try {
    // 1. Fixture row
    final fixtureRes = await _tracked.insertRow(
      table: 'fixtures',
      doInsert: () => _db.into(_db.fixtures).insert(FixturesCompanion(
        position:    Value(draft.position),
        unitNumber:  Value(draft.unitNumber),
        fixtureType: Value(draft.fixtureType),
        wattage:     Value(draft.wattage),
        function:    Value(draft.function),
        focus:       Value(draft.focus),
        accessories: Value(draft.accessories),
        flagged:     const Value(0),
        sortOrder:   Value(sort),
      )),
      buildSnapshot: _buildSnapshot,
    );
    final fixtureId = fixtureRes.rowId;

    // 2. Intensity part
    await _tracked.insertRow(
      table: 'fixture_parts',
      doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
        fixtureId:  Value(fixtureId),
        partOrder:  const Value(0),
        partType:   const Value('intensity'),
        channel:    Value(draft.channel),
        address:    Value(draft.dimmer),
        circuit:    Value(draft.circuit),
        ipAddress:  Value(draft.ipAddress),
        subnet:     Value(draft.subnet),
        macAddress: Value(draft.macAddress),
        ipv6:       Value(draft.ipv6),
      )),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
              .getSingle()).toJson(),
    );

    // 3. Gel part (optional)
    if (draft.color != null && draft.color!.isNotEmpty) {
      final maxOrder = await _maxPartOrder(fixtureId);
      await _tracked.insertRow(
        table: 'fixture_parts',
        doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
          fixtureId: Value(fixtureId),
          partOrder: Value(maxOrder + 1),
          partType:  const Value('gel'),
          partName:  Value(draft.color),
        )),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                .getSingle()).toJson(),
      );
    }

    // 4. Gobo parts (optional)
    for (final entry in [(draft.gobo1), (draft.gobo2)].indexed) {
      final name = entry.$2;
      if (name != null && name.isNotEmpty) {
        final maxOrder = await _maxPartOrder(fixtureId);
        await _tracked.insertRow(
          table: 'fixture_parts',
          doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
            fixtureId: Value(fixtureId),
            partOrder: Value(maxOrder + 1),
            partType:  const Value('gobo'),
            partName:  Value(name),
          )),
          buildSnapshot: (id) async =>
              (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                  .getSingle()).toJson(),
        );
      }
    }

    return fixtureId;
  } finally {
    _tracked.endBatchFrame();
  }
}
```

### 3. Update `SpreadsheetViewController.submitAddFixture()`
```dart
Future<void> submitAddFixture() async {
  final draft = addDraft;
  if (draft == null) return;
  await repo.addFixtureFromDraft(draft);
  if (continueAdding) {
    draft.advanceForContinue();
    notifyListeners();
  } else {
    cancelAddMode();
  }
}
```

---

## Verification / Tests

- [ ] Fill in Position + Type, click ADD FIXTURE — new row appears in grid.
- [ ] Press Ctrl+Z — entire fixture (all parts) removed in one undo step.
- [ ] "Continue adding" with unitNumber = 5 → next draft has unitNumber = 6, channel cleared.
- [ ] Revisions table shows inserts sharing the same `batchId`.
