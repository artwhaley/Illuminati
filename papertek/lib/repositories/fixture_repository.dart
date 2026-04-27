import 'package:drift/drift.dart';
import '../database/database.dart';

class FixtureRow {
  const FixtureRow({
    required this.id,
    this.channel,
    this.dimmer,
    this.circuit,
    required this.position,
    this.unitNumber,
    this.fixtureType,
    this.wattage,
    this.color,
    this.gobo1,
    this.gobo2,
    this.function,
    this.focus,
    required this.flagged,
    required this.patched,
    required this.sortOrder,
    this.accessories,
    this.ipAddress,
    this.subnet,
    this.macAddress,
    this.ipv6,
    required this.hung,
    required this.focused,
  });

  final int id;
  final String? channel;
  final String? dimmer;    // the dimmer/address label looked up from intensity part
  final String? circuit;
  final String? position;  // null = "Unspecified"
  final int? unitNumber;
  final String? fixtureType;
  final String? wattage;
  final String? color;
  final String? gobo1;
  final String? gobo2;
  final String? function;
  final String? focus;
  final bool flagged;
  final bool patched;
  final double sortOrder;
  final String? accessories;
  final String? ipAddress;
  final String? subnet;
  final String? macAddress;
  final String? ipv6;
  final bool hung;
  final bool focused;
}

class FixtureRepository {
  FixtureRepository(this._db);
  final AppDatabase _db;

  // ── Watch ─────────────────────────────────────────────────────────────────

  Stream<List<FixtureRow>> watchRows() {
    return (_db.select(_db.fixtures)
          ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
        .watch()
        .asyncMap((fixtures) async {
      final parts   = await _db.select(_db.fixtureParts).get();
      final dimmers = await _db.select(_db.dimmers).get();
      final circuits = await _db.select(_db.circuits).get();

      return fixtures.map((f) {
        final fParts = parts.where((p) => p.fixtureId == f.id).toList()
          ..sort((a, b) => a.partOrder.compareTo(b.partOrder));

        final intensityPart =
            fParts.where((p) => p.partType == 'intensity').firstOrNull;
        final gelPart  = fParts.where((p) => p.partType == 'gel').firstOrNull;
        final goboParts = fParts.where((p) => p.partType == 'gobo').toList();

        final addr      = intensityPart?.address;
        final dimmerName = addr != null
            ? dimmers.where((d) => d.address == addr).firstOrNull?.name
            : null;
        final circuitName = dimmerName != null
            ? circuits.where((c) => c.dimmer == dimmerName).firstOrNull?.name
            : null;

        return FixtureRow(
          id: f.id,
          channel: intensityPart?.channel,
          dimmer: dimmerName,
          circuit: circuitName,
          position: f.position,
          unitNumber: f.unitNumber,
          fixtureType: f.fixtureType,
          wattage: f.wattage,
          color: gelPart?.partName,
          gobo1: goboParts.isNotEmpty ? goboParts[0].partName : null,
          gobo2: goboParts.length > 1 ? goboParts[1].partName : null,
          function: f.function,
          focus: f.focus,
          flagged: f.flagged != 0,
          patched: intensityPart?.channel != null || intensityPart?.address != null,
          sortOrder: f.sortOrder,
          accessories: f.accessories,
          ipAddress: intensityPart?.ipAddress,
          subnet: intensityPart?.subnet,
          macAddress: intensityPart?.macAddress,
          ipv6: intensityPart?.ipv6,
          hung: f.hung != 0,
          focused: f.focused != 0,
        );
      }).toList();
    });
  }

  // ── Sort-order helpers ────────────────────────────────────────────────────

  Future<double> _maxSortOrder() async {
    final rows = await _db.select(_db.fixtures).get();
    if (rows.isEmpty) return 0.0;
    return rows.map((r) => r.sortOrder).reduce((a, b) => a > b ? a : b);
  }

  Future<double> _sortOrderAfter(double after) async {
    final rows = await (_db.select(_db.fixtures)
          ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
        .get();
    double? next;
    for (final r in rows) {
      if (r.sortOrder > after) { next = r.sortOrder; break; }
    }
    return next == null ? after + 1.0 : (after + next) / 2.0;
  }

  // ── Add / Clone ───────────────────────────────────────────────────────────

  Future<int> addFixture({double? afterSortOrder}) async {
    final sort = afterSortOrder == null
        ? await _maxSortOrder() + 1.0
        : await _sortOrderAfter(afterSortOrder);

    final fixtureId = await _db.into(_db.fixtures).insert(
          FixturesCompanion(flagged: const Value(0), sortOrder: Value(sort)),
        );
    await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
      fixtureId: Value(fixtureId),
      partOrder: const Value(0),
      partType: const Value('intensity'),
    ));
    return fixtureId;
  }

  Future<int> cloneFixture(int sourceId) async {
    final source = await (_db.select(_db.fixtures)
          ..where((f) => f.id.equals(sourceId)))
        .getSingleOrNull();
    if (source == null) throw StateError('Fixture $sourceId not found');

    final sort = await _sortOrderAfter(source.sortOrder);

    final newId = await _db.into(_db.fixtures).insert(FixturesCompanion(
      fixtureTypeId: Value(source.fixtureTypeId),
      fixtureType: Value(source.fixtureType),
      position: Value(source.position),
      unitNumber: Value(source.unitNumber != null ? source.unitNumber! + 1 : null),
      wattage: Value(source.wattage),
      function: Value(source.function),
      focus: Value(source.focus),
      flagged: const Value(0),
      sortOrder: Value(sort),
      accessories: Value(source.accessories),
      hung: Value(source.hung),
      focused: Value(source.focused),
    ));

    final sourceParts = await (_db.select(_db.fixtureParts)
          ..where((p) => p.fixtureId.equals(sourceId)))
        .get();
    for (final part in sourceParts) {
      await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
        fixtureId: Value(newId),
        partOrder: Value(part.partOrder),
        partType: Value(part.partType),
        partName: Value(part.partName),
        channel: Value(part.channel),
        address: Value(part.address),
        ipAddress: Value(part.ipAddress),
        subnet: Value(part.subnet),
        macAddress: Value(part.macAddress),
        ipv6: Value(part.ipv6),
      ));
    }
    return newId;
  }

  // ── Fixture-level updates ─────────────────────────────────────────────────

  Future<void> updatePosition(int id, String? position) =>
      (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
          .write(FixturesCompanion(position: Value(position)));

  Future<void> updateUnitNumber(int id, int? unitNumber) =>
      (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
          .write(FixturesCompanion(unitNumber: Value(unitNumber)));

  Future<void> updateFixtureType(int id, String? type) =>
      (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
          .write(FixturesCompanion(fixtureType: Value(type)));

  Future<void> updateWattage(int id, String? wattage) =>
      (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
          .write(FixturesCompanion(wattage: Value(wattage)));

  Future<void> updateFunction(int id, String? fn) =>
      (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
          .write(FixturesCompanion(function: Value(fn)));

  Future<void> updateFocus(int id, String? focus) =>
      (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
          .write(FixturesCompanion(focus: Value(focus)));

  Future<void> updateAccessories(int id, String? accessories) =>
      (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
          .write(FixturesCompanion(accessories: Value(accessories)));

  Future<void> toggleFlag(int id) async {
    final f = await (_db.select(_db.fixtures)..where((r) => r.id.equals(id))).getSingle();
    await (_db.update(_db.fixtures)..where((r) => r.id.equals(id)))
        .write(FixturesCompanion(flagged: Value(f.flagged == 0 ? 1 : 0)));
  }

  Future<void> toggleHung(int id) async {
    final f = await (_db.select(_db.fixtures)..where((r) => r.id.equals(id))).getSingle();
    await (_db.update(_db.fixtures)..where((r) => r.id.equals(id)))
        .write(FixturesCompanion(hung: Value(f.hung == 0 ? 1 : 0)));
  }

  Future<void> toggleFocused(int id) async {
    final f = await (_db.select(_db.fixtures)..where((r) => r.id.equals(id))).getSingle();
    await (_db.update(_db.fixtures)..where((r) => r.id.equals(id)))
        .write(FixturesCompanion(focused: Value(f.focused == 0 ? 1 : 0)));
  }

  // ── Part-level upserts ────────────────────────────────────────────────────

  Future<void> updateIntensityChannel(int fixtureId, String? channel) async {
    final existing = await _intensityPart(fixtureId);
    if (existing != null) {
      await (_db.update(_db.fixtureParts)..where((p) => p.id.equals(existing.id)))
          .write(FixturePartsCompanion(channel: Value(channel)));
    } else {
      await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
        fixtureId: Value(fixtureId),
        partOrder: const Value(0),
        partType: const Value('intensity'),
        channel: Value(channel),
      ));
    }
  }

  Future<void> updateIntensityIp(int fixtureId, String? ip) =>
      _updateIntensityField(fixtureId, FixturePartsCompanion(ipAddress: Value(ip)));

  Future<void> updateIntensitySubnet(int fixtureId, String? subnet) =>
      _updateIntensityField(fixtureId, FixturePartsCompanion(subnet: Value(subnet)));

  Future<void> updateIntensityMac(int fixtureId, String? mac) =>
      _updateIntensityField(fixtureId, FixturePartsCompanion(macAddress: Value(mac)));

  Future<void> updateIntensityIpv6(int fixtureId, String? ipv6) =>
      _updateIntensityField(fixtureId, FixturePartsCompanion(ipv6: Value(ipv6)));

  Future<void> _updateIntensityField(
      int fixtureId, FixturePartsCompanion companion) async {
    final existing = await _intensityPart(fixtureId);
    if (existing != null) {
      await (_db.update(_db.fixtureParts)..where((p) => p.id.equals(existing.id)))
          .write(companion);
    } else {
      await _db.into(_db.fixtureParts).insert(
        companion.copyWith(
          fixtureId: Value(fixtureId),
          partOrder: const Value(0),
          partType: const Value('intensity'),
        ),
      );
    }
  }

  Future<FixturePart?> _intensityPart(int fixtureId) =>
      (_db.select(_db.fixtureParts)
            ..where((p) =>
                p.fixtureId.equals(fixtureId) & p.partType.equals('intensity')))
          .getSingleOrNull();

  Future<void> upsertGelColor(int fixtureId, String? color) async {
    final existing = await (_db.select(_db.fixtureParts)
          ..where((p) =>
              p.fixtureId.equals(fixtureId) & p.partType.equals('gel')))
        .getSingleOrNull();

    if (existing != null) {
      await (_db.update(_db.fixtureParts)..where((p) => p.id.equals(existing.id)))
          .write(FixturePartsCompanion(partName: Value(color)));
    } else if (color != null && color.isNotEmpty) {
      final maxOrder = await _maxPartOrder(fixtureId);
      await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
        fixtureId: Value(fixtureId),
        partOrder: Value(maxOrder + 1),
        partType: const Value('gel'),
        partName: Value(color),
      ));
    }
  }

  Future<void> upsertGobo(int fixtureId, int goboIndex, String? name) async {
    final goboParts = await (_db.select(_db.fixtureParts)
          ..where((p) =>
              p.fixtureId.equals(fixtureId) & p.partType.equals('gobo'))
          ..orderBy([(p) => OrderingTerm.asc(p.partOrder)]))
        .get();

    if (goboIndex < goboParts.length) {
      await (_db.update(_db.fixtureParts)
            ..where((p) => p.id.equals(goboParts[goboIndex].id)))
          .write(FixturePartsCompanion(partName: Value(name)));
    } else if (name != null && name.isNotEmpty) {
      final maxOrder = await _maxPartOrder(fixtureId);
      await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
        fixtureId: Value(fixtureId),
        partOrder: Value(maxOrder + 1),
        partType: const Value('gobo'),
        partName: Value(name),
      ));
    }
  }

  Future<int> _maxPartOrder(int fixtureId) async {
    final all = await (_db.select(_db.fixtureParts)
          ..where((p) => p.fixtureId.equals(fixtureId)))
        .get();
    return all.isEmpty ? -1 : all.map((p) => p.partOrder).reduce((a, b) => a > b ? a : b);
  }
}
