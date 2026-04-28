import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../repositories/tracked_write_repository.dart';
import '../repositories/revision_repository.dart';
import '../repositories/show_meta_repository.dart';
import '../repositories/position_repository.dart';
import '../repositories/role_contact_repository.dart';
import '../repositories/fixture_type_repository.dart';
import '../repositories/venue_repository.dart';
import '../repositories/fixture_repository.dart';
import '../services/show_file_service.dart';
import '../repositories/spreadsheet_view_preset_repository.dart';
import '../services/import/import_service.dart';
import '../services/commit_service.dart';

// ── Core ─────────────────────────────────────────────────────────────────────

/// The currently open show database. Setting this switches the app between
/// StartScreen and MainShell.
final databaseProvider = StateProvider<AppDatabase?>((ref) => null);

/// Stateless service for creating / opening .papertek files.
final showFileServiceProvider =
    Provider<ShowFileService>((ref) => ShowFileService());

// ── Derived from the open database ───────────────────────────────────────────

// NOT autoDispose — the undo stack and designer-mode state must survive
// tab switches and widget rebuilds for the entire lifetime of the open show.
final trackedWriteProvider =
    Provider<TrackedWriteRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  return db != null ? TrackedWriteRepository(db) : null;
});

/// Designer mode flag. True = TrackedWriteRepository writes without revision
/// rows. Flipping requires committing pending revisions first.
final designerModeProvider = StateProvider<bool>((ref) => false);

// ── Revision query layer ──────────────────────────────────────────────────────

final revisionRepoProvider =
    Provider.autoDispose<RevisionRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  return db != null ? RevisionRepository(db) : null;
});

/// Set of fixture IDs with at least one pending revision → yellow highlight.
final pendingFixtureIdsProvider =
    StreamProvider.autoDispose<Set<int>>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value({});
  return repo.watchPendingFixtureIds();
});

/// Set of fixture IDs with conflicting pending revisions → red highlight.
final conflictFixtureIdsProvider =
    StreamProvider.autoDispose<Set<int>>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value({});
  return repo.watchConflictingFixtureIds();
});

/// Pending revisions grouped by fixture ID (for the review queue).
final pendingGroupedRevisionsProvider =
    StreamProvider.autoDispose<Map<int?, List<RevisionView>>>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value({});
  return repo.watchPendingGroupedByFixture();
});

/// Total pending revision count — drives badge on Maintenance tab icon.
final pendingCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value(0);
  return repo.watchPendingCount();
});

final showMetaRepoProvider =
    Provider.autoDispose<ShowMetaRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return ShowMetaRepository(db, tracked);
});

final currentShowMetaProvider =
    StreamProvider.autoDispose<ShowMetaData?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return Stream.value(null);
  return (db.select(db.showMeta)..limit(1)).watchSingleOrNull();
});

final importServiceProvider = Provider.autoDispose<ImportService?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return ImportService(db: db, tracked: tracked);
});

final commitServiceProvider = Provider.autoDispose<CommitService?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return CommitService(db: db, tracked: tracked);
});

final positionRepoProvider =
    Provider.autoDispose<PositionRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return PositionRepository(db, tracked);
});

final lightingPositionsProvider =
    StreamProvider.autoDispose<List<LightingPosition>>((ref) {
  final repo = ref.watch(positionRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAll();
});

final positionGroupsProvider =
    StreamProvider.autoDispose<List<PositionGroup>>((ref) {
  final repo = ref.watch(positionRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchGroups();
});

final roleContactRepoProvider =
    Provider.autoDispose<RoleContactRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return RoleContactRepository(db, tracked);
});

final fixtureTypeRepoProvider =
    Provider.autoDispose<FixtureTypeRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return FixtureTypeRepository(db, tracked);
});

final fixtureTypesProvider =
    StreamProvider.autoDispose<List<FixtureType>>((ref) {
  final repo = ref.watch(fixtureTypeRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAll();
});

final venueRepoProvider = Provider.autoDispose<VenueRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return VenueRepository(db, tracked);
});

final channelsProvider = StreamProvider.autoDispose<List<Channel>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchChannels();
});

final addressesProvider =
    StreamProvider.autoDispose<List<AddressesData>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAddresses();
});

final dimmersProvider = StreamProvider.autoDispose<List<Dimmer>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchDimmers();
});

final circuitsProvider = StreamProvider.autoDispose<List<Circuit>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchCircuits();
});

final fixtureRepoProvider = Provider.autoDispose<FixtureRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return FixtureRepository(db, tracked);
});

final fixtureRowsProvider =
    StreamProvider.autoDispose<List<FixtureRow>>((ref) {
  final repo = ref.watch(fixtureRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchRows();
});

final spreadsheetViewPresetRepoProvider =
    Provider.autoDispose<SpreadsheetViewPresetRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return SpreadsheetViewPresetRepository(db, tracked);
});

final spreadsheetViewPresetsProvider =
    StreamProvider.autoDispose<List<SpreadsheetViewPreset>>((ref) {
  final repo = ref.watch(spreadsheetViewPresetRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchPresets();
});


