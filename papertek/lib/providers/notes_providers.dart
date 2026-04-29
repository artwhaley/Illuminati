import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/notes_repository.dart';
import 'show_provider.dart';

final notesRepoProvider = Provider<NotesRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  if (db == null) return null;
  return NotesRepository(db);
});

class NotesFilter {
  NotesFilter({
    this.completed,
    this.elevated,
    this.search,
    this.fromDate,
    this.toDate,
    this.positionFilter,
    this.fixtureIdFilter,
  });

  final bool? completed;
  final bool? elevated;
  final String? search;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? positionFilter;
  final int? fixtureIdFilter;

  NotesFilter copyWith({
    bool? completed,
    bool? elevated,
    String? search,
    DateTime? fromDate,
    DateTime? toDate,
    String? positionFilter,
    int? fixtureIdFilter,
    bool clearCompleted = false,
    bool clearElevated = false,
    bool clearSearch = false,
    bool clearFromDate = false,
    bool clearToDate = false,
    bool clearPositionFilter = false,
    bool clearFixtureIdFilter = false,
  }) {
    return NotesFilter(
      completed: clearCompleted ? null : completed ?? this.completed,
      elevated: clearElevated ? null : elevated ?? this.elevated,
      search: clearSearch ? null : search ?? this.search,
      fromDate: clearFromDate ? null : fromDate ?? this.fromDate,
      toDate: clearToDate ? null : toDate ?? this.toDate,
      positionFilter: clearPositionFilter ? null : positionFilter ?? this.positionFilter,
      fixtureIdFilter: clearFixtureIdFilter ? null : fixtureIdFilter ?? this.fixtureIdFilter,
    );
  }
}

final workNotesFilterProvider = StateProvider<NotesFilter>((ref) => NotesFilter());
final boardNotesFilterProvider = StateProvider<NotesFilter>((ref) => NotesFilter());

final workNotesProvider = StreamProvider<List<NoteWithDetails>>((ref) {
  final repo = ref.watch(notesRepoProvider);
  if (repo == null) return Stream.value([]);
  
  final filter = ref.watch(workNotesFilterProvider);
  return repo.watchNotes(
    type: 'work',
    completed: filter.completed,
    elevated: filter.elevated,
    search: filter.search,
    fromDate: filter.fromDate,
    toDate: filter.toDate,
    positionFilter: filter.positionFilter,
    fixtureIdFilter: filter.fixtureIdFilter,
  );
});

final boardNotesProvider = StreamProvider<List<NoteWithDetails>>((ref) {
  final repo = ref.watch(notesRepoProvider);
  if (repo == null) return Stream.value([]);
  
  final filter = ref.watch(boardNotesFilterProvider);
  return repo.watchNotes(
    type: 'board',
    completed: filter.completed,
    elevated: filter.elevated,
    search: filter.search,
    fromDate: filter.fromDate,
    toDate: filter.toDate,
    positionFilter: filter.positionFilter,
    fixtureIdFilter: filter.fixtureIdFilter,
  );
});

final noteActionsProvider = StreamProvider.family<List<NoteActionData>, int>((ref, noteId) {
  final repo = ref.watch(notesRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchActionsForNote(noteId);
});

final fixtureSearchProvider = FutureProvider.family<List<FixtureSearchResult>, String>((ref, query) async {
  final repo = ref.watch(notesRepoProvider);
  if (repo == null) return [];
  return repo.searchFixtures(query);
});
