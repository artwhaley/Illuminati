import 'package:drift/drift.dart';
import 'fixtures.dart';

class CustomFields extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // 'text' | 'number' | 'boolean' | 'date'
  TextColumn get dataType => text()();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
}

class CustomFieldValues extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get fixtureId => integer().references(Fixtures, #id, onDelete: KeyAction.cascade)();
  IntColumn get customFieldId => integer().references(CustomFields, #id, onDelete: KeyAction.cascade)();
  TextColumn get value => text().nullable()();
}

class Reports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // JSON: columns, sort, filter, grouping, PDF layout settings
  TextColumn get templateJson => text()();
  IntColumn get isSystem => integer().withDefault(const Constant(0))();
}
