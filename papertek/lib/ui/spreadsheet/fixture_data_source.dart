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

class FixtureDataSource extends DataGridSource {
  FixtureDataSource({
    required this.onCellEditCommit,
    required this.onBooleanSet,
    required this.onNativeEditStart,
    required this.onNativeEditComplete,
  });

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
  List<DataGridRow> _rows = [];
  List<String> _visibleCols = List.of(kDefaultColumnOrder);

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

  void setTheme(ThemeData theme) => _theme = theme;

  Color get _textMain => _theme?.colorScheme.onSurface ?? Colors.white;
  Color get _textMuted => _theme?.colorScheme.onSurfaceVariant ?? Colors.grey;
  Color get _accent => _theme?.colorScheme.primary ?? Colors.amber;
  Color get _bgAlt =>
      (_theme?.colorScheme.surfaceContainer ?? const Color(0xFF1A1D23))
          .withValues(alpha: 0.4);
  Color get _bgSel =>
      _theme?.colorScheme.primaryContainer ?? const Color(0xFF2D2A1C);

  // Pending / conflict highlight sets — updated by the tab via Riverpod streams.
  Set<int> _pendingIds = {};
  Set<int> _conflictIds = {};

  static const _kPendingColor  = Color(0x1ADDAA00); // 10% opacity amber
  static const _kConflictColor = Color(0x1ACC3333); // 10% opacity red

  /// Called by the tab whenever the pending/conflict sets change.
  void updateRevisionState(Set<int> pending, Set<int> conflicts) {
    if (pending == _pendingIds && conflicts == _conflictIds) return;
    _pendingIds  = pending;
    _conflictIds = conflicts;
    notifyListeners();
  }

  String? get selectedColName => _selectedColName;
  FixtureRow? get selectedFixture => _selectedFixtureId == null
      ? null
      : _allFixtures.where((f) => f.id == _selectedFixtureId).firstOrNull;

  String? get selectedCellValue {
    final f = selectedFixture;
    final colId = _selectedColName;
    if (f == null || colId == null) return null;
    return kColumnById[colId]?.getValue(f);
  }

  void setSelectedCell(int? fixtureId, String? colName) {
    _selectedFixtureId = fixtureId;
    _selectedColName = colName;
  }

  void updateRows(List<FixtureRow> fixtures) {
    _allFixtures = fixtures;
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

  @override
  Future<void> handleSort() async {
    _rebuildFilteredRows();
    notifyListeners();
  }

  @override
  int compare(DataGridRow? a, DataGridRow? b, SortColumnDetails sortColumn) {
    final spec = kColumnById[sortColumn.name];
    if (spec == null) return 0;

    final va = a?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value;
    final vb = b?.getCells().firstWhere((c) => c.columnName == sortColumn.name).value;

    int cmp;
    if (spec.isNumeric) {
      final na = double.tryParse(va?.toString() ?? '') ?? 0.0;
      final nb = double.tryParse(vb?.toString() ?? '') ?? 0.0;
      cmp = na.compareTo(nb);
    } else {
      cmp = (va?.toString() ?? '').toLowerCase().compareTo((vb?.toString() ?? '').toLowerCase());
    }

    if (cmp != 0) {
      return sortColumn.sortDirection == DataGridSortDirection.ascending ? cmp : -cmp;
    }
    return 0;
  }

  void _rebuildFilteredRows() {
    Iterable<FixtureRow> list = _allFixtures;

    if (_filterCol != null && _filterValue != null && _filterValue!.isNotEmpty) {
      final exact = _filterValue!.toLowerCase();
      final spec = kColumnById[_filterCol!];
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
        return kColumns.any((spec) {
          final v = spec.getValue(f) ?? '';
          return v.toLowerCase().contains(q);
        });
      });
    }

    // ── Native Sorting Integration ───────────────────────────────────────────
    if (sortedColumns.isNotEmpty) {
      final sortedList = list.toList();
      sortedList.sort((a, b) {
        for (final sortCol in sortedColumns) {
          final spec = kColumnById[sortCol.name];
          if (spec == null) continue;
          final va = spec.getValue(a);
          final vb = spec.getValue(b);

          int cmp;
          if (spec.isNumeric) {
            final na = double.tryParse(va ?? '') ?? 0.0;
            final nb = double.tryParse(vb ?? '') ?? 0.0;
            cmp = na.compareTo(nb);
          } else {
            cmp = (va ?? '').toLowerCase().compareTo((vb ?? '').toLowerCase());
          }

          if (cmp != 0) {
            return sortCol.sortDirection == DataGridSortDirection.ascending ? cmp : -cmp;
          }
        }
        return a.id.compareTo(b.id);
      });
      list = sortedList;
    }

    _filteredFixtures = list.toList();
    _rowToFixture.clear();
    _rowToPartOrder.clear();
    _rowToIndex.clear();
    _rows = [];

    for (final f in _filteredFixtures) {
      // ── Parent / single row ──────────────────────────────────────────────
      final parentRow = DataGridRow(cells: [
        for (final spec in kColumns)
          DataGridCell(columnName: spec.id, value: spec.getValue(f) ?? ''),
      ]);
      _rowToFixture[parentRow] = f;
      _rowToPartOrder[parentRow] = null;
      _rowToIndex[parentRow] = _rows.length;
      _rows.add(parentRow);

      // ── Child rows: always shown for multi-part fixtures ─────────────────
      if (f.isMultiPart) {
        for (final part in f.parts) {
          final childRow = DataGridRow(cells: [
            for (final spec in kColumns)
              DataGridCell(
                columnName: spec.id,
                value: spec.getPartValue?.call(part) ?? '',
              ),
          ]);
          _rowToFixture[childRow] = f;
          _rowToPartOrder[childRow] = part.partOrder;
          _rowToIndex[childRow] = _rows.length;
          _rows.add(childRow);
        }
      }
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

    // ── Child row ────────────────────────────────────────────────────────────
    if (isChild) {
      final bgChild = (_theme?.colorScheme.surfaceContainerHighest ??
              const Color(0xFF2A2D34))
          .withValues(alpha: 0.35);
      final byName = {
        for (final cell in row.getCells()) cell.columnName: cell.value?.toString() ?? '',
      };
      return DataGridRowAdapter(
        color: bgChild,
        cells: _visibleCols.map((name) {
          String text;
          Color color;
          if (name == '#') {
            text = '  ·${partOrder + 1}';
            color = _textMuted;
          } else if (name == 'chan') {
            text = byName['chan'] ?? '';
            color = _accent;
          } else if (name == 'dimmer') {
            text = byName['dimmer'] ?? '';
            color = _textMuted;
          } else {
            text = byName[name] ?? '';
            color = _textMuted;
          }
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
    final isMulti = fixture.isMultiPart;
    final isPending  = _pendingIds.contains(fixture.id);
    final isConflict = _conflictIds.contains(fixture.id);
    Color bg;
    if (isConflict) {
      bg = _kConflictColor;
    } else if (isPending) {
      bg = _kPendingColor;
    } else {
      bg = index.isEven ? Colors.transparent : _bgAlt;
    }
    final byName = {
      for (final cell in row.getCells()) cell.columnName: cell.value?.toString() ?? '',
    };

    return DataGridRowAdapter(
      cells: _visibleCols.map((name) {
        final isSelectedCell = selected && name == _selectedColName;
        var color = _textMain;
        var bold = false;
        // Multi-part parent rows show fixture-level data only; part-level columns are blank.
        String text = (isMulti && const {'chan', 'dimmer', 'circuit', 'ip', 'subnet', 'mac', 'ipv6'}.contains(name))
            ? ''
            : (byName[name] ?? '');

        switch (name) {
          case '#':
            color = selected ? _textMain : _textMuted;
            bold = selected;
            break;
          case 'chan':
            if (!isMulti) {
              color = _accent;
              bold = true;
            } else {
              color = _textMuted;
            }
            break;
          case 'dimmer':
          case 'circuit':
            color = _textMuted;
            break;
          case 'hung':
          case 'patch':
          case 'focused':
            color = byName[name] == '✓' ? Colors.green : _textMuted;
            break;
          default:
            color = _textMain;
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

    onNativeEditStart(fixture, col);

    String initial;
    if (partOrder != null) {
      final part = fixture.parts.where((p) => p.partOrder == partOrder).firstOrNull;
      if (col == 'chan') {
        initial = part?.channel ?? '';
      } else if (col == 'dimmer') {
        initial = part?.address ?? '';
      } else {
        return null;
      }
    } else {
      if (kColumnById[col]?.isReadOnly ?? false) return null;
      initial = kColumnById[col]?.getValue(fixture) ?? '';
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

    final nextText = (_newCellValue ?? _editingController?.text ?? '').trim();
    _editingController?.dispose();
    _editingController = null;
    _newCellValue = null;

    final val = nextText.isEmpty ? null : nextText;

    try {
      if (partOrder != null) {
        if (col == 'chan')   await onCellEditCommit(fixture, 'chan',   val, partOrder);
        if (col == 'dimmer') await onCellEditCommit(fixture, 'dimmer', val, partOrder);
        return;
      }

      if (!(kColumnById[col]?.isReadOnly ?? false)) {
        await onCellEditCommit(fixture, col, val, null);
      }
    } finally {
      onNativeEditComplete();
    }
  }
}
