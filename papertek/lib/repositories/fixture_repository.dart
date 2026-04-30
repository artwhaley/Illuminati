import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';
import 'custom_field_repository.dart';
import '../ui/spreadsheet/fixture_draft.dart';

/// One intensity part of a multi-part fixture (e.g. one cell of a cyc).
class FixturePartRow {
  const FixturePartRow({
    required this.id,
    required this.partOrder,
    this.channel,
    this.address,
    this.circuit,
    this.ipAddress,
    this.subnet,
    this.macAddress,
    this.ipv6,
    this.color = '',
    this.gobo = '',
    this.accessories = '',
  });

  final int id;
  final int partOrder;
  final String? channel;
  final String? address;
  final String? circuit;
  final String? ipAddress;
  final String? subnet;
  final String? macAddress;
  final String? ipv6;
  final String color;
  final String gobo;
  final String accessories;
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
    this.color = '',
    this.gobo = '',
    this.function,
    this.focus,
    required this.flagged,
    required this.patched,
    required this.sortOrder,
    this.accessories = '',
    this.ipAddress,
    this.subnet,
    this.macAddress,
    this.ipv6,
    required this.hung,
    required this.focused,
    this.parts = const [],
    this.colorByPart = const {},
    this.goboByPart = const {},
    this.accessoriesByPart = const {},
    this.customFieldValues = const {},
  });

  final int id;
  final String? channel;
  final String? dimmer;   // raw address from intensity part (fixture_parts.address)
  final String? circuit;  // raw circuit from intensity part (fixture_parts.circuit)
  final String? position;
  final int? unitNumber;
  final String? fixtureType;
  final String? wattage;
  final String color;
  final String gobo;
  final String? function;
  final String? focus;
  final bool flagged;
  final bool patched;
  final double sortOrder;
  final String accessories;
  final String? ipAddress;
  final String? subnet;
  final String? macAddress;
  final String? ipv6;
  final bool hung;
  final bool focused;
  final List<FixturePartRow> parts;

  final Map<int, String> colorByPart;
  final Map<int, String> goboByPart;
  final Map<int, String> accessoriesByPart;
  final Map<int, String?> customFieldValues;

  bool get isMultiPart => parts.length > 1;
}

class FixtureRepository {
  FixtureRepository(this._db, this._tracked, {this.customFields});
  final AppDatabase _db;
  final TrackedWriteRepository _tracked;
  final CustomFieldRepository? customFields;

  // ── Watch ─────────────────────────────────────────────────────────────────

  Stream<List<FixtureRow>> watchRows() {
    return _db.customSelect(
      'SELECT 1',
      readsFrom: { _db.fixtures, _db.fixtureParts, _db.gels, _db.gobos, _db.accessories, _db.customFieldValues },
    ).watch().asyncMap((_) async {
      final fixtures = await (_db.select(_db.fixtures)
            ..where((f) => f.deleted.equals(0))
            ..orderBy([(f) => OrderingTerm.asc(f.sortOrder)]))
          .get();
      final parts = await (_db.select(_db.fixtureParts)
            ..where((p) => p.deleted.equals(0)))
          .get();
      final gels = await (_db.select(_db.gels)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      final gobos = await (_db.select(_db.gobos)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      final accs = await (_db.select(_db.accessories)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();
      final customValues = await _db.select(_db.customFieldValues).get();

      return fixtures.map((f) {
        final fParts = parts.where((p) => p.fixtureId == f.id).toList()
          ..sort((a, b) => a.partOrder.compareTo(b.partOrder));

        final intensityParts = fParts
            .where((p) => p.partType == 'intensity')
            .toList()
          ..sort((a, b) => a.partOrder.compareTo(b.partOrder));
        final intensityPart = intensityParts.firstOrNull;

        // Aggregate strings for the parent row
        final fixtureGels = gels.where((g) => g.fixtureId == f.id).toList();
        final fixtureGobos = gobos.where((g) => g.fixtureId == f.id).toList();
        final fixtureAccs = accs.where((a) => a.fixtureId == f.id).toList();

        final colorStr = fixtureGels.map((g) => g.color).join(' + ');
        final goboStr = fixtureGobos.map((g) => g.goboNumber).join(' + ');
        final accStr = fixtureAccs.map((a) => a.name).join(' + ');

        // Per-part maps
        final colorByPart = <int, String>{};
        final goboByPart = <int, String>{};
        final accessoriesByPart = <int, String>{};

        for (final p in fParts) {
          final pGels = fixtureGels.where((g) => g.fixturePartId == p.id).map((g) => g.color).join(' + ');
          final pGobos = fixtureGobos.where((g) => g.fixturePartId == p.id).map((g) => g.goboNumber).join(' + ');
          final pAccs = fixtureAccs.where((a) => a.fixturePartId == p.id).map((a) => a.name).join(' + ');
          if (pGels.isNotEmpty) colorByPart[p.id] = pGels;
          if (pGobos.isNotEmpty) goboByPart[p.id] = pGobos;
          if (pAccs.isNotEmpty) accessoriesByPart[p.id] = pAccs;
        }

        final fCustomValues = {
          for (final cv in customValues.where((cv) => cv.fixtureId == f.id))
            cv.customFieldId: cv.value
        };

        return FixtureRow(
          id: f.id,
          channel: intensityPart?.channel,
          dimmer: intensityPart?.address,
          circuit: intensityPart?.circuit,
          position: f.position,
          unitNumber: f.unitNumber,
          fixtureType: f.fixtureType,
          wattage: f.wattage,
          color: colorStr,
          gobo: goboStr,
          accessories: accStr,
          function: f.function,
          focus: f.focus,
          flagged: f.flagged != 0,
          patched: f.patched != 0,
          sortOrder: f.sortOrder,
          ipAddress: intensityPart?.ipAddress,
          subnet: intensityPart?.subnet,
          macAddress: intensityPart?.macAddress,
          ipv6: intensityPart?.ipv6,
          hung: f.hung != 0,
          focused: f.focused != 0,
          colorByPart: colorByPart,
          goboByPart: goboByPart,
          accessoriesByPart: accessoriesByPart,
          customFieldValues: fCustomValues,
          parts: intensityParts.map((p) => FixturePartRow(
            id: p.id,
            partOrder: p.partOrder,
            channel: p.channel,
            address: p.address,
            circuit: p.circuit,
            ipAddress: p.ipAddress,
            subnet: p.subnet,
            macAddress: p.macAddress,
            ipv6: p.ipv6,
            color: colorByPart[p.id] ?? '',
            gobo: goboByPart[p.id] ?? '',
            accessories: accessoriesByPart[p.id] ?? '',
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

  /// Inserts a new fixture pre-populated from [draft].
  /// All inserts are a single undo frame.
  Future<double> addFixtureFromDraft(FixtureDraft draft, {double? afterSortOrder}) async {
    final sort = afterSortOrder == null
        ? await _maxSortOrder() + 1.0
        : await _sortOrderAfter(afterSortOrder);
    _tracked.beginBatchFrame('Add fixture');
    try {
      // 1. Fixture row
        final fixtureRes = await _tracked.insertRow(
          table: 'fixtures',
          doInsert: () => _db.into(_db.fixtures).insert(FixturesCompanion(
            position:    Value(draft.position),
            unitNumber:  Value(draft.unitNumber),
            fixtureType: Value(draft.fixtureType),
            wattage:     Value(draft.wattage),
            function:    Value(draft.function),
            focus:       Value(draft.focus),
            flagged:     const Value(0),
            sortOrder:   Value(sort),
          )),
          buildSnapshot: _buildSnapshot,
        );
      final fixtureId = fixtureRes.rowId;

      // 2. Intensity part
      final partRes = await _tracked.insertRow(
        table: 'fixture_parts',
        doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
          fixtureId:  Value(fixtureId),
          partOrder:  const Value(0),
          partType:   const Value('intensity'),
          channel:    Value(draft.channel),
          address:    Value(draft.dimmer),
          circuit:    Value(draft.circuit),
          ipAddress:  Value(draft.ipAddress),
          subnet:     Value(draft.subnet),
          macAddress: Value(draft.macAddress),
          ipv6:       Value(draft.ipv6),
        )),
        buildSnapshot: (id) async =>
            (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                .getSingle()).toJson(),
      );
      final partId = partRes.rowId;

      // 3. Gel (optional)
      if (draft.color != null && draft.color!.isNotEmpty) {
        await addGel(fixtureId: fixtureId, partId: partId, color: draft.color!);
      }

      // 4. Gobo (optional)
      if (draft.gobo != null && draft.gobo!.isNotEmpty) {
        await addGobo(fixtureId: fixtureId, partId: partId, goboNumber: draft.gobo!);
      }

      // 5. Accessories (optional)
      if (draft.accessories != null && draft.accessories!.isNotEmpty) {
        await addAccessory(fixtureId: fixtureId, partId: partId, name: draft.accessories!);
      }

      return sort;
    } finally {
      _tracked.endBatchFrame();
    }
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
              hung: Value(source.hung),
              focused: Value(source.focused),
            ));

        final sourceParts = await (_db.select(_db.fixtureParts)
              ..where((p) => p.fixtureId.equals(sourceId)))
            .get();
        for (final part in sourceParts) {
          final partRes = await _tracked.insertRow(
            table: 'fixture_parts',
            doInsert: () => _db.into(_db.fixtureParts).insert(FixturePartsCompanion(
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
                )),
            buildSnapshot: (id) async =>
                (await (_db.select(_db.fixtureParts)..where((p) => p.id.equals(id)))
                    .getSingle()).toJson(),
          );
          final newPartId = partRes.rowId;
          
          // Clone Gels
          final sourceGels = await (_db.select(_db.gels)..where((g) => g.fixturePartId.equals(part.id))).get();
          for (final gel in sourceGels) {
            await _tracked.insertRow(
              table: 'gels',
              doInsert: () => _db.into(_db.gels).insert(GelsCompanion(
                    fixtureId: Value(newId),
                    fixturePartId: Value(newPartId),
                    color: Value(gel.color),
                    size: Value(gel.size),
                    maker: Value(gel.maker),
                    sortOrder: Value(gel.sortOrder),
                  )),
              buildSnapshot: (id) async =>
                  (await (_db.select(_db.gels)..where((t) => t.id.equals(id))).getSingle()).toJson(),
            );
          }

          // Clone Gobos
          final sourceGobos = await (_db.select(_db.gobos)..where((g) => g.fixturePartId.equals(part.id))).get();
          for (final gobo in sourceGobos) {
            await _tracked.insertRow(
              table: 'gobos',
              doInsert: () => _db.into(_db.gobos).insert(GobosCompanion(
                    fixtureId: Value(newId),
                    fixturePartId: Value(newPartId),
                    goboNumber: Value(gobo.goboNumber),
                    size: Value(gobo.size),
                    maker: Value(gobo.maker),
                    sortOrder: Value(gobo.sortOrder),
                  )),
              buildSnapshot: (id) async =>
                  (await (_db.select(_db.gobos)..where((t) => t.id.equals(id))).getSingle()).toJson(),
            );
          }

          // Clone Accessories
          final sourceAccs = await (_db.select(_db.accessories)..where((a) => a.fixturePartId.equals(part.id))).get();
          for (final acc in sourceAccs) {
            await _tracked.insertRow(
              table: 'accessories',
              doInsert: () => _db.into(_db.accessories).insert(AccessoriesCompanion(
                    fixtureId: Value(newId),
                    fixturePartId: Value(newPartId),
                    name: Value(acc.name),
                    sortOrder: Value(acc.sortOrder),
                  )),
              buildSnapshot: (id) async =>
                  (await (_db.select(_db.accessories)..where((t) => t.id.equals(id))).getSingle()).toJson(),
            );
          }
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

  // ── Gels ───────────────────────────────────────────────────────────────────

  Future<List<Gel>> listGelsByPart(int partId) => (_db.select(_db.gels)
        ..where((t) => t.fixturePartId.equals(partId))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();

  Future<List<Gel>> listGelsByFixture(int fixtureId) => (_db.select(_db.gels)
        ..where((t) => t.fixtureId.equals(fixtureId))
        ..orderBy([
          (t) => OrderingTerm.asc(t.fixturePartId),
          (t) => OrderingTerm.asc(t.sortOrder)
        ]))
      .get();

  Future<void> addGel({required int fixtureId, required int partId, required String color}) async {
    final maxOrder = await _maxCollectionOrder(_db.gels, partId);
    await _tracked.insertRow(
      table: 'gels',
      doInsert: () => _db.into(_db.gels).insert(GelsCompanion(
            fixtureId: Value(fixtureId),
            fixturePartId: Value(partId),
            color: Value(color),
            sortOrder: Value(maxOrder + 1.0),
          )),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.gels)..where((t) => t.id.equals(id))).getSingle()).toJson(),
    );
  }

  Future<void> updateGel(int id, {required String color}) async {
    final g = await (_db.select(_db.gels)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.updateField(
      table: 'gels',
      id: id,
      field: 'color',
      newValue: color,
      readCurrentValue: () async => g.color,
      applyUpdate: (v) async =>
          (_db.update(_db.gels)..where((t) => t.id.equals(id))).write(GelsCompanion(color: Value(v))),
    );
  }

  Future<void> reorderGel(int id, double sortOrder) async {
    final g = await (_db.select(_db.gels)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.updateField(
      table: 'gels',
      id: id,
      field: 'sort_order',
      newValue: sortOrder,
      readCurrentValue: () async => g.sortOrder,
      applyUpdate: (v) async => (_db.update(_db.gels)..where((t) => t.id.equals(id)))
          .write(GelsCompanion(sortOrder: Value(v))),
      undoDescription: 'reorder gel',
    );
  }

  Future<void> deleteGel(int id) async {
    final g = await (_db.select(_db.gels)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.deleteRow(
      table: 'gels',
      id: id,
      buildSnapshot: () async => g.toJson(),
      doDelete: () async => (_db.delete(_db.gels)..where((t) => t.id.equals(id))).go(),
    );
  }

  // ── Gobos ──────────────────────────────────────────────────────────────────

  Future<List<Gobo>> listGobosByPart(int partId) => (_db.select(_db.gobos)
        ..where((t) => t.fixturePartId.equals(partId))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();

  Future<List<Gobo>> listGobosByFixture(int fixtureId) => (_db.select(_db.gobos)
        ..where((t) => t.fixtureId.equals(fixtureId))
        ..orderBy([
          (t) => OrderingTerm.asc(t.fixturePartId),
          (t) => OrderingTerm.asc(t.sortOrder)
        ]))
      .get();

  Future<void> addGobo({required int fixtureId, required int partId, required String goboNumber}) async {
    final maxOrder = await _maxCollectionOrder(_db.gobos, partId);
    await _tracked.insertRow(
      table: 'gobos',
      doInsert: () => _db.into(_db.gobos).insert(GobosCompanion(
            fixtureId: Value(fixtureId),
            fixturePartId: Value(partId),
            goboNumber: Value(goboNumber),
            sortOrder: Value(maxOrder + 1.0),
          )),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.gobos)..where((t) => t.id.equals(id))).getSingle()).toJson(),
    );
  }

  Future<void> updateGobo(int id, {required String goboNumber}) async {
    final g = await (_db.select(_db.gobos)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.updateField(
      table: 'gobos',
      id: id,
      field: 'gobo_number',
      newValue: goboNumber,
      readCurrentValue: () async => g.goboNumber,
      applyUpdate: (v) async => (_db.update(_db.gobos)..where((t) => t.id.equals(id)))
          .write(GobosCompanion(goboNumber: Value(v))),
    );
  }

  Future<void> reorderGobo(int id, double sortOrder) async {
    final g = await (_db.select(_db.gobos)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.updateField(
      table: 'gobos',
      id: id,
      field: 'sort_order',
      newValue: sortOrder,
      readCurrentValue: () async => g.sortOrder,
      applyUpdate: (v) async => (_db.update(_db.gobos)..where((t) => t.id.equals(id)))
          .write(GobosCompanion(sortOrder: Value(v))),
      undoDescription: 'reorder gobo',
    );
  }

  Future<void> deleteGobo(int id) async {
    final g = await (_db.select(_db.gobos)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.deleteRow(
      table: 'gobos',
      id: id,
      buildSnapshot: () async => g.toJson(),
      doDelete: () async => (_db.delete(_db.gobos)..where((t) => t.id.equals(id))).go(),
    );
  }

  // ── Accessories ────────────────────────────────────────────────────────────

  Future<List<Accessory>> listAccessoriesByPart(int partId) => (_db.select(_db.accessories)
        ..where((t) => t.fixturePartId.equals(partId))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
      .get();

  Future<List<Accessory>> listAccessoriesByFixture(int fixtureId) => (_db.select(_db.accessories)
        ..where((t) => t.fixtureId.equals(fixtureId))
        ..orderBy([
          (t) => OrderingTerm.asc(t.fixturePartId),
          (t) => OrderingTerm.asc(t.sortOrder)
        ]))
      .get();

  Future<void> addAccessory({required int fixtureId, required int partId, required String name}) async {
    final maxOrder = await _maxCollectionOrder(_db.accessories, partId);
    await _tracked.insertRow(
      table: 'accessories',
      doInsert: () => _db.into(_db.accessories).insert(AccessoriesCompanion(
            fixtureId: Value(fixtureId),
            fixturePartId: Value(partId),
            name: Value(name),
            sortOrder: Value(maxOrder + 1.0),
          )),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.accessories)..where((t) => t.id.equals(id))).getSingle()).toJson(),
    );
  }

  Future<void> updateAccessory(int id, {required String name}) async {
    final a = await (_db.select(_db.accessories)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.updateField(
      table: 'accessories',
      id: id,
      field: 'name',
      newValue: name,
      readCurrentValue: () async => a.name,
      applyUpdate: (v) async => (_db.update(_db.accessories)..where((t) => t.id.equals(id)))
          .write(AccessoriesCompanion(name: Value(v))),
    );
  }

  Future<void> reorderAccessory(int id, double sortOrder) async {
    final a = await (_db.select(_db.accessories)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.updateField(
      table: 'accessories',
      id: id,
      field: 'sort_order',
      newValue: sortOrder,
      readCurrentValue: () async => a.sortOrder,
      applyUpdate: (v) async => (_db.update(_db.accessories)..where((t) => t.id.equals(id)))
          .write(AccessoriesCompanion(sortOrder: Value(v))),
      undoDescription: 'reorder accessory',
    );
  }

  Future<void> deleteAccessory(int id) async {
    final a = await (_db.select(_db.accessories)..where((t) => t.id.equals(id))).getSingle();
    await _tracked.deleteRow(
      table: 'accessories',
      id: id,
      buildSnapshot: () async => a.toJson(),
      doDelete: () async => (_db.delete(_db.accessories)..where((t) => t.id.equals(id))).go(),
    );
  }

  /// Wraps a collection edit session in a single batch frame for undo/redo.
  Future<void> runCollectionEdit(String description, Future<void> Function() action) async {
    _tracked.beginBatchFrame(description);
    try {
      await action();
    } finally {
      _tracked.endBatchFrame();
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

  Future<List<FixturePart>> getPartsForFixture(int fixtureId) =>
      (_db.select(_db.fixtureParts)
            ..where((p) => p.fixtureId.equals(fixtureId))
            ..orderBy([(p) => OrderingTerm.asc(p.partOrder)]))
          .get();

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

  Future<double> _maxCollectionOrder(Table table, int partId) async {
    final rows = await (_db.select(table as ResultSetImplementation<HasResultSet, dynamic>)
          ..where((t) => (t as dynamic).fixturePartId.equals(partId)))
        .get();
    if (rows.isEmpty) return 0.0;
    return rows.map((r) => (r as dynamic).sortOrder as double).reduce((a, b) => a > b ? a : b);
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
    final gels = await (_db.select(_db.gels)..where((t) => t.fixtureId.equals(id))).get();
    final gobos = await (_db.select(_db.gobos)..where((t) => t.fixtureId.equals(id))).get();
    final accs = await (_db.select(_db.accessories)..where((t) => t.fixtureId.equals(id))).get();

    return {
      'fixture': fixture.toJson(),
      'parts': parts.map((p) => p.toJson()).toList(),
      'gels': gels.map((g) => g.toJson()).toList(),
      'gobos': gobos.map((g) => g.toJson()).toList(),
      'accessories': accs.map((a) => a.toJson()).toList(),
    };
  }
}
