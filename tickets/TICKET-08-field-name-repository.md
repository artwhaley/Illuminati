# TICKET-08 — FieldNameRepository

**Phase:** 4 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. New class with simple CRUD pattern matching existing repositories.  
**Depends on:** TICKET-04 (`FieldNames` Drift table and generated companions must exist)  
**Blocks:** TICKET-10 (FieldNameNotifier consumes this repository)

---

## Goal

Create `FieldNameRepository` — a simple data access class for reading and writing user-editable field display names from the `field_names` table.

---

## Files to Read First

1. `papertek/lib/repositories/fixture_repository.dart` — for style/pattern reference (constructor, `_db` dependency)
2. `papertek/lib/database/database.dart` — to confirm `fieldNames` table accessor name after build_runner runs

---

## Step 1: Create New File

Create `papertek/lib/repositories/field_name_repository.dart`:

```dart
import 'package:drift/drift.dart';
import '../database/database.dart';

class FieldNameRepository {
  FieldNameRepository(this._db);
  final AppDatabase _db;

  /// Returns all stored display name overrides as a map of fieldId → displayName.
  Future<Map<String, String>> getAllDisplayNames() async {
    final rows = await _db.select(_db.fieldNames).get();
    return {for (final r in rows) r.fieldId: r.displayName};
  }

  /// Watches display names and emits whenever they change.
  Stream<Map<String, String>> watchAllDisplayNames() {
    return (_db.select(_db.fieldNames)).watch().map(
      (rows) => {for (final r in rows) r.fieldId: r.displayName},
    );
  }

  /// Persists a display name override. Inserts or updates.
  Future<void> setDisplayName(String fieldId, String displayName) async {
    await _db.into(_db.fieldNames).insertOnConflictUpdate(
      FieldNamesCompanion(
        fieldId: Value(fieldId),
        displayName: Value(displayName),
      ),
    );
  }

  /// Resets a field to its default by removing the override row.
  /// The default is re-inserted by the migration, so this leaves it as-is.
  /// Pass the default label to restore it explicitly.
  Future<void> resetToDefault(String fieldId, String defaultLabel) async {
    await setDisplayName(fieldId, defaultLabel);
  }
}
```

---

## Step 2: Wire into the Provider Graph

Find the file where `FixtureRepository` is provided (likely `show_provider.dart` or a similar providers file). Add a provider for `FieldNameRepository` in the same style:

```dart
final fieldNameRepositoryProvider = Provider<FieldNameRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);  // use whatever the db provider is named
  return FieldNameRepository(db);
});
```

---

## Verify

`FieldNameRepository` compiles. `getAllDisplayNames()` returns a `Map<String, String>`. The provider resolves without error.
