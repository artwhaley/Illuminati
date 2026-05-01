import 'dart:convert';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/database/database.dart';
import 'package:papertek/repositories/tracked_write_repository.dart';
import 'package:papertek/repositories/operational_repository.dart';

AppDatabase openTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  late AppDatabase db;
  late TrackedWriteRepository tracked;
  late OperationalRepository operational;

  setUp(() {
    db = openTestDb();
    tracked = TrackedWriteRepository(db);
    operational = OperationalRepository(db);
  });
  tearDown(() => db.close());

  // ── Step 1.1: show_meta + users_local ─────────────────────────────────
  group('Step 1.1 – show_meta + users_local', () {
    test('inserts and reads show_meta row', () async {
      await db.into(db.showMeta).insert(ShowMetaCompanion(
            showName: const Value('Hamlet'),
            producer: const Value('Test Producer'),
            schemaVersion: const Value(6),
          ));
      final rows = await db.select(db.showMeta).get();
      expect(rows, hasLength(1));
      expect(rows.first.showName, 'Hamlet');
      expect(rows.first.cloudId, isNull);
      expect(rows.first.schemaVersion, 6);
    });

    test('inserts users_local row', () async {
      await db.into(db.usersLocal).insert(const UsersLocalCompanion(
            userId: Value('u-1'),
            displayName: Value('Ada Lovelace'),
          ));
      final row = await (db.select(db.usersLocal)
            ..where((t) => t.userId.equals('u-1')))
          .getSingle();
      expect(row.displayName, 'Ada Lovelace');
    });
  });

  // ── Step 1.2: venue tables + patch query ──────────────────────────────
  group('Step 1.2 – venue tables', () {
    test('patch-by-channel returns expected join', () async {
      await db.into(db.channels).insert(const ChannelsCompanion(
            name: Value('101'),
            notes: Value('designer note'),
          ));
      await db.into(db.channels).insert(const ChannelsCompanion(name: Value('102')));
      await db.into(db.addresses).insert(const AddressesCompanion(
            name: Value('1/001'),
            type: Value('DMX'),
            channel: Value('101'),
          ));

      final patch = await db.patchByChannel();
      final row101 = patch.firstWhere((r) => r['channel_name'] == '101');
      expect(row101['address_name'], '1/001');

      final row102 = patch.firstWhere((r) => r['channel_name'] == '102');
      expect(row102['address_name'], isNull);
    });
  });

  // ── Step 1.3: fixture core + CHECK constraint ─────────────────────────
  group('Step 1.3 – fixture core tables', () {
    test('inserts fixture type and fixture', () async {
      final typeId = await db.into(db.fixtureTypes).insert(const FixtureTypesCompanion(
            name: Value('Source Four 36°'),
            wattage: Value('575W'),
          ));
      final fixId = await db.into(db.fixtures).insert(FixturesCompanion(
            fixtureTypeId: Value(typeId),
            fixtureType: const Value('Source Four 36°'),
            position: const Value('1st Electric'),
          ));
      await db.into(db.fixtureParts).insert(FixturePartsCompanion(
            fixtureId: Value(fixId),
            partOrder: const Value(0),
            partType: const Value('intensity'),
          ));
      final parts = await (db.select(db.fixtureParts)
            ..where((t) => t.fixtureId.equals(fixId)))
          .get();
      expect(parts, hasLength(1));
    });

    test('invalid part_type fails CHECK constraint', () async {
      final fixId = await db.into(db.fixtures).insert(const FixturesCompanion(
            position: Value('SL'),
          ));
      expect(
        () async => db.into(db.fixtureParts).insert(FixturePartsCompanion(
              fixtureId: Value(fixId),
              partOrder: const Value(0),
              partType: const Value('invalid_type'),
            )),
        throwsA(anything),
      );
    });
  });

  // ── Step 1.4: attachable tables + cascade ─────────────────────────────
  group('Step 1.4 – attachable tables', () {
    test('gels, gobos, accessories attach and cascade on fixture delete', () async {
      final fixId = await db.into(db.fixtures).insert(const FixturesCompanion(
            position: Value('Balcony Rail'),
          ));
      final partId = await db.into(db.fixtureParts).insert(FixturePartsCompanion(
            fixtureId: Value(fixId),
            partOrder: const Value(0),
          ));

      await db.into(db.gels).insert(GelsCompanion(
            color: const Value('R02'),
            fixtureId: Value(fixId),
            fixturePartId: Value(partId),
          ));
      // Gel attached to a specific part
      await db.into(db.gels).insert(GelsCompanion(
            color: const Value('L201'),
            fixtureId: Value(fixId),
            fixturePartId: Value(partId),
          ));
      await db.into(db.gobos).insert(GobosCompanion(
            goboNumber: const Value('R77735'),
            fixtureId: Value(fixId),
            fixturePartId: Value(partId),
          ));
      await db.into(db.accessories).insert(AccessoriesCompanion(
            name: const Value('Top Hat'),
            fixtureId: Value(fixId),
            fixturePartId: Value(partId),
          ));
      await operational.addWorkNote(
        body: 'Focus note',
        userId: 'local-user',
        fixtureId: fixId,
      );

      // Delete fixture — cascade should remove gels, gobos, accessories, parts
      await (db.delete(db.fixtures)..where((t) => t.id.equals(fixId))).go();

      expect(await (db.select(db.gels)..where((t) => t.fixtureId.equals(fixId))).get(), isEmpty);
      expect(await (db.select(db.gobos)..where((t) => t.fixtureId.equals(fixId))).get(), isEmpty);
      expect(await (db.select(db.accessories)..where((t) => t.fixtureId.equals(fixId))).get(), isEmpty);
    });
  });

  // ── Step 1.5: custom fields ────────────────────────────────────────────
  group('Step 1.5 – custom fields', () {
    test('creates custom field and assigns value to fixture', () async {
      final fixId = await db.into(db.fixtures).insert(const FixturesCompanion(
            position: Value('1E'),
          ));
      final fieldId = await db.into(db.customFields).insert(const CustomFieldsCompanion(
            name: Value('Color Temp'),
            dataType: Value('text'),
          ));
      await db.into(db.customFieldValues).insert(CustomFieldValuesCompanion(
            fixtureId: Value(fixId),
            customFieldId: Value(fieldId),
            value: const Value('3200K'),
          ));
      final val = await (db.select(db.customFieldValues)
            ..where((t) => t.fixtureId.equals(fixId)))
          .getSingle();
      expect(val.value, '3200K');

      expect(await db.select(db.reports).get(), isEmpty);
    });
  });

  // ── Step 1.6: revision + commit tables ───────────────────────────────
  group('Step 1.6 – revision tables', () {
    test('inserts update, insert, delete revisions including JSON null', () async {
      final commitId = await db.into(db.commits).insert(const CommitsCompanion(
            userId: Value('local-user'),
            timestamp: Value('2026-01-01T00:00:00Z'),
          ));

      // update revision where old_value is JSON null
      await db.into(db.revisions).insert(RevisionsCompanion(
            operation: const Value('update'),
            targetTable: const Value('fixtures'),
            targetId: const Value(1),
            fieldName: const Value('focus'),
            oldValue: const Value('null'), // JSON null
            newValue: const Value('"CS"'),
            userId: const Value('local-user'),
            timestamp: const Value('2026-01-01T00:00:00Z'),
            commitId: Value(commitId),
            status: const Value('committed'),
          ));

      // insert revision
      await db.into(db.revisions).insert(const RevisionsCompanion(
            operation: Value('insert'),
            targetTable: Value('fixtures'),
            targetId: Value(2),
            newValue: Value('{"position":"1E"}'),
            userId: Value('local-user'),
            timestamp: Value('2026-01-01T00:00:01Z'),
          ));

      // delete revision
      await db.into(db.revisions).insert(const RevisionsCompanion(
            operation: Value('delete'),
            targetTable: Value('fixtures'),
            targetId: Value(3),
            oldValue: Value('{"position":"SR","unit":5}'),
            userId: Value('local-user'),
            timestamp: Value('2026-01-01T00:00:02Z'),
          ));

      final pending = await (db.select(db.revisions)
            ..where((t) => t.status.equals('pending')))
          .get();
      expect(pending, hasLength(2));
    });

    test('import_batch revision with shared batch_id', () async {
      const batchId = 'batch-001';
      await db.into(db.revisions).insert(const RevisionsCompanion(
            operation: Value('import_batch'),
            targetTable: Value('fixtures'),
            newValue: Value('{"source":"hookup.csv","row_count":50}'),
            batchId: Value(batchId),
            userId: Value('local-user'),
            timestamp: Value('2026-01-01T00:00:00Z'),
          ));
      await db.into(db.revisions).insert(const RevisionsCompanion(
            operation: Value('insert'),
            targetTable: Value('fixtures'),
            targetId: Value(1),
            newValue: Value('{"position":"1E"}'),
            batchId: Value(batchId),
            userId: Value('local-user'),
            timestamp: Value('2026-01-01T00:00:01Z'),
          ));

      final batch = await (db.select(db.revisions)
            ..where((t) => t.batchId.equals(batchId)))
          .get();
      expect(batch, hasLength(2));
    });
  });

  // ── Step 1.7: tracked write layer ────────────────────────────────────
  group('Step 1.7 – tracked write repository', () {
    test('updateField creates one pending update revision', () async {
      final fixId = await db.into(db.fixtures).insert(const FixturesCompanion(
            position: Value('1E'),
            area: Value('CS'),
          ));

      await tracked.updateField(
        table: 'fixtures',
        id: fixId,
        field: 'area',
        newValue: 'USL',
        readCurrentValue: () async {
          final row = await (db.select(db.fixtures)..where((t) => t.id.equals(fixId))).getSingle();
          return row.area;
        },
        applyUpdate: (v) async {
          await (db.update(db.fixtures)..where((t) => t.id.equals(fixId)))
              .write(FixturesCompanion(area: Value(v as String)));
        },
      );

      final revs = await (db.select(db.revisions)
            ..where((t) =>
                t.targetId.equals(fixId) &
                t.operation.equals('update') &
                t.fieldName.equals('area')))
          .get();
      expect(revs, hasLength(1));
      expect(revs.first.status, 'pending');
      expect(revs.first.oldValue, jsonEncode('CS'));
      expect(revs.first.newValue, jsonEncode('USL'));

      // Verify live row reflects new value
      final updated = await (db.select(db.fixtures)..where((t) => t.id.equals(fixId))).getSingle();
      expect(updated.area, 'USL');
    });

    test('insertRow creates one pending insert revision with snapshot', () async {
      final res = await tracked.insertRow(
        table: 'fixtures',
        doInsert: () => db.into(db.fixtures).insert(const FixturesCompanion(position: Value('2E'))),
        buildSnapshot: (id) async => {'id': id, 'position': '2E'},
      );
      final id = res.rowId;

      final revs = await (db.select(db.revisions)
            ..where((t) => t.operation.equals('insert') & t.targetId.equals(id)))
          .get();
      expect(revs, hasLength(1));
      expect(revs.first.status, 'pending');
      expect(revs.first.oldValue, isNull);
      expect(jsonDecode(revs.first.newValue!)['position'], '2E');
    });

    test('deleteRow creates one pending delete revision with snapshot', () async {
      final fixId = await db.into(db.fixtures).insert(const FixturesCompanion(position: Value('3E')));

      await tracked.deleteRow(
        table: 'fixtures',
        id: fixId,
        buildSnapshot: () async => {'id': fixId, 'position': '3E'},
        doDelete: () async =>
            (db.delete(db.fixtures)..where((t) => t.id.equals(fixId))).go(),
      );

      final revs = await (db.select(db.revisions)
            ..where((t) => t.operation.equals('delete') & t.targetId.equals(fixId)))
          .get();
      expect(revs, hasLength(1));
      expect(revs.first.status, 'pending');
      expect(revs.first.newValue, isNull);
      expect(jsonDecode(revs.first.oldValue!)['position'], '3E');

      // Fixture row should be gone
      final remaining = await (db.select(db.fixtures)..where((t) => t.id.equals(fixId))).get();
      expect(remaining, isEmpty);
    });

    test('operational work note does NOT create supervisor revision', () async {
      final fixId = await db.into(db.fixtures).insert(const FixturesCompanion(position: Value('SL')));
      await operational.addWorkNote(body: 'Gel check', userId: 'local-user', fixtureId: fixId);

      final revs = await db.select(db.revisions).get();
      expect(revs, isEmpty);
    });

    test('beginImportBatch / endImportBatch shares batch_id', () async {
      final batchId = tracked.beginImportBatch();

      final res1 = await tracked.insertRow(
        table: 'fixtures',
        doInsert: () => db.into(db.fixtures).insert(const FixturesCompanion(position: Value('Rail'))),
        buildSnapshot: (id) async => {'id': id, 'position': 'Rail'},
        batchId: batchId,
      );
      final id1 = res1.rowId;
      final res2 = await tracked.insertRow(
        table: 'fixtures',
        doInsert: () => db.into(db.fixtures).insert(const FixturesCompanion(position: Value('Rail'))),
        buildSnapshot: (id) async => {'id': id, 'position': 'Rail'},
        batchId: batchId,
      );
      final id2 = res2.rowId;

      await tracked.endImportBatch(
        batchId: batchId,
        summary: {'source': 'hookup.csv', 'row_count': 2, 'fixture_ids': [id1, id2]},
      );

      final batchRevs = await (db.select(db.revisions)
            ..where((t) => t.batchId.equals(batchId)))
          .get();
      // 2 insert + 1 import_batch summary
      expect(batchRevs, hasLength(3));
      final summary = batchRevs.firstWhere((r) => r.operation == 'import_batch');
      expect(jsonDecode(summary.newValue!)['row_count'], 2);
    });
  });
}
