# REPORT-003: Default Templates & Persistence

## Summary
Create the `ReportTemplateRepository` for CRUD operations on the `Reports` table, define the 3 built-in default templates, wire providers into `show_provider.dart`, and seed defaults on first open.

## Depends On
- REPORT-001 (data models)

## Files to Create
1. `lib/features/reports/report_template_defaults.dart`
2. `lib/repositories/report_template_repository.dart`

## Files to Modify
1. `lib/providers/show_provider.dart` — add `reportTemplateRepoProvider` and `reportTemplatesProvider`

## Detailed Instructions

### 1. `report_template_defaults.dart`

Define the 3 built-in templates as `const` values.

```dart
import 'report_template.dart';

const kDefaultTemplates = <ReportTemplate>[
  // 1. Channel Hookup
  ReportTemplate(
    name: 'Channel Hookup',
    columns: [
      ReportColumn(id: 'chan', label: 'CH', fieldKeys: ['chan'], fixedWidth: 30, isBold: true),
      ReportColumn(id: 'dimmer', label: 'DIM', fieldKeys: ['dimmer'], fixedWidth: 40),
      ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], fixedWidth: 80),
      ReportColumn(id: 'unit', label: 'U#', fieldKeys: ['unit'], fixedWidth: 30),
      ReportColumn(id: 'stack_purpose_area', label: 'PURPOSE / AREA', fieldKeys: ['function', 'focus'], flex: 1),
      ReportColumn(id: 'stack_instrument', label: 'FULL DEFINITION', fieldKeys: ['type', 'wattage'], flex: 2),
      ReportColumn(id: 'stack_color_template', label: 'COLOR / TEMPLATE', fieldKeys: ['color', 'gobo1'], fixedWidth: 80),
    ],
    groupByFieldKey: 'position',
    sortByFieldKey: 'chan',
    sortAscending: true,
    orientation: 'portrait',
  ),

  // 2. Instrument Schedule
  ReportTemplate(
    name: 'Instrument Schedule',
    columns: [
      ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], fixedWidth: 100),
      ReportColumn(id: 'unit', label: 'U#', fieldKeys: ['unit'], fixedWidth: 30),
      ReportColumn(id: 'type', label: 'TYPE', fieldKeys: ['type'], flex: 1),
      ReportColumn(id: 'wattage', label: 'WATT', fieldKeys: ['wattage'], fixedWidth: 60),
      ReportColumn(id: 'accessories', label: 'ACCESSORIES', fieldKeys: ['accessories'], flex: 1),
      ReportColumn(id: 'color', label: 'COLOR', fieldKeys: ['color'], fixedWidth: 80),
      ReportColumn(id: 'chan', label: 'CH', fieldKeys: ['chan'], fixedWidth: 40),
      ReportColumn(id: 'dimmer', label: 'DIM', fieldKeys: ['dimmer'], fixedWidth: 50),
    ],
    groupByFieldKey: 'position',
    sortByFieldKey: 'unit',
    sortAscending: true,
    orientation: 'landscape',
  ),

  // 3. Channel Schedule
  ReportTemplate(
    name: 'Channel Schedule',
    columns: [
      ReportColumn(id: 'chan', label: 'CH', fieldKeys: ['chan'], fixedWidth: 40, isBold: true),
      ReportColumn(id: 'dimmer', label: 'DIM', fieldKeys: ['dimmer'], fixedWidth: 50),
      ReportColumn(id: 'circuit', label: 'CKT', fieldKeys: ['circuit'], fixedWidth: 50),
      ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], fixedWidth: 80),
      ReportColumn(id: 'unit', label: 'U#', fieldKeys: ['unit'], fixedWidth: 30),
      ReportColumn(id: 'function', label: 'PURPOSE', fieldKeys: ['function'], flex: 1),
      ReportColumn(id: 'type', label: 'TYPE', fieldKeys: ['type'], flex: 1),
      ReportColumn(id: 'color', label: 'COLOR', fieldKeys: ['color'], fixedWidth: 60),
    ],
    sortByFieldKey: 'chan',
    sortAscending: true,
    orientation: 'portrait',
  ),
];
```

### 2. `report_template_repository.dart`

Follow the exact same pattern as `SpreadsheetViewPresetRepository`:

```dart
import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../features/reports/report_template.dart';
import '../features/reports/report_template_defaults.dart';
import 'tracked_write_repository.dart';

class ReportTemplateRepository {
  ReportTemplateRepository(this._db, this._tracked);
  final AppDatabase _db;
  final TrackedWriteRepository _tracked;

  Stream<List<Report>> watchTemplates() {
    return (_db.select(_db.reports)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<int> createTemplate(String name, ReportTemplate template) async {
    return await _db.into(_db.reports).insert(ReportsCompanion(
      name: Value(name),
      templateJson: Value(jsonEncode(template.toJson())),
    ));
  }

  Future<void> updateTemplate(int id, ReportTemplate template) async {
    await (_db.update(_db.reports)..where((t) => t.id.equals(id))).write(
      ReportsCompanion(
        name: Value(template.name),
        templateJson: Value(jsonEncode(template.toJson())),
      ),
    );
  }

  Future<void> deleteTemplate(int id) async {
    await (_db.delete(_db.reports)..where((t) => t.id.equals(id))).go();
  }

  /// Seeds the 3 default templates if the table is empty.
  Future<void> seedDefaults() async {
    final query = _db.selectOnly(_db.reports)..addColumns([_db.reports.id.count()]);
    final result = await query.getSingle();
    final count = result.read(_db.reports.id.count()) ?? 0;
    if (count > 0) return;

    await _db.batch((batch) {
      for (final tmpl in kDefaultTemplates) {
        batch.insert(_db.reports, ReportsCompanion(
          name: Value(tmpl.name),
          templateJson: Value(jsonEncode(tmpl.toJson())),
        ));
      }
    });
  }

  /// Parses a Report row's templateJson into a ReportTemplate.
  static ReportTemplate parseTemplate(Report row) {
    return ReportTemplate.fromJson(
      jsonDecode(row.templateJson) as Map<String, dynamic>,
    );
  }
}
```

### 3. Modify `show_provider.dart`

Add these two providers at the bottom of the file, before the closing blank lines:

```dart
/// Repository for saved report templates.
final reportTemplateRepoProvider = Provider.autoDispose<ReportTemplateRepository?>((ref) {
  final db = ref.watch(databaseProvider);
  final tracked = ref.watch(trackedWriteProvider);
  if (db == null || tracked == null) return null;
  return ReportTemplateRepository(db, tracked);
});

/// Streams the list of saved report templates.
final reportTemplatesProvider = StreamProvider.autoDispose<List<Report>>((ref) {
  final repo = ref.watch(reportTemplateRepoProvider);
  if (repo == null) return Stream.value([]);
  return repo.watchTemplates();
});
```

Add the required imports at the top of `show_provider.dart`:
```dart
import '../repositories/report_template_repository.dart';
```

### 4. Seed defaults on show open

In `main_shell.dart`, find where `spreadsheetViewPresetRepoProvider` seeds its defaults (look for `seedDefaults()` call). Add a parallel seed call for report templates:

```dart
final reportRepo = ref.read(reportTemplateRepoProvider);
reportRepo?.seedDefaults();
```

If there is no explicit `seedDefaults()` call for presets in `main_shell.dart`, then add the seed call in the `initState()` or `didChangeDependencies()` of `ReportsTab` instead:

```dart
@override
void initState() {
  super.initState();
  _loadTheme();
  // Seed default report templates
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(reportTemplateRepoProvider)?.seedDefaults();
  });
}
```

## Testing
- After hot restart, verify the `reports` table contains 3 rows (use sqlite browser or add a debug print)
- Verify `ReportTemplateRepository.parseTemplate()` correctly deserializes the stored JSON
- Verify the providers compile without errors
