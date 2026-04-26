import 'package:drift/drift.dart';

class Commits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get userId => text()();
  TextColumn get timestamp => text()();
  TextColumn get notes => text().nullable()();
}

// operation values: 'update' | 'insert' | 'delete' | 'import_batch'
// old_value / new_value are JSON text; JSON null means the field was null;
// SQL NULL means "not applicable for this operation".
class Revisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operation => text()();
  TextColumn get targetTable => text()();
  IntColumn get targetId => integer().nullable()();
  // update: column name; insert/delete/import_batch: NULL
  TextColumn get fieldName => text().nullable()();
  // JSON-encoded value or snapshot; SQL NULL = not applicable
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  // Groups many revision rows from one bulk action (e.g. one CSV import)
  TextColumn get batchId => text().nullable()();
  TextColumn get userId => text()();
  TextColumn get timestamp => text()();
  // 'pending' | 'committed' | 'rejected'
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get commitId => integer().nullable().references(Commits, #id)();
}
