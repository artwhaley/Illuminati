import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../features/reports/report_template.dart';
import '../features/reports/report_template_defaults.dart';

class ReportTemplateRepository {
  ReportTemplateRepository(this._db);
  final AppDatabase _db;

  Stream<List<Report>> watchTemplates() {
    return (_db.select(_db.reports)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<int> createTemplate(String name, ReportTemplate template) async {
    return await _db.into(_db.reports).insert(ReportsCompanion(
      name: Value(name),
      templateJson: Value(jsonEncode(template.toJson())),
      isSystem: const Value(0),
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
    final row = await (_db.select(_db.reports)..where((t) => t.id.equals(id))).getSingle();
    if (row.isSystem == 1) {
      throw StateError('Cannot delete system template');
    }
    await (_db.delete(_db.reports)..where((t) => t.id.equals(id))).go();
  }

  /// Seeds the default templates if the table is empty.
  Future<void> seedDefaults() async {
    final query = _db.selectOnly(_db.reports)..addColumns([_db.reports.id.count()]);
    final result = await query.getSingle();
    final count = result.read(_db.reports.id.count()) ?? 0;
    if (count > 0) return;

    await _db.batch((batch) {
      for (final tmpl in kDefaultTemplates) {
        batch.insert(_db.reports, ReportsCompanion(
          name: Value(tmpl.name),
          isSystem: const Value(1),
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
