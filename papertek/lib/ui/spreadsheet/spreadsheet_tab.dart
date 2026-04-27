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

const _kReadOnlyCols = {'#', 'dimmer', 'circuit', 'patch', 'hung', 'focused'};
const _kNumericCols  = {'#', 'chan', 'unit'};
const _kAlwaysVisible = {'#'};

const _kPrefsWidthKey = 'papertek.colWidths.v1';
const _kMinimalSpreadsheetMode = true;

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
  final Future<void> Function(FixtureRow fixture, String col, String? value)
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

  // ── Public API ──────────────────────────────────────────────────────────

  void setVisibleCols(List<String> cols) => _visibleCols = cols;

  void setSelectedCell(int? fixtureId, String? colName) {
    _selectedFixtureId = fixtureId;
    _selectedColName   = colName;
    // No notifyListeners() — caller uses a separate ValueNotifier for sidebar
    // so the DataGrid is never rebuilt on tap, keeping double-tap intact.
  }

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
    final bg     = sel ? _bgSel : (isEven ? Colors.transparent : _bgAlt);

    Widget cell(String colName, String text, Color color, {bool bold = false}) {
      final isSelectedCell = sel && colName == _selectedColName;
      return Container(
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
      color: bg,
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
  double _lastNotesWidth = 120.0;
  bool _isEditingGridCell = false;
  List<FixtureRow>? _deferredRowsWhileEditing;

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
    _minimalSource = _MinimalFixtureSource(onCellEditCommit: _onEdit);
    _source.onSortChanged = () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    };
    _searchCtrl.addListener(_onSearchChanged);
    _loadColWidths();
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
          onChanged: (hidden) => setState(() => _hiddenCols = hidden),
        ),
      ],
    );
  }

  // ── Data edit handler ─────────────────────────────────────────────────────

  Future<void> _onEdit(FixtureRow fixture, String col, String? value) async {
    final repo = ref.read(fixtureRepoProvider);
    if (repo == null) return;
    switch (col) {
      case 'chan':
        return repo.updateIntensityChannel(fixture.id, value);
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
          width:      name == 'notes' ? notesWidth : _colWidths[name]!,
          minimumWidth: 32,
          allowEditing: !_kReadOnlyCols.contains(name),
          allowSorting: name != '#',
          label: hdr(name, _kColLabels[name]!),
        ),
    ];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _source.setTheme(theme);
    _source.setVisibleCols(_visibleColOrder);
    _minimalSource.setTheme(theme);
    _minimalSource.setVisibleCols(_visibleColOrder);

    final fixtures    = ref.watch(fixtureRowsProvider).valueOrNull ?? [];
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
                    onEdit: (col, val) =>
                        sel != null ? _onEdit(sel, col, val) : Future.value(),
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
                      filterActive: filterActive,
                      filterLabel: filterActive
                          ? '${_kColLabels[_filterCol!] ?? _filterCol!}: $_filterValue'
                          : null,
                      onQuickFilter: _applyQuickFilter,
                      onClearFilter: _clearFilter,
                      onColumnsPressed: _showColumnPicker,
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
                                setState(() {});
                                _saveColWidths();
                              },
                              onColumnDragging: (details) {
                                if (details.action != DataGridColumnDragAction.dropped ||
                                    details.from == null ||
                                    details.to == null) {
                                  return true;
                                }
                                final from = details.from!;
                                final to = details.to!;
                                if (from == to ||
                                    from < 0 ||
                                    to < 0 ||
                                    from >= _visibleColOrder.length ||
                                    to >= _visibleColOrder.length) {
                                  return true;
                                }

                                final visible = List<String>.from(_visibleColOrder);
                                final moved = visible.removeAt(from);
                                visible.insert(to, moved);
                                final hidden = _colOrder.where(_hiddenCols.contains).toList();
                                setState(() {
                                  _colOrder = [...visible, ...hidden];
                                });
                                return true;
                              },
                              onCellTap: (details) {
                                _syncMinimalSelectionFromRowCol(details.rowColumnIndex);
                              },
                              onCurrentCellActivated: (_, current) {
                                _syncMinimalSelectionFromRowCol(current);
                              },
                            ),
                          );
                        },
                      ),
                    ),
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
              onEdit: (col, val) =>
                  sel != null ? _onEdit(sel, col, val) : Future.value(),
            );
          },
        ),
        Expanded(
          child: Column(
            children: [
              _Toolbar(
                theme: theme,
                searchCtrl: _searchCtrl,
                filterActive: filterActive,
                filterLabel: filterActive
                    ? '${_kColLabels[_filterCol!] ?? _filterCol!}: $_filterValue'
                    : null,
                onQuickFilter: _applyQuickFilter,
                onClearFilter: _clearFilter,
                onColumnsPressed: _showColumnPicker,
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
                        currentCellStyle: DataGridCurrentCellStyle(
                          borderColor: theme.colorScheme.primary.withValues(alpha: 0.6),
                          borderWidth: 1,
                        ),
                      ),
                      child: SfDataGrid(
                        key: _dataGridKey,
                        source: _minimalSource,
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
                          final rowIdx = details.rowColumnIndex.rowIndex - 1;
                          if (rowIdx < 0 || rowIdx >= _minimalSource.rows.length) return;
                          final fixture = _minimalSource.fixtureForRow(_minimalSource.rows[rowIdx]);
                          if (fixture == null) return;
                          _minimalSource.setSelectedCell(
                            fixture.id,
                            details.column.columnName,
                          );
                          _sidebarSelection.value = fixture;
                        },
                      ),
                    );
                  },
                ),
              ),
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
    final fixture = _minimalSource.fixtureForRow(_minimalSource.rows[rowIdx]);
    if (fixture == null) return;

    String? colName;
    final colIdx = rci.columnIndex - 1;
    if (colIdx >= 0 && colIdx < _visibleColOrder.length) {
      colName = _visibleColOrder[colIdx];
    }

    _minimalSource.setSelectedCell(fixture.id, colName);
    _sidebarSelection.value = fixture;
  }
}

class _MinimalFixtureSource extends DataGridSource {
  _MinimalFixtureSource({required this.onCellEditCommit});

  final Future<void> Function(FixtureRow fixture, String col, String? value)
      onCellEditCommit;

  List<FixtureRow> _allFixtures = [];
  List<FixtureRow> _filteredFixtures = [];

  final Map<DataGridRow, FixtureRow> _rowToFixture = {};
  List<DataGridRow> _rows = [];
  List<String> _visibleCols = List.of(_kColOrder);

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

  void setVisibleCols(List<String> cols) {
    _visibleCols = cols;
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

    _filteredFixtures = list.toList();
    _rowToFixture.clear();
    _rows = _filteredFixtures.map((f) {
      final row = DataGridRow(cells: [
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
      _rowToFixture[row] = f;
      return row;
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final fixture = _rowToFixture[row];
    final index = _rows.indexOf(row);
    final selected = fixture != null && fixture.id == _selectedFixtureId;
    final bg = selected ? _bgSel : (index.isEven ? Colors.transparent : _bgAlt);

    final byName = {
      for (final cell in row.getCells()) cell.columnName: cell.value?.toString() ?? '',
    };
    return DataGridRowAdapter(
      color: bg,
      cells: _visibleCols.map((name) {
        final isSelectedCell = selected && name == _selectedColName;
        var color = _textMain;
        var bold = false;
        switch (name) {
          case '#':
            color = selected ? _textMain : _textMuted;
            bold = selected;
            break;
          case 'chan':
            color = _accent;
            bold = true;
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
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            byName[name] ?? '',
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
    final col = column.columnName;
    if (_kReadOnlyCols.contains(col)) return null;
    final fixture = _rowToFixture[row];
    if (fixture == null) return null;

    final initial = switch (col) {
      'chan' => fixture.channel ?? '',
      'position' => fixture.position ?? '',
      'unit' => fixture.unitNumber?.toString() ?? '',
      'type' => fixture.fixtureType ?? '',
      'function' => fixture.function ?? '',
      'focus' => fixture.focus ?? '',
      'accessories' => fixture.accessories ?? '',
      'ip' => fixture.ipAddress ?? '',
      'subnet' => fixture.subnet ?? '',
      'mac' => fixture.macAddress ?? '',
      'ipv6' => fixture.ipv6 ?? '',
      _ => '',
    };

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
        onChanged: (value) => _newCellValue = value,
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
    if (_kReadOnlyCols.contains(col)) return;

    final nextText = (_newCellValue ?? _editingController?.text ?? '').trim();
    _editingController?.dispose();
    _editingController = null;
    _newCellValue = null;

    switch (col) {
      case 'chan':
        await onCellEditCommit(fixture, 'chan', nextText.isEmpty ? null : nextText);
        break;
      case 'position':
        await onCellEditCommit(fixture, 'position', nextText.isEmpty ? null : nextText);
        break;
      case 'unit':
        await onCellEditCommit(fixture, 'unit', nextText.isEmpty ? null : nextText);
        break;
      case 'type':
        await onCellEditCommit(fixture, 'type', nextText.isEmpty ? null : nextText);
        break;
      case 'function':
        await onCellEditCommit(
          fixture,
          'function',
          nextText.isEmpty ? null : nextText,
        );
        break;
      case 'focus':
        await onCellEditCommit(fixture, 'focus', nextText.isEmpty ? null : nextText);
        break;
      case 'accessories':
        await onCellEditCommit(
          fixture,
          'accessories',
          nextText.isEmpty ? null : nextText,
        );
        break;
      case 'ip':
        await onCellEditCommit(fixture, 'ip', nextText.isEmpty ? null : nextText);
        break;
      case 'subnet':
        await onCellEditCommit(fixture, 'subnet', nextText.isEmpty ? null : nextText);
        break;
      case 'mac':
        await onCellEditCommit(fixture, 'mac', nextText.isEmpty ? null : nextText);
        break;
      case 'ipv6':
        await onCellEditCommit(fixture, 'ipv6', nextText.isEmpty ? null : nextText);
        break;
      default:
        return;
    }
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
    required this.onEdit,
  });

  final ThemeData theme;
  final FixtureRow? selected;
  final bool canClone;
  final VoidCallback onAdd;
  final VoidCallback onClone;
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
    required this.filterActive,
    required this.filterLabel,
    required this.onQuickFilter,
    required this.onClearFilter,
    required this.onColumnsPressed,
  });

  final ThemeData theme;
  final TextEditingController searchCtrl;
  final bool filterActive;
  final String? filterLabel;
  final VoidCallback onQuickFilter;
  final VoidCallback onClearFilter;
  // Receives the button's BuildContext so showMenu can position correctly.
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
          const SizedBox(width: 8),
          _quickFilterChip(),
          if (filterActive) ...[
            const SizedBox(width: 4),
            _filterBadge(),
          ],
          const Spacer(),
          // Builder captures the chip's own RenderObject for menu positioning.
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

  Widget _quickFilterChip() {
    final active = filterActive;
    return InkWell(
      onTap: onQuickFilter,
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
            Icon(Icons.filter_alt_outlined, size: 14,
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 5),
            Text('Quick Filter',
                style: theme.textTheme.labelSmall?.copyWith(
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
          height: 22,
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
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.close, size: 12,
                  color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      );

  Widget _chip(BuildContext ctx, IconData icon, String label, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon, size: 15,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 5),
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
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
