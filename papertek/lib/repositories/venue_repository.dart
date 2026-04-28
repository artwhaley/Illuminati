import 'package:drift/drift.dart';
import '../database/database.dart';
import 'tracked_write_repository.dart';

/// CRUD for the four venue lookup tables: Channels, Addresses, Dimmers, Circuits.
/// Positions and PositionGroups are handled by PositionRepository.
class VenueRepository {
  VenueRepository(this._db, this._tracked);

  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  // ── Channels ──────────────────────────────────────────────────────────────

  Stream<List<Channel>> watchChannels() =>
      (_db.select(_db.channels)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addChannel(String name) async {
    final res = await _tracked.insertRow(
      table: 'channels',
      doInsert: () => _db.into(_db.channels).insert(ChannelsCompanion(name: Value(name))),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.channels)..where((t) => t.id.equals(id))).getSingle()).toJson(),
    );
    return res.rowId;
  }

  Future<void> renameChannel(int id, String name) => _updateChannelField(
      id, 'name', name, (r) => r.name, (v) => ChannelsCompanion(name: Value(v)));

  Future<void> updateChannelNotes(int id, String? notes) => _updateChannelField(
      id, 'notes', notes, (r) => r.notes, (v) => ChannelsCompanion(notes: Value(v)));

  Future<void> deleteChannel(int id) => _tracked.deleteRow(
        table: 'channels',
        id: id,
        buildSnapshot: () async =>
            (await (_db.select(_db.channels)..where((t) => t.id.equals(id))).getSingle()).toJson(),
        doDelete: () => (_db.delete(_db.channels)..where((t) => t.id.equals(id))).go(),
      );

  // ── Addresses ─────────────────────────────────────────────────────────────

  Stream<List<AddressesData>> watchAddresses() =>
      (_db.select(_db.addresses)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addAddress(String name) async {
    final res = await _tracked.insertRow(
      table: 'addresses',
      doInsert: () => _db.into(_db.addresses).insert(AddressesCompanion(name: Value(name))),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.addresses)..where((t) => t.id.equals(id))).getSingle()).toJson(),
    );
    return res.rowId;
  }

  Future<void> renameAddress(int id, String name) => _updateAddressField(
      id, 'name', name, (r) => r.name, (v) => AddressesCompanion(name: Value(v)));

  Future<void> updateAddressType(int id, String? type) => _updateAddressField(
      id, 'type', type, (r) => r.type, (v) => AddressesCompanion(type: Value(v)));

  Future<void> updateAddressChannel(int id, String? channel) => _updateAddressField(
      id, 'channel', channel, (r) => r.channel, (v) => AddressesCompanion(channel: Value(v)));

  Future<void> deleteAddress(int id) => _tracked.deleteRow(
        table: 'addresses',
        id: id,
        buildSnapshot: () async =>
            (await (_db.select(_db.addresses)..where((t) => t.id.equals(id))).getSingle()).toJson(),
        doDelete: () => (_db.delete(_db.addresses)..where((t) => t.id.equals(id))).go(),
      );

  // ── Dimmers ───────────────────────────────────────────────────────────────

  Stream<List<Dimmer>> watchDimmers() =>
      (_db.select(_db.dimmers)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addDimmer(String name) async {
    final res = await _tracked.insertRow(
      table: 'dimmers',
      doInsert: () => _db.into(_db.dimmers).insert(DimmersCompanion(name: Value(name))),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.dimmers)..where((t) => t.id.equals(id))).getSingle()).toJson(),
    );
    return res.rowId;
  }

  Future<void> renameDimmer(int id, String name) => _updateDimmerField(
      id, 'name', name, (r) => r.name, (v) => DimmersCompanion(name: Value(v)));

  Future<void> updateDimmerAddress(int id, String? address) => _updateDimmerField(
      id, 'address', address, (r) => r.address, (v) => DimmersCompanion(address: Value(v)));

  Future<void> updateDimmerPack(int id, String? pack) => _updateDimmerField(
      id, 'pack', pack, (r) => r.pack, (v) => DimmersCompanion(pack: Value(v)));

  Future<void> updateDimmerRack(int id, String? rack) => _updateDimmerField(
      id, 'rack', rack, (r) => r.rack, (v) => DimmersCompanion(rack: Value(v)));

  Future<void> updateDimmerLocation(int id, String? location) => _updateDimmerField(
      id, 'location', location, (r) => r.location, (v) => DimmersCompanion(location: Value(v)));

  Future<void> updateDimmerCapacity(int id, String? capacity) => _updateDimmerField(
      id, 'capacity', capacity, (r) => r.capacity, (v) => DimmersCompanion(capacity: Value(v)));

  Future<void> deleteDimmer(int id) => _tracked.deleteRow(
        table: 'dimmers',
        id: id,
        buildSnapshot: () async =>
            (await (_db.select(_db.dimmers)..where((t) => t.id.equals(id))).getSingle()).toJson(),
        doDelete: () => (_db.delete(_db.dimmers)..where((t) => t.id.equals(id))).go(),
      );

  // ── Circuits ──────────────────────────────────────────────────────────────

  Stream<List<Circuit>> watchCircuits() =>
      (_db.select(_db.circuits)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addCircuit(String name) async {
    final res = await _tracked.insertRow(
      table: 'circuits',
      doInsert: () => _db.into(_db.circuits).insert(CircuitsCompanion(name: Value(name))),
      buildSnapshot: (id) async =>
          (await (_db.select(_db.circuits)..where((t) => t.id.equals(id))).getSingle()).toJson(),
    );
    return res.rowId;
  }

  Future<void> renameCircuit(int id, String name) => _updateCircuitField(
      id, 'name', name, (r) => r.name, (v) => CircuitsCompanion(name: Value(v)));

  Future<void> updateCircuitDimmer(int id, String? dimmer) => _updateCircuitField(
      id, 'dimmer', dimmer, (r) => r.dimmer, (v) => CircuitsCompanion(dimmer: Value(v)));

  Future<void> updateCircuitCapacity(int id, String? capacity) => _updateCircuitField(
      id, 'capacity', capacity, (r) => r.capacity, (v) => CircuitsCompanion(capacity: Value(v)));

  Future<void> deleteCircuit(int id) => _tracked.deleteRow(
        table: 'circuits',
        id: id,
        buildSnapshot: () async =>
            (await (_db.select(_db.circuits)..where((t) => t.id.equals(id))).getSingle()).toJson(),
        doDelete: () => (_db.delete(_db.circuits)..where((t) => t.id.equals(id))).go(),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _updateChannelField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(Channel) readField,
    ChannelsCompanion Function(T) buildCompanion,
  ) =>
      _tracked.updateField(
        table: 'channels',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async =>
            readField(await (_db.select(_db.channels)..where((t) => t.id.equals(id))).getSingle()),
        applyUpdate: (v) async =>
            (_db.update(_db.channels)..where((t) => t.id.equals(id))).write(buildCompanion(v)),
      );

  Future<void> _updateAddressField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(AddressesData) readField,
    AddressesCompanion Function(T) buildCompanion,
  ) =>
      _tracked.updateField(
        table: 'addresses',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async =>
            readField(await (_db.select(_db.addresses)..where((t) => t.id.equals(id))).getSingle()),
        applyUpdate: (v) async =>
            (_db.update(_db.addresses)..where((t) => t.id.equals(id))).write(buildCompanion(v)),
      );

  Future<void> _updateDimmerField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(Dimmer) readField,
    DimmersCompanion Function(T) buildCompanion,
  ) =>
      _tracked.updateField(
        table: 'dimmers',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async =>
            readField(await (_db.select(_db.dimmers)..where((t) => t.id.equals(id))).getSingle()),
        applyUpdate: (v) async =>
            (_db.update(_db.dimmers)..where((t) => t.id.equals(id))).write(buildCompanion(v)),
      );

  Future<void> _updateCircuitField<T>(
    int id,
    String fieldName,
    T newValue,
    T Function(Circuit) readField,
    CircuitsCompanion Function(T) buildCompanion,
  ) =>
      _tracked.updateField(
        table: 'circuits',
        id: id,
        field: fieldName,
        newValue: newValue,
        readCurrentValue: () async =>
            readField(await (_db.select(_db.circuits)..where((t) => t.id.equals(id))).getSingle()),
        applyUpdate: (v) async =>
            (_db.update(_db.circuits)..where((t) => t.id.equals(id))).write(buildCompanion(v)),
      );
}
