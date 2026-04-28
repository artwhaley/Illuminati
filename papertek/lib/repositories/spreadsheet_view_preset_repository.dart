import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

class SpreadsheetViewPresetRepository {
  SpreadsheetViewPresetRepository(this._db, this._tracked);

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  Stream<List<SpreadsheetViewPreset>> watchPresets() {
    return (_db.select(_db.spreadsheetViewPresets)
          ..orderBy([(t) => OrderingTerm.asc(t.isSystem), (t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<int> createPreset({
    required String name,
    required Map<String, dynamic> presetData,
    bool isSystem = false,
  }) async {
    final now = DateTime.now().toIso8601String();
    return await _db.into(_db.spreadsheetViewPresets).insert(SpreadsheetViewPresetsCompanion(
          name: Value(name),
          isSystem: Value(isSystem ? 1 : 0),
          createdAt: Value(now),
          updatedAt: Value(now),
          presetJson: Value(jsonEncode(presetData)),
        ));
  }

  Future<void> updatePreset(int id, Map<String, dynamic> presetData) async {
    final now = DateTime.now().toIso8601String();
    await (_db.update(_db.spreadsheetViewPresets)..where((t) => t.id.equals(id))).write(
      SpreadsheetViewPresetsCompanion(
        updatedAt: Value(now),
        presetJson: Value(jsonEncode(presetData)),
      ),
    );
  }

  Future<void> deletePreset(int id) async {
    await (_db.delete(_db.spreadsheetViewPresets)..where((t) => t.id.equals(id))).go();
  }

  Future<void> seedDefaults() async {
    final query = _db.selectOnly(_db.spreadsheetViewPresets)..addColumns([_db.spreadsheetViewPresets.id.count()]);
    final result = await query.getSingle();
    final count = result.read(_db.spreadsheetViewPresets.id.count()) ?? 0;
    if (count > 0) return;

    final now = DateTime.now().toIso8601String();
    
    const hiddenNetworkCols = [
      'type', 'focus', 'accessories', 'ip', 'subnet', 'mac', 'ipv6',
      'hung', 'patch', 'focused', 'circuit', 'notes',
    ];

    final defaults = [
      {
        'name': 'Patch by Channel',
        'json': {
          'version': 1,
          'columnOrder': [
            '#', 'chan', 'dimmer', 'position', 'unit', 'function',
            ...hiddenNetworkCols,
          ],
          'hiddenColumns': hiddenNetworkCols,
          'sorts': [{'column': 'chan', 'direction': 'asc'}],
        }
      },
      {
        'name': 'Patch by Address',
        'json': {
          'version': 1,
          'columnOrder': [
            '#', 'dimmer', 'chan', 'position', 'unit', 'function',
            ...hiddenNetworkCols,
          ],
          'hiddenColumns': hiddenNetworkCols,
          'sorts': [{'column': 'dimmer', 'direction': 'asc'}],
        }
      },
      {
        'name': 'Position View',
        'json': {
          'version': 1,
          'columnOrder': [
            '#', 'position', 'unit', 'chan', 'dimmer', 'function',
            ...hiddenNetworkCols,
          ],
          'hiddenColumns': hiddenNetworkCols,
          'sorts': [
            {'column': 'position', 'direction': 'asc'},
            {'column': 'unit', 'direction': 'asc'},
          ],
        }
      },
    ];

    await _db.batch((batch) {
      for (final d in defaults) {
        batch.insert(_db.spreadsheetViewPresets, SpreadsheetViewPresetsCompanion(
          name: Value(d['name'] as String),
          isSystem: const Value(1),
          createdAt: Value(now),
          updatedAt: Value(now),
          presetJson: Value(jsonEncode(d['json'])),
        ));
      }
    });
  }
}
