import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

/// One intensity part of a multi-part fixture (e.g. one cell of a cyc).
class FixturePartRow {
  const FixturePartRow({
    required this.partOrder,
    this.channel,
    this.address,
    this.circuit,
    this.ipAddress,
    this.subnet,
    this.macAddress,
    this.ipv6,
  });

  final int partOrder;
  final String? channel;
  final String? address;
  final String? circuit;
  final String? ipAddress;
  final String? subnet;
  final String? macAddress;
  final String? ipv6;
}

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
    this.parts = const [],
  });

  final int id;
  final String? channel;
  final String? dimmer;   // raw address from intensity part (fixture_parts.address)
  final String? circuit;  // raw circuit from intensity part (fixture_parts.circuit)
  final String? position;
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
  final List<FixturePartRow> parts;

  bool get isMultiPart => parts.length > 1;
}

class FixtureRepository {
  FixtureRepository(this._db, this._tracked);
  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  // ── Watch ─────────────────────────────────────────────────────────────────

  Stream<List<FixtureRow>> watchRows() {
    return _db.customSelect(
      'SELECT 1',
      readsFrom: { _db.fixtures, _db.fixtureParts },
    ).watch().asyncMap((_) async {
      final fixtures = await (_db.select(_db.fixtures)
            ..where((f) => f.deleted.equals(0))
            ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
          .get();
      final parts = await (_db.select(_db.fixtureParts)
            ..where((p) => p.deleted.equals(0)))
          .get();

      return fixtures.map((f) {
        final fParts = parts.where((p) => p.fixtureId == f.id).toList()
          ..sort((a, b) => a.partOrder.compareTo(b.partOrder));

        final intensityParts = fParts
            .where((p) => p.partType == 'intensity')
            .toList()
          ..sort((a, b) => a.partOrder.compareTo(b.partOrder));
        final intensityPart = intensityParts.firstOrNull;
        final gelPart  = fParts.where((p) => p.partType == 'gel').firstOrNull;
        final goboParts = fParts.where((p) => p.partType == 'gobo').toList();

        return FixtureRow(
          id: f.id,
          channel: intensityPart?.channel,
          dimmer: intensityPart?.address,
          circuit: intensityPart?.circuit,
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
          patched: f.patched != 0,
          sortOrder: f.sortOrder,
          accessories: f.accessories,
          ipAddress: intensityPart?.ipAddress,
          subnet: intensityPart?.subnet,
          macAddress: intensityPart?.macAddress,
          ipv6: intensityPart?.ipv6,
          hung: f.hung != 0,
          focused: f.focused != 0,
          parts: intensityParts.map((p) => FixturePartRow(
            partOrder: p.partOrder,
            channel: p.channel,
            address: p.address,
            circuit: p.circuit,
            ipAddress: p.ipAddress,
            subnet: p.subnet,
            macAddress: p.macAddress,
            ipv6: p.ipv6,
          )).toList(),
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

    final res = await _tracked.insertRow(
      table: 'fixtures',
      doInsert: () async {
        final fixtureId = await _db.into(_db.fixtures).insert(
              FixturesCompanion(flagged: const Value(0), sortOrder: Value(sort)),
            );
        await _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
              fixtureId: Value(fixtureId),
              partOrder: const Value(0),
              partType: const Value('intensity'),
            ));
        return fixtureId;
      },
      buildSnapshot: _buildSnapshot,
    );
    return res.rowId;
  }

  Future<int> cloneFixture(int sourceId) async {
    final source = await (_db.select(_db.fixtures)
          ..where((f) => f.id.equals(sourceId)))
        .getSingleOrNull();
    if (source == null) throw StateError('Fixture $sourceId not found');

    final sort = await _sortOrderAfter(source.sortOrder);

    final res = await _tracked.insertRow(
      table: 'fixtures',
      doInsert: () async {
        final newId = await _db.into(_db.fixtures).insert(FixturesCompanion(
              fixtureTypeId: Value(source.fixtureTypeId),
              fixtureType: Value(source.fixtureType),
              position: Value(source.position),
              unitNumber:
                  Value(source.unitNumber != null ? source.unitNumber! + 1 : null),
              wattage: Value(source.wattage),
              function: Value(source.function),
              focus: Value(source.focus),
              flagged: const Value(0),
              patched: Value(source.patched),
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
                circuit: Value(part.circuit),
                ipAddress: Value(part.ipAddress),
                subnet: Value(part.subnet),
                macAddress: Value(part.macAddress),
                ipv6: Value(part.ipv6),
              ));
        }
        return newId;
      },
      buildSnapshot: _buildSnapshot,
    );
    return res.rowId;
  }

  // ── Fixture-level updates ─────────────────────────────────────────────────

  Future<void> updatePosition(int id, String? position) => _updateField(
      id, 'position', position, (f) => f.position, (v) => FixturesCompanion(position: Value(v)));

  Future<void> updateUnitNumber(int id, int? unitNumber) => _updateField(
      id, 'unit_number', unitNumber, (f) => f.unitNumber, (v) => FixturesCompanion(unitNumber: Value(v)));

  Future<void> updateFixtureType(int id, String? type) => _updateField(
      id, 'fixture_type', type, (f) => f.fixtureType, (v) => FixturesCompanion(fixtureType: Value(v)));

  Future<void> updateWattage(int id, String? wattage) => _updateField(
      id, 'wattage', wattage, (f) => f.wattage, (v) => FixturesCompanion(wattage: Value(v)));

  Future<void> updateFunction(int id, String? fn) => _updateField(
      id, 'function', fn, (f) => f.function, (v) => FixturesCompanion(function: Value(v)));

  Future<void> updateFocus(int id, String? focus) => _updateField(
      id, 'focus', focus, (f) => f.focus, (v) => FixturesCompanion(focus: Value(v)));

  Future<void> updateAccessories(int id, String? accessories) => _updateField(
      id, 'accessories', accessories, (f) => f.accessories, (v) => FixturesCompanion(accessories: Value(v)));

  Future<void> toggleFlag(int id) async {
    // Flagged is operational - not tracked.
    final f = await (_db.select(_db.fixtures)..where((r) => r.id.equals(id))).getSingle();
    await (_db.update(_db.fixtures)..where((r) => r.id.equals(id)))
        .write(FixturesCompanion(flagged: Value(f.flagged == 0 ? 1 : 0)));
  }

  Future<void> setPatched(int id, {required bool value}) => _updateField(
      id, 'patched', value ? 1 : 0, (f) => f.patched, (v) => FixturesCompanion(patched: Value(v)));

  Future<void> setHung(int id, {required bool value}) => _updateField(
      id, 'hung', value ? 1 : 0, (f) => f.hung, (v) => FixturesCompanion(hung: Value(v)));

  Future<void> setFocused(int id, {required bool value}) => _updateField(
      id, 'focused', value ? 1 : 0, (f) => f.focused, (v) => FixturesCompanion(focused: Value(v)));

  // ── Part-level updates ────────────────────────────────────────────────────

  Future<void> updateIntensityChannel(int fixtureId, String? channel) async {
    final existing = await _intensityPart(fixtureId);
    if (existing != null) {
      await _updatePartField(fixtureId, existing.id, 'channel', channel,
          (p) => p.channel, (v) => FixturePartsCompanion(channel: Value(v)));
    } else {
      await _tracked.insertRow(
        table: 'fixture_parts',
        doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
              fixtureId: Value(fixtureId),
              partOrder: const Value(0),
              partType: const Value('intensity'),
              channel: Value(channel),
            )),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                    .getSingle())
                .toJson(),
      );
    }
  }

  Future<void> updateIntensityIp(int fixtureId, String? ip) =>
      _updateIntensityField(fixtureId, 'ip_address', ip, (p) => p.ipAddress,
          (v) => FixturePartsCompanion(ipAddress: Value(v)));

  Future<void> updateIntensitySubnet(int fixtureId, String? subnet) =>
      _updateIntensityField(fixtureId, 'subnet', subnet, (p) => p.subnet,
          (v) => FixturePartsCompanion(subnet: Value(v)));

  Future<void> updateIntensityMac(int fixtureId, String? mac) =>
      _updateIntensityField(fixtureId, 'mac_address', mac, (p) => p.macAddress,
          (v) => FixturePartsCompanion(macAddress: Value(v)));

  Future<void> updateIntensityIpv6(int fixtureId, String? ipv6) =>
      _updateIntensityField(fixtureId, 'ipv6', ipv6, (p) => p.ipv6,
          (v) => FixturePartsCompanion(ipv6: Value(v)));

  Future<void> _updateIntensityField<T>(
    int fixtureId,
    String fieldName,
    T newValue,
    T Function(FixturePart) readField,
    FixturePartsCompanion Function(T) buildCompanion,
  ) async {
    final existing = await _intensityPart(fixtureId);
    if (existing != null) {
      await _updatePartField(
          fixtureId, existing.id, fieldName, newValue, readField, buildCompanion);
    } else {
      await _tracked.insertRow(
        table: 'fixture_parts',
        doInsert: () => _db.into(_db.fixtureParts).insert(
              buildCompanion(newValue).copyWith(
                fixtureId: Value(fixtureId),
                partOrder: const Value(0),
                partType: const Value('intensity'),
              ),
            ),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                    .getSingle())
                .toJson(),
      );
    }
  }

  Future<void> upsertGelColor(int fixtureId, String? color) async {
    final existing = await (_db.select(_db.fixtureParts)
          ..where((p) => p.fixtureId.equals(fixtureId) & p.partType.equals('gel')))
        .getSingleOrNull();

    if (existing != null) {
      await _updatePartField(fixtureId, existing.id, 'part_name', color,
          (p) => p.partName, (v) => FixturePartsCompanion(partName: Value(v)));
    } else if (color != null && color.isNotEmpty) {
      final maxOrder = await _maxPartOrder(fixtureId);
      await _tracked.insertRow(
        table: 'fixture_parts',
        doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
              fixtureId: Value(fixtureId),
              partOrder: Value(maxOrder + 1),
              partType: const Value('gel'),
              partName: Value(color),
            )),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                    .getSingle())
                .toJson(),
      );
    }
  }

  Future<void> upsertGobo(int fixtureId, int goboIndex, String? name) async {
    final goboParts = await (_db.select(_db.fixtureParts)
          ..where((p) => p.fixtureId.equals(fixtureId) & p.partType.equals('gobo'))
          ..orderBy([(p) => OrderingTerm.asc(p.partOrder)]))
        .get();

    if (goboIndex < goboParts.length) {
      final part = goboParts[goboIndex];
      await _updatePartField(fixtureId, part.id, 'part_name', name,
          (p) => p.partName, (v) => FixturePartsCompanion(partName: Value(v)));
    } else if (name != null && name.isNotEmpty) {
      final maxOrder = await _maxPartOrder(fixtureId);
      await _tracked.insertRow(
        table: 'fixture_parts',
        doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
              fixtureId: Value(fixtureId),
              partOrder: Value(maxOrder + 1),
              partType: const Value('gobo'),
              partName: Value(name),
            )),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                    .getSingle())
                .toJson(),
      );
    }
  }

  Future<void> deleteFixture(int id) => _tracked.deleteRow(
        table: 'fixtures',
        id: id,
        buildSnapshot: () => _buildSnapshot(id),
        doDelete: () => (_db.update(_db.fixtures)..where((f) => f.id.equals(id)))
            .write(const FixturesCompanion(deleted: Value(1))),
      );

  Future<void> updatePartChannel(int fixtureId, int partOrder, String? channel) async {
    final part = await _partByOrder(fixtureId, partOrder);
    if (part != null) {
      await _updatePartField(fixtureId, part.id, 'channel', channel,
          (p) => p.channel, (v) => FixturePartsCompanion(channel: Value(v)));
    }
  }

  Future<void> updatePartAddress(int fixtureId, int partOrder, String? address) async {
    final part = await _partByOrder(fixtureId, partOrder);
    if (part != null) {
      await _updatePartField(fixtureId, part.id, 'address', address,
          (p) => p.address, (v) => FixturePartsCompanion(address: Value(v)));
    }
  }

  Future<void> updatePartCircuit(int fixtureId, int partOrder, String? circuit) async {
    final part = await _partByOrder(fixtureId, partOrder);
    if (part != null) {
      await _updatePartField(fixtureId, part.id, 'circuit', circuit,
          (p) => p.circuit, (v) => FixturePartsCompanion(circuit: Value(v)));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<FixturePart?> _intensityPart(int fixtureId) => (_db.select(_db.fixtureParts)
        ..where((p) => p.fixtureId.equals(fixtureId) & p.partType.equals('intensity')))
      .getSingleOrNull();

  Future<FixturePart?> _partByOrder(int fixtureId, int partOrder) =>
      (_db.select(_db.fixtureParts)
            ..where((p) => p.fixtureId.equals(fixtureId) & p.partOrder.equals(partOrder)))
          .getSingleOrNull();

  Future<int> _maxPartOrder(int fixtureId) async {
    final all = await (_db.select(_db.fixtureParts)..where((p) => p.fixtureId.equals(fixtureId)))
        .get();
    return all.isEmpty ? -1 : all.map((p) => p.partOrder).reduce((a, b) => a > b ? a : b);
  }

  Future<void> _updateField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(Fixture) readField,
    FixturesCompanion Function(T) buildCompanion,
  ) =>
      _tracked.updateField(
        table: 'fixtures',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async {
          final row = await (_db.select(_db.fixtures)..where((t) => t.id.equals(id))).getSingle();
          return readField(row);
        },
        applyUpdate: (v) async {
          await (_db.update(_db.fixtures)..where((t) => t.id.equals(id))).write(buildCompanion(v));
        },
      );

  Future<void> _updatePartField<T>(
    int fixtureId,
    int partId,
    String fieldName,
    T newValue,
    T Function(FixturePart) readField,
    FixturePartsCompanion Function(T) buildCompanion,
  ) =>
      _tracked.updateField(
        table: 'fixture_parts',
        id: partId,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async {
          final row =
              await (_db.select(_db.fixtureParts)..where((t) => t.id.equals(partId))).getSingle();
          return readField(row);
        },
        applyUpdate: (v) async {
          await (_db.update(_db.fixtureParts)..where((t) => t.id.equals(partId)))
              .write(buildCompanion(v));
        },
      );

  Future<Map<String, dynamic>> _buildSnapshot(int id) async {
    final fixture = await (_db.select(_db.fixtures)..where((t) => t.id.equals(id))).getSingle();
    final parts = await (_db.select(_db.fixtureParts)..where((t) => t.fixtureId.equals(id))).get();
    return {
      'fixture': fixture.toJson(),
      'parts': parts.map((p) => p.toJson()).toList(),
    };
  }
}
