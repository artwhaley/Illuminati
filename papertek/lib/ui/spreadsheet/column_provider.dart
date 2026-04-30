import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'column_spec.dart';
import '../../providers/show_provider.dart';

/// Provides the unified list of all columns (System + Custom).
final allColumnsProvider = Provider.autoDispose<List<ColumnSpec>>((ref) {
  final customFields = ref.watch(customFieldsProvider).value ?? [];
  
  final customSpecs = customFields.map((f) => ColumnSpec.custom(f.id, f.name)).toList();
  
  return [...kColumns, ...customSpecs];
});

/// Fast lookup by ID across all columns.
final columnByIdProvider = Provider.autoDispose<Map<String, ColumnSpec>>((ref) {
  final cols = ref.watch(allColumnsProvider);
  return {for (final c in cols) c.id: c};
});

/// Provides the default column order, including any newly added custom fields at the end.
final defaultColumnOrderProvider = Provider.autoDispose<List<String>>((ref) {
  final cols = ref.watch(allColumnsProvider);
  return cols.map((c) => c.id).toList();
});
