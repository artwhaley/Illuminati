import 'package:drift/drift.dart';
import '../database/database.dart';

// Handles work_notes and maintenance_log.
// These do NOT create supervisor revisions — they are operational, not design data.
class OperationalRepository {
  OperationalRepository(this._db);

  final AppDatabase _db;

  Future<int> addWorkNote({
    required String body,
    required String userId,
    int? fixtureId,
    String? position,
  }) =>
      _db.into(_db.workNotes).insert(WorkNotesCompanion(
            body: Value(body),
            userId: Value(userId),
            timestamp: Value(DateTime.now().toIso8601String()),
            fixtureId: Value(fixtureId),
            position: Value(position),
          ));

  Future<int> logMaintenance({
    required int fixtureId,
    required String description,
    required String userId,
  }) async {
    return _db.into(_db.maintenanceLog).insert(
          MaintenanceLogCompanion(
            fixtureId: Value(fixtureId),
            description: Value(description),
            userId: Value(userId),
            timestamp: Value(DateTime.now().toIso8601String()),
          ),
        );
  }

  Future<void> resolveMaintenance(int logId) async {
    await (_db.update(_db.maintenanceLog)..where((t) => t.id.equals(logId)))
        .write(const MaintenanceLogCompanion(resolved: Value(1)));
  }
}
