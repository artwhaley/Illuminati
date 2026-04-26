import 'package:drift/drift.dart';
import '../database/database.dart';

// Handles work_notes, maintenance_log, and fixtures.flagged.
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
    bool setFlag = true,
  }) async {
    final logId = await _db.into(_db.maintenanceLog).insert(
          MaintenanceLogCompanion(
            fixtureId: Value(fixtureId),
            description: Value(description),
            userId: Value(userId),
            timestamp: Value(DateTime.now().toIso8601String()),
          ),
        );
    if (setFlag) {
      await (_db.update(_db.fixtures)..where((t) => t.id.equals(fixtureId)))
          .write(const FixturesCompanion(flagged: Value(1)));
    }
    return logId;
  }

  Future<void> resolveMaintenance(int logId) async {
    final entry = await (_db.select(_db.maintenanceLog)
          ..where((t) => t.id.equals(logId)))
        .getSingleOrNull();
    if (entry == null) return;

    await _db.transaction(() async {
      await (_db.update(_db.maintenanceLog)..where((t) => t.id.equals(logId)))
          .write(const MaintenanceLogCompanion(resolved: Value(1)));
      // Clear flag only if no other unresolved entries exist for this fixture.
      final remaining = await (_db.select(_db.maintenanceLog)
            ..where((t) =>
                t.fixtureId.equals(entry.fixtureId) &
                t.resolved.equals(0) &
                t.id.equals(logId).not()))
          .get();
      if (remaining.isEmpty) {
        await (_db.update(_db.fixtures)
              ..where((t) => t.id.equals(entry.fixtureId)))
            .write(const FixturesCompanion(flagged: Value(0)));
      }
    });
  }
}
