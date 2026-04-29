import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../../database/database.dart';
import '../../repositories/fixture_repository.dart';
import '../../repositories/show_meta_repository.dart';
import '../../repositories/spreadsheet_view_preset_repository.dart';
import '../../providers/show_provider.dart';
import 'column_spec.dart';
import 'fixture_data_source.dart';
import 'spreadsheet_view_controller.dart';
import 'widgets/sidebar.dart';
import 'widgets/toolbar.dart';
import 'widgets/filter_strip.dart';
import 'widgets/status_bar.dart';
import 'widgets/column_picker.dart';
import 'widgets/presets_strip.dart';

// ── SPREADSHEET ARCHITECTURE ────────────────────────────────────────────────
// This file acts as the orchestrator for the spreadsheet tab.
// It coordinates between the SpreadsheetViewController (business logic),
// the FixtureDataSource (data adapter), and various UI components.
// ─────────────────────────────────────────────────────────────────────────────

class SpreadsheetTab extends ConsumerStatefulWidget {
  const SpreadsheetTab({super.key});

  @override
  ConsumerState<SpreadsheetTab> createState() => _SpreadsheetTabState();
}

class _SpreadsheetTabState extends ConsumerState<SpreadsheetTab> {
  late final FixtureDataSource _source;
  late final SpreadsheetViewController _controller;
  
  // Separate notifier for sidebar selection — never triggers a DataGrid rebuild.
  final ValueNotifier<FixtureRow?> _sidebarSelection = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    
    // Initialize Data Source
    _source = FixtureDataSource(
      onCellEditCommit: (f, col, val, part) => _controller.editCell(f, col, val, part),
      onBooleanSet: (f, col, val) async {
        final repo = ref.read(fixtureRepoProvider);
        if (repo == null) return;
        switch (col) {
          case 'patch':   await repo.setPatched(f.id, value: val); break;
          case 'hung':    await repo.setHung(f.id, value: val); break;
          case 'focused': await repo.setFocused(f.id, value: val); break;
        }
      },
      onNativeEditStart: (f, col) {
        // Any logic needed when native grid editing starts
      },
      onNativeEditComplete: () {
        // Any logic needed when native grid editing completes
      },
    );

    // Initialize Controller
    _controller = SpreadsheetViewController(
      repo: ref.read(fixtureRepoProvider)!,
      presetRepo: ref.read(spreadsheetViewPresetRepoProvider),
      dataSource: _source,
    );

    _controller.addListener(_onControllerChanged);

    // Seed defaults for presets if needed
    Future.microtask(() async {
      final repo = ref.read(spreadsheetViewPresetRepoProvider);
      await repo?.seedDefaults();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _source.dispose();
    _sidebarSelection.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _showColumnPicker(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final pos = renderBox.localToGlobal(Offset.zero);

    showMenu<Never>(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy + 40, pos.dx + 200, pos.dy + 400),
      elevation: 8,
      items: [
        ColumnPickerMenuEntry(
          hidden: _controller.hiddenCols,
          onChanged: (hidden) => _controller.setHiddenCols(hidden),
        ),
      ],
    );
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
      await _controller.savePreset(name);
    }
  }

  void _showFixtureContextMenu(Offset pos, FixtureRow fixture) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 1, pos.dy + 1),
      items: [
        PopupMenuItem(
          onTap: () => _controller.cloneFixture(fixture),
          child: const ListTile(
            leading: Icon(Icons.copy),
            title: Text('Clone Fixture'),
            dense: true,
          ),
        ),
        PopupMenuItem(
          onTap: () => _controller.deleteFixture(fixture),
          child: ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Fixture', style: TextStyle(color: Colors.red)),
            dense: true,
          ),
        ),
      ],
    );
  }

  void _syncSelectionFromRowCol(RowColumnIndex rci) {
    final rowIdx = rci.rowIndex - 1;
    if (rowIdx < 0 || rowIdx >= _source.rows.length) return;
    final row = _source.rows[rowIdx];
    final fixture = _source.fixtureForRow(row);
    if (fixture == null) return;

    String? colName;
    final colIdx = rci.columnIndex;
    if (colIdx >= 0 && colIdx < _controller.visibleColOrder.length) {
      colName = _controller.visibleColOrder[colIdx];
    }

    _source.setSelectedCell(fixture.id, colName);
    _sidebarSelection.value = fixture;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Watch relevant providers
    final fixtures = ref.watch(fixtureRowsProvider).valueOrNull ?? [];
    final presets = ref.watch(spreadsheetViewPresetsProvider).valueOrNull ?? [];
    final pendingIds = ref.watch(pendingFixtureIdsProvider).valueOrNull ?? {};
    final conflictIds = ref.watch(conflictFixtureIdsProvider).valueOrNull ?? {};
    final showName = ref.watch(currentShowMetaProvider).valueOrNull?.showName ?? '';

    // Update Data Source
    _source.updateRows(fixtures);
    _source.updateRevisionState(pendingIds, conflictIds);
    _source.setTheme(theme);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Sidebar ───────────────────────────────────────────────────
              Container(
                width: 220,
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: theme.colorScheme.outlineVariant)),
                  color: theme.colorScheme.surfaceContainerLow,
                ),
                child: ListenableBuilder(
                  listenable: Listenable.merge([_source, _sidebarSelection]),
                  builder: (ctx, _) {
                    final sel = _source.selectedFixture;
                    return SpreadsheetSidebar(
                      theme: theme,
                      selected: sel,
                      canClone: sel != null,
                      onAdd: _controller.addFixture,
                      onClone: () { if (sel != null) _controller.cloneFixture(sel); },
                      onDelete: () { if (sel != null) _controller.deleteFixture(sel); },
                      onEdit: (col, val) =>
                          sel != null ? _controller.editCell(sel, col, val, null) : Future.value(),
                    );
                  },
                ),
              ),

              // ── Main Content Area ──────────────────────────────────────────
              Expanded(
                child: Material(
                  color: theme.colorScheme.surface,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      SpreadsheetToolbar(
                        theme: theme,
                        searchCtrl: _controller.searchController,
                        sortSpecs: _controller.sortSpecs,
                        onSortLevel: _controller.setSortLevel,
                        onToggleDirection: _controller.toggleSortDirection,
                        availableCols: kDefaultColumnOrder.where((c) => !_controller.hiddenCols.contains(c) && c != '#').toList(),
                        onColumnsPressed: _showColumnPicker,
                      ),
                      SpreadsheetFilterStrip(
                        theme: theme,
                        filterActive: _controller.filterActive,
                        filterLabel: _controller.filterLabel,
                        onQuickFilter: () {
                           final selCol = _source.selectedColName;
                           final selVal = _source.selectedCellValue;
                           if (selCol != null && selVal != null) {
                             _controller.applyQuickFilter(selCol, selVal);
                           }
                        },
                        onClearFilter: _controller.clearFilter,
                      ),
                      Expanded(
                        child: SfDataGridTheme(
                          data: SfDataGridThemeData(
                            headerColor: theme.colorScheme.surfaceContainerLow,
                            gridLineColor: theme.colorScheme.outlineVariant,
                          ),
                          child: SfDataGrid(
                            controller: _controller.gridController,
                            source: _source,
                            allowSorting: true, 
                            allowMultiColumnSorting: true,
                            allowFiltering: false,
                            allowColumnsResizing: true,
                            allowColumnsDragging: true,
                            onColumnResizeUpdate: (args) {
                              _controller.updateColumnWidth(args.column.columnName, args.width);
                              return true;
                            },
                            onColumnSortChanged: (newCol, oldCol) {
                              _controller.syncFromGridSort();
                            },
                            onColumnDragging: (args) {
                              if (args.action == DataGridColumnDragAction.dropped) {
                                if (args.from != null && args.to != null) {
                                  _controller.reorderVisibleColumn(args.from!, args.to!);
                                }
                              }
                              return true;
                            },
                            selectionMode: SelectionMode.single,
                            navigationMode: GridNavigationMode.cell,
                            columnWidthMode: ColumnWidthMode.none,
                            headerRowHeight: 32,
                            rowHeight: 28,
                            gridLinesVisibility: GridLinesVisibility.both,
                            headerGridLinesVisibility: GridLinesVisibility.both,
                            columns: _controller.visibleColOrder.map((id) {
                              final spec = kColumnById[id]!;
                              return GridColumn(
                                columnName: id,
                                width: _controller.colWidths[id] ?? spec.defaultWidth,
                                autoFitPadding: const EdgeInsets.symmetric(horizontal: 8),
                                label: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    spec.label,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              );
                            }).toList(),
                            onCellTap: (details) {
                              final rci = details.rowColumnIndex;
                              _syncSelectionFromRowCol(rci);
                              
                              final rowIdx = rci.rowIndex - 1;
                              final fixture = rowIdx >= 0 && rowIdx < _source.rows.length
                                  ? _source.fixtureForRow(_source.rows[rowIdx])
                                  : null;
                              final colIdx = rci.columnIndex;
                              final colName = colIdx >= 0 && colIdx < _controller.visibleColOrder.length
                                  ? _controller.visibleColOrder[colIdx]
                                  : null;

                              final wasSelected = fixture != null &&
                                  _source.selectedFixture?.id == fixture.id &&
                                  _source.selectedColName == colName;

                              if (wasSelected) {
                                _controller.gridController.beginEdit(rci);
                              }
                            },
                            onCurrentCellActivated: (_, current) => _syncSelectionFromRowCol(current),
                            onCellSecondaryTap: (details) {
                              _syncSelectionFromRowCol(details.rowColumnIndex);
                              final rowIdx = details.rowColumnIndex.rowIndex - 1;
                              if (rowIdx < 0 || rowIdx >= _source.rows.length) return;
                              final fixture = _source.fixtureForRow(_source.rows[rowIdx]);
                              if (fixture != null) _showFixtureContextMenu(details.globalPosition, fixture);
                            },
                          ),
                        ),
                      ),
                      SpreadsheetPresetsStrip(
                        theme: theme,
                        presets: presets,
                        controller: _controller,
                        onCreatePressed: _showCreatePresetDialog,
                      ),
                      SpreadsheetStatusBar(
                        totalFixtures: fixtures.length,
                        visibleCount: _source.rows.length,
                        filterActive: _controller.filterActive,
                        showName: showName,
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
