import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'column_spec.dart';
import '../../providers/show_provider.dart';

/// Holds current display-name overrides and applies them to kColumns.
/// Widgets that render column headers should watch this provider so they
/// rebuild when a user renames a field.
///
/// State is a `Map<fieldId, currentLabel>`.
class FieldNameNotifier extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    final repo = ref.watch(fieldNameRepositoryProvider);
    if (repo == null) return {};
    final names = await repo.getAllDisplayNames();
    _applyToColumns(names);
    return names;
  }

  void _applyToColumns(Map<String, String> names) {
    for (final entry in names.entries) {
      final col = kColumnById[entry.key];
      if (col != null) col.label = entry.value;
    }
  }

  Future<void> setLabel(String fieldId, String displayName) async {
    final repo = ref.read(fieldNameRepositoryProvider);
    if (repo == null) return;
    await repo.setDisplayName(fieldId, displayName);
    final col = kColumnById[fieldId];
    if (col != null) col.label = displayName;
    state = AsyncData({...state.valueOrNull ?? {}, fieldId: displayName});
  }

  Future<void> resetToDefault(String fieldId) async {
    final col = kColumnById[fieldId];
    if (col == null) return;
    await setLabel(fieldId, col.defaultLabel);
  }
}

final fieldNameNotifierProvider =
    AsyncNotifierProvider<FieldNameNotifier, Map<String, String>>(
  FieldNameNotifier.new,
);
