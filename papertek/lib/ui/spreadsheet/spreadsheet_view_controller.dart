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
import '../../../repositories/fixture_repository.dart';
import '../../../repositories/spreadsheet_view_preset_repository.dart';
import 'column_spec.dart';
import 'fixture_data_source.dart';

class SpreadsheetViewController extends ChangeNotifier {
  SpreadsheetViewController({
    required this.repo,
    required this.presetRepo,
    required this.dataSource,
  }) {
    _init();
  }

  final FixtureRepository repo;
  final SpreadsheetViewPresetRepository? presetRepo;
  final FixtureDataSource dataSource;

  // ── Grid State ─────────────────────────────────────────────────────────────
  final DataGridController gridController = DataGridController();
  final TextEditingController searchController = TextEditingController();

  List<String> colOrder = List.from(kDefaultColumnOrder);
  Set<String> hiddenCols = {};
  Map<String, double> colWidths = Map.from(kDefaultWidths);
  List<SortSpec> sortSpecs = [];

  SpreadsheetViewPreset? activePreset;
  bool isPresetDirty = false;

  // ── Initialization ──────────────────────────────────────────────────────────
  void _init() {
    searchController.addListener(_onSearchChanged);
    dataSource.onSortChanged = _onDataSourceSortChanged;
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
  String? get filterLabel => _filterCol != null ? '${kColumnById[_filterCol!]?.label ?? _filterCol}: $_filterValue' : null;

  // ── Sorting ────────────────────────────────────────────────────────────────
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
    dataSource.setSortSpecs(sortSpecs);
    isPresetDirty = true;
    notifyListeners();
  }

  void toggleSortDirection(int level) {
    if (level < sortSpecs.length) {
      sortSpecs[level] = sortSpecs[level].toggle();
      dataSource.setSortSpecs(sortSpecs);
      isPresetDirty = true;
      notifyListeners();
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
      dataSource.setSortSpecs(sortSpecs);
    }
    
    dataSource.setVisibleCols(visibleColOrder);
    notifyListeners();
  }

  Map<String, dynamic> captureCurrentState() {
    return {
      'version': 1,
      'columnOrder': colOrder,
      'hiddenColumns': hiddenCols.toList(),
      'columnWidths': colWidths,
      'sorts': sortSpecs.map((s) => s.toJson()).toList(),
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

  Future<void> cloneFixture(FixtureRow fixture) async {
    await repo.cloneFixture(fixture.id);
  }

  Future<void> deleteFixture(FixtureRow fixture) async {
    await repo.deleteFixture(fixture.id);
  }

  Future<void> editCell(FixtureRow fixture, String col, String? value, int? partOrder) async {
    final spec = kColumnById[col];
    if (spec != null && spec.onEdit != null) {
      // Note: partOrder is currently handled by the data source for specific columns,
      // but here we centralize the update logic.
      await spec.onEdit!(fixture.id, value, repo);
    }
  }
}
