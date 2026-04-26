import 'package:drift/drift.dart';
import '../database/database.dart';

/// CRUD for the four venue lookup tables: Channels, Addresses, Dimmers, Circuits.
/// Positions and PositionGroups are handled by PositionRepository.
class VenueRepository {
  VenueRepository(this._db);

  final AppDatabase _db;

  // ── Channels ──────────────────────────────────────────────────────────────

  Stream<List<Channel>> watchChannels() =>
      (_db.select(_db.channels)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addChannel(String name) =>
      _db.into(_db.channels).insert(ChannelsCompanion(name: Value(name)));

  Future<void> renameChannel(int id, String name) =>
      (_db.update(_db.channels)..where((t) => t.id.equals(id)))
          .write(ChannelsCompanion(name: Value(name)));

  Future<void> updateChannelNotes(int id, String? notes) =>
      (_db.update(_db.channels)..where((t) => t.id.equals(id)))
          .write(ChannelsCompanion(notes: Value(notes)));

  Future<void> deleteChannel(int id) =>
      (_db.delete(_db.channels)..where((t) => t.id.equals(id))).go();

  // ── Addresses ─────────────────────────────────────────────────────────────

  Stream<List<AddressesData>> watchAddresses() =>
      (_db.select(_db.addresses)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addAddress(String name) =>
      _db.into(_db.addresses).insert(AddressesCompanion(name: Value(name)));

  Future<void> renameAddress(int id, String name) =>
      (_db.update(_db.addresses)..where((t) => t.id.equals(id)))
          .write(AddressesCompanion(name: Value(name)));

  Future<void> updateAddressType(int id, String? type) =>
      (_db.update(_db.addresses)..where((t) => t.id.equals(id)))
          .write(AddressesCompanion(type: Value(type)));

  Future<void> updateAddressChannel(int id, String? channel) =>
      (_db.update(_db.addresses)..where((t) => t.id.equals(id)))
          .write(AddressesCompanion(channel: Value(channel)));

  Future<void> deleteAddress(int id) =>
      (_db.delete(_db.addresses)..where((t) => t.id.equals(id))).go();

  // ── Dimmers ───────────────────────────────────────────────────────────────

  Stream<List<Dimmer>> watchDimmers() =>
      (_db.select(_db.dimmers)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addDimmer(String name) =>
      _db.into(_db.dimmers).insert(DimmersCompanion(name: Value(name)));

  Future<void> renameDimmer(int id, String name) =>
      (_db.update(_db.dimmers)..where((t) => t.id.equals(id)))
          .write(DimmersCompanion(name: Value(name)));

  Future<void> updateDimmerAddress(int id, String? address) =>
      (_db.update(_db.dimmers)..where((t) => t.id.equals(id)))
          .write(DimmersCompanion(address: Value(address)));

  Future<void> updateDimmerPack(int id, String? pack) =>
      (_db.update(_db.dimmers)..where((t) => t.id.equals(id)))
          .write(DimmersCompanion(pack: Value(pack)));

  Future<void> updateDimmerRack(int id, String? rack) =>
      (_db.update(_db.dimmers)..where((t) => t.id.equals(id)))
          .write(DimmersCompanion(rack: Value(rack)));

  Future<void> updateDimmerLocation(int id, String? location) =>
      (_db.update(_db.dimmers)..where((t) => t.id.equals(id)))
          .write(DimmersCompanion(location: Value(location)));

  Future<void> updateDimmerCapacity(int id, String? capacity) =>
      (_db.update(_db.dimmers)..where((t) => t.id.equals(id)))
          .write(DimmersCompanion(capacity: Value(capacity)));

  Future<void> deleteDimmer(int id) =>
      (_db.delete(_db.dimmers)..where((t) => t.id.equals(id))).go();

  // ── Circuits ──────────────────────────────────────────────────────────────

  Stream<List<Circuit>> watchCircuits() =>
      (_db.select(_db.circuits)
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> addCircuit(String name) =>
      _db.into(_db.circuits).insert(CircuitsCompanion(name: Value(name)));

  Future<void> renameCircuit(int id, String name) =>
      (_db.update(_db.circuits)..where((t) => t.id.equals(id)))
          .write(CircuitsCompanion(name: Value(name)));

  Future<void> updateCircuitDimmer(int id, String? dimmer) =>
      (_db.update(_db.circuits)..where((t) => t.id.equals(id)))
          .write(CircuitsCompanion(dimmer: Value(dimmer)));

  Future<void> updateCircuitCapacity(int id, String? capacity) =>
      (_db.update(_db.circuits)..where((t) => t.id.equals(id)))
          .write(CircuitsCompanion(capacity: Value(capacity)));

  Future<void> deleteCircuit(int id) =>
      (_db.delete(_db.circuits)..where((t) => t.id.equals(id))).go();
}
