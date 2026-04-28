import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../providers/show_provider.dart';
import '../../repositories/fixture_repository.dart';
import '../../database/database.dart';
import '../../repositories/spreadsheet_view_preset_repository.dart';


// ── Column metadata ───────────────────────────────────────────────────────────

const _kColOrder = [
  '#', 'chan', 'dimmer', 'position', 'unit', 'type',
  'function', 'focus', 'accessories', 'ip', 'subnet', 'mac', 'ipv6',
  'hung', 'patch', 'focused', 'circuit', 'notes',
];

const _kColLabels = {
  '#': '#',
  'chan':        'CHAN',
  'dimmer':      'ADDRESS',
  'position':    'POSITION',
  'unit':        'U#',
  'type':        'FIXTURE TYPE',
  'function':    'PURPOSE',
  'focus':       'FOCUS AREA',
  'accessories': 'ACCESSORIES',
  'ip':          'IP ADDRESS',
  'subnet':      'SUBNET',
  'mac':         'MAC ADDRESS',
  'ipv6':        'IPV6',
  'hung':        'HUNG',
  'patch':       'PATCHED',
  'focused':     'FOCUSED',
  'circuit':     'CIRCUIT',
  'notes':       'NOTES',
};

const _kDefaultWidths = {
  '#':           40.0,
  'chan':         60.0,
  'dimmer':       80.0,
  'position':    140.0,
  'unit':         50.0,
  'type':        160.0,
  'function':    120.0,
  'focus':       120.0,
  'accessories': 120.0,
  'ip':          120.0,
  'subnet':      110.0,
  'mac':         130.0,
  'ipv6':        150.0,
  'hung':         55.0,
  'patch':        60.0,
  'focused':      65.0,
  'circuit':      80.0,
  'notes':       120.0,
};

// Boolean columns use checkboxes in the grid — allowEditing stays false so
// double-tap doesn't open a text field.  Interaction is handled in buildRow.
const _kReadOnlyCols  = {'#', 'patch', 'hung', 'focused'};
const _kBooleanCols   = {'patch', 'hung', 'focused'};
const _kNumericCols  = {'#', 'chan', 'unit'};
const _kAlwaysVisible = {'#'};

const _kPrefsWidthKey = 'papertek.colWidths.v1';
const _kMinimalSpreadsheetMode = true;

class SortSpec {
  final String column;
  final bool ascending;
  SortSpec({required this.column, this.ascending = true});

  SortSpec toggle() => SortSpec(column: column, ascending: !ascending);

  Map<String, dynamic> toJson() => {'column': column, 'direction': ascending ? 'asc' : 'desc'};
  static SortSpec fromJson(Map<String, dynamic> json) => 
      SortSpec(column: json['column'] as String, ascending: json['direction'] == 'asc');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortSpec && runtimeType == other.runtimeType && column == other.column && ascending == other.ascending;

  @override
  int get hashCode => column.hashCode ^ ascending.hashCode;
}

// ── DataGridSource ────────────────────────────────────────────────────────────

class _FixtureDataSource extends DataGridSource {
  _FixtureDataSource({
    required this.onCellEditCommit,
    required this.onNativeEditComplete,
    required this.onNativeEditStart,
  });

  List<DataGridRow> _baseRows = [];
  List<DataGridRow> _rows     = [];
  List<DataGridRow> _filtered = [];

  final Map<DataGridRow, FixtureRow> _rowToFixture = {};

  int?    _selectedFixtureId;
  String? _selectedColName;

  String  _searchQuery = '';
  String? _filterCol;
  String? _filterValue;

  List<String> _visibleCols = List.of(_kColOrder);

  VoidCallback? onSortChanged;
  final Future<void> Function(FixtureRow fixture, String col, String? value, int? partOrder)
      onCellEditCommit;
  final VoidCallback onNativeEditComplete;
  final void Function(FixtureRow fixture, String col) onNativeEditStart;

  TextEditingController? _editingController;
  FocusNode? _editingFocusNode;
  String? _newCellValue;

  ThemeData? _theme;
  void setTheme(ThemeData t) => _theme = t;

  Color get _textMain  => _theme?.colorScheme.onSurface ?? Colors.white;
  Color get _textMuted => _theme?.colorScheme.onSurfaceVariant ?? Colors.grey;
  Color get _accent    => _theme?.colorScheme.primary ?? Colors.amber;
  Color get _bgAlt     =>
      (_theme?.colorScheme.surfaceContainer ?? const Color(0xFF1A1D23))
          .withValues(alpha: 0.4);
  Color get _bgSel => _theme?.colorScheme.primaryContainer ?? const Color(0xFF2D2A1C);

  Set<int> _pendingIds  = {};
  Set<int> _conflictIds = {};
  static const _kPendingColor  = Color(0x1ADDAA00); // 10% opacity amber
  static const _kConflictColor = Color(0x1ACC3333); // 10% opacity red

  void updateRevisionState(Set<int> pending, Set<int> conflicts) {
    if (pending == _pendingIds && conflicts == _conflictIds) return;
    _pendingIds  = pending;
    _conflictIds = conflicts;
    notifyListeners();
  }

  // ── Public API ──────────────────────────────────────────────────────────

  void setVisibleCols(List<String> cols) => _visibleCols = cols;

  void setSelectedCell(int? fixtureId, String? colName) {
    _selectedFixtureId = fixtureId;
    _selectedColName   = colName;
    // No notifyListeners() — caller uses a separate ValueNotifier for sidebar
    // so the DataGrid is never rebuilt on tap, keeping double-tap intact.
  }

  String? get selectedColName => _selectedColName;

  FixtureRow? get selectedFixture => _selectedFixtureId == null
      ? null
      : _rowToFixture.values.where((f) => f.id == _selectedFixtureId).firstOrNull;

  FixtureRow? fixtureForRow(DataGridRow row) => _rowToFixture[row];

  String? get selectedCellValue {
    final f   = selectedFixture;
    final col = _selectedColName;
    if (f == null || col == null) return null;
    return _fixtureValueForCol(f, col);
  }

  void updateData(List<FixtureRow> fixtures) {
    _rowToFixture.clear();
    final built = <DataGridRow>[];
    for (final f in fixtures) {
      final row = DataGridRow(cells: [
        DataGridCell<String>(columnName: '#',           value: ''),
        DataGridCell<String>(columnName: 'chan',        value: f.channel ?? ''),
        DataGridCell<String>(columnName: 'dimmer',      value: f.dimmer ?? ''),
        DataGridCell<String>(columnName: 'position',    value: f.position ?? ''),
        DataGridCell<String>(columnName: 'unit',        value: f.unitNumber?.toString() ?? ''),
        DataGridCell<String>(columnName: 'type',        value: f.fixtureType ?? ''),
        DataGridCell<String>(columnName: 'function',    value: f.function ?? ''),
        DataGridCell<String>(columnName: 'focus',       value: f.focus ?? ''),
        DataGridCell<String>(columnName: 'accessories', value: f.accessories ?? ''),
        DataGridCell<String>(columnName: 'ip',          value: f.ipAddress ?? ''),
        DataGridCell<String>(columnName: 'subnet',      value: f.subnet ?? ''),
        DataGridCell<String>(columnName: 'mac',         value: f.macAddress ?? ''),
        DataGridCell<String>(columnName: 'ipv6',        value: f.ipv6 ?? ''),
        DataGridCell<String>(columnName: 'hung',        value: f.hung    ? '✓' : '—'),
        DataGridCell<String>(columnName: 'patch',       value: f.patched ? '✓' : '—'),
        DataGridCell<String>(columnName: 'focused',     value: f.focused ? '✓' : '—'),
        DataGridCell<String>(columnName: 'circuit',     value: f.circuit ?? ''),
        DataGridCell<String>(columnName: 'notes',       value: ''),
      ]);
      built.add(row);
      _rowToFixture[row] = f;
    }
    _baseRows = built;
    _rows     = List.of(_baseRows);
    _applySortInPlace();
    _rebuildFiltered();
    notifyListeners();
  }

  void applyFilters({required String search, String? filterCol, String? filterValue}) {
    _searchQuery  = search;
    _filterCol    = filterCol;
    _filterValue  = filterValue;
    _rebuildFiltered();
    notifyListeners();
  }

  void _rebuildFiltered() {
    var list = _rows;

    if (_filterCol != null && _filterValue != null && _filterValue!.isNotEmpty) {
      final q = _filterValue!.toLowerCase();
      list = list.where((row) =>
          _cellStr(row, _filterCol!).toLowerCase() == q).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((row) => row.getCells().any(
            (cell) => (cell.value?.toString() ?? '').toLowerCase().contains(q),
          )).toList();
    }

    _filtered = list;
  }

  // ── DataGridSource overrides ────────────────────────────────────────────

  @override
  List<DataGridRow> get rows => _filtered;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final fixture = _rowToFixture[row];
    if (fixture == null) return null;

    final index  = _filtered.indexOf(row);
    final sel    = fixture.id == _selectedFixtureId;
    final isEven = index.isEven;
    final isPending  = _pendingIds.contains(fixture.id);
    final isConflict = _conflictIds.contains(fixture.id);
    Color bg;
    if (isConflict) {
      bg = _kConflictColor;
    } else if (isPending) {
      bg = _kPendingColor;
    } else {
      bg = isEven ? Colors.transparent : _bgAlt;
    }

    Widget cell(String colName, String text, Color color, {bool bold = false}) {
      final isSelectedCell = sel && colName == _selectedColName;
      return Container(
        color: bg,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 13,
            fontWeight: bold || isSelectedCell ? FontWeight.bold : FontWeight.normal,
            color: isSelectedCell ? Colors.orange : color,
          ),
        ),
      );
    }

    return DataGridRowAdapter(
      cells: [
        for (final name in _visibleCols)
          _buildCellWidget(name, fixture, cell, sel),
      ],
    );
  }

  Widget _buildCellWidget(
    String name,
    FixtureRow f,
    Widget Function(String, String, Color, {bool bold}) cell,
    bool sel,
  ) {
    switch (name) {
      case '#':
        final idx = _filtered.indexWhere((r) => _rowToFixture[r]?.id == f.id);
        return cell('#', '${idx + 1}', sel ? _textMain : _textMuted, bold: sel);
      case 'chan':
        return cell('chan', f.channel ?? '', _accent, bold: true);
      case 'dimmer':
        return cell('dimmer', f.dimmer ?? '', _textMuted);
      case 'position':
        return cell('position', f.position ?? 'Unspecified', _textMain);
      case 'unit':
        return cell('unit', f.unitNumber?.toString() ?? '', _textMain);
      case 'type':
        return cell('type', f.fixtureType ?? '', _textMain);
      case 'function':
        return cell('function', f.function ?? '', _textMain);
      case 'focus':
        return cell('focus', f.focus ?? '', _textMain);
      case 'accessories':
        return cell('accessories', f.accessories ?? '', _textMain);
      case 'ip':
        return cell('ip', f.ipAddress ?? '', _textMain);
      case 'subnet':
        return cell('subnet', f.subnet ?? '', _textMain);
      case 'mac':
        return cell('mac', f.macAddress ?? '', _textMain);
      case 'ipv6':
        return cell('ipv6', f.ipv6 ?? '', _textMain);
      case 'hung':
        return cell('hung', f.hung ? '✓' : '—',
            f.hung ? Colors.green : _textMuted);
      case 'patch':
        return cell('patch', f.patched ? '✓' : '—',
            f.patched ? Colors.green : _textMuted);
      case 'focused':
        return cell('focused', f.focused ? '✓' : '—',
            f.focused ? Colors.green : _textMuted);
      case 'circuit':
        return cell('circuit', f.circuit ?? '', _textMuted);
      case 'notes':
        return cell('notes', '', _textMain);
      default:
        return cell(name, '', _textMain);
    }
  }

  // ── Sorting ─────────────────────────────────────────────────────────────

  @override
  Future<void> performSorting(List<DataGridRow> dataGridRows) async {
    _rows = List.of(_baseRows);
    _applySortInPlace();
    _rebuildFiltered();
    onSortChanged?.call();
  }

  void _applySortInPlace() {
    if (sortedColumns.isEmpty) return;
    final sort = sortedColumns.first;
    final asc  = sort.sortDirection == DataGridSortDirection.ascending;
    _rows.sort((a, b) {
      final aStr = _cellStr(a, sort.name);
      final bStr = _cellStr(b, sort.name);
      int cmp;
      if (_kNumericCols.contains(sort.name)) {
        final an = int.tryParse(aStr);
        final bn = int.tryParse(bStr);
        cmp = (an != null && bn != null) ? an.compareTo(bn) : aStr.compareTo(bStr);
      } else {
        cmp = aStr.compareTo(bStr);
      }
      return asc ? cmp : -cmp;
    });
  }

  String _cellStr(DataGridRow row, String col) =>
      row.getCells().firstWhere((c) => c.columnName == col,
              orElse: () => const DataGridCell<String>(columnName: '', value: ''))
          .value
          ?.toString() ??
      '';

  String? _fixtureValueForCol(FixtureRow f, String col) {
    switch (col) {
      case 'chan':         return f.channel;
      case 'position':    return f.position;
      case 'unit':        return f.unitNumber?.toString();
      case 'type':        return f.fixtureType;
      case 'function':    return f.function;
      case 'focus':       return f.focus;
      case 'accessories': return f.accessories;
      case 'ip':          return f.ipAddress;
      case 'subnet':      return f.subnet;
      case 'mac':         return f.macAddress;
      case 'ipv6':        return f.ipv6;
      default:            return null;
    }
  }

  @override
  Widget? buildEditWidget(
    DataGridRow row,
    RowColumnIndex rowColumnIndex,
    GridColumn column,
    CellSubmit submitCell,
  ) {
    final colName = column.columnName;
    if (_kReadOnlyCols.contains(colName)) return null;
    final fixture = fixtureForRow(row);
    if (fixture == null) return null;
    onNativeEditStart(fixture, colName);

    final initial = _fixtureValueForCol(fixture, colName) ?? '';
    _editingController?.dispose();
    _editingFocusNode?.dispose();
    _editingController = TextEditingController(text: initial);
    _newCellValue = null;
    _editingFocusNode = FocusNode();

    _editingFocusNode?.requestFocus();
    Future.microtask(() => _editingFocusNode?.requestFocus());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editingFocusNode?.requestFocus();
      final c = _editingController;
      if (c != null) {
        c.selection =
            TextSelection(baseOffset: 0, extentOffset: c.text.length);
      }
    });

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _editingController,
        focusNode: _editingFocusNode,
        autofocus: true,
        showCursor: true,
        enableInteractiveSelection: true,
        textInputAction: TextInputAction.done,
        onChanged: (value) {
          _newCellValue = value;
        },
        onTap: () {
          _editingFocusNode?.requestFocus();
        },
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
    final colName = column.columnName;
    if (_kReadOnlyCols.contains(colName)) return;

    final fixture = fixtureForRow(dataGridRow);
    if (fixture == null) return;

    final oldValue = (_fixtureValueForCol(fixture, colName) ?? '').trim();
    final nextText = (_newCellValue ?? _editingController?.text ?? '').trim();
    _editingController?.dispose();
    _editingController = null;
    _editingFocusNode?.dispose();
    _editingFocusNode = null;
    _newCellValue = null;

    try {
      if (nextText == oldValue) return;
      await onCellEditCommit(
        fixture,
        colName,
        nextText.isEmpty ? null : nextText,
        null, // _FixtureDataSource is always single-part
      );
    } finally {
      onNativeEditComplete();
    }
  }
}

// ── SpreadsheetTab ────────────────────────────────────────────────────────────

class SpreadsheetTab extends ConsumerStatefulWidget {
  const SpreadsheetTab({super.key});

  @override
  ConsumerState<SpreadsheetTab> createState() => _SpreadsheetTabState();
}

class _SpreadsheetTabState extends ConsumerState<SpreadsheetTab> {
  late final _FixtureDataSource _source;
  late final _MinimalFixtureSource _minimalSource;
  StreamSubscription<List<FixtureRow>>? _fixtureRowsSub;

  // Separate notifier for sidebar selection — never triggers a DataGrid rebuild.
  final ValueNotifier<FixtureRow?> _sidebarSelection = ValueNotifier(null);

  final GlobalKey _dataGridKey = GlobalKey();
  final DataGridController _minimalGridCtrl = DataGridController();
  final DataGridController _mainGridCtrl = DataGridController();

  double _lastNotesWidth = 120.0;
  bool _isEditingGridCell = false;
  List<FixtureRow>? _deferredRowsWhileEditing;

  List<SortSpec> _sortSpecs = [];
  SpreadsheetViewPreset? _activePreset;
  bool _isPresetDirty = false;

  final Map<String, double> _colWidths = Map.of(_kDefaultWidths);
  List<String> _colOrder = List.of(_kColOrder);
  Set<String> _hiddenCols = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String? _filterCol;
  String? _filterValue;

  @override
  void initState() {
    super.initState();
    _source = _FixtureDataSource(
      onCellEditCommit: _onEdit,
      onNativeEditComplete: () {
        _isEditingGridCell = false;
        final deferred = _deferredRowsWhileEditing;
        if (deferred != null) {
          _deferredRowsWhileEditing = null;
          _source.updateData(deferred);
        }
      },
      onNativeEditStart: (fixture, colName) {
        _isEditingGridCell = true;
      },
    );
    _minimalSource = _MinimalFixtureSource(
      onCellEditCommit: _onEdit,
      onBooleanSet: (fixture, col, value) async {
        final repo = ref.read(fixtureRepoProvider);
        if (repo == null) return;
        switch (col) {
          case 'patch':   await repo.setPatched(fixture.id, value: value);
          case 'hung':    await repo.setHung(fixture.id, value: value);
          case 'focused': await repo.setFocused(fixture.id, value: value);
        }
      },
    );
    _minimalSource.onSortChanged = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    };
    _searchCtrl.addListener(_onSearchChanged);
    _loadColWidths();

    // Seed defaults and initial sort
    Future.microtask(() async {
      final repo = ref.read(spreadsheetViewPresetRepoProvider);
      await repo?.seedDefaults();
    });

    _fixtureRowsSub = ref.read(fixtureRowsProvider.stream).listen((rows) {
      _minimalSource.updateRows(rows);
      if (_isEditingGridCell) {
        _deferredRowsWhileEditing = rows;
        return;
      }
      _source.updateData(rows);
    });
  }

  @override
  void dispose() {
    _fixtureRowsSub?.cancel();
    _searchCtrl.dispose();
    _sidebarSelection.dispose();
    _minimalGridCtrl.dispose();
    _mainGridCtrl.dispose();
    super.dispose();
  }

  // ── Persistent column widths ──────────────────────────────────────────────

  Future<void> _loadColWidths() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_kPrefsWidthKey);
    if (raw == null) return;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    if (mounted) {
      setState(() {
        for (final e in map.entries) {
          if (_kDefaultWidths.containsKey(e.key)) {
            _colWidths[e.key] = (e.value as num).toDouble();
          }
        }
      });
    }

  }

  Future<void> _saveColWidths() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsWidthKey, jsonEncode(_colWidths));
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged() {
    if (_kMinimalSpreadsheetMode) {
      _minimalSource.applyFilters(
        search: _searchCtrl.text,
        filterCol: _filterCol,
        filterValue: _filterValue,
      );
    } else {
      _source.applyFilters(
        search: _searchCtrl.text,
        filterCol: _filterCol,
        filterValue: _filterValue,
      );
    }
    setState(() {});
  }

  // ── Quick filter ──────────────────────────────────────────────────────────

  void _applyQuickFilter() {
    final colName =
        _kMinimalSpreadsheetMode ? _minimalSource.selectedColName : _source._selectedColName;
    final value =
        _kMinimalSpreadsheetMode ? _minimalSource.selectedCellValue : _source.selectedCellValue;
    if (colName == null || value == null || value.isEmpty) return;

    if (_filterCol == colName && _filterValue == value) {
      setState(() { _filterCol = null; _filterValue = null; });
    } else {
      setState(() { _filterCol = colName; _filterValue = value; });
    }
    if (_kMinimalSpreadsheetMode) {
      _minimalSource.applyFilters(
        search: _searchCtrl.text,
        filterCol: _filterCol,
        filterValue: _filterValue,
      );
    } else {
      _source.applyFilters(
        search: _searchCtrl.text,
        filterCol: _filterCol,
        filterValue: _filterValue,
      );
    }
  }

  void _clearFilter() {
    setState(() { _filterCol = null; _filterValue = null; });
    if (_kMinimalSpreadsheetMode) {
      _minimalSource.applyFilters(search: _searchCtrl.text);
    } else {
      _source.applyFilters(search: _searchCtrl.text);
    }
  }

  // ── Column picker (anchored dropdown) ─────────────────────────────────────

  void _showColumnPicker(BuildContext btnContext) {
    final box     = btnContext.findRenderObject()! as RenderBox;
    final overlay = Navigator.of(btnContext).overlay!.context.findRenderObject()! as RenderBox;
    final pos = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(box.size.bottomLeft(Offset.zero), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<void>(
      context: btnContext,
      position: pos,
      elevation: 8,
      items: [
        _ColumnPickerMenuEntry(
          hidden: _hiddenCols,
          onChanged: (hidden) => setState(() {
            _hiddenCols = hidden;
            _isPresetDirty = true;
          }),
        ),
      ],
    );
  }

  // ── Data edit handler ─────────────────────────────────────────────────────

  // partOrder non-null means a child (part-specific) edit on a multi-part fixture.
  Future<void> _onEdit(
      FixtureRow fixture, String col, String? value, int? partOrder) async {
    final repo = ref.read(fixtureRepoProvider);
    if (repo == null) return;

    if (partOrder != null) {
      switch (col) {
        case 'chan':    return repo.updatePartChannel(fixture.id, partOrder, value);
        case 'dimmer':  return repo.updatePartAddress(fixture.id, partOrder, value);
        case 'circuit': return repo.updatePartCircuit(fixture.id, partOrder, value);
      }
      return;
    }

    switch (col) {
      case 'chan':
        return repo.updateIntensityChannel(fixture.id, value);
      case 'dimmer':
        return repo.updatePartAddress(fixture.id, 0, value);
      case 'circuit':
        return repo.updatePartCircuit(fixture.id, 0, value);
      case 'position':
        return repo.updatePosition(fixture.id, value);
      case 'unit':
        return repo.updateUnitNumber(fixture.id, int.tryParse(value ?? ''));
      case 'type':
        return repo.updateFixtureType(fixture.id, value);
      case 'function':
        return repo.updateFunction(fixture.id, value);
      case 'focus':
        return repo.updateFocus(fixture.id, value);
      case 'accessories':
        return repo.updateAccessories(fixture.id, value);
      case 'ip':
        return repo.updateIntensityIp(fixture.id, value);
      case 'subnet':
        return repo.updateIntensitySubnet(fixture.id, value);
      case 'mac':
        return repo.updateIntensityMac(fixture.id, value);
      case 'ipv6':
        return repo.updateIntensityIpv6(fixture.id, value);
      default:
        return;
    }
  }

  // ── Add / Clone ───────────────────────────────────────────────────────────

  Future<void> _deleteFixture(FixtureRow fixture) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete fixture?'),
        content: Text(
          'Delete ${fixture.fixtureType ?? 'fixture'} in '
          '${fixture.position ?? 'unknown position'} (unit ${fixture.unitNumber ?? '?'})? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final repo = ref.read(fixtureRepoProvider);
    if (repo == null) return;
    await repo.deleteFixture(fixture.id);
    _minimalSource.setSelectedCell(null, null);
    _sidebarSelection.value = null;
  }

  Future<void> _showFixtureContextMenu(
      Offset globalPosition, FixtureRow fixture) async {
    final theme = Theme.of(context);
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        globalPosition.dx + 1,
        globalPosition.dy + 1,
      ),
      items: [
        PopupMenuItem(
          value: 'clone',
          child: Row(children: [
            const Icon(Icons.copy_outlined, size: 16),
            const SizedBox(width: 8),
            const Text('Clone Fixture'),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, size: 16, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Text('Delete Fixture',
                style: TextStyle(color: theme.colorScheme.error)),
          ]),
        ),
      ],
    );
    if (!mounted) return;
    if (result == 'clone') await _cloneFixture();
    if (result == 'delete') await _deleteFixture(fixture);
  }

  Future<void> _addFixture() async {
    final repo = ref.read(fixtureRepoProvider);
    if (repo == null) return;
    final selected =
        _kMinimalSpreadsheetMode ? _minimalSource.selectedFixture : _source.selectedFixture;
    final newId = await repo.addFixture(afterSortOrder: selected?.sortOrder);
    if (mounted) {
      if (_kMinimalSpreadsheetMode) {
        _minimalSource.setSelectedCell(newId, null);
      } else {
        _source.setSelectedCell(newId, null);
      }
    }
  }

  Future<void> _cloneFixture() async {
    final repo = ref.read(fixtureRepoProvider);
    if (repo == null) return;
    final sel =
        _kMinimalSpreadsheetMode ? _minimalSource.selectedFixture : _source.selectedFixture;
    if (sel == null) return;
    final newId = await repo.cloneFixture(sel.id);
    if (mounted) {
      if (_kMinimalSpreadsheetMode) {
        _minimalSource.setSelectedCell(newId, null);
      } else {
        _source.setSelectedCell(newId, null);
      }
    }
  }

  // ── Column builder ────────────────────────────────────────────────────────

  List<String> get _visibleColOrder =>
      _colOrder.where((n) => !_hiddenCols.contains(n)).toList();

  List<GridColumn> _buildColumns(ThemeData theme, double availableWidth) {
    final visible = _visibleColOrder;
    final fixedSum = visible
        .where((n) => n != 'notes')
        .fold(0.0, (s, n) => s + (_colWidths[n] ?? 0));
    final notesWidth = (availableWidth - fixedSum).clamp(80.0, double.infinity);
    _lastNotesWidth = notesWidth;

    final sortInfo = _source.sortedColumns.firstOrNull;

    Widget hdr(String name, String label) {
      final isSorted = sortInfo?.name == name;
      final isAsc    = isSorted &&
          sortInfo!.sortDirection == DataGridSortDirection.ascending;
      final color = isSorted
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurfaceVariant;
      return Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ),
            if (isSorted) ...[
              const SizedBox(width: 2),
              Icon(isAsc ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 11, color: color),
            ],
          ],
        ),
      );
    }

    return [
      for (final name in visible)
        GridColumn(
          columnName: name,
          width:      name == 'notes' ? notesWidth : (_colWidths[name] ?? 100.0),
          minimumWidth: 32,
          allowEditing: !_kReadOnlyCols.contains(name),
          allowSorting: name != '#',
          label: hdr(name, _kColLabels[name]!),
        ),
    ];
  }

  // ── Multi-column Sort Logic ──────────────────────────────────────────────

  void _setPrimarySortFromHeaderClick(String column) {
    setState(() {
      _sortSpecs = [SortSpec(column: column, ascending: true)];
      _minimalSource.setSortSpecs(_sortSpecs);
      _isPresetDirty = true;
    });
  }

  void _setSortLevel(int level, String? column) {
    setState(() {
      if (column == null) {
        if (level < _sortSpecs.length) {
          _sortSpecs.removeRange(level, _sortSpecs.length);
        }
      } else {
        final newSpec = SortSpec(column: column);
        if (level < _sortSpecs.length) {
          _sortSpecs[level] = newSpec;
        } else {
          _sortSpecs.add(newSpec);
        }
        _normalizeSortSpecs();
      }
      _minimalSource.setSortSpecs(_sortSpecs);
      _isPresetDirty = true;
    });
  }

  void _toggleSortDirection(int level) {
    if (level >= _sortSpecs.length) return;
    setState(() {
      _sortSpecs[level] = _sortSpecs[level].toggle();
      _minimalSource.setSortSpecs(_sortSpecs);
      _isPresetDirty = true;
    });
  }

  void _normalizeSortSpecs() {
    final seen = <String>{};
    _sortSpecs.removeWhere((s) => !seen.add(s.column));
    if (_sortSpecs.length > 3) _sortSpecs = _sortSpecs.sublist(0, 3);
  }



  Widget _buildPresetsStrip(ThemeData theme, List<SpreadsheetViewPreset> presets) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final p in presets) ...[
                    _buildPresetButton(theme, p),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: _showCreatePresetDialog,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            tooltip: 'New Preset',
          ),
          if (_activePreset != null) ...[
            const SizedBox(width: 4),
            TextButton.icon(
              icon: const Icon(Icons.save, size: 14),
              label: const Text('Update', style: TextStyle(fontSize: 11)),
              onPressed: _isPresetDirty ? _updateActivePreset : null,
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetButton(ThemeData theme, SpreadsheetViewPreset preset) {
    final isActive = _activePreset?.id == preset.id;
    final color = isActive
        ? (_isPresetDirty ? Colors.yellow[800] : Colors.orange[800])
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurfaceVariant;

    return ActionChip(
      label: Text(preset.name, style: TextStyle(color: textColor, fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
      onPressed: () => _applyPreset(preset),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  Future<void> _applyPreset(SpreadsheetViewPreset preset) async {
    final data = jsonDecode(preset.presetJson) as Map<String, dynamic>;
    setState(() {
      _activePreset = preset;
      _isPresetDirty = false;
      
      if (data.containsKey('columnOrder')) {
        final storedOrder = List<String>.from(data['columnOrder']);
        final validStored = storedOrder.where((c) => _kColLabels.containsKey(c)).toList();
        // Columns absent from the stored order are implicitly hidden; place them at the end
        // so _colOrder always contains every known column (required for drag-reorder invariant).
        final implicitlyHidden = _kColOrder.where((c) => !validStored.contains(c)).toList();
        _colOrder = [...validStored, ...implicitlyHidden];
        _hiddenCols = implicitlyHidden.toSet();
      }
      if (data.containsKey('hiddenColumns')) {
        // Merge explicit hiddenColumns with any implicitly-hidden ones derived above.
        _hiddenCols = _hiddenCols.union(Set<String>.from(data['hiddenColumns'] as List));
      }
      if (data.containsKey('columnWidths')) {
        final widths = Map<String, dynamic>.from(data['columnWidths']);
        for (final e in widths.entries) {
          if (_kDefaultWidths.containsKey(e.key)) {
             _colWidths[e.key] = (e.value as num).toDouble();
          }
        }
      }
      if (data.containsKey('sorts')) {
        final specs = (data['sorts'] as List).map((s) => SortSpec.fromJson(s as Map<String, dynamic>)).toList();
        _sortSpecs = specs.where((s) => _kColLabels.containsKey(s.column)).toList();
        _minimalSource.setSortSpecs(_sortSpecs);
      }
    });
  }

  Future<void> _showCreatePresetDialog() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Preset'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Preset Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save')),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      final repo = ref.read(spreadsheetViewPresetRepoProvider);
      final data = _captureCurrentState();
      await repo?.createPreset(name: name, presetData: data);
      // The stream will update the UI with the new preset
    }
  }

  Future<void> _updateActivePreset() async {
    if (_activePreset == null) return;
    final repo = ref.read(spreadsheetViewPresetRepoProvider);
    final data = _captureCurrentState();
    await repo?.updatePreset(_activePreset!.id, data);
    setState(() => _isPresetDirty = false);
  }

  Map<String, dynamic> _captureCurrentState() {
    return {
      'version': 1,
      'columnOrder': _colOrder,
      'hiddenColumns': _hiddenCols.toList(),
      'columnWidths': _colWidths,
      'sorts': _sortSpecs.map((s) => s.toJson()).toList(),
    };
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _source.setTheme(theme);
    _source.setVisibleCols(_visibleColOrder);
    _minimalSource.setTheme(theme);
    _minimalSource.setVisibleCols(_visibleColOrder);

    // ── Revision highlights ────────────────────────────────────────────────
    final pendingIds  = ref.watch(pendingFixtureIdsProvider).valueOrNull ?? {};
    final conflictIds = ref.watch(conflictFixtureIdsProvider).valueOrNull ?? {};
    _minimalSource.updateRevisionState(pendingIds, conflictIds);
    _source.updateRevisionState(pendingIds, conflictIds);
    // ────────────────────────────────────────────────────────────────────────

    final fixtures    = ref.watch(fixtureRowsProvider).valueOrNull ?? [];
    final presetsAsync = ref.watch(spreadsheetViewPresetsProvider);
    final presets = presetsAsync.valueOrNull ?? [];
    final surfaceLow  = theme.colorScheme.surfaceContainerLow;
    final outline     = theme.colorScheme.outlineVariant;
    final filterActive = _filterCol != null;

    if (_kMinimalSpreadsheetMode) {
      final cardColor = theme.colorScheme.surfaceContainerLow;
      final borderColor = theme.colorScheme.outlineVariant;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListenableBuilder(
                listenable: Listenable.merge([_minimalSource, _sidebarSelection]),
                builder: (ctx, _) {
                  final sel = _minimalSource.selectedFixture;
                  return _Sidebar(
                    theme: theme,
                    selected: sel,
                    canClone: sel != null,
                    onAdd: _addFixture,
                    onClone: _cloneFixture,
                    onDelete: () { if (sel != null) _deleteFixture(sel); },
                    onEdit: (col, val) =>
                        sel != null ? _onEdit(sel, col, val, null) : Future.value(),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    _Toolbar(
                      theme: theme,
                      searchCtrl: _searchCtrl,
                      sortSpecs: _sortSpecs,
                      onSortLevel: _setSortLevel,
                      onToggleDirection: _toggleSortDirection,
                      availableCols: _kColOrder.where((c) => !_hiddenCols.contains(c) && c != '#').toList(),
                      onColumnsPressed: _showColumnPicker,
                    ),
                    _FilterStrip(
                      theme: theme,
                      filterActive: filterActive,
                      filterLabel: filterActive
                          ? '${_kColLabels[_filterCol!] ?? _filterCol!}: $_filterValue'
                          : null,
                      onQuickFilter: _applyQuickFilter,
                      onClearFilter: _clearFilter,
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (ctx, constraints) {
                          final cols = _buildColumns(theme, constraints.maxWidth);
                          return SfDataGridTheme(
                            data: SfDataGridThemeData(
                              headerColor: surfaceLow,
                              gridLineColor: outline,
                              sortIconColor: Colors.transparent,
                            ),
                            child: SfDataGrid(
                              key: _dataGridKey,
                              controller: _minimalGridCtrl,
                              source: _minimalSource,
                              columns: cols,
                              rowHeight: 32,
                              headerRowHeight: 32,
                              selectionMode: SelectionMode.single,
                              navigationMode: GridNavigationMode.cell,
                              allowSorting: true,
                              allowEditing: true,
                              editingGestureType: EditingGestureType.doubleTap,
                              allowColumnsResizing: true,
                              allowColumnsDragging: true,
                              columnWidthMode: ColumnWidthMode.none,
                              gridLinesVisibility: GridLinesVisibility.horizontal,
                              headerGridLinesVisibility: GridLinesVisibility.horizontal,
                              onColumnResizeUpdate: (details) {
                                _colWidths[details.column.columnName] = details.width;
                                if (mounted) setState(() {});
                                return true;
                              },
                              onColumnResizeEnd: (details) {
                                setState(() {
                                  _isPresetDirty = true;
                                });
                                _saveColWidths();
                              },
                              onColumnDragging: (details) {
                                if (details.action == DataGridColumnDragAction.dropped) {
                                  final from = details.from;
                                  final to = details.to;
                                  if (from == null || to == null || from == to) return true;

                                  final visible = List<String>.from(_visibleColOrder);
                                  if (from < visible.length && to < visible.length) {
                                    final moved = visible.removeAt(from);
                                    visible.insert(to, moved);
                                    final hidden = _colOrder.where(_hiddenCols.contains).toList();
                                    setState(() {
                                      _colOrder = [...visible, ...hidden];
                                      _isPresetDirty = true;
                                    });
                                  }
                                }
                                return true;
                              },
                              onColumnSortChanging: (col, details) {
                                if (col != null) {
                                  _setPrimarySortFromHeaderClick(col.name);
                                }
                                return false; 
                              },
                              onCellTap: (details) {
                                final rci = details.rowColumnIndex;
                                final colIdx = rci.columnIndex;
                                String? colName;
                                if (colIdx >= 0 && colIdx < _visibleColOrder.length) {
                                  colName = _visibleColOrder[colIdx];
                                }
                                final rowIdx = rci.rowIndex - 1;
                                final fixture = rowIdx >= 0 && rowIdx < _minimalSource.rows.length
                                    ? _minimalSource.fixtureForRow(_minimalSource.rows[rowIdx])
                                    : null;

                                final wasSelected = fixture != null &&
                                    _minimalSource.selectedFixture?.id == fixture.id &&
                                    _minimalSource.selectedColName == colName;

                                _syncMinimalSelectionFromRowCol(rci);

                                if (wasSelected) {
                                  _minimalGridCtrl.beginEdit(rci);
                                }
                              },
                              onCurrentCellActivated: (_, current) {
                                _syncMinimalSelectionFromRowCol(current);
                              },
                              onCellSecondaryTap: (details) {
                                _syncMinimalSelectionFromRowCol(details.rowColumnIndex);
                                final rowIdx = details.rowColumnIndex.rowIndex - 1;
                                if (rowIdx < 0 || rowIdx >= _minimalSource.rows.length) return;
                                final fixture = _minimalSource.fixtureForRow(_minimalSource.rows[rowIdx]);
                                if (fixture == null) return;
                                _showFixtureContextMenu(details.globalPosition, fixture);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    _buildPresetsStrip(theme, presets),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar listens to _sidebarSelection (tap updates) AND _source (data updates).
        ListenableBuilder(
          listenable: Listenable.merge([_source, _sidebarSelection]),
          builder: (ctx, _) {
            // Always read from _source so data stays fresh after DB updates.
            final sel = _source.selectedFixture;
            return _Sidebar(
              theme: theme,
              selected: sel,
              canClone: sel != null,
              onAdd: _addFixture,
              onClone: _cloneFixture,
              onDelete: () { if (sel != null) _deleteFixture(sel); },
              onEdit: (col, val) =>
                  sel != null ? _onEdit(sel, col, val, null) : Future.value(),
            );
          },
        ),
        Expanded(
          child: Column(
            children: [
              _Toolbar(
                theme: theme,
                searchCtrl: _searchCtrl,
                sortSpecs: _sortSpecs,
                onSortLevel: _setSortLevel,
                onToggleDirection: _toggleSortDirection,
                availableCols: _kColOrder.where((c) => !_hiddenCols.contains(c) && c != '#').toList(),
                onColumnsPressed: _showColumnPicker,
              ),
              _FilterStrip(
                theme: theme,
                filterActive: filterActive,
                filterLabel: filterActive
                    ? '${_kColLabels[_filterCol!] ?? _filterCol!}: $_filterValue'
                    : null,
                onQuickFilter: _applyQuickFilter,
                onClearFilter: _clearFilter,
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final cols = _buildColumns(theme, constraints.maxWidth);
                    return SfDataGridTheme(
                      data: SfDataGridThemeData(
                        headerColor: surfaceLow,
                        gridLineColor: outline,
                        sortIconColor: Colors.transparent,
                        selectionColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        rowHoverColor: Colors.purple.withValues(alpha: 0.1),
                        currentCellStyle: DataGridCurrentCellStyle(
                          borderColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                          borderWidth: 1,
                        ),
                      ),
                      child: SfDataGrid(
                        key: _dataGridKey,
                        controller: _mainGridCtrl,
                        source: _source,
                        columns: cols,
                        rowHeight: 32,
                        headerRowHeight: 32,
                        selectionMode: SelectionMode.single,
                        navigationMode: GridNavigationMode.cell,
                        allowSorting: false,
                        allowColumnsResizing: true,
                        allowColumnsDragging: false,
                        columnWidthMode: ColumnWidthMode.none,
                        gridLinesVisibility: GridLinesVisibility.horizontal,
                        headerGridLinesVisibility: GridLinesVisibility.horizontal,
                        onColumnResizeUpdate: (details) {
                          _colWidths[details.column.columnName] = details.width;
                          if (mounted) setState(() {});
                          return true;
                        },
                        onColumnResizeEnd: (details) {
                          setState(() {});
                          _saveColWidths();
                        },
                        allowEditing: true,
                        editingGestureType: EditingGestureType.doubleTap,
                        onCellTap: (details) {
                          final rci = details.rowColumnIndex;
                          final colIdx = rci.columnIndex;
                          String? colName;
                          if (colIdx >= 0 && colIdx < _visibleColOrder.length) {
                            colName = _visibleColOrder[colIdx];
                          }
                          final rowIdx = rci.rowIndex - 1;
                          final fixture = rowIdx >= 0 && rowIdx < _source.rows.length
                              ? _source.fixtureForRow(_source.rows[rowIdx])
                              : null;

                          final wasSelected = fixture != null &&
                              _source.selectedFixture?.id == fixture.id &&
                              _source.selectedColName == colName;

                          _syncMainSelectionFromRowCol(rci);

                          if (wasSelected) {
                            _mainGridCtrl.beginEdit(rci);
                          }
                        },
                        onCurrentCellActivated: (_, current) {
                          _syncMainSelectionFromRowCol(current);
                        },
                        onCellSecondaryTap: (details) {
                          _syncMainSelectionFromRowCol(details.rowColumnIndex);
                          final rowIdx = details.rowColumnIndex.rowIndex - 1;
                          if (rowIdx < 0 || rowIdx >= _source.rows.length) return;
                          final fixture = _source.fixtureForRow(_source.rows[rowIdx]);
                          if (fixture == null) return;
                          _showFixtureContextMenu(details.globalPosition, fixture);
                        },
                      ),
                    );
                  },
                ),
              ),
              _buildPresetsStrip(theme, presets),
              _StatusBar(
                totalFixtures: fixtures.length,
                visibleCount: _minimalSource.rows.length,
                filterActive: filterActive,
                showName:
                    ref.watch(currentShowMetaProvider).valueOrNull?.showName ?? '',
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _simpleHeaderCell(String label) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      );

  void _syncMinimalSelectionFromRowCol(RowColumnIndex rci) {
    final rowIdx = rci.rowIndex - 1;
    if (rowIdx < 0 || rowIdx >= _minimalSource.rows.length) return;
    final row = _minimalSource.rows[rowIdx];
    final fixture = _minimalSource.fixtureForRow(row);
    if (fixture == null) return;

    String? colName;
    final colIdx = rci.columnIndex;
    if (colIdx >= 0 && colIdx < _visibleColOrder.length) {
      colName = _visibleColOrder[colIdx];
    }

    _minimalSource.setSelectedCell(fixture.id, colName);
    _sidebarSelection.value = fixture;
  }

  void _syncMainSelectionFromRowCol(RowColumnIndex rci) {
    final rowIdx = rci.rowIndex - 1;
    if (rowIdx < 0 || rowIdx >= _source.rows.length) return;
    final row = _source.rows[rowIdx];
    final fixture = _source.fixtureForRow(row);
    if (fixture == null) return;

    String? colName;
    final colIdx = rci.columnIndex;
    if (colIdx >= 0 && colIdx < _visibleColOrder.length) {
      colName = _visibleColOrder[colIdx];
    }

    _source.setSelectedCell(fixture.id, colName);
    _sidebarSelection.value = fixture;
  }
}

class _MinimalFixtureSource extends DataGridSource {
  _MinimalFixtureSource({
    required this.onCellEditCommit,
    required this.onBooleanSet,
  });

  VoidCallback? onSortChanged;

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
  List<SortSpec> _sortSpecs = [];

  final Map<DataGridRow, FixtureRow> _rowToFixture = {};
  // null = parent/single row; non-null = child row for that part order
  final Map<DataGridRow, int?> _rowToPartOrder = {};
  List<DataGridRow> _rows = [];
  List<String> _visibleCols = List.of(_kColOrder);

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
    final col = _selectedColName;
    if (f == null || col == null) return null;
    return switch (col) {
      '#' => f.id.toString(),
      'chan' => f.channel,
      'dimmer' => f.dimmer,
      'position' => f.position,
      'unit' => f.unitNumber?.toString(),
      'type' => f.fixtureType,
      'function' => f.function,
      'focus' => f.focus,
      'accessories' => f.accessories,
      'ip' => f.ipAddress,
      'subnet' => f.subnet,
      'mac' => f.macAddress,
      'ipv6' => f.ipv6,
      'hung' => f.hung ? '✓' : '—',
      'patch' => f.patched ? '✓' : '—',
      'focused' => f.focused ? '✓' : '—',
      'circuit' => f.circuit,
      'notes' => '',
      _ => null,
    };
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

  void setSortSpecs(List<SortSpec> specs) {
    _sortSpecs = specs;
    _rebuildFilteredRows();
    onSortChanged?.call();
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

  void _rebuildFilteredRows() {
    Iterable<FixtureRow> list = _allFixtures;

    if (_filterCol != null && _filterValue != null && _filterValue!.isNotEmpty) {
      final exact = _filterValue!.toLowerCase();
      list = list.where((f) {
        final v = switch (_filterCol!) {
          '#' => f.id.toString(),
          'chan' => f.channel ?? '',
          'dimmer' => f.dimmer ?? '',
          'position' => f.position ?? '',
          'unit' => f.unitNumber?.toString() ?? '',
          'type' => f.fixtureType ?? '',
          'function' => f.function ?? '',
          'focus' => f.focus ?? '',
          'accessories' => f.accessories ?? '',
          'ip' => f.ipAddress ?? '',
          'subnet' => f.subnet ?? '',
          'mac' => f.macAddress ?? '',
          'ipv6' => f.ipv6 ?? '',
          'hung' => f.hung ? '✓' : '—',
          'patch' => f.patched ? '✓' : '—',
          'focused' => f.focused ? '✓' : '—',
          'circuit' => f.circuit ?? '',
          'notes' => '',
          _ => '',
        };
        return v.toLowerCase() == exact;
      });
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((f) {
        final fields = <String>[
          f.id.toString(),
          f.channel ?? '',
          f.dimmer ?? '',
          f.position ?? '',
          f.unitNumber?.toString() ?? '',
          f.fixtureType ?? '',
          f.function ?? '',
          f.focus ?? '',
          f.accessories ?? '',
          f.ipAddress ?? '',
          f.subnet ?? '',
          f.macAddress ?? '',
          f.ipv6 ?? '',
          f.hung ? '✓' : '—',
          f.patched ? '✓' : '—',
          f.focused ? '✓' : '—',
          f.circuit ?? '',
        ];
        return fields.any((v) => v.toLowerCase().contains(q));
      });
    }

    if (_sortSpecs.isNotEmpty) {
      final sortedList = list.toList();
      sortedList.sort((a, b) {
        for (final spec in _sortSpecs) {
          final va = _getSortValue(a, spec.column);
          final vb = _getSortValue(b, spec.column);

          int cmp;
          if (_kNumericCols.contains(spec.column)) {
            final na = double.tryParse(va ?? '') ?? 0.0;
            final nb = double.tryParse(vb ?? '') ?? 0.0;
            cmp = na.compareTo(nb);
          } else {
            cmp = (va ?? '').toLowerCase().compareTo((vb ?? '').toLowerCase());
          }

          if (cmp != 0) return spec.ascending ? cmp : -cmp;
        }
        return a.id.compareTo(b.id);
      });
      list = sortedList;
    }

    _filteredFixtures = list.toList();
    _rowToFixture.clear();
    _rowToPartOrder.clear();
    _rows = [];

    for (final f in _filteredFixtures) {
      // ── Parent / single row ──────────────────────────────────────────────
      final parentRow = DataGridRow(cells: [
        DataGridCell<int>(columnName: '#', value: f.id),
        DataGridCell<String>(columnName: 'chan', value: f.channel ?? ''),
        DataGridCell<String>(columnName: 'dimmer', value: f.dimmer ?? ''),
        DataGridCell<String>(columnName: 'position', value: f.position ?? ''),
        DataGridCell<String>(columnName: 'unit', value: f.unitNumber?.toString() ?? ''),
        DataGridCell<String>(columnName: 'type', value: f.fixtureType ?? ''),
        DataGridCell<String>(columnName: 'function', value: f.function ?? ''),
        DataGridCell<String>(columnName: 'focus', value: f.focus ?? ''),
        DataGridCell<String>(columnName: 'accessories', value: f.accessories ?? ''),
        DataGridCell<String>(columnName: 'ip', value: f.ipAddress ?? ''),
        DataGridCell<String>(columnName: 'subnet', value: f.subnet ?? ''),
        DataGridCell<String>(columnName: 'mac', value: f.macAddress ?? ''),
        DataGridCell<String>(columnName: 'ipv6', value: f.ipv6 ?? ''),
        DataGridCell<String>(columnName: 'hung', value: f.hung ? '✓' : '—'),
        DataGridCell<String>(columnName: 'patch', value: f.patched ? '✓' : '—'),
        DataGridCell<String>(columnName: 'focused', value: f.focused ? '✓' : '—'),
        DataGridCell<String>(columnName: 'circuit', value: f.circuit ?? ''),
        const DataGridCell<String>(columnName: 'notes', value: ''),
      ]);
      _rowToFixture[parentRow] = f;
      _rowToPartOrder[parentRow] = null;
      _rows.add(parentRow);

      // ── Child rows: always shown for multi-part fixtures ─────────────────
      if (f.isMultiPart) {
        for (final part in f.parts) {
          final childRow = DataGridRow(cells: [
            DataGridCell<int>(columnName: '#', value: part.partOrder + 1),
            DataGridCell<String>(columnName: 'chan', value: part.channel ?? ''),
            DataGridCell<String>(columnName: 'dimmer', value: part.address ?? ''),
            const DataGridCell<String>(columnName: 'position', value: ''),
            const DataGridCell<String>(columnName: 'unit', value: ''),
            const DataGridCell<String>(columnName: 'type', value: ''),
            const DataGridCell<String>(columnName: 'function', value: ''),
            const DataGridCell<String>(columnName: 'focus', value: ''),
            const DataGridCell<String>(columnName: 'accessories', value: ''),
            DataGridCell<String>(columnName: 'ip', value: part.ipAddress ?? ''),
            DataGridCell<String>(columnName: 'subnet', value: part.subnet ?? ''),
            DataGridCell<String>(columnName: 'mac', value: part.macAddress ?? ''),
            DataGridCell<String>(columnName: 'ipv6', value: part.ipv6 ?? ''),
            const DataGridCell<String>(columnName: 'hung', value: ''),
            const DataGridCell<String>(columnName: 'patch', value: ''),
            const DataGridCell<String>(columnName: 'focused', value: ''),
            const DataGridCell<String>(columnName: 'circuit', value: ''),
            const DataGridCell<String>(columnName: 'notes', value: ''),
          ]);
          _rowToFixture[childRow] = f;
          _rowToPartOrder[childRow] = part.partOrder;
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
    final index = _rows.indexOf(row);
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
      if (_kReadOnlyCols.contains(col)) return null;
      initial = switch (col) {
        'chan'         => fixture.channel ?? '',
        'dimmer'       => fixture.dimmer ?? '',
        'position'     => fixture.position ?? '',
        'unit'         => fixture.unitNumber?.toString() ?? '',
        'type'         => fixture.fixtureType ?? '',
        'function'     => fixture.function ?? '',
        'focus'        => fixture.focus ?? '',
        'accessories'  => fixture.accessories ?? '',
        'ip'           => fixture.ipAddress ?? '',
        'subnet'       => fixture.subnet ?? '',
        'mac'          => fixture.macAddress ?? '',
        'ipv6'         => fixture.ipv6 ?? '',
        _              => '',
      };
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

    if (partOrder != null) {
      if (col == 'chan')   await onCellEditCommit(fixture, 'chan',   val, partOrder);
      if (col == 'dimmer') await onCellEditCommit(fixture, 'dimmer', val, partOrder);
      return;
    }

    if (_kReadOnlyCols.contains(col)) return;
    switch (col) {
      case 'chan':        await onCellEditCommit(fixture, col, val, null);
      case 'dimmer':     await onCellEditCommit(fixture, col, val, null);
      case 'position':   await onCellEditCommit(fixture, col, val, null);
      case 'unit':       await onCellEditCommit(fixture, col, val, null);
      case 'type':       await onCellEditCommit(fixture, col, val, null);
      case 'function':   await onCellEditCommit(fixture, col, val, null);
      case 'focus':      await onCellEditCommit(fixture, col, val, null);
      case 'accessories':await onCellEditCommit(fixture, col, val, null);
      case 'ip':         await onCellEditCommit(fixture, col, val, null);
      case 'subnet':     await onCellEditCommit(fixture, col, val, null);
      case 'mac':        await onCellEditCommit(fixture, col, val, null);
      case 'ipv6':       await onCellEditCommit(fixture, col, val, null);
    }
  }

  String? _getSortValue(FixtureRow f, String col) {
    return switch (col) {
      '#' => f.id.toString(),
      'chan' => f.channel,
      'dimmer' => f.dimmer,
      'position' => f.position,
      'unit' => f.unitNumber?.toString(),
      'type' => f.fixtureType,
      'function' => f.function,
      'focus' => f.focus,
      'accessories' => f.accessories,
      'ip' => f.ipAddress,
      'subnet' => f.subnet,
      'mac' => f.macAddress,
      'ipv6' => f.ipv6,
      'hung' => f.hung ? '✓' : '—',
      'patch' => f.patched ? '✓' : '—',
      'focused' => f.focused ? '✓' : '—',
      'circuit' => f.circuit,
      _ => null,
    };
  }
}

// ── Column picker menu entry (anchored dropdown) ──────────────────────────────

class _ColumnPickerMenuEntry extends PopupMenuEntry<Never> {
  const _ColumnPickerMenuEntry({
    required this.hidden,
    required this.onChanged,
  });

  final Set<String> hidden;
  final void Function(Set<String>) onChanged;

  @override
  double get height => (_kColOrder.length - _kAlwaysVisible.length) * 40.0;

  @override
  bool represents(Never? value) => false;

  @override
  State<_ColumnPickerMenuEntry> createState() => _ColumnPickerMenuEntryState();
}

class _ColumnPickerMenuEntryState extends State<_ColumnPickerMenuEntry> {
  late Set<String> _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = Set.of(widget.hidden);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final name in _kColOrder)
          if (!_kAlwaysVisible.contains(name))
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(_kColLabels[name] ?? name,
                  style: GoogleFonts.jetBrainsMono(fontSize: 13)),
              value: !_hidden.contains(name),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _hidden.remove(name);
                  } else {
                    _hidden.add(name);
                  }
                });
                widget.onChanged(_hidden);
              },
            ),
      ],
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.theme,
    required this.selected,
    required this.canClone,
    required this.onAdd,
    required this.onClone,
    required this.onDelete,
    required this.onEdit,
  });

  final ThemeData theme;
  final FixtureRow? selected;
  final bool canClone;
  final VoidCallback onAdd;
  final VoidCallback onClone;
  final VoidCallback onDelete;
  final Future<void> Function(String col, String? value) onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Fixture'),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: canClone ? onClone : null,
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  label: const Text('Clone Fixture'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: selected != null ? onDelete : null,
                  icon: Icon(Icons.delete_outline, size: 16,
                      color: selected != null ? theme.colorScheme.error : null),
                  label: const Text('Delete Fixture'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                        color: selected != null
                            ? theme.colorScheme.error.withValues(alpha: 0.5)
                            : theme.colorScheme.outlineVariant),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Expanded(
            child: _PropertiesPanel(
              theme: theme,
              fixture: selected,
              onEdit: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Properties panel ──────────────────────────────────────────────────────────

class _PropertiesPanel extends StatelessWidget {
  const _PropertiesPanel({
    required this.theme,
    required this.fixture,
    required this.onEdit,
  });

  final ThemeData theme;
  final FixtureRow? fixture;
  final Future<void> Function(String col, String? value) onEdit;

  @override
  Widget build(BuildContext context) {
    final f = fixture;
    if (f == null) {
      return Center(
        child: Text('No fixture\nselected',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _section('PATCH'),
        _EditRow(
          key: ValueKey('chan-${f.id}'),
          label: 'Channel',
          value: f.channel,
          accent: true,
          theme: theme,
          onSubmit: (v) => onEdit('chan', v),
        ),
        _ReadRow(label: 'Address', value: f.dimmer, theme: theme),
        _ReadRow(label: 'Circuit', value: f.circuit, theme: theme),
        _divider(),
        _section('FIXTURE'),
        _EditRow(
          key: ValueKey('pos-${f.id}'),
          label: 'Position',
          value: f.position,
          theme: theme,
          onSubmit: (v) => onEdit('position', v),
        ),
        _EditRow(
          key: ValueKey('unit-${f.id}'),
          label: 'Unit #',
          value: f.unitNumber?.toString(),
          theme: theme,
          onSubmit: (v) => onEdit('unit', v),
        ),
        _EditRow(
          key: ValueKey('type-${f.id}'),
          label: 'Type',
          value: f.fixtureType,
          theme: theme,
          onSubmit: (v) => onEdit('type', v),
        ),
        _EditRow(
          key: ValueKey('func-${f.id}'),
          label: 'Purpose',
          value: f.function,
          theme: theme,
          onSubmit: (v) => onEdit('function', v),
        ),
        _EditRow(
          key: ValueKey('focus-${f.id}'),
          label: 'Focus Area',
          value: f.focus,
          theme: theme,
          onSubmit: (v) => onEdit('focus', v),
        ),
        _EditRow(
          key: ValueKey('acc-${f.id}'),
          label: 'Accessories',
          value: f.accessories,
          theme: theme,
          onSubmit: (v) => onEdit('accessories', v),
        ),
        _divider(),
        _section('NETWORK'),
        _EditRow(
          key: ValueKey('ip-${f.id}'),
          label: 'IP',
          value: f.ipAddress,
          theme: theme,
          onSubmit: (v) => onEdit('ip', v),
        ),
        _EditRow(
          key: ValueKey('sub-${f.id}'),
          label: 'Subnet',
          value: f.subnet,
          theme: theme,
          onSubmit: (v) => onEdit('subnet', v),
        ),
        _EditRow(
          key: ValueKey('mac-${f.id}'),
          label: 'MAC',
          value: f.macAddress,
          theme: theme,
          onSubmit: (v) => onEdit('mac', v),
        ),
        _EditRow(
          key: ValueKey('ipv6-${f.id}'),
          label: 'IPv6',
          value: f.ipv6,
          theme: theme,
          onSubmit: (v) => onEdit('ipv6', v),
        ),
        _divider(),
        _section('STATUS'),
        _ReadRow(
          label: 'Patched',
          value: f.patched ? 'Yes' : 'No',
          valueColor: f.patched ? Colors.green : null,
          theme: theme,
        ),
        _ReadRow(
          label: 'Hung',
          value: f.hung ? 'Yes' : 'No',
          valueColor: f.hung ? Colors.green : null,
          theme: theme,
        ),
        _ReadRow(
          label: 'Focused',
          value: f.focused ? 'Yes' : 'No',
          valueColor: f.focused ? Colors.green : null,
          theme: theme,
        ),
        _ReadRow(
          label: 'Flagged',
          value: f.flagged ? 'Yes' : 'No',
          valueColor: f.flagged ? theme.colorScheme.primary : null,
          theme: theme,
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(height: 16, color: theme.colorScheme.outlineVariant);

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.8)),
      );
}

// ── Read-only property row ────────────────────────────────────────────────────

class _ReadRow extends StatelessWidget {
  const _ReadRow({
    required this.label,
    required this.value,
    required this.theme,
    this.accent = false,
    this.valueColor,
  });

  final String label;
  final String? value;
  final ThemeData theme;
  final bool accent;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final vc = valueColor ??
        (accent ? theme.colorScheme.primary : theme.colorScheme.onSurface);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value ?? '—',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: vc)),
          ),
        ],
      ),
    );
  }
}

// ── Editable property row ─────────────────────────────────────────────────────

class _EditRow extends StatefulWidget {
  const _EditRow({
    super.key,
    required this.label,
    required this.value,
    required this.theme,
    required this.onSubmit,
    this.accent = false,
  });

  final String label;
  final String? value;
  final ThemeData theme;
  final void Function(String?) onSubmit;
  final bool accent;

  @override
  State<_EditRow> createState() => _EditRowState();
}

class _EditRowState extends State<_EditRow> {
  late TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_EditRow old) {
    super.didUpdateWidget(old);
    // Sync controller when value changes externally (e.g. DB update),
    // but only if this field isn't currently being edited.
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) _submit();
  }

  void _submit() {
    final val = _ctrl.text.trim();
    widget.onSubmit(val.isEmpty ? null : val);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent
        ? widget.theme.colorScheme.primary
        : widget.theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(widget.label,
                style: widget.theme.textTheme.labelSmall?.copyWith(
                    color: widget.theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: SizedBox(
              height: 24,
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 12, color: accent),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  filled: true,
                  fillColor:
                      widget.theme.colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                        color: widget.theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                        color: widget.theme.colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide:
                        BorderSide(color: widget.theme.colorScheme.primary),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.theme,
    required this.searchCtrl,
    required this.sortSpecs,
    required this.onSortLevel,
    required this.onToggleDirection,
    required this.availableCols,
    required this.onColumnsPressed,
  });

  final ThemeData theme;
  final TextEditingController searchCtrl;
  final List<SortSpec> sortSpecs;
  final void Function(int, String?) onSortLevel;
  final void Function(int) onToggleDirection;
  final List<String> availableCols;
  final void Function(BuildContext) onColumnsPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _searchBox(),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                _buildSortLevel(0, '1st'),
                const SizedBox(width: 12),
                _buildSortLevel(1, '2nd'),
                const SizedBox(width: 12),
                _buildSortLevel(2, '3rd'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (ctx) => _chip(
              ctx,
              Icons.view_column_outlined,
              'Columns',
              () => onColumnsPressed(ctx),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortLevel(int level, String label) {
    final spec = level < sortSpecs.length ? sortSpecs[level] : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        )),
        const SizedBox(width: 6),
        SizedBox(
          width: 90,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true,
              value: spec?.column,
              hint: const Text('None', style: TextStyle(fontSize: 10)),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              icon: Icon(Icons.arrow_drop_down, size: 14, color: theme.colorScheme.onSurfaceVariant),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('None', style: TextStyle(fontSize: 10))),
                ...availableCols.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(_kColLabels[c] ?? c, style: const TextStyle(fontSize: 10)),
                )),
              ],
              onChanged: (val) => onSortLevel(level, val),
            ),
          ),
        ),
        if (spec != null)
          IconButton(
            icon: Icon(spec.ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 12),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            onPressed: () => onToggleDirection(level),
          ),
      ],
    );
  }

  Widget _searchBox() => SizedBox(
        width: 200,
        height: 28,
        child: TextField(
          controller: searchCtrl,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLowest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            hintText: 'Search…',
            hintStyle: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            prefixIcon: Icon(Icons.search, size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 28, minHeight: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      );

  Widget _chip(BuildContext ctx, IconData icon, String label, VoidCallback onTap,
          {bool active = false}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 15,
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 5),
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ),
      );
}

class _FilterStrip extends StatelessWidget {
  const _FilterStrip({
    required this.theme,
    required this.filterActive,
    required this.filterLabel,
    required this.onQuickFilter,
    required this.onClearFilter,
  });

  final ThemeData theme;
  final bool filterActive;
  final String? filterLabel;
  final VoidCallback onQuickFilter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _quickFilterChip(),
          if (filterActive) ...[
            const SizedBox(width: 12),
            _filterBadge(),
          ],
        ],
      ),
    );
  }

  Widget _quickFilterChip() {
    final active = filterActive;
    return InkWell(
      onTap: onQuickFilter,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: active
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, size: 12,
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text('Quick Filter',
                style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  Widget _filterBadge() => InkWell(
        onTap: onClearFilter,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(filterLabel ?? '',
                  style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.close, size: 10,
                  color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      );
}

// ── Status bar ────────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.totalFixtures,
    required this.visibleCount,
    required this.filterActive,
    required this.showName,
    required this.theme,
  });

  final int totalFixtures;
  final int visibleCount;
  final bool filterActive;
  final String showName;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 7, color: Colors.green),
          const SizedBox(width: 8),
          Text('LOCAL',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: muted, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (filterActive) ...[
            Text('$visibleCount of $totalFixtures fixtures',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600)),
          ] else ...[
            Text('$totalFixtures fixtures',
                style: theme.textTheme.labelSmall?.copyWith(color: muted)),
          ],
          const Spacer(),
          if (showName.isNotEmpty)
            Text(showName,
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
