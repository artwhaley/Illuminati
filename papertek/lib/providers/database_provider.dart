import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';

// Holds the currently open database. Null until a show is opened/created.
final databaseProvider = StateProvider<AppDatabase?>((ref) => null);

// Convenience accessor — throws if no show is open.
extension DatabaseRef on WidgetRef {
  AppDatabase get db {
    final db = read(databaseProvider);
    if (db == null) throw StateError('No show is open');
    return db;
  }
}
