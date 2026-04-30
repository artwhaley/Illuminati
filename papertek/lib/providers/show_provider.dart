/// ── SERVICE REGISTRY & DEPENDENCY INJECTION ──────────────────────────────────
///
/// This file is the "Central Nervous System" of the PaperTek application. It 
/// uses Riverpod to manage application state, service lifecycles, and 
/// dependency injection.
///
/// KEY CONCEPTS:
/// 1. The Root (databaseProvider): 
///    Everything starts here. When a .papertek file is opened, this provider 
///    is populated. Almost every other provider in the app "watches" this. 
///    When it becomes null, the app reverts to the Start Screen.
///
/// 2. Layered Architecture:
///    - Core: Low-level database and file services.
///    - Repositories: High-level APIs for interacting with specific data 
///      (Fixtures, Channels, etc.). These encapsulate the "Tracked Write" logic.
///    - Streams: Reactive data sources that the UI binds to.
///
/// 3. autoDispose vs. Persistent:
///    - autoDispose: Used for UI-bound data (like a list of fixtures). When 
///      no screen is looking at the data, Riverpod closes the stream to 
///      save memory and CPU.
///    - Persistent: Used for core services (like TrackedWriteRepository). 
///      These must stay alive as long as the show is open because they 
///      maintain critical state like the Undo/Redo stack.
/// ─────────────────────────────────────────────────────────────────────────────

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
import '../repositories/operational_repository.dart';
import '../services/show_file_service.dart';
import '../repositories/spreadsheet_view_preset_repository.dart';
import '../services/import/import_service.dart';
import '../services/commit_service.dart';
import '../repositories/report_template_repository.dart';
import '../ui/reports/report_template_notifier.dart';
import '../features/reports/report_template.dart';
import '../repositories/custom_field_repository.dart';

// ── CORE PROVIDERS ───────────────────────────────────────────────────────────

/// The currently open show database. 
/// Setting this to non-null triggers the app to switch from the Start Screen 
/// to the Main Shell. Setting it to null closes the show.
final databaseProvider = StateProvider<AppDatabase?>((ref) => null);

/// Stateless service responsible for file-system operations like creating,
/// opening, and saving .papertek (SQLite) files.
final showFileServiceProvider =
    Provider<ShowFileService>((ref) => ShowFileService());

// ── REPOSITORIES (The Business Logic Layer) ──────────────────────────────────

/// The central write-coordinator for the app.
/// This repository is NOT autoDispose because it holds the application's
/// Undo/Redo stack and current "Designer Mode" transaction state.
final trackedWriteProvider =
    Provider<TrackedWriteRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  return db != null ? TrackedWriteRepository(db) : null;
});

/// Global flag for "Designer Mode".
/// - TRUE: Writes are committed immediately to the database (No Undo/Redo).
/// - FALSE: Writes create "Pending Revisions" that must be committed later.
final designerModeProvider = StateProvider<bool>((ref) => false);

/// Repository for querying and managing the audit trail (Pending Revisions).
final revisionRepoProvider =
    Provider.autoDispose<RevisionRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  return db != null ? RevisionRepository(db) : null;
});

// ── REACTIVE UI DATA STREAMS ──────────────────────────────────────────────────

/// Provides a set of Fixture IDs that have uncommitted changes.
/// Used to highlight rows in yellow on the spreadsheet.
final pendingFixtureIdsProvider =
    StreamProvider.autoDispose<Set<int>>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value({});
  return repo.watchPendingFixtureIds();
});

/// Provides a set of Fixture IDs where multiple users/devices have 
/// edited the same data, creating a conflict. Drives the red highlights.
final conflictFixtureIdsProvider =
    StreamProvider.autoDispose<Set<int>>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value({});
  return repo.watchConflictingFixtureIds();
});

/// The raw list of pending revisions grouped by fixture, used in the
/// "Review Changes" queue on the Maintenance tab.
final pendingGroupedRevisionsProvider =
    StreamProvider.autoDispose<Map<int?, List<RevisionView>>>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value({});
  return repo.watchPendingGroupedByFixture();
});

/// Total number of uncommitted changes across the entire show.
/// Drives the notification badge on the Maintenance tab icon.
final pendingCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repo = ref.watch(revisionRepoProvider);
  if (repo == null) return Stream.value(0);
  return repo.watchPendingCount();
});

// ── DOMAIN REPOSITORIES ──────────────────────────────────────────────────────
// These providers expose specialized repositories for different parts of
// the lighting data model (Positions, Types, Venues, etc.)

/// Handles high-level show metadata (Show Name, Designer Name, Date).
final showMetaRepoProvider =
    Provider.autoDispose<ShowMetaRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return ShowMetaRepository(db, tracked);
});

/// Streams the current show metadata row.
final currentShowMetaProvider =
    StreamProvider.autoDispose<ShowMetaData?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return Stream.value(null);
  return (db.select(db.showMeta)..limit(1)).watchSingleOrNull();
});

/// Service for importing CSV/Lightwright data.
final importServiceProvider = Provider.autoDispose<ImportService?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return ImportService(db: db, tracked: tracked);
});

/// Service for committing pending revisions into the permanent "Revision History".
final commitServiceProvider = Provider.autoDispose<CommitService?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return CommitService(db: db, tracked: tracked);
});

/// Repository for "Lighting Positions" (e.g. Electric 1, FOH Pipe).
final positionRepoProvider =
    Provider.autoDispose<PositionRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return PositionRepository(db, tracked);
});

/// Streams all defined lighting positions.
final lightingPositionsProvider =
    StreamProvider.autoDispose<List<LightingPosition>>((ref) {
  final repo = ref.watch(positionRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAll();
});

/// Streams positions grouped into hierarchy (e.g. Overhead vs Deck).
final positionGroupsProvider =
    StreamProvider.autoDispose<List<PositionGroup>>((ref) {
  final repo = ref.watch(positionRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchGroups();
});

/// Repository for the show's contact list (ME, ALD, Production Electricians).
final roleContactRepoProvider =
    Provider.autoDispose<RoleContactRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return RoleContactRepository(db, tracked);
});

/// Repository for "Fixture Types" (e.g. S4 26deg, Mac Aura).
final fixtureTypeRepoProvider =
    Provider.autoDispose<FixtureTypeRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return FixtureTypeRepository(db, tracked);
});

/// Streams all unique fixture types defined in the show.
final fixtureTypesProvider =
    StreamProvider.autoDispose<List<FixtureType>>((ref) {
  final repo = ref.watch(fixtureTypeRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAll();
});

/// Repository for venue-specific infrastructure (Dimmers, Circuits, Addresses).
final venueRepoProvider = Provider.autoDispose<VenueRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return VenueRepository(db, tracked);
});

/// Streams the list of console channels.
final channelsProvider = StreamProvider.autoDispose<List<Channel>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchChannels();
});

/// Streams the raw DMX/Network address patch.
final addressesProvider =
    StreamProvider.autoDispose<List<AddressesData>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchAddresses();
});

/// Streams venue dimmer data.
final dimmersProvider = StreamProvider.autoDispose<List<Dimmer>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchDimmers();
});

/// Streams venue circuit data.
final circuitsProvider = StreamProvider.autoDispose<List<Circuit>>((ref) {
  final repo = ref.watch(venueRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchCircuits();
});

/// THE PRIMARY REPOSITORY: Manages all Fixture data.
final fixtureRepoProvider = Provider.autoDispose<FixtureRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return FixtureRepository(db, tracked);
});

/// The reactive stream of all fixtures in the show. 
/// This is what powers the main Spreadsheet tab.
final fixtureRowsProvider =
    StreamProvider.autoDispose<List<FixtureRow>>((ref) {
  final repo = ref.watch(fixtureRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchRows();
});

/// Repository for Spreadsheet layout presets (column order, hidden cols, etc).
final spreadsheetViewPresetRepoProvider =
    Provider.autoDispose<SpreadsheetViewPresetRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return SpreadsheetViewPresetRepository(db, tracked);
});

/// Streams the list of saved spreadsheet view presets.
final spreadsheetViewPresetsProvider =
    StreamProvider.autoDispose<List<SpreadsheetViewPreset>>((ref) {
  final repo = ref.watch(spreadsheetViewPresetRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchPresets();
});

/// Repository for user-defined custom fields.
final customFieldRepoProvider = Provider.autoDispose<CustomFieldRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return CustomFieldRepository(db, tracked);
});

/// Streams all defined custom fields.
final customFieldsProvider = StreamProvider.autoDispose<List<CustomField>>((ref) {
  final repo = ref.watch(customFieldRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchFields();
});

/// Repository for saved report templates.
final reportTemplateRepoProvider = Provider.autoDispose<ReportTemplateRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return ReportTemplateRepository(db);
});

/// Streams the list of saved report templates.
final reportTemplatesProvider = StreamProvider.autoDispose<List<Report>>((ref) {
  final repo = ref.watch(reportTemplateRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchTemplates();
});

/// The currently-edited report template. Shared between the editor panel and PDF preview.
final activeReportTemplateProvider =
    StateNotifierProvider<ReportTemplateNotifier, ReportTemplate>((ref) {
  return ReportTemplateNotifier();
});

/// The currently selected template row id in DB.
final activeReportTemplateIdProvider = StateProvider<int?>((ref) => null);

/// Dirty flag for template editor state.
final activeReportTemplateDirtyProvider = StateProvider<bool>((ref) => false);

// ── OPERATIONAL PROVIDERS ───────────────────────────────────────────────────

final operationalRepoProvider = Provider.autoDispose<OperationalRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return OperationalRepository(db);
});

final unresolvedMaintenanceProvider = StreamProvider.autoDispose<List<MaintenanceLogData>>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return Stream.value([]);
  return (db.select(db.maintenanceLog)..where((t) => t.resolved.equals(0))).watch();
});

final flaggedFixturesProvider = StreamProvider.autoDispose<List<FixtureRow>>((ref) {
  final repo = ref.watch(fixtureRepoProvider);
  if (repo == null) return Stream.value([]);
  // We can't filter flagged=1 directly in watchRows() without adding a param, 
  // so we'll filter the stream here.
  return repo.watchRows().map((list) => list.where((f) => f.flagged == 1).toList());
});


