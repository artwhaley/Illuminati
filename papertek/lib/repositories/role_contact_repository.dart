import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

/// Role keys used throughout the app. Keep in sync with the UI defaults map.
abstract final class RoleKey {
  static const designer = 'designer';
  static const asstDesigner = 'asst_designer';
  static const masterElectrician = 'master_electrician';
  static const producer = 'producer';
  static const asstMasterElectrician = 'asst_master_electrician';
  static const stageManager = 'stage_manager';

  static const all = [
    designer,
    asstDesigner,
    masterElectrician,
    producer,
    asstMasterElectrician,
    stageManager,
  ];
}

class RoleContactRepository {
  RoleContactRepository(this._db, this._tracked);

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  Future<RoleContact?> getContact(String roleKey) =>
      (_db.select(_db.roleContacts)
            ..where((t) => t.roleKey.equals(roleKey)))
          .getSingleOrNull();

  Stream<RoleContact?> watchContact(String roleKey) =>
      (_db.select(_db.roleContacts)
            ..where((t) => t.roleKey.equals(roleKey)))
          .watchSingleOrNull();

  Future<void> upsertContact({
    required String roleKey,
    String? email,
    String? phone,
    String? mailingAddress,
    String? paperTekUserId,
  }) async {
    final existing = await getContact(roleKey);
    if (existing == null) {
      await _tracked.insertRow(
        table: 'role_contacts',
        doInsert: () => _db.into(_db.roleContacts).insert(RoleContactsCompanion.insert(
              roleKey: roleKey,
              email: Value(email),
              phone: Value(phone),
              mailingAddress: Value(mailingAddress),
              paperTekUserId: Value(paperTekUserId),
            )),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.roleContacts)..where((t) => t.id.equals(id))).getSingle())
                .toJson(),
      );
    } else {
      final batchId = _tracked.beginImportBatch();
      await _db.transaction(() async {
        if (email != existing.email) {
          await _updateField(existing.id, 'email', email, (r) => r.email,
              (v) => RoleContactsCompanion(email: Value(v)),
              batchId: batchId);
        }
        if (phone != existing.phone) {
          await _updateField(existing.id, 'phone', phone, (r) => r.phone,
              (v) => RoleContactsCompanion(phone: Value(v)),
              batchId: batchId);
        }
        if (mailingAddress != existing.mailingAddress) {
          await _updateField(existing.id, 'mailing_address', mailingAddress, (r) => r.mailingAddress,
              (v) => RoleContactsCompanion(mailingAddress: Value(v)),
              batchId: batchId);
        }
        if (paperTekUserId != existing.paperTekUserId) {
          await _updateField(existing.id, 'paper_tek_user_id', paperTekUserId,
              (r) => r.paperTekUserId, (v) => RoleContactsCompanion(paperTekUserId: Value(v)),
              batchId: batchId);
        }
      });
    }
  }

  Future<void> _updateField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(RoleContact) readField,
    RoleContactsCompanion Function(T) buildCompanion, {
    String? batchId,
  }) =>
      _tracked.updateField(
        table: 'role_contacts',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async =>
            readField(await (_db.select(_db.roleContacts)..where((t) => t.id.equals(id))).getSingle()),
        applyUpdate: (v) async =>
            (_db.update(_db.roleContacts)..where((t) => t.id.equals(id))).write(buildCompanion(v)),
        batchId: batchId,
      );
}
