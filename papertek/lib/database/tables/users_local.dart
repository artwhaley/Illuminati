import 'package:drift/drift.dart';

class UsersLocal extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get lastSeen => text().nullable()();

  @override
  Set<Column> get primaryKey => {userId};
}
