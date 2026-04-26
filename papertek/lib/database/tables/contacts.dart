import 'package:drift/drift.dart';

/// Stores contact details for each named role in a show.
/// One row per role key; upserted in place when the user edits contact info.
/// Role keys: 'designer', 'asst_designer', 'master_electrician',
///            'producer', 'asst_master_electrician', 'stage_manager'
class RoleContacts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get roleKey => text().unique()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get mailingAddress => text().nullable()();
  // Reserved for future cloud account linking.
  TextColumn get paperTekUserId => text().nullable()();
}
