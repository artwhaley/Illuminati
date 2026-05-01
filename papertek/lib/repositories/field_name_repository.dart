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

  /// Resets a field to its default by restoring the default label.
  Future<void> resetToDefault(String fieldId, String defaultLabel) async {
    await setDisplayName(fieldId, defaultLabel);
  }
}
