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

  /// Normalizes column widths so they always sum to exactly 100%.
  void _normalizeWidths(List<ReportColumn> cols) {
    if (cols.isEmpty) return;
    final currentTotal = cols.fold(0.0, (sum, c) => sum + c.widthPercent);
    if (currentTotal == 0) {
      // Fallback: equal distribution if everything is 0
      final equal = 100.0 / cols.length;
      for (int i = 0; i < cols.length; i++) {
        cols[i] = cols[i].copyWith(widthPercent: equal);
      }
      return;
    }

    final ratio = 100.0 / currentTotal;
    for (int i = 0; i < cols.length; i++) {
      cols[i] = cols[i].copyWith(widthPercent: cols[i].widthPercent * ratio);
    }
  }

  /// Manually trigger normalization to 100%.
  void normalizeWidths() {
    final cols = List<ReportColumn>.from(state.columns);
    _normalizeWidths(cols);
    state = state.copyWith(columns: cols);
  }

  /// Adds a column by field key or stack ID.
  void addColumn(String keyOrStackId) {
    if (state.columns.any((c) => c.id == keyOrStackId)) return;

    ReportColumn? newCol;
    if (kStackedColumns.containsKey(keyOrStackId)) {
      final base = kStackedColumns[keyOrStackId]!;
      newCol = base.copyWith(fontSize: state.dataFontSize, widthPercent: 10.0);
    } else if (kReportFields.containsKey(keyOrStackId)) {
      final field = kReportFields[keyOrStackId]!;
      newCol = ReportColumn(
        id: field.key,
        label: field.label.toUpperCase(),
        fieldKeys: [field.key],
        widthPercent: 10.0,
        fontSize: state.dataFontSize,
      );
    }

    if (newCol == null) return;

    final updatedCols = [...state.columns, newCol];
    _normalizeWidths(updatedCols);
    state = state.copyWith(columns: updatedCols);
  }

  /// Removes a column by its ID.
  void removeColumn(String columnId) {
    final updatedCols = state.columns.where((c) => c.id != columnId).toList();
    _normalizeWidths(updatedCols);
    state = state.copyWith(columns: updatedCols);
  }

  /// Reorders columns (from ReorderableListView callback).
  void reorderColumns(int oldIndex, int newIndex) {
    final cols = List<ReportColumn>.from(state.columns);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = cols.removeAt(oldIndex);
    cols.insert(newIndex, item);
    state = state.copyWith(columns: cols);
  }

  /// Sets a column's width as a percentage of usable page width (0–100).
  void setColumnWidthPercent(String columnId, double percent) {
    final clamped = percent.clamp(1.0, 100.0);
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(widthPercent: clamped);
      }).toList(),
    );
  }

  /// Resizes two adjacent columns. [handleIndex] is the divider index (0-based).
  /// The column at [handleIndex] gets [leftPercent], and the column at
  /// [handleIndex + 1] gets [rightPercent].
  void resizeColumns(int handleIndex, double leftPercent, double rightPercent) {
    final cols = List<ReportColumn>.from(state.columns);
    cols[handleIndex] = cols[handleIndex].copyWith(widthPercent: leftPercent);
    cols[handleIndex + 1] = cols[handleIndex + 1].copyWith(widthPercent: rightPercent);
    state = state.copyWith(columns: cols);
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

  /// Toggles italic on a column.
  void toggleColumnItalic(String columnId) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(isItalic: !c.isItalic);
      }).toList(),
    );
  }

  /// Sets a column's font size.
  void setColumnFontSize(String columnId, double fontSize) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(fontSize: fontSize);
      }).toList(),
    );
  }

  /// Sets a column's text alignment ('left', 'center', or 'right').
  void setColumnTextAlign(String columnId, String align) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(textAlign: align);
      }).toList(),
    );
  }

  /// Toggles the cell border box on a column.
  void toggleColumnBoxed(String columnId) {
    state = state.copyWith(
      columns: state.columns.map((c) {
        if (c.id != columnId) return c;
        return c.copyWith(isBoxed: !c.isBoxed);
      }).toList(),
    );
  }

  /// Sets the group-by field. Pass null to disable grouping.
  void setGroupBy(String? fieldKey) {
    state = state.copyWith(groupByFieldKey: () => fieldKey);
  }

  /// Sets a specific sort level.
  void setSortLevel(int index, String? fieldKey, {bool ascending = true}) {
    final levels = List<SortLevel>.from(state.sortLevels);
    if (fieldKey == null) {
      if (index < levels.length) {
        levels.removeAt(index);
      }
    } else {
      final newLevel = SortLevel(fieldKey: fieldKey, ascending: ascending);
      if (index < levels.length) {
        levels[index] = newLevel;
      } else {
        levels.add(newLevel);
      }
    }
    state = state.copyWith(sortLevels: levels);
  }

  /// Adds a new blank sort level if under max (3).
  void addSortLevel() {
    if (state.sortLevels.length >= 3) return;
    state = state.copyWith(
      sortLevels: [...state.sortLevels, const SortLevel(fieldKey: '')],
    );
  }

  /// Removes a sort level at index.
  void removeSortLevel(int index) {
    final levels = List<SortLevel>.from(state.sortLevels);
    if (index < levels.length) {
      levels.removeAt(index);
      state = state.copyWith(sortLevels: levels);
    }
  }

  /// Sets orientation ('portrait' or 'landscape').
  void setOrientation(String orientation) {
    state = state.copyWith(orientation: orientation);
  }

  /// Sets the font family for the entire report.
  void setFontFamily(String family) {
    state = state.copyWith(fontFamily: family);
  }

  /// Sets the default data font size.
  void setDataFontSize(double size) {
    state = state.copyWith(dataFontSize: size);
  }

  /// Sets whether to use header-mode multipart sorting.
  void setMultipartHeader(bool value) {
    state = state.copyWith(multipartHeader: value);
  }
}
