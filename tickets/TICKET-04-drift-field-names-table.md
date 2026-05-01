# TICKET-04 — Drift Table Definition: FieldNames

**Phase:** 2 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. New file, small, straightforward.  
**Depends on:** TICKET-01 (migration creates the SQL table; this creates the Dart class)  
**Blocks:** TICKET-08 (FieldNameRepository), TICKET-10 (FieldNameNotifier)

---

## Goal

Create a new Drift table class for `field_names` and register it with the database.

---

## Files to Read First

1. `papertek/lib/database/tables/fixtures.dart` — for style reference
2. `papertek/lib/database/database.dart` — to know where to add the import and table registration

---

## Step 1: Create New File

Create `papertek/lib/database/tables/field_names.dart`:

```dart
import 'package:drift/drift.dart';

class FieldNames extends Table {
  TextColumn get fieldId => text()();
  TextColumn get displayName => text()();

  @override
  Set<Column> get primaryKey => {fieldId};
}
```

---

## Step 2: Register in `database.dart`

Add import at the top of `database.dart` alongside the other table imports:
```dart
import 'tables/field_names.dart';
```

Add `FieldNames` to the `@DriftDatabase(tables: [...])` annotation. Place it in the "Migration 22" section (add a comment):
```dart
// Migration 22: User-editable field display names
FieldNames,
```

---

## Verify

`dart run build_runner build` completes. The generated `database.g.dart` should now include `fieldNames` table accessor and a `FieldNamesCompanion` class. Check that `FieldNamesCompanion` has `fieldId` and `displayName` fields.
