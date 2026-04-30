/// ── FIXTURE DATA SOURCE (DATA ADAPTER) ────────────────────────────────────
///
/// This class is the "Translator" between our domain models ([FixtureRow]) 
/// and the Syncfusion DataGrid's internal row format ([DataGridRow]).
///
/// KEY FEATURES:
/// parent-child flattening: It handles multi-part fixtures by "flattening" 
/// them into a list of rows where parts appear immediately below their 
/// parent fixture, but only if they contain unique data (like specific channels).
///
/// reactive sorting & filtering: It performs efficient local filtering and 
/// multi-column sorting without re-querying the database, ensuring that 
/// typing in the search bar feels instantaneous even with thousands of rows.
///
/// deferred updates: If the user is currently editing a cell, incoming 
/// database updates are queued until the edit is finished, preventing 
/// focus loss or "ghosting" while typing.
/// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../repositories/fixture_repository.dart';
import 'column_spec.dart';
import 'spreadsheet_view_controller.dart';

class FixtureDataSource extends DataGridSource {
  FixtureDataSource({
    required List<ColumnSpec> columns,
    required this.onCellEditCommit,
    required this.onBooleanSet,
    required this.onNativeEditStart,
    required this.onNativeEditComplete,
  }) : _columns = columns,
       _colById = {for (final c in columns) c.id: c},
       _multipartMode = MultipartDisplayMode.header;

  List<ColumnSpec> _columns;
  Map<String, ColumnSpec> _colById;
  MultipartDisplayMode _multipartMode;

  void setMultipartMode(MultipartDisplayMode mode) {
    if (_multipartMode == mode) return;
    _multipartMode = mode;
    _rebuildFilteredRows();
    notifyListeners();
  }

  void setColumns(List<ColumnSpec> columns) {
    _columns = columns;
    _colById = {for (final c in columns) c.id: c};
    _rowCache.clear();
    _rebuildFilteredRows();
  }

  VoidCallback? onSortChanged;
  final void Function(FixtureRow fixture, String col) onNativeEditStart;
  final VoidCallback onNativeEditComplete;

  void setVisibleCols(List<String> cols) {
    _visibleCols = cols;
    notifyListeners();
  }

  final Future<void> Function(FixtureRow fixture, String col, String? value, int? partOrder)
      onCellEditCommit;
  /// Called when a checkbox cell changes. [col] is 'patch', 'hung', or 'focused'.
  final Future<void> Function(FixtureRow fixture, String col, bool value)
      onBooleanSet;

  List<FixtureRow> _allFixtures = [];
  List<FixtureRow> _filteredFixtures = [];

  final Map<DataGridRow, FixtureRow> _rowToFixture = {};
  // null = parent/single row; non-null = child row for that part order
  final Map<DataGridRow, int?> _rowToPartOrder = {};
  final Map<DataGridRow, int> _rowToIndex = {};
  final Map<String, DataGridRow> _rowCache = {}; // Cache key: fixtureId:partOrder
  List<DataGridRow> _rows = [];
  List<String> _visibleCols = [];

  bool isChildRow(DataGridRow row) => _rowToPartOrder[row] != null;
  int? partOrderForRow(DataGridRow row) => _rowToPartOrder[row];

  TextEditingController? _editingController;
  String? _newCellValue;
  String _searchQuery = '';
  String? _filterCol;
  String? _filterValue;
  int? _selectedFixtureId;
  String? _selectedColName;
  ThemeData? _theme;

  void setTheme(ThemeData theme) {
    if (_theme == theme) return;
    _theme = theme;
    notifyListeners();
  }

  Color get _textMain => _theme?.colorScheme.onSurface ?? Colors.white;
  Color get _textMuted => _theme?.colorScheme.onSurfaceVariant ?? Colors.grey;
  Color get _accent => _theme?.colorScheme.primary ?? Colors.amber;
  Color get _bgAlt =>
      (_theme?.colorScheme.surfaceContainer ?? const Color(0xFF1A1D23))
          .withValues(alpha: 0.4);
  Color get _bgSel =>
      _theme?.colorScheme.primaryContainer ?? const Color(0xFF2D2A1C);

  Set<int> _pendingIds = {};
  Set<int> _conflictIds = {};

  /// Called by the tab whenever the pending/conflict sets change.
  void updateRevisionState(Set<int> pending, Set<int> conflicts) {
    if (pending == _pendingIds && conflicts == _conflictIds) return;
    _pendingIds  = pending;
    _conflictIds = conflicts;
    notifyListeners();
  }

  Color get _pendingColor => _theme?.brightness == Brightness.dark
      ? const Color(0x87141111) // Even darker and more desaturated reddish amber
      : (_theme?.colorScheme.primary ?? Colors.amber).withValues(alpha: 0.1);
  Color get _conflictColor => (_theme?.colorScheme.error ?? Colors.red).withValues(alpha: 0.1);

  String? get selectedColName => _selectedColName;
  FixtureRow? get selectedFixture => _selectedFixtureId == null
      ? null
      : _allFixtures.where((f) => f.id == _selectedFixtureId).firstOrNull;

  String? get selectedCellValue {
    final f = selectedFixture;
    final colId = _selectedColName;
    if (f == null || colId == null) return null;
    return _colById[colId]?.getValue(f);
  }

  void setSelectedCell(int? fixtureId, String? colName) {
    _selectedFixtureId = fixtureId;
    _selectedColName = colName;
  }

  void updateData(List<FixtureRow> fixtures) {
    _allFixtures = fixtures;
    _rowCache.clear();
    if (_visibleCols.isEmpty) {
       _visibleCols = _columns.map((c) => c.id).toList();
    }
    _rebuildFilteredRows();
    notifyListeners();
  }

  void applyFilters({required String search, String? filterCol, String? filterValue}) {
    _searchQuery = search;
    _filterCol = filterCol;
    _filterValue = filterValue;
    _rebuildFilteredRows();
    notifyListeners();
  }

  FixtureRow? fixtureForRow(DataGridRow row) => _rowToFixture[row];
  int? partOrderByRow(DataGridRow row) => _rowToPartOrder[row];

  @override
  Future<void> handleSort() async {
    _rebuildFilteredRows();
    notifyListeners();
  }

  static final _naturalRegExp = RegExp(r'(\d+|\D+)');

  int _naturalCompare(String a, String b) {
    final matchesA = _naturalRegExp.allMatches(a.toLowerCase()).toList();
    final matchesB = _naturalRegExp.allMatches(b.toLowerCase()).toList();

    for (var i = 0; i < matchesA.length && i < matchesB.length; i++) {
      final partA = matchesA[i].group(0)!;
      final partB = matchesB[i].group(0)!;

      final numA = int.tryParse(partA);
      final numB = int.tryParse(partB);

      if (numA != null && numB != null) {
        final cmp = numA.compareTo(numB);
        if (cmp != 0) return cmp;
      } else {
        final cmp = partA.compareTo(partB);
        if (cmp != 0) return cmp;
      }
    }
    return matchesA.length.compareTo(matchesB.length);
  }

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    final spec = _colById[sortColumn.name];
    if (spec == null) return 0;

    final va = a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value?.toString() ?? '';
    final vb = b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value?.toString() ?? '';

    int cmp;
    if (spec.isNumeric) {
      final na = double.tryParse(va);
      final nb = double.tryParse(vb);
      if (na != null && nb != null) {
        cmp = na.compareTo(nb);
      } else {
        cmp = _naturalCompare(va, vb);
      }
    } else {
      cmp = _naturalCompare(va, vb);
    }

    if (cmp != 0) {
      return sortColumn.sortDirection == DataGridSortDirection.ascending ? cmp : -cmp;
    }
    return 0;
  }

  String _getValueForSort(FixtureRow f, int? partOrder, ColumnSpec spec) {
    if (partOrder != null && spec.isPartLevel) {
      final part = f.parts.where((p) => p.partOrder == partOrder).firstOrNull;
      if (part != null) return spec.getPartValue?.call(f, part) ?? '';
    }
    return spec.getValue(f) ?? '';
  }

  String _getHeaderModeSortValue(FixtureRow fixture, ColumnSpec spec) {
    final firstPart = fixture.parts.firstOrNull;
    if (firstPart != null) {
      final partValue = spec.getPartValue?.call(fixture, firstPart);
      if (partValue != null && partValue.isNotEmpty) return partValue;
    }
    return spec.getValue(fixture) ?? '';
  }

  void _rebuildFilteredRows() {
    Iterable<FixtureRow> list = _allFixtures;

    if (_filterCol != null && _filterValue != null && _filterValue!.isNotEmpty) {
      final exact = _filterValue!.toLowerCase();
      final spec = _colById[_filterCol!];
      if (spec != null) {
        list = list.where((f) {
          final v = spec.getValue(f) ?? '';
          return v.toLowerCase() == exact;
        });
      }
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((f) {
        return _columns.any((spec) {
          final v = spec.getValue(f) ?? '';
          return v.toLowerCase().contains(q);
        });
      });
    }

    _rowToFixture.clear();
    _rowToPartOrder.clear();
    _rowToIndex.clear();
    _rows = [];

    // ── Flattening ──────────────────────────────────────────────────────────
    final List<({FixtureRow f, int? partOrder})> descriptors = [];

    for (final f in list) {
      if (_multipartMode == MultipartDisplayMode.header) {
        // Parent always exists in header mode
        descriptors.add((f: f, partOrder: null));
        if (f.isMultiPart) {
          for (final part in f.parts) {
            descriptors.add((f: f, partOrder: part.partOrder));
          }
        }
      } else {
        // Headerless mode: only parent for single-part, only parts for multi-part
        if (!f.isMultiPart) {
          descriptors.add((f: f, partOrder: null));
        } else {
          for (final part in f.parts) {
            descriptors.add((f: f, partOrder: part.partOrder));
          }
        }
      }
    }

    // ── Mode-Aware Sorting ───────────────────────────────────────────────────
    if (sortedColumns.isNotEmpty) {
      descriptors.sort((a, b) {
        for (final sortCol in sortedColumns) {
          final spec = _colById[sortCol.name];
          if (spec == null) continue;

          final va = _multipartMode == MultipartDisplayMode.header 
              ? _getHeaderModeSortValue(a.f, spec)
              : _getValueForSort(a.f, a.partOrder, spec);
              
          final vb = _multipartMode == MultipartDisplayMode.header 
              ? _getHeaderModeSortValue(b.f, spec)
              : _getValueForSort(b.f, b.partOrder, spec);

          int cmp;
          if (spec.isNumeric) {
            final na = double.tryParse(va ?? '');
            final nb = double.tryParse(vb ?? '');
            if (na != null && nb != null) {
              cmp = na.compareTo(nb);
            } else {
              cmp = _naturalCompare(va ?? '', vb ?? '');
            }
          } else {
            cmp = _naturalCompare(va ?? '', vb ?? '');
          }

          if (cmp != 0) {
            return sortCol.sortDirection == DataGridSortDirection.ascending ? cmp : -cmp;
          }
        }
        
        // Tie-breaker: fixture ID, then part order
        final fCmp = a.f.id.compareTo(b.f.id);
        if (fCmp != 0) return fCmp;
        return (a.partOrder ?? -1).compareTo(b.partOrder ?? -1);
      });
    }

    // ── Materialization ──────────────────────────────────────────────────────
    for (final desc in descriptors) {
      final f = desc.f;
      final partOrder = desc.partOrder;
      final cacheKey = partOrder == null ? '${f.id}' : '${f.id}:$partOrder';
      
      // Try to reuse the row object if possible to maintain SfDataGrid stability
      DataGridRow row;
      if (_rowCache.containsKey(cacheKey)) {
        row = _rowCache[cacheKey]!;
      } else {
        if (partOrder == null) {
          row = DataGridRow(cells: [
            for (final spec in _columns)
              DataGridCell(columnName: spec.id, value: spec.getValue(f) ?? ''),
          ]);
        } else {
          final part = f.parts.firstWhere((p) => p.partOrder == partOrder);
          row = DataGridRow(cells: [
            for (final spec in _columns)
              DataGridCell(columnName: spec.id, value: spec.getPartValue?.call(f, part) ?? ''),
          ]);
        }
        _rowCache[cacheKey] = row;
      }
      
      _rowToFixture[row] = f;
      _rowToPartOrder[row] = partOrder;
      _rowToIndex[row] = _rows.length;
      _rows.add(row);
    }
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final fixture = _rowToFixture[row];
    if (fixture == null) return DataGridRowAdapter(color: Colors.transparent, cells: []);
    final index = _rowToIndex[row] ?? 0;
    final partOrder = _rowToPartOrder[row];
    final isChild = partOrder != null;
    final selected = fixture.id == _selectedFixtureId;

    final visibleEntries = _visibleCols.asMap().entries.toList();

    // ── Child row ────────────────────────────────────────────────────────────
    if (isChild) {
      const parentFallbackCols = {'position', 'type', 'function', 'focus', 'unit'};
      final bgChild = (_theme?.colorScheme.surfaceContainerHighest ??
              _theme?.colorScheme.surface ?? 
              Colors.transparent)
          .withValues(alpha: 0.35);
      final byName = {
        for (final cell in row.getCells()) cell.columnName: cell.value?.toString() ?? '',
      };
      return DataGridRowAdapter(
        color: bgChild,
        cells: visibleEntries.map((entry) {
          final idx = entry.key;
          final name = entry.value;
          final isFirst = idx == 0;

          var text = byName[name] ?? '';
          if (text.isEmpty && parentFallbackCols.contains(name)) {
            text = _colById[name]?.getValue(fixture) ?? '';
          }
          final color = isFirst ? _accent : _textMuted; // Keep child rows slightly muted generally
          
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.jetBrainsMono(fontSize: 13, color: color),
            ),
          );
        }).toList(),
      );
    }

    // ── Parent / single row ──────────────────────────────────────────────────
    final isPending  = _pendingIds.contains(fixture.id);
    final isConflict = _conflictIds.contains(fixture.id);
    Color bg;
    if (isConflict) {
      bg = _conflictColor;
    } else if (isPending) {
      bg = _pendingColor;
    } else {
      bg = index.isEven ? Colors.transparent : _bgAlt;
    }
    final byName = {
      for (final cell in row.getCells()) cell.columnName: cell.value?.toString() ?? '',
    };

    return DataGridRowAdapter(
      cells: visibleEntries.map((entry) {
        final idx = entry.key;
        final name = entry.value;
        final isFirst = idx == 0;
        final isSelectedCell = selected && name == _selectedColName;
        
        var color = isFirst ? _accent : _textMain;
        var bold = isFirst || (selected && !isFirst); // Bold first col OR selected row items
        
        String text = (fixture.isMultiPart && const {'chan', 'dimmer', 'circuit', 'ip', 'subnet', 'mac', 'ipv6', 'color', 'gobo', 'accessories'}.contains(name))
            ? ''
            : (byName[name] ?? '');

        // Override status column colors
        if (const {'hung', 'patch', 'focused'}.contains(name)) {
          if (byName[name] == '✓') {
            color = Colors.green;
          }
        }

        if (isSelectedCell) {
          color = Colors.orange;
          bold = true;
        }

        return Container(
          color: bg,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget? buildGroupCaptionCellWidget(
    RowColumnIndex rowColumnIndex,
    String summaryValue,
  ) {
    final theme = _theme;
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        summaryValue,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: theme?.colorScheme.onSurfaceVariant ?? Colors.white70,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  @override
  Widget? buildEditWidget(
    DataGridRow row,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final fixture = _rowToFixture[row];
    if (fixture == null) return null;
    final col = column.columnName;
    final partOrder = _rowToPartOrder[row];
    final spec = _colById[col];
    if (spec == null || spec.isReadOnly || spec.isCollection) return null;

    onNativeEditStart(fixture, col);

    String initial;
    if (partOrder != null) {
      final part = fixture.parts.where((p) => p.partOrder == partOrder).firstOrNull;
      if (spec.isPartLevel) {
        initial = part == null ? '' : (spec.getPartValue?.call(fixture, part) ?? '');
      } else {
        initial = spec.getValue(fixture) ?? '';
      }
    } else {
      initial = spec.getValue(fixture) ?? '';
    }

    _editingController?.dispose();
    _editingController = TextEditingController(text: initial);
    _newCellValue = null;

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _editingController,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onChanged: (v) => _newCellValue = v,
        onSubmitted: (_) => submitCell(),
      ),
    );
  }

  @override
  Future<void> onCellSubmit(
    DataGridRow dataGridRow,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
  ) async {
    final fixture = _rowToFixture[dataGridRow];
    if (fixture == null) return;
    final col = column.columnName;
    final partOrder = _rowToPartOrder[dataGridRow];
    final spec = _colById[col];
    if (spec == null || spec.isReadOnly || spec.isCollection) return;

    final nextText = (_newCellValue ?? _editingController?.text ?? '').trim();
    _editingController?.dispose();
    _editingController = null;
    _newCellValue = null;

    final val = nextText.isEmpty ? null : nextText;

    try {
      await onCellEditCommit(
        fixture,
        col,
        val,
        partOrder != null && spec.isPartLevel ? partOrder : null,
      );
    } finally {
      onNativeEditComplete();
    }
  }
}
