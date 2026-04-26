import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

class ShowMetaRepository {
  ShowMetaRepository(this._db, this._tracked);

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  // ── Queries ──────────────────────────────────────────────────────────────

  Future<ShowMetaData?> getCurrent() =>
      (_db.select(_db.showMeta)..limit(1)).getSingleOrNull();

  Stream<ShowMetaData?> watchCurrent() =>
      (_db.select(_db.showMeta)..limit(1)).watchSingleOrNull();

  // ── Value mutations ───────────────────────────────────────────────────────

  Future<void> updateShowName(int id, String v) =>
      _update(id, 'show_name', v, (r) => r.showName,
          ShowMetaCompanion(showName: Value(v)));

  Future<void> updateCompany(int id, String? v) =>
      _update(id, 'company', v, (r) => r.company,
          ShowMetaCompanion(company: Value(v)));

  Future<void> updateProducer(int id, String v) =>
      _update(id, 'producer', v, (r) => r.producer,
          ShowMetaCompanion(producer: Value(v)));

  Future<void> updateDesigner(int id, String? v) =>
      _update(id, 'designer', v, (r) => r.designer,
          ShowMetaCompanion(designer: Value(v)));

  Future<void> updateAsstDesigner(int id, String? v) =>
      _update(id, 'asst_designer', v, (r) => r.asstDesigner,
          ShowMetaCompanion(asstDesigner: Value(v)));

  Future<void> updateDesignBusiness(int id, String? v) =>
      _update(id, 'design_business', v, (r) => r.designBusiness,
          ShowMetaCompanion(designBusiness: Value(v)));

  Future<void> updateMasterElectrician(int id, String? v) =>
      _update(id, 'master_electrician', v, (r) => r.masterElectrician,
          ShowMetaCompanion(masterElectrician: Value(v)));

  Future<void> updateAsstMasterElectrician(int id, String? v) =>
      _update(id, 'asst_master_electrician', v, (r) => r.asstMasterElectrician,
          ShowMetaCompanion(asstMasterElectrician: Value(v)));

  Future<void> updateStageManager(int id, String? v) =>
      _update(id, 'stage_manager', v, (r) => r.stageManager,
          ShowMetaCompanion(stageManager: Value(v)));

  Future<void> updateVenue(int id, String? v) =>
      _update(id, 'venue', v, (r) => r.venue,
          ShowMetaCompanion(venue: Value(v)));

  Future<void> updateTechDate(int id, String? v) =>
      _update(id, 'tech_date', v, (r) => r.techDate,
          ShowMetaCompanion(techDate: Value(v)));

  Future<void> updateOpeningDate(int id, String? v) =>
      _update(id, 'opening_date', v, (r) => r.openingDate,
          ShowMetaCompanion(openingDate: Value(v)));

  Future<void> updateClosingDate(int id, String? v) =>
      _update(id, 'closing_date', v, (r) => r.closingDate,
          ShowMetaCompanion(closingDate: Value(v)));

  Future<void> updateMode(int id, String? v) =>
      _update(id, 'mode', v, (r) => r.mode,
          ShowMetaCompanion(mode: Value(v)));

  // ── Label override mutations ──────────────────────────────────────────────
  // null = restore the built-in default label.

  Future<void> updateLabelDesigner(int id, String? v) =>
      _update(id, 'label_designer', v, (r) => r.labelDesigner,
          ShowMetaCompanion(labelDesigner: Value(v)));

  Future<void> updateLabelAsstDesigner(int id, String? v) =>
      _update(id, 'label_asst_designer', v, (r) => r.labelAsstDesigner,
          ShowMetaCompanion(labelAsstDesigner: Value(v)));

  Future<void> updateLabelMasterElectrician(int id, String? v) =>
      _update(id, 'label_master_electrician', v,
          (r) => r.labelMasterElectrician,
          ShowMetaCompanion(labelMasterElectrician: Value(v)));

  Future<void> updateLabelProducer(int id, String? v) =>
      _update(id, 'label_producer', v, (r) => r.labelProducer,
          ShowMetaCompanion(labelProducer: Value(v)));

  Future<void> updateLabelAsstMasterElectrician(int id, String? v) =>
      _update(id, 'label_asst_master_electrician', v,
          (r) => r.labelAsstMasterElectrician,
          ShowMetaCompanion(labelAsstMasterElectrician: Value(v)));

  Future<void> updateLabelStageManager(int id, String? v) =>
      _update(id, 'label_stage_manager', v, (r) => r.labelStageManager,
          ShowMetaCompanion(labelStageManager: Value(v)));

  // ── Private helper ────────────────────────────────────────────────────────

  Future<void> _update<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(ShowMetaData) readField,
    ShowMetaCompanion companion,
  ) =>
      _tracked.updateField(
        table: 'show_meta',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async {
          final row = await (_db.select(_db.showMeta)
                ..where((t) => t.id.equals(id)))
              .getSingle();
          return readField(row);
        },
        applyUpdate: (_) async {
          await (_db.update(_db.showMeta)..where((t) => t.id.equals(id)))
              .write(companion);
        },
      );
}
