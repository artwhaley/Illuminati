/// Identifier checks for dynamic SQL that interpolates table/column names.
/// Values stay parameterized; only identifiers are allowlisted + pattern-checked
/// so a tampered .papertek file cannot turn a rollback into arbitrary SQL.
///
/// **Schema work:** When you add a table (or new `updateField` path) that can
/// appear in `revisions`, add the table name to [kRevisionTrackedTables] and
/// ensure [TrackedWriteRepository._getUpdateSet] includes the same table.
/// Field names must be `snake_case` (the [RegExp] below). If reject/undo
/// throws `StateError` mentioning "invalid table or field", update this file
/// first—do not disable these checks.

/// Tables the app may record in `revisions.target_table` for tracked updates.
/// Keep in sync with [TrackedWriteRepository] call sites.
const Set<String> kRevisionTrackedTables = {
  'fixtures',
  'fixture_parts',
  'lighting_positions',
  'position_groups',
  'fixture_types',
  'channels',
  'addresses',
  'dimmers',
  'circuits',
  'role_contacts',
  'show_meta',
};

final RegExp _sqlIdentifier = RegExp(r'^[a-z][a-z0-9_]*$');

bool _isSafeIdentifier(String s) => _sqlIdentifier.hasMatch(s);

/// Safe for `UPDATE t SET col = ? WHERE id = ?`.
bool revisionUpdateTargetIsSafe(String table, String? fieldName) {
  if (fieldName == null || !_isSafeIdentifier(fieldName)) return false;
  if (!_isSafeIdentifier(table)) return false;
  return kRevisionTrackedTables.contains(table);
}

/// Safe for `DELETE FROM t WHERE id = ?`.
bool revisionTableNameIsSafe(String table) {
  if (!_isSafeIdentifier(table)) return false;
  return kRevisionTrackedTables.contains(table);
}
