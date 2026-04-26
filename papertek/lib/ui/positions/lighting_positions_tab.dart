import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/show_provider.dart';
import '../../repositories/position_repository.dart';

// ── Data model for the unified top-level list ──────────────────────────────────

sealed class _TopItem {
  int get sortOrder;
  String get listKey;
}

class _SinglePosition extends _TopItem {
  _SinglePosition(this.pos);
  final LightingPosition pos;
  @override
  int get sortOrder => pos.sortOrder;
  @override
  String get listKey => 'pos_${pos.id}';
}

class _GroupItem extends _TopItem {
  _GroupItem(this.group, this.members);
  final PositionGroup group;
  final List<LightingPosition> members;
  @override
  int get sortOrder => group.sortOrder;
  @override
  String get listKey => 'group_${group.id}';
}

// ── Tab widget ─────────────────────────────────────────────────────────────────

class LightingPositionsTab extends ConsumerStatefulWidget {
  const LightingPositionsTab({super.key});

  @override
  ConsumerState<LightingPositionsTab> createState() =>
      _LightingPositionsTabState();
}

class _LightingPositionsTabState extends ConsumerState<LightingPositionsTab> {
  final _selected = <String>{};
  final _scrollCtrl = ScrollController();
  double _toolbarPad = 8.0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_updateToolbarPad);
  }

  void _updateToolbarPad() {
    if (!mounted || !_scrollCtrl.hasClients) return;
    final t = (_scrollCtrl.offset / 280.0).clamp(0.0, 1.0);
    final newPad = 8.0 + t * 120.0;
    if ((newPad - _toolbarPad).abs() > 1.0) {
      setState(() => _toolbarPad = newPad);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Selection ────────────────────────────────────────────────────────────
  //
  // Left-click  → single-select (clears others); Ctrl+left-click → toggle.
  // Right-click → toggle (add / remove from multi-selection).

  void _primaryTap(String key) {
    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    setState(() {
      if (isCtrl) {
        _applyToggle(key);
      } else {
        _selected
          ..clear()
          ..add(key);
      }
    });
  }

  void _multiToggle(String key) => setState(() => _applyToggle(key));

  void _applyToggle(String key) {
    if (_selected.contains(key)) {
      _selected.remove(key);
    } else {
      _selected.add(key);
    }
  }

  Set<int> get _selectedPositionIds => _selected
      .where((k) => k.startsWith('pos_'))
      .map((k) => int.parse(k.substring(4)))
      .toSet();

  Set<int> get _selectedGroupIds => _selected
      .where((k) => k.startsWith('group_'))
      .map((k) => int.parse(k.substring(6)))
      .toSet();

  // ── List builder ─────────────────────────────────────────────────────────

  List<_TopItem> _buildTopItems(
    List<LightingPosition> positions,
    List<PositionGroup> groups,
  ) {
    final grouped = <int, List<LightingPosition>>{};
    final ungrouped = <LightingPosition>[];

    for (final pos in positions) {
      if (pos.groupId != null) {
        grouped.putIfAbsent(pos.groupId!, () => []).add(pos);
      } else {
        ungrouped.add(pos);
      }
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    final items = <_TopItem>[
      ...ungrouped.map(_SinglePosition.new),
      ...groups.map((g) => _GroupItem(g, grouped[g.id] ?? [])),
    ];
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  // ── Tool actions ─────────────────────────────────────────────────────────

  Future<void> _addPosition(PositionRepository repo) async {
    final name =
        await _nameDialog(context, title: 'New Position', hint: 'Position name');
    if (name == null) return;
    await repo.addPosition(name);
  }

  Future<void> _deleteSelected(
      PositionRepository repo, List<_TopItem> items) async {
    final posIds = _selectedPositionIds;
    final grpIds = _selectedGroupIds;
    if (posIds.isEmpty && grpIds.isEmpty) return;

    final ok = await _confirmDialog(
      context,
      title: 'Delete',
      message: 'Delete ${posIds.length + grpIds.length} item(s)?\n'
          'Fixtures in deleted positions will lose their position assignment.',
    );
    if (!ok) return;

    for (final id in posIds) {
      await repo.deletePosition(id);
    }
    for (final id in grpIds) {
      await repo.deleteGroup(id);
    }
    setState(() => _selected.clear());
  }

  Future<void> _combineSelected(
      PositionRepository repo, List<LightingPosition> positions) async {
    final posIds = _selectedPositionIds.toList();
    if (posIds.length != 2) return;

    final a = positions.firstWhere((p) => p.id == posIds[0]);
    final b = positions.firstWhere((p) => p.id == posIds[1]);

    final result = await showDialog<({int keepId, String? newName})>(
      context: context,
      builder: (_) => _CombineDialog(posA: a, posB: b),
    );
    if (result == null) return;

    final deleteId = result.keepId == a.id ? b.id : a.id;
    await repo.combinePositions(
      keepId: result.keepId,
      deleteId: deleteId,
      newName: result.newName,
    );
    setState(() => _selected.clear());
  }

  Future<void> _groupSelected(
      PositionRepository repo, List<LightingPosition> positions) async {
    final posIds = _selectedPositionIds.toList();
    if (posIds.length < 2) return;

    final name =
        await _nameDialog(context, title: 'New Group', hint: 'Group name');
    if (name == null) return;

    await repo.createGroup(name, posIds);
    setState(() => _selected.clear());
  }

  Future<void> _ungroupSelected(PositionRepository repo) async {
    for (final id in _selectedPositionIds) {
      await repo.removeFromGroup(id);
    }
    setState(() => _selected.clear());
  }

  // ── Rename with uniqueness enforcement ────────────────────────────────────

  Future<void> _handlePositionRename(
    int id,
    LightingPosition beingRenamed,
    String newName,
    List<LightingPosition> allPositions,
    PositionRepository repo,
  ) async {
    // Find any other position already carrying that name.
    LightingPosition? conflict;
    for (final p in allPositions) {
      if (p.id != id && p.name == newName) {
        conflict = p;
        break;
      }
    }

    if (conflict == null) {
      await repo.renamePosition(id, newName);
      return;
    }

    // Build a suggested unique name (newName_1, newName_2, …).
    final takenNames =
        allPositions.where((p) => p.id != id).map((p) => p.name).toSet();
    var suffix = 1;
    while (takenNames.contains('${newName}_$suffix')) {
      suffix++;
    }
    final suggested = '${newName}_$suffix';

    if (!mounted) return;

    final existing = conflict; // non-null, captured for use after await
    final result = await showDialog<_ConflictResolution>(
      context: context,
      builder: (_) => _RenameConflictDialog(
        beingRenamed: beingRenamed,
        existing: existing,
        targetName: newName,
        suggested: suggested,
      ),
    );

    if (result == null || !mounted) return;

    switch (result) {
      case _MergeKeepExisting():
        // Keep the already-named position; move beingRenamed's fixtures into it.
        await repo.combinePositions(keepId: existing.id, deleteId: id);
        setState(() => _selected.clear());
      case _MergeKeepNew():
        // Keep beingRenamed's metadata; rename it to targetName; absorb existing.
        await repo.combinePositions(
            keepId: id, deleteId: existing.id, newName: newName);
      case _UseAlternateName(:final name):
        await repo.renamePosition(id, name);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final positionsAsync = ref.watch(lightingPositionsProvider);
    final groupsAsync = ref.watch(positionGroupsProvider);
    final repo = ref.watch(positionRepoProvider);

    final positions = positionsAsync.valueOrNull ?? [];
    final groups = groupsAsync.valueOrNull ?? [];
    final items = _buildTopItems(positions, groups);

    final selPosIds = _selectedPositionIds;
    final selectedAreGrouped = selPosIds.isNotEmpty &&
        positions
            .where((p) => selPosIds.contains(p.id))
            .every((p) => p.groupId != null);

    // Single selected position drives the info panel.
    LightingPosition? singleSelected;
    if (selPosIds.length == 1 && _selectedGroupIds.isEmpty) {
      final id = selPosIds.first;
      for (final p in positions) {
        if (p.id == id) {
          singleSelected = p;
          break;
        }
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Tool sidebar (LEFT) ────────────────────────────────────────
        Container(
          width: 52,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFF23272E))),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: _toolbarPad),
                _ToolButton(
                  icon: Icons.add,
                  tooltip: 'Add Position',
                  onPressed: repo != null ? () => _addPosition(repo) : null,
                ),
                _ToolButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete Selected',
                  onPressed: (repo != null && _selected.isNotEmpty)
                      ? () => _deleteSelected(repo, items)
                      : null,
                ),
                const Divider(indent: 8, endIndent: 8),
                _ToolButton(
                  icon: Icons.merge,
                  tooltip: 'Combine 2 Positions',
                  onPressed: (repo != null && selPosIds.length == 2)
                      ? () => _combineSelected(repo, positions)
                      : null,
                ),
                _ToolButton(
                  icon: Icons.folder_outlined,
                  tooltip: 'Group Selected',
                  onPressed: (repo != null && selPosIds.length >= 2)
                      ? () => _groupSelected(repo, positions)
                      : null,
                ),
                _ToolButton(
                  icon: Icons.folder_off_outlined,
                  tooltip: 'Remove from Group',
                  onPressed: (repo != null && selectedAreGrouped)
                      ? () => _ungroupSelected(repo)
                      : null,
                ),
              ],
            ),
          ),
        ),

        // ── Position info panel (LEFT) ─────────────────────────────────
        _PositionInfoPanel(position: singleSelected, repo: repo),

        // ── Main list area ─────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: positionsAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : items.isEmpty
                        ? Center(
                            child: Text(
                              'No positions yet.\nUse + to add one.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF6B7280)),
                            ),
                          )
                        : Scrollbar(
                            controller: _scrollCtrl,
                            child: ReorderableListView.builder(
                              scrollController: _scrollCtrl,
                              buildDefaultDragHandles: false,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              itemCount: items.length,
                              onReorder: repo == null
                                  ? (_, __) {}
                                  : (oldIndex, newIndex) async {
                                      if (newIndex > oldIndex) newIndex--;
                                      final reordered = [...items];
                                      final moved =
                                          reordered.removeAt(oldIndex);
                                      reordered.insert(newIndex, moved);
                                      await repo.reorderTopLevel(
                                        reordered.map((item) {
                                          if (item is _SinglePosition) {
                                            return (
                                              id: item.pos.id,
                                              isGroup: false
                                            );
                                          } else {
                                            return (
                                              id: (item as _GroupItem).group.id,
                                              isGroup: true
                                            );
                                          }
                                        }).toList(),
                                      );
                                    },
                              itemBuilder: (_, i) {
                                final item = items[i];
                                if (item is _SinglePosition) {
                                  return _PositionCard(
                                    key: ValueKey(item.listKey),
                                    index: i,
                                    position: item.pos,
                                    selected: _selected.contains(item.listKey),
                                    onTap: () => _primaryTap(item.listKey),
                                    onSecondaryTap: () =>
                                        _multiToggle(item.listKey),
                                    onRename: repo != null
                                        ? (name) => _handlePositionRename(
                                            item.pos.id, item.pos, name,
                                            positions, repo)
                                        : null,
                                  );
                                } else {
                                  final grp = item as _GroupItem;
                                  return _GroupCard(
                                    key: ValueKey(item.listKey),
                                    index: i,
                                    group: grp.group,
                                    members: grp.members,
                                    selected: _selected.contains(item.listKey),
                                    selectedPositionKeys: _selected,
                                    onGroupTap: () =>
                                        _primaryTap(item.listKey),
                                    onGroupSecondaryTap: () =>
                                        _multiToggle(item.listKey),
                                    onPositionTap: (pos) =>
                                        _primaryTap('pos_${pos.id}'),
                                    onPositionSecondaryTap: (pos) =>
                                        _multiToggle('pos_${pos.id}'),
                                    onRename: repo != null
                                        ? (name) => repo.renameGroup(
                                            grp.group.id, name)
                                        : null,
                                    onReorderMembers: repo != null
                                        ? (ids) => repo.reorderWithinGroup(
                                            grp.group.id, ids)
                                        : null,
                                  );
                                }
                              },
                            ),
                          ),
              ),
              // ── Selection hint ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
                child: Text(
                  'Ctrl+click or right-click to multi-select · Double-click name to rename',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF4B5263),
                        fontSize: 10,
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

// ── Position info panel ────────────────────────────────────────────────────────
//
// Always present at fixed width. Populates when a single position is selected.

class _PositionInfoPanel extends StatefulWidget {
  const _PositionInfoPanel({required this.position, required this.repo});

  final LightingPosition? position;
  final PositionRepository? repo;

  @override
  State<_PositionInfoPanel> createState() => _PositionInfoPanelState();
}

class _PositionInfoPanelState extends State<_PositionInfoPanel> {
  late final TextEditingController _trimCtrl;
  late final TextEditingController _plasterCtrl;
  late final TextEditingController _centerCtrl;
  int? _lastId;

  @override
  void initState() {
    super.initState();
    _trimCtrl = TextEditingController(text: widget.position?.trim ?? '');
    _plasterCtrl =
        TextEditingController(text: widget.position?.fromPlasterLine ?? '');
    _centerCtrl =
        TextEditingController(text: widget.position?.fromCenterLine ?? '');
    _lastId = widget.position?.id;
  }

  @override
  void didUpdateWidget(_PositionInfoPanel old) {
    super.didUpdateWidget(old);
    final pos = widget.position;
    if (pos?.id != _lastId) {
      // Different position selected — always sync all fields.
      _lastId = pos?.id;
      _trimCtrl.text = pos?.trim ?? '';
      _plasterCtrl.text = pos?.fromPlasterLine ?? '';
      _centerCtrl.text = pos?.fromCenterLine ?? '';
    } else if (pos != null) {
      // Same position updated in DB — sync only unfocused fields.
      if (!_trimCtrl.selection.isValid) _trimCtrl.text = pos.trim ?? '';
      if (!_plasterCtrl.selection.isValid) {
        _plasterCtrl.text = pos.fromPlasterLine ?? '';
      }
      if (!_centerCtrl.selection.isValid) {
        _centerCtrl.text = pos.fromCenterLine ?? '';
      }
    }
  }

  @override
  void dispose() {
    _trimCtrl.dispose();
    _plasterCtrl.dispose();
    _centerCtrl.dispose();
    super.dispose();
  }

  void _saveTrim() {
    if (widget.position == null || widget.repo == null) return;
    final v = _trimCtrl.text.trim();
    widget.repo!.updateTrim(widget.position!.id, v.isEmpty ? null : v);
  }

  void _savePlaster() {
    if (widget.position == null || widget.repo == null) return;
    final v = _plasterCtrl.text.trim();
    widget.repo!
        .updateFromPlasterLine(widget.position!.id, v.isEmpty ? null : v);
  }

  void _saveCenter() {
    if (widget.position == null || widget.repo == null) return;
    final v = _centerCtrl.text.trim();
    widget.repo!
        .updateFromCenterLine(widget.position!.id, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPosition = widget.position != null;

    return Container(
      width: 180,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF23272E))),
      ),
      padding: const EdgeInsets.all(12),
      child: hasPosition
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.position!.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _InfoField(
                  label: 'TRIM',
                  controller: _trimCtrl,
                  onSave: _saveTrim,
                ),
                const SizedBox(height: 12),
                _InfoField(
                  label: 'FROM PLASTER',
                  controller: _plasterCtrl,
                  onSave: _savePlaster,
                ),
                const SizedBox(height: 12),
                _InfoField(
                  label: 'FROM CENTER',
                  controller: _centerCtrl,
                  onSave: _saveCenter,
                ),
              ],
            )
          : Center(
              child: Text(
                'Select a\nposition',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF4B5263),
                ),
              ),
            ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.controller,
    required this.onSave,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      onFocusChange: (has) {
        if (!has) onSave();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF6B7280),
              letterSpacing: 0.6,
              fontSize: 9,
            ),
          ),
          TextField(
            controller: controller,
            style: theme.textTheme.bodySmall,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF23272E), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onSubmitted: (_) => onSave(),
          ),
        ],
      ),
    );
  }
}

// ── Position card (StatefulWidget — supports inline rename via double-tap) ─────

class _PositionCard extends StatefulWidget {
  const _PositionCard({
    super.key,
    required this.index,
    required this.position,
    required this.selected,
    required this.onTap,
    required this.onSecondaryTap,
    this.onRename,
  });

  final int index;
  final LightingPosition position;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSecondaryTap;
  final Future<void> Function(String)? onRename;

  @override
  State<_PositionCard> createState() => _PositionCardState();
}

class _PositionCardState extends State<_PositionCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.position.name);
  }

  @override
  void didUpdateWidget(_PositionCard old) {
    super.didUpdateWidget(old);
    if (widget.position.name != old.position.name && !_ctrl.selection.isValid) {
      _ctrl.text = widget.position.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commitRename() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty && v != widget.position.name) {
      widget.onRename?.call(v);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: widget.selected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _editing ? null : widget.onTap,
          onSecondaryTap: _editing ? null : widget.onSecondaryTap,
          onDoubleTap: widget.onRename == null
              ? null
              : () {
                  _ctrl.text = widget.position.name;
                  setState(() => _editing = true);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _editing
                      ? CallbackShortcuts(
                          bindings: {
                            const SingleActivator(LogicalKeyboardKey.escape):
                                () => setState(() => _editing = false),
                          },
                          child: Focus(
                            onFocusChange: (has) {
                              if (!has) _commitRename();
                            },
                            child: TextField(
                              controller: _ctrl,
                              autofocus: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.selected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _commitRename(),
                            ),
                          ),
                        )
                      : Text(
                          widget.position.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.selected
                                ? theme.colorScheme.primary
                                : null,
                            fontWeight: widget.selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(Icons.drag_indicator,
                      size: 18, color: Color(0xFF4B5263)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Group card ────────────────────────────────────────────────────────────────
//
// Members use a fixed-height ReorderableListView (NeverScrollableScrollPhysics,
// no shrinkWrap). The SizedBox gives a tight bounded constraint so the inner
// list's size never affects the outer list's layout — breaking the circular
// dependency that causes _dependents.isEmpty crashes with shrinkWrap:true.
// ReorderableDragStartListener on each handle lets the user drag within the
// group without conflicting with the outer list's long-press drag.

class _GroupCard extends StatefulWidget {
  const _GroupCard({
    super.key,
    required this.index,
    required this.group,
    required this.members,
    required this.selected,
    required this.selectedPositionKeys,
    required this.onGroupTap,
    required this.onGroupSecondaryTap,
    required this.onPositionTap,
    required this.onPositionSecondaryTap,
    this.onRename,
    this.onReorderMembers,
  });

  final int index;
  final PositionGroup group;
  final List<LightingPosition> members;
  final bool selected;
  final Set<String> selectedPositionKeys;
  final VoidCallback onGroupTap;
  final VoidCallback onGroupSecondaryTap;
  final void Function(LightingPosition) onPositionTap;
  final void Function(LightingPosition) onPositionSecondaryTap;
  final Future<void> Function(String)? onRename;
  final Future<void> Function(List<int>)? onReorderMembers;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _expanded = true;
  bool _editingName = false;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.group.name);
  }

  @override
  void didUpdateWidget(_GroupCard old) {
    super.didUpdateWidget(old);
    if (widget.group.name != old.group.name) {
      _nameCtrl.text = widget.group.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _commitGroupRename() {
    final v = _nameCtrl.text.trim();
    if (v.isNotEmpty && v != widget.group.name) {
      widget.onRename?.call(v);
    }
    setState(() => _editingName = false);
  }

  // Each member tile is ~38 px tall (8+6 vertical padding + ~18 px content +
  // 2 px bottom gap). The SizedBox uses this to give the inner list a tight
  // bounded height so the outer list's layout is never affected by the inner.
  static const double _tileHeight = 38.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: widget.selected
              ? amber.withValues(alpha: 0.08)
              : const Color(0xFF13161B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.selected
                ? amber.withValues(alpha: 0.5)
                : const Color(0xFF23272E),
          ),
        ),
        child: Column(
          children: [
            // ── Group header ────────────────────────────────────────────
            // Layout (L→R): [drag] [caret] [folder] [name  (count)]
            InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              onTap: _editingName ? null : widget.onGroupTap,
              onSecondaryTap: _editingName ? null : widget.onGroupSecondaryTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Row(
                  children: [
                    // Collapse / expand caret
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: widget.selected ? amber : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    // Name + member count (Expanded — takes all middle space)
                    Expanded(
                      child: _editingName
                          ? CallbackShortcuts(
                              bindings: {
                                const SingleActivator(
                                        LogicalKeyboardKey.escape):
                                    () => setState(() => _editingName = false),
                              },
                              child: Focus(
                                onFocusChange: (has) {
                                  if (!has) _commitGroupRename();
                                },
                                child: TextField(
                                  controller: _nameCtrl,
                                  autofocus: true,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: widget.selected ? amber : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (_) => _commitGroupRename(),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onDoubleTap: widget.onRename == null
                                  ? null
                                  : () {
                                      _nameCtrl.text = widget.group.name;
                                      setState(() => _editingName = true);
                                    },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.group.name,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: widget.selected ? amber : null,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.members.length}',
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                            color: const Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    // Drag handle — right side, anchored to the header so it
                    // stays at the top regardless of expanded card height.
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: const Icon(Icons.drag_indicator,
                          size: 18, color: Color(0xFF4B5263)),
                    ),
                  ],
                ),
              ),
            ),

            // ── Member list — fixed-height inner ReorderableListView ────
            if (_expanded && widget.members.isNotEmpty) ...[
              const Divider(height: 1, indent: 12, endIndent: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(36, 4, 4, 8),
                child: SizedBox(
                  height: widget.members.length * _tileHeight,
                  child: ReorderableListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    padding: EdgeInsets.zero,
                    itemCount: widget.members.length,
                    onReorder: (oldIdx, newIdx) {
                      if (newIdx > oldIdx) newIdx--;
                      final reordered = [...widget.members];
                      final moved = reordered.removeAt(oldIdx);
                      reordered.insert(newIdx, moved);
                      widget.onReorderMembers
                          ?.call(reordered.map((p) => p.id).toList());
                    },
                    itemBuilder: (_, i) =>
                        _buildMemberTile(i, widget.members[i], amber, theme),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Drag handle on the RIGHT, inset ~12 px (~5% of a typical panel width).
  // ReorderableDragStartListener makes only the handle icon trigger the drag,
  // leaving the rest of the tile available for tap/select.
  Widget _buildMemberTile(
      int index, LightingPosition pos, Color amber, ThemeData theme) {
    final posKey = 'pos_${pos.id}';
    final isSel = widget.selectedPositionKeys.contains(posKey);
    return Padding(
      key: ValueKey(pos.id),
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSel ? amber.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => widget.onPositionTap(pos),
          onSecondaryTap: () => widget.onPositionSecondaryTap(pos),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10, right: 4, top: 8, bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pos.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSel ? amber : null,
                      fontWeight:
                          isSel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 36),
                    child: Icon(Icons.drag_indicator,
                        size: 14, color: Color(0xFF4B5263)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tool button ────────────────────────────────────────────────────────────────

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: onPressed != null
          ? Theme.of(context).colorScheme.primary
          : const Color(0xFF3A3F4A),
    );
  }
}

// ── Dialogs ────────────────────────────────────────────────────────────────────

// _nameDialog uses a StatefulWidget so the TextEditingController is disposed
// in State.dispose() — AFTER the exit animation completes. Disposing it after
// showDialog() resolves (but before teardown) causes "controller used after
// disposed" assertion failures during the dialog's exit frame.
Future<String?> _nameDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String? initial,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) =>
          _NameDialog(title: title, hint: hint, initial: initial),
    );

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.hint,
    this.initial,
  });

  final String title;
  final String hint;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_ctrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          decoration: InputDecoration(labelText: widget.hint),
          autofocus: true,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

Future<bool> _confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}

// ── Rename conflict resolution ─────────────────────────────────────────────────

sealed class _ConflictResolution {}

class _MergeKeepExisting extends _ConflictResolution {}

class _MergeKeepNew extends _ConflictResolution {}

class _UseAlternateName extends _ConflictResolution {
  _UseAlternateName(this.name);
  final String name;
}

class _RenameConflictDialog extends StatefulWidget {
  const _RenameConflictDialog({
    required this.beingRenamed,
    required this.existing,
    required this.targetName,
    required this.suggested,
  });

  final LightingPosition beingRenamed;
  final LightingPosition existing;
  final String targetName;
  final String suggested;

  @override
  State<_RenameConflictDialog> createState() => _RenameConflictDialogState();
}

class _RenameConflictDialogState extends State<_RenameConflictDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.suggested);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submitRename() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty) Navigator.of(context).pop(_UseAlternateName(v));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final existing = widget.existing.name;
    final renaming = widget.beingRenamed.name;

    return AlertDialog(
      title: const Text('Name Already In Use'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '"${widget.targetName}" is already used by another position. '
              'Choose how to resolve this:',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(_MergeKeepExisting()),
              child: Text('Merge — keep "$existing" location data'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(_MergeKeepNew()),
              child: Text('Merge — keep "$renaming" location data'),
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 4),
            Text(
              'Or use a different name:',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(isDense: true),
                    onSubmitted: (_) => _submitRename(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton(
                    onPressed: _submitRename,
                    child: const Text('Rename'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

// ── Combine dialog ─────────────────────────────────────────────────────────────

class _CombineDialog extends StatefulWidget {
  const _CombineDialog({required this.posA, required this.posB});

  final LightingPosition posA;
  final LightingPosition posB;

  @override
  State<_CombineDialog> createState() => _CombineDialogState();
}

class _CombineDialogState extends State<_CombineDialog> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _useCustomName() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context)
          .pop((keepId: widget.posA.id, newName: _ctrl.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Combine Positions'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Fixtures from the discarded position will be reassigned. '
              'Which name should the combined position carry?',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pop((keepId: widget.posA.id, newName: null)),
                    child: Text(widget.posA.name),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pop((keepId: widget.posB.id, newName: null)),
                    child: Text(widget.posB.name),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 4),
            Text(
              'Or enter a new name:',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'New position name',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      onFieldSubmitted: (_) => _useCustomName(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: FilledButton(
                      onPressed: _useCustomName,
                      child: const Text('Use'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
