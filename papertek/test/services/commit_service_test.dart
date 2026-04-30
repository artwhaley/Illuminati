import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papertek/database/database.dart';
import 'package:papertek/repositories/tracked_write_repository.dart';
import 'package:papertek/services/commit_service.dart';
import 'package:drift/drift.dart';

AppDatabase _buildInMemoryDb() => AppDatabase.forTesting(NativeDatabase.memory());

Future<int> _insertFixture(AppDatabase db, {String? position}) async {
  return db.into(db.fixtures).insert(FixturesCompanion.insert(
    fixtureType: const Value('S4 26'),
    position: Value(position),
    sortOrder: const Value(1.0),
  ));
}

Future<int> _insertRevision(
  AppDatabase db, {
  required int targetId,
  required String targetTable,
  required String fieldName,
  required String? oldValue,
  required String? newValue,
  String status = 'pending',
  String userId = 'test-user',
}) async {
  return db.into(db.revisions).insert(RevisionsCompanion.insert(
    targetTable: targetTable,
    targetId: Value(targetId),
    fieldName: Value(fieldName),
    oldValue: Value(oldValue != null ? jsonEncode(oldValue) : null),
    newValue: Value(newValue != null ? jsonEncode(newValue) : null),
    status: Value(status),
    operation: 'update',
    userId: userId,
    timestamp: DateTime.now().toIso8601String(),
  ));
}

void main() {
  late AppDatabase db;
  late TrackedWriteRepository tracked;
  late CommitService service;

  setUp(() async {
    db = _buildInMemoryDb();
    tracked = TrackedWriteRepository(db);
    service = CommitService(db: db, tracked: tracked);
  });

  tearDown(() async {
    await db.close();
  });

  // ── Test 1: Single revision approve ────────────────────────────────────────
  test('approving a single revision marks it committed', () async {
    final fixtureId = await _insertFixture(db, position: 'Catwalk');
    final revId = await _insertRevision(db,
      targetId: fixtureId,
      targetTable: 'fixtures',
      fieldName: 'position',
      oldValue: 'Electric 1',
      newValue: 'Catwalk',
    );

    await service.commitBatch(decisions: {revId: ReviewDecision.approve});

    final rev = await (db.select(db.revisions)..where((r) => r.id.equals(revId))).getSingle();
    expect(rev.status, equals('committed'));

    // DB value should remain at 'Catwalk' (approve does not change DB — the change was
    // already applied when the revision was created).
    final fixture = await (db.select(db.fixtures)..where((f) => f.id.equals(fixtureId))).getSingle();
    expect(fixture.position, equals('Catwalk'));
  });

  // ── Test 2: Single revision reject ─────────────────────────────────────────
  test('rejecting a single revision rolls back the DB value', () async {
    final fixtureId = await _insertFixture(db, position: 'Catwalk');
    final revId = await _insertRevision(db,
      targetId: fixtureId,
      targetTable: 'fixtures',
      fieldName: 'position',
      oldValue: 'Electric 1',
      newValue: 'Catwalk',
    );

    await service.commitBatch(decisions: {revId: ReviewDecision.reject});

    final rev = await (db.select(db.revisions)..where((r) => r.id.equals(revId))).getSingle();
    expect(rev.status, equals('rejected'));

    final fixture = await (db.select(db.fixtures)..where((f) => f.id.equals(fixtureId))).getSingle();
    expect(fixture.position, equals('Electric 1'));
  });

  // ── Test 3: Conflict — approve latest, earlier is auto-rejected ─────────────
  test('approving the latest revision auto-rejects the earlier one', () async {
    final fixtureId = await _insertFixture(db, position: 'Balcony');
    // Rev A: Electric 1 → Catwalk
    final revA = await _insertRevision(db,
      targetId: fixtureId,
      targetTable: 'fixtures',
      fieldName: 'position',
      oldValue: 'Electric 1',
      newValue: 'Catwalk',
    );
    // Rev B: Catwalk → Balcony
    final revB = await _insertRevision(db,
      targetId: fixtureId,
      targetTable: 'fixtures',
      fieldName: 'position',
      oldValue: 'Catwalk',
      newValue: 'Balcony',
    );

    // Reviewer approves only revB; revA should be auto-rejected.
    await service.commitBatch(decisions: {revB: ReviewDecision.approve});

    final revARow = await (db.select(db.revisions)..where((r) => r.id.equals(revA))).getSingle();
    final revBRow = await (db.select(db.revisions)..where((r) => r.id.equals(revB))).getSingle();

    expect(revBRow.status, equals('committed'));
    expect(revARow.status, equals('rejected'));

    // DB value stays at 'Balcony' (approve does not change DB).
    final fixture = await (db.select(db.fixtures)..where((f) => f.id.equals(fixtureId))).getSingle();
    expect(fixture.position, equals('Balcony'));
  });

  // ── Test 4: Conflict — reject both restores original value ──────────────────
  test('rejecting both conflicting revisions restores the original value', () async {
    final fixtureId = await _insertFixture(db, position: 'Balcony');
    final revA = await _insertRevision(db,
      targetId: fixtureId,
      targetTable: 'fixtures',
      fieldName: 'position',
      oldValue: 'Electric 1',
      newValue: 'Catwalk',
    );
    final revB = await _insertRevision(db,
      targetId: fixtureId,
      targetTable: 'fixtures',
      fieldName: 'position',
      oldValue: 'Catwalk',
      newValue: 'Balcony',
    );

    // Both rejected — must process newest (revB) first to get correct rollback.
    await service.commitBatch(decisions: {
      revA: ReviewDecision.reject,
      revB: ReviewDecision.reject,
    });

    final fixture = await (db.select(db.fixtures)..where((f) => f.id.equals(fixtureId))).getSingle();
    expect(fixture.position, equals('Electric 1'));

    final revARow = await (db.select(db.revisions)..where((r) => r.id.equals(revA))).getSingle();
    final revBRow = await (db.select(db.revisions)..where((r) => r.id.equals(revB))).getSingle();
    expect(revARow.status, equals('rejected'));
    expect(revBRow.status, equals('rejected'));
  });
}
