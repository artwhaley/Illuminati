import 'package:drift/drift.dart';
import '../database/database.dart';

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
  RoleContactRepository(this._db);

  final AppDatabase _db;

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
      await _db.into(_db.roleContacts).insert(RoleContactsCompanion.insert(
            roleKey: roleKey,
            email: Value(email),
            phone: Value(phone),
            mailingAddress: Value(mailingAddress),
            paperTekUserId: Value(paperTekUserId),
          ));
    } else {
      await (_db.update(_db.roleContacts)
            ..where((t) => t.roleKey.equals(roleKey)))
          .write(RoleContactsCompanion(
            email: Value(email),
            phone: Value(phone),
            mailingAddress: Value(mailingAddress),
            paperTekUserId: Value(paperTekUserId),
          ));
    }
  }
}
