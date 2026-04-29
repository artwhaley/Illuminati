# REPORT-004: Template State Management (Riverpod)

## Summary
Create the `ReportTemplateNotifier` (a Riverpod `StateNotifier`) that manages the currently-edited report template. This is the shared state between the editor UI and the PDF preview.

## Depends On
- REPORT-001 (data models)
- REPORT-003 (persistence — for loading/saving)

## Files to Create
1. `lib/ui/reports/report_template_notifier.dart`

## Files to Modify
1. `lib/providers/show_provider.dart` — add the `activeReportTemplateProvider`

## Detailed Instructions

### 1. `report_template_notifier.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/reports/report_template.dart';
import '../../features/reports/report_field_registry.dart';

class ReportTemplateNotifier extends StateNotifier<ReportTemplate> {
  ReportTemplateNotifier() : super(const ReportTemplate(
    name: 'Untitled Report',
    columns: [],
  ));

  /// Loads a full template (e.g., from the database).
  void loadTemplate(ReportTemplate template) {
    state = template;
  }

  /// Sets the template name.
  void setName(String name) {
    state = state.copyWith(name: name);
  }

  /// Adds a column by field key or stack ID.
  /// If the key is a stacked column ID, uses the pre-built definition.
  /// If it's a simple field key, creates a new ReportColumn from kReportFields.
  void addColumn(String keyOrStackId) {
    // Don't add duplicates
    if (state.columns.any((c) => c.id == keyOrStackId)) return;

    ReportColumn? newCol;

    // Check stacked columns first
    if (kStackedColumns.containsKey(keyOrStackId)) {
      newCol = kStackedColumns[keyOrStackId]!;
    } else if (kReportFields.containsKey(keyOrStackId)) {
      final field = kReportFields[keyOrStackId]!;
      newCol = ReportColumn(
        id: field.key,
        label: field.label.toUpperCase(),
        fieldKeys: [field.key],
        fixedWidth: field.defaultWidth,
      );
    }

    if (newCol == null) return;

    state = state.copyWith(columns: [...state.columns, newCol]);
  }

  /// Removes a column by its ID.
  void removeColumn(String columnId) {
    state = state.copyWith(
      columns: state.columns.where((c) => c.id != columnId).toList(),
    );
  }

  /// Reorders columns (from ReorderableListView callback).
  void reorderColumns(int oldIndex, int newIndex) {
    final cols = List<ReportColumn>.from(state.columns);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = cols.removeAt(oldIndex);
    cols.insert(newIndex, item);
    state = state.copyWith(columns: cols);
  }

  /// Sets a column to fixed width mode.
  void setColumnFixedWidth(String columnId, double width) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(fixedWidth: () => width);
      }).toList(),
    );
  }

  /// Sets a column to flex mode with given flex weight.
  void setColumnFlex(String columnId, int flex) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(fixedWidth: () => null, flex: flex);
      }).toList(),
    );
  }

  /// Updates a column's label.
  void setColumnLabel(String columnId, String label) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(label: label);
      }).toList(),
    );
  }

  /// Toggles bold on a column.
  void toggleColumnBold(String columnId) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(isBold: !c.isBold);
      }).toList(),
    );
  }

  /// Sets the group-by field. Pass null to disable grouping.
  void setGroupBy(String? fieldKey) {
    state = state.copyWith(groupByFieldKey: () => fieldKey);
  }

  /// Sets the sort-by field and direction.
  void setSortBy(String? fieldKey, {bool ascending = true}) {
    state = state.copyWith(
      sortByFieldKey: () => fieldKey,
      sortAscending: ascending,
    );
  }

  /// Sets orientation ('portrait' or 'landscape').
  void setOrientation(String orientation) {
    state = state.copyWith(orientation: orientation);
  }

  /// Sets the data font size.
  void setDataFontSize(double size) {
    state = state.copyWith(dataFontSize: size);
  }
}
```

### 2. Modify `show_provider.dart`

Add this provider (it does NOT depend on the database — it's pure UI state):

```dart
import '../ui/reports/report_template_notifier.dart';
import '../features/reports/report_template.dart';

/// The currently-edited report template. Shared between the editor panel and PDF preview.
final activeReportTemplateProvider =
    StateNotifierProvider<ReportTemplateNotifier, ReportTemplate>((ref) {
  return ReportTemplateNotifier();
});
```

## Testing
- Verify the notifier compiles
- Verify `addColumn('chan')` adds a column, calling it again does NOT add a duplicate
- Verify `addColumn('stack_instrument')` adds the stacked column with `fieldKeys: ['type', 'wattage']`
- Verify `reorderColumns(0, 2)` moves the first column to position 2
- Verify `setColumnFlex('chan', 2)` sets the column to flex mode and clears fixedWidth
- Verify `setColumnFixedWidth('chan', 50)` sets fixedWidth and the column renders with a SizedBox
