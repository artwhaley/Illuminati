import 'package:drift/drift.dart';

class FieldNames extends Table {
  TextColumn get fieldId => text()();
  TextColumn get displayName => text()();

  @override
  Set<Column> get primaryKey => {fieldId};
}
