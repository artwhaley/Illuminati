/// ── SPREADSHEET VIEW CONTROLLER ──────────────────────────────────────────
///
/// This controller is the "Brain" of the spreadsheet tab. It manages all 
/// non-persistent view state that coordinates between multiple widgets.
///
/// RESPONSIBILITIES:
/// 1. Sorting & Filtering: Maintains multi-level sort specs and search state.
/// 2. Column Management: Handles visibility, ordering, and resizing.
/// 3. View Presets: Coordinates the loading, saving, and updating of 
///    [SpreadsheetViewPreset] objects.
/// 4. Action Delegation: Routes CRUD actions (Add/Clone/Delete) and cell 
///    edits to the appropriate repository.
///
/// DESIGN PATTERN:
/// By using a [ChangeNotifier] controller, we avoid "Prop Drilling" and ensure 
/// that the toolbar, sidebar, and grid always stay in sync without redundant 
/// rebuilds of the entire page.
/// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../../../database/database.dart';
import '../../repositories/fixture_repository.dart';
import '../../repositories/custom_field_repository.dart';
import '../../../repositories/spreadsheet_view_preset_repository.dart';
import 'column_spec.dart';
import 'fixture_data_source.dart';
import 'fixture_draft.dart';

class SpreadsheetViewController extends ChangeNotifier {
  SpreadsheetViewController({
    required this.repo,
    required this.presetRepo,
    required this.dataSource,
    required List<ColumnSpec> columns,
    this.customFieldRepo,
  }) : _columns = columns {
    _init();
  }

  final FixtureRepository repo;
  final SpreadsheetViewPresetRepository? presetRepo;
  final FixtureDataSource dataSource;
  final CustomFieldRepository? customFieldRepo;
  
  List<ColumnSpec> _columns;

  // ── Grid State ─────────────────────────────────────────────────────────────
  final DataGridController gridController = DataGridController();
  final TextEditingController searchController = TextEditingController();

  List<String> colOrder = [];
  Set<String> hiddenCols = {};
  Map<String, double> colWidths = {};
  List<SortSpec> sortSpecs = [SortSpec(column: 'chan', ascending: true)];

  // ── Add Fixture Mode ───────────────────────────────────────────────────────

  /// Whether the sidebar is currently in "Add Fixture" mode.
  bool isAddMode = false;

  /// The draft being composed in add mode. Null when not in add mode.
  FixtureDraft? addDraft;

  /// The sort order of the row we started adding from.
  double? _addDonorSortOrder;

  /// Whether to stay in add mode after a successful insert.
  bool continueAdding = false;

  /// Whether to copy the selected fixture's values when entering add mode.
  bool copySelected = true;

  /// The column ID of the last field the user edited in add mode.
  /// Used to restore focus after a continue-adding insert.
  String? lastEditedAddField;

  SpreadsheetViewPreset? activePreset;
  bool isPresetDirty = false;

  bool groupBySort1 = false;
  bool _groupingActive = false;

  void setGroupBySort1(bool enabled) {
    if (groupBySort1 == enabled) return;
    groupBySort1 = enabled;
    _syncGridGrouping();
    notifyListeners();
  }

  void _syncGridGrouping() {
    if (_groupingActive) {
      try {
        dataSource.clearColumnGroups();
      } catch (_) {
        // In some Syncfusion versions, this crashes if the grid isn't fully attached.
      }
      _groupingActive = false;
    }

    if (groupBySort1 && sortSpecs.isNotEmpty) {
      final sort1 = sortSpecs.first.column;
      try {
        dataSource.addColumnGroup(ColumnGroup(
          name: sort1,
          sortGroupRows: true,
        ));
        _groupingActive = true;
      } catch (_) {
        // Swallow if grid not ready
      }
    }
  }

  // ── Initialization ──────────────────────────────────────────────────────────
  void _init() {
    colOrder = _columns.map((c) => c.id).toList();
    colWidths = {for (final c in _columns) c.id: c.defaultWidth};

    searchController.addListener(_onSearchChanged);
    dataSource.onSortChanged = _onDataSourceSortChanged;
    // Initial sort sync
    _syncSortToDataSource();
    
    // Initial grouping sync - delay to allow grid to mount and avoid null-check crashes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (gridController.hashCode != 0) { // Tiny check to see if we're still alive
        _syncGridGrouping();
      }
    });
  }

  void updateColumns(List<ColumnSpec> columns) {
    _columns = columns;
    // Sync order: keep existing order, append new ones.
    final newOrder = List<String>.from(colOrder);
    final existingIds = Set<String>.from(colOrder);
    for (final c in columns) {
      if (!existingIds.contains(c.id)) {
        newOrder.add(c.id);
        colWidths[c.id] = c.defaultWidth;
      }
    }
    colOrder = newOrder;
    dataSource.setColumns(columns);
    notifyListeners();
  }

  void _syncSortToDataSource() {
    dataSource.sortedColumns.clear();
    for (final spec in sortSpecs) {
      dataSource.sortedColumns.add(SortColumnDetails(
        name: spec.column,
        sortDirection: spec.ascending ? DataGridSortDirection.ascending : DataGridSortDirection.descending,
      ));
    }
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    gridController.dispose();
    super.dispose();
  }

  // ── Actions ────────────────────────────────────────────────────────────────
  void _onSearchChanged() {
    dataSource.applyFilters(
      search: searchController.text,
      filterCol: _filterCol,
      filterValue: _filterValue,
    );
    notifyListeners();
  }

  void _onDataSourceSortChanged() {
    // Sync local sort specs if data source sorting changes externally
    // (though currently data source sort is driven by this controller)
  }

  String? _filterCol;
  String? _filterValue;

  void applyQuickFilter(String col, String value) {
    _filterCol = col;
    _filterValue = value;
    _onSearchChanged();
  }

  void clearFilter() {
    _filterCol = null;
    _filterValue = null;
    _onSearchChanged();
  }

  bool get filterActive => _filterCol != null || searchController.text.isNotEmpty;
  String? get filterLabel {
    if (_filterCol == null) return null;
    final spec = _columns.firstWhere((c) => c.id == _filterCol, orElse: () => ColumnSpec(id: _filterCol!, label: _filterCol!, defaultWidth: 100, getValue: (f) => null));
    return '${spec.label}: $_filterValue';
  }

  // ── Sorting ────────────────────────────────────────────────────────────────
  bool _isSyncingSort = false;

  void _syncGridSort() {
    if (_isSyncingSort) return;
    _isSyncingSort = true;
    try {
      dataSource.sortedColumns.clear();
      for (final s in sortSpecs) {
        dataSource.sortedColumns.add(SortColumnDetails(
          name: s.column,
          sortDirection: s.ascending ? DataGridSortDirection.ascending : DataGridSortDirection.descending,
        ));
      }
    } finally {
      _isSyncingSort = false;
    }
    notifyListeners();
  }

  void syncFromGridSort() {
    if (_isSyncingSort) return;
    _isSyncingSort = true;
    try {
      sortSpecs = dataSource.sortedColumns.map((s) => SortSpec(
        column: s.name,
        ascending: s.sortDirection == DataGridSortDirection.ascending,
      )).toList();
      _syncGridGrouping();
      isPresetDirty = true;
    } finally {
      _isSyncingSort = false;
    }
    notifyListeners();
  }

  void setSortLevel(int level, String? column) {
    if (column == null) {
      if (level < sortSpecs.length) {
        sortSpecs.removeRange(level, sortSpecs.length);
      }
    } else {
      final newSpec = SortSpec(column: column);
      if (level < sortSpecs.length) {
        sortSpecs[level] = newSpec;
        if (sortSpecs.length > level + 1) {
          sortSpecs.removeRange(level + 1, sortSpecs.length);
        }
      } else {
        sortSpecs.add(newSpec);
      }
    }
    _syncGridSort();
    _syncGridGrouping();
    isPresetDirty = true;
  }

  void toggleSortDirection(int level) {
    if (level < sortSpecs.length) {
      sortSpecs[level] = sortSpecs[level].toggle();
      _syncGridSort();
      _syncGridGrouping();
      isPresetDirty = true;
    }
  }

  // ── Columns ────────────────────────────────────────────────────────────────
  void setHiddenCols(Set<String> hidden) {
    hiddenCols = hidden;
    dataSource.setVisibleCols(visibleColOrder);
    isPresetDirty = true;
    notifyListeners();
  }

  List<String> get visibleColOrder => colOrder.where((c) => !hiddenCols.contains(c)).toList();

  void updateColumnWidth(String colId, double width) {
    colWidths[colId] = width;
    isPresetDirty = true;
    notifyListeners();
  }

  void reorderVisibleColumn(int fromIdx, int toIdx) {
    if (fromIdx == toIdx) return;
    final visible = visibleColOrder;
    if (fromIdx >= 0 && fromIdx < visible.length && toIdx >= 0 && toIdx < visible.length) {
      final colId = visible[fromIdx];
      
      // Move in the master colOrder
      final oldMasterIdx = colOrder.indexOf(colId);
      if (oldMasterIdx != -1) {
        colOrder.removeAt(oldMasterIdx);
        
        // Find the new master index. We want it to be placed at the 'toIdx' position
        // among the visible columns.
        final targetColId = visible[toIdx];
        final newMasterIdx = colOrder.indexOf(targetColId);
        
        // If we moved right, we want to insert after the target. 
        // If we moved left, we want to insert before the target.
        // Actually, List.insert inserts BEFORE the index.
        // If we removed the item, the indices of subsequent items shifted.
        
        if (fromIdx < toIdx) {
          colOrder.insert(newMasterIdx + 1, colId);
        } else {
          colOrder.insert(newMasterIdx, colId);
        }
        
        dataSource.setVisibleCols(visibleColOrder);
        isPresetDirty = true;
        notifyListeners();
      }
    }
  }

  // ── Presets ────────────────────────────────────────────────────────────────
  void applyPreset(SpreadsheetViewPreset preset) {
    final data = jsonDecode(preset.presetJson) as Map<String, dynamic>;
    activePreset = preset;
    isPresetDirty = false;

    if (data.containsKey('columnOrder')) {
      final storedOrder = List<String>.from(data['columnOrder']);
      final validStored = storedOrder.where((c) => kColumnById.containsKey(c)).toList();
      final implicitlyHidden = kDefaultColumnOrder.where((c) => !validStored.contains(c)).toList();
      colOrder = [...validStored, ...implicitlyHidden];
      hiddenCols = implicitlyHidden.toSet();
    }
    if (data.containsKey('hiddenColumns')) {
      hiddenCols = hiddenCols.union(Set<String>.from(data['hiddenColumns'] as List));
    }
    if (data.containsKey('columnWidths')) {
      final widths = Map<String, dynamic>.from(data['columnWidths']);
      for (final e in widths.entries) {
        if (kDefaultWidths.containsKey(e.key)) {
          colWidths[e.key] = (e.value as num).toDouble();
        }
      }
    }
    if (data.containsKey('sorts')) {
      final specs = (data['sorts'] as List).map((s) => SortSpec.fromJson(s as Map<String, dynamic>)).toList();
      sortSpecs = specs.where((s) => kColumnById.containsKey(s.column)).toList();
    }

    if (data.containsKey('groupBySort1')) {
      groupBySort1 = data['groupBySort1'] as bool;
    } else {
      groupBySort1 = false;
    }
    
    dataSource.setVisibleCols(visibleColOrder);
    _syncGridSort();
    _syncGridGrouping();
  }

  Map<String, dynamic> captureCurrentState() {
    return {
      'version': 1,
      'columnOrder': colOrder,
      'hiddenColumns': hiddenCols.toList(),
      'columnWidths': colWidths,
      'sorts': sortSpecs.map((s) => s.toJson()).toList(),
      'groupBySort1': groupBySort1,
    };
  }

  Future<void> savePreset(String name) async {
    final data = captureCurrentState();
    await presetRepo?.createPreset(name: name, presetData: data);
  }

  Future<void> updateActivePreset() async {
    if (activePreset == null) return;
    final data = captureCurrentState();
    await presetRepo?.updatePreset(activePreset!.id, data);
    isPresetDirty = false;
    notifyListeners();
  }

  Future<void> deletePreset(int id) async {
    await presetRepo?.deletePreset(id);
    if (activePreset?.id == id) {
      activePreset = null;
      isPresetDirty = false;
    }
    notifyListeners();
  }

  // ── Database Operations ────────────────────────────────────────────────────
  Future<void> addFixture() async {
    await repo.addFixture();
  }

  /// Enter add mode. If [donor] is provided and [copySelected] is true, prefill the draft.
  void enterAddMode({FixtureRow? donor}) {
    isAddMode = true;
    _addDonorSortOrder = donor?.sortOrder;
    addDraft = (donor != null && copySelected)
        ? FixtureDraft.fromDonor(donor, _allEditableFields())
        : FixtureDraft();
    notifyListeners();
  }

  Set<String> _allEditableFields() => _columns
      .where((c) => !c.isReadOnly && c.id != '#')
      .map((c) => c.id)
      .toSet();

  void setCopySelected(bool value) {
    copySelected = value;
    notifyListeners();
  }

  /// Exit add mode and discard the draft.
  void cancelAddMode() {
    isAddMode = false;
    addDraft = null;
    _addDonorSortOrder = null;
    notifyListeners();
  }



  void setContinueAdding(bool value) {
    continueAdding = value;
    notifyListeners();
  }

  /// Called from the sidebar "ADD FIXTURE" button.
  /// Inserts the current [addDraft] via the repository, then either
  /// stays in add mode (advance draft) or exits.
  Future<void> submitAddFixture() async {
    final draft = addDraft;
    if (draft == null) return;

    final newSort = await repo.addFixtureFromDraft(draft, afterSortOrder: _addDonorSortOrder);

    if (continueAdding) {
      draft.advanceForContinue();
      _addDonorSortOrder = newSort; // Next insert goes after this one
      // Trigger a rebuild so the sidebar editor reflects the updated draft.
      notifyListeners();
    } else {
      cancelAddMode();
    }
  }

  void updateDraftField(String colId, String? val) {
    final d = addDraft;
    if (d == null) return;
    switch (colId) {
      case 'chan':        d.channel     = val; break;
      case 'dimmer':      d.dimmer      = val; break;
      case 'circuit':     d.circuit     = val; break;
      case 'position':    d.position    = val; break;
      case 'unit':        d.unitNumber  = int.tryParse(val ?? ''); break;
      case 'type':        d.fixtureType = val; break;
      case 'function':    d.function    = val; break;
      case 'focus':       d.focus       = val; break;
      case 'accessories': d.accessories = val; break;
      case 'ip':          d.ipAddress   = val; break;
      case 'subnet':      d.subnet      = val; break;
      case 'mac':         d.macAddress  = val; break;
      case 'ipv6':        d.ipv6        = val; break;
    }
    lastEditedAddField = colId;
    notifyListeners();
  }



  Future<void> deleteFixture(FixtureRow fixture) async {
    await repo.deleteFixture(fixture.id);
  }

  Future<void> editCell(FixtureRow fixture, String col, String? value, int? partOrder) async {
    final spec = kColumnById[col];
    if (spec != null && spec.onEdit != null) {
      await spec.onEdit!(fixture.id, value, repo, partOrder: partOrder);
    }
  }
}
