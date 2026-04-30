import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

import '../../repositories/fixture_repository.dart';
import '../../providers/show_provider.dart';
import 'column_spec.dart';
import 'fixture_data_source.dart';
import 'spreadsheet_view_controller.dart';
import 'widgets/sidebar.dart';
import 'widgets/toolbar.dart';
import 'widgets/status_bar.dart';
import 'widgets/column_picker.dart';
import 'widgets/presets_strip.dart';
import 'widgets/collection_editor_dialog.dart';
import 'column_provider.dart';
import '../../repositories/custom_field_repository.dart';

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
  
  // Track if the selection just changed to avoid triggering edit on the first click.
  bool _selectionJustChanged = false;
  
  // Separate notifier for sidebar selection — never triggers a DataGrid rebuild.
  final ValueNotifier<FixtureRow?> _sidebarSelection = ValueNotifier(null);
  
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    // Initialize Data Source
    _source = FixtureDataSource(
      columns: ref.read(allColumnsProvider),
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
      columns: ref.read(allColumnsProvider),
      customFieldRepo: ref.read(customFieldRepoProvider),
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
    _horizontalScrollController.dispose();
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
          columns: ref.read(allColumnsProvider),
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
      items: <PopupMenuEntry>[
        PopupMenuItem(
          onTap: () => _showMaintenanceLogDialog(fixture),
          child: const ListTile(
            leading: Icon(Icons.flag_outlined),
            title: Text('Log Maintenance / Flag'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () => _controller.deleteFixture(fixture),
          child: const ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete Fixture', style: TextStyle(color: Colors.red)),
            dense: true,
          ),
        ),
      ],
    );
  }

  void _showMaintenanceLogDialog(FixtureRow fixture) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log Maintenance: Ch ${fixture.channel ?? "—"}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Describe the issue or work performed. This will flag the fixture for review.'),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Lamp burnt out, Lens dirty...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final repo = ref.read(operationalRepoProvider);
              if (repo != null && ctrl.text.isNotEmpty) {
                await repo.logMaintenance(
                  fixtureId: fixture.id,
                  description: ctrl.text,
                  userId: 'local-user', // TODO: real user
                );
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Log & Flag'),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    _source.setSelectedCell(null, null);
    _sidebarSelection.value = null;
    _controller.gridController.selectedIndex = -1;
    _controller.gridController.selectedRow = null;
    _controller.gridController.moveCurrentCellTo(RowColumnIndex(-1, -1));
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
    _selectionJustChanged = true;
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
    final columns = ref.watch(allColumnsProvider);

    // Update Data Source
    _source.setColumns(columns);
    _source.updateData(fixtures);
    _source.updateRevisionState(pendingIds, conflictIds);
    _source.setTheme(theme);
    
    _controller.updateColumns(columns);

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
                      isAddMode: _controller.isAddMode,
                      addDraft: _controller.isAddMode ? _controller.addDraft : null,
                      continueAdding: _controller.continueAdding,
                      copySelected: _controller.copySelected,
                      lastEditedAddField: _controller.lastEditedAddField,
                      onEnterAddMode: () => _controller.enterAddMode(donor: sel),
                      onCancelAddMode: _controller.cancelAddMode,
                      onSubmitAdd: () => _controller.submitAddFixture(),
                      onContinueAddingChanged: _controller.setContinueAdding,
                      onCopySelectedChanged: _controller.setCopySelected,
                      onDraftEdit: (colId, val) {
                        _controller.updateDraftField(colId, val);
                      },
                      onDelete: () { if (sel != null) _controller.deleteFixture(sel); },
                      onEdit: (col, val) =>
                          sel != null ? _controller.editCell(sel, col, val, null) : Future.value(),
                      columns: columns,
                      repo: ref.read(fixtureRepoProvider)!,
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
                      // Scrollable Grid Area
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final totalGridWidth = _controller.visibleColOrder.fold(0.0, (sum, id) {
                              return sum + (_controller.colWidths[id] ?? kColumnById[id]?.defaultWidth ?? 100.0);
                            });

                            final contentWidth = totalGridWidth > constraints.maxWidth 
                                ? totalGridWidth 
                                : constraints.maxWidth;

                            return Scrollbar(
                              controller: _horizontalScrollController,
                              thumbVisibility: true,
                              child: SingleChildScrollView(
                                controller: _horizontalScrollController,
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  color: theme.colorScheme.surface, // Actual grid area color
                                  width: contentWidth,
                                  child: Column(
                                    children: [
                                      Listener(
                                        onPointerDown: (e) {
                                          if (e.buttons == 1 || e.buttons == 2) _clearSelection();
                                        },
                                        child: SpreadsheetToolbar(
                                          theme: theme,
                                          searchCtrl: _controller.searchController,
                                          sortSpecs: _controller.sortSpecs,
                                          onSortLevel: _controller.setSortLevel,
                                          onToggleDirection: _controller.toggleSortDirection,
                                          availableCols: kDefaultColumnOrder.where((c) => !_controller.hiddenCols.contains(c) && c != '#').toList(),
                                          onColumnsPressed: _showColumnPicker,
                                          onDeselect: _clearSelection,
                                          groupBySort1: _controller.groupBySort1,
                                          onGroupBySort1Changed: (val) => _controller.setGroupBySort1(val ?? false),
                                        ),
                                      ),
                                      Expanded(
                                        child: SfDataGridTheme(
                                          data: SfDataGridThemeData(
                                            headerColor: theme.colorScheme.surfaceContainerLow,
                                            gridLineColor: theme.colorScheme.outlineVariant,
                                            selectionColor: theme.brightness == Brightness.dark
                                                ? const Color(0xFF42451A).withValues(alpha: 0.8)
                                                : theme.colorScheme.primary.withValues(alpha: 0.1),
                                          ),
                                          child: SfDataGrid(
                                            controller: _controller.gridController,
                                            source: _source,
                                            allowSorting: true, 
                                            allowMultiColumnSorting: true,
                                            allowExpandCollapseGroup: true,
                                            allowFiltering: false,
                                            allowEditing: true,
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
                                                final from = args.from;
                                                final to = args.to;
                                                if (from != null && to != null) {
                                                  _controller.reorderVisibleColumn(from, to);
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
                                              
                                              // Capture previous selection to detect "click again to edit"
                                              final prevFixtureId = _source.selectedFixture?.id;
                                              final prevColName = _source.selectedColName;
                                              final selectionJustChangedNow = _selectionJustChanged;

                                              _syncSelectionFromRowCol(rci);
                                              
                                              final rowIdx = rci.rowIndex - 1;
                                              final fixture = rowIdx >= 0 && rowIdx < _source.rows.length
                                                  ? _source.fixtureForRow(_source.rows[rowIdx])
                                                  : null;
                                              final colIdx = rci.columnIndex;
                                              final colName = colIdx >= 0 && colIdx < _controller.visibleColOrder.length
                                                  ? _controller.visibleColOrder[colIdx]
                                                  : null;

                                              final wasAlreadySelected = !selectionJustChangedNow &&
                                                  fixture != null &&
                                                  prevFixtureId == fixture.id &&
                                                  prevColName == colName;
                                              
                                              _selectionJustChanged = false;

                                              if (wasAlreadySelected) {
                                                final colById = ref.read(columnByIdProvider);
                                                final spec = colById[colName];
                                                if (spec?.isCollection ?? false) {
                                                  // Launch collection editor
                                                  final kind = _getCollectionKind(colName!);
                                                  if (kind != null) {
                                                    // partOrder check for child rows
                                                    final partOrder = _source.partOrderByRow(_source.rows[rowIdx]);
                                                    final partId = partOrder != null 
                                                        ? fixture.parts.firstWhere((p) => p.partOrder == partOrder).id
                                                        : null;

                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => CollectionEditorDialog(
                                                        fixtureId: fixture.id,
                                                        kind: kind,
                                                        partId: partId,
                                                        repo: ref.read(fixtureRepoProvider)!,
                                                      ),
                                                    );
                                                  }
                                                } else {
                                                  _controller.gridController.beginEdit(RowColumnIndex(rci.rowIndex - 1, rci.columnIndex));
                                                }
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
                                      // ── SEMI-TRANSPARENT SCROLLBAR TRACK ─────────
                                      Container(
                                        height: 11, // 1px less than 12
                                        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Fixed Presets & Status Bars
                      SpreadsheetPresetsStrip(
                        theme: theme,
                        presets: presets,
                        controller: _controller,
                        onCreatePressed: _showCreatePresetDialog,
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
                      Listener(
                        onPointerDown: (e) {
                          if (e.buttons == 1 || e.buttons == 2) _clearSelection();
                        },
                        child: SpreadsheetStatusBar(
                          totalFixtures: fixtures.length,
                          visibleCount: _source.rows.length,
                          filterActive: _controller.filterActive,
                          showName: showName,
                          theme: theme,
                        ),
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

  CollectionKind? _getCollectionKind(String colId) {
    if (colId == 'color') return CollectionKind.gel;
    if (colId == 'gobo') return CollectionKind.gobo;
    if (colId == 'accessories') return CollectionKind.accessory;
    return null;
  }
}
