import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

/// Manages user-defined custom fields and their values per fixture.
class CustomFieldRepository {
  CustomFieldRepository(this._db, this._tracked);

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  // ── Field Definitions ─────────────────────────────────────────────────────

  Stream<List<CustomField>> watchFields() => (_db.select(_db.customFields)
        ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
      .watch();

  Future<List<CustomField>> getFields() => (_db.select(_db.customFields)
        ..orderBy([(t) => OrderingTerm.asc(t.displayOrder)]))
      .get();

  Future<int> createField({
    required String name,
    String dataType = 'text',
  }) async {
    final maxOrder = await (_db.select(_db.customFields)
          ..orderBy([(t) => OrderingTerm.desc(t.displayOrder)])
          ..limit(1))
        .getSingleOrNull()
        .then((r) => r?.displayOrder ?? -1);

    return await _db.into(_db.customFields).insert(CustomFieldsCompanion(
          name: Value(name),
          dataType: Value(dataType),
          displayOrder: Value(maxOrder + 1),
        ));
  }

  Future<void> updateFieldName(int id, String name) async {
    await (_db.update(_db.customFields)..where((t) => t.id.equals(id)))
        .write(CustomFieldsCompanion(name: Value(name)));
  }

  Future<void> deleteField(int id) async {
    await _db.transaction(() async {
      // Cascade delete values first (if not handled by DB)
      await (_db.delete(_db.customFieldValues)..where((t) => t.customFieldId.equals(id))).go();
      await (_db.delete(_db.customFields)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> reorderFields(List<int> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.update(_db.customFields)..where((t) => t.id.equals(orderedIds[i])))
            .write(CustomFieldsCompanion(displayOrder: Value(i)));
      }
    });
  }

  // ── Values ────────────────────────────────────────────────────────────────

  Future<void> updateValue({
    required int fixtureId,
    required int fieldId,
    required String? value,
    String? fieldName, // For revision display
  }) async {
    final existing = await (_db.select(_db.customFieldValues)
          ..where((t) => t.fixtureId.equals(fixtureId))
          ..where((t) => t.customFieldId.equals(fieldId)))
        .getSingleOrNull();

    if (existing == null) {
      if (value == null || value.isEmpty) return;
      await _tracked.insertRow(
        table: 'custom_field_values',
        doInsert: () => _db.into(_db.customFieldValues).insert(CustomFieldValuesCompanion(
              fixtureId: Value(fixtureId),
              customFieldId: Value(fieldId),
              value: Value(value),
            )),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.customFieldValues)..where((t) => t.id.equals(id))).getSingle())
                .toJson(),
      );
    } else {
      await _tracked.updateField(
        table: 'custom_field_values',
        id: existing.id,
        field: 'value',
        newValue: value,
        readCurrentValue: () async => existing.value,
        applyUpdate: (v) async {
          if (v == null || v.isEmpty) {
             await (_db.delete(_db.customFieldValues)..where((t) => t.id.equals(existing.id))).go();
          } else {
            await (_db.update(_db.customFieldValues)..where((t) => t.id.equals(existing.id)))
                .write(CustomFieldValuesCompanion(value: Value(v)));
          }
        },
        undoDescription: 'Update ${fieldName ?? 'Custom Field'}',
      );
    }
  }

  Future<Map<int, String>> getValuesForFixture(int fixtureId) async {
    final rows = await (_db.select(_db.customFieldValues)
          ..where((t) => t.fixtureId.equals(fixtureId)))
        .get();
    return {for (final r in rows) r.customFieldId: r.value ?? ''};
  }
}
