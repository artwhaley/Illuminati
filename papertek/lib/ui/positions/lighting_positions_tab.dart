import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/show_provider.dart';
import 'position_list_item.dart';
import 'positions_controller.dart';
import 'widgets/tool_button.dart';
import 'widgets/position_info_panel.dart';
import 'widgets/position_card.dart';
import 'widgets/position_group_card.dart';

// ── Tab widget ─────────────────────────────────────────────────────────────────

class LightingPositionsTab extends ConsumerStatefulWidget {
  const LightingPositionsTab({super.key});

  @override
  ConsumerState<LightingPositionsTab> createState() =>
      _LightingPositionsTabState();
}

class _LightingPositionsTabState extends ConsumerState<LightingPositionsTab> {
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(positionsControllerProvider.notifier);
    final posState = ref.watch(positionsControllerProvider);
    final selected = posState.selected;

    final positionsAsync = ref.watch(lightingPositionsProvider);
    final groupsAsync = ref.watch(positionGroupsProvider);
    final repo = ref.watch(positionRepoProvider);

    final positions = positionsAsync.valueOrNull ?? [];
    final groups = groupsAsync.valueOrNull ?? [];
    final items = controller.buildTopItems(positions, groups);

    final selPosIds = controller.selectedPositionIds;
    final selectedAreGrouped = selPosIds.isNotEmpty &&
        positions
            .where((p) => selPosIds.contains(p.id))
            .every((p) => p.groupId != null);

    // Single selected position drives the info panel.
    LightingPosition? singleSelected;
    if (selPosIds.length == 1 && controller.selectedGroupIds.isEmpty) {
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
                PositionToolButton(
                  icon: Icons.add,
                  tooltip: 'Add Position',
                  onPressed: repo != null ? () => controller.addPosition(context) : null,
                ),
                PositionToolButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete Selected',
                  onPressed: (repo != null && selected.isNotEmpty)
                      ? () => controller.deleteSelected(context, items)
                      : null,
                ),
                const Divider(indent: 8, endIndent: 8),
                PositionToolButton(
                  icon: Icons.merge,
                  tooltip: 'Combine 2 Positions',
                  onPressed: (repo != null && selPosIds.length == 2)
                      ? () => controller.combineSelected(context, positions)
                      : null,
                ),
                PositionToolButton(
                  icon: Icons.folder_outlined,
                  tooltip: 'Group Selected',
                  onPressed: (repo != null && selPosIds.length >= 2)
                      ? () => controller.groupSelected(context, positions)
                      : null,
                ),
                PositionToolButton(
                  icon: Icons.folder_off_outlined,
                  tooltip: 'Remove from Group',
                  onPressed: (repo != null && selectedAreGrouped)
                      ? () => controller.ungroupSelected()
                      : null,
                ),
              ],
            ),
          ),
        ),

        // ── Position info panel (LEFT) ─────────────────────────────────
        PositionInfoPanel(position: singleSelected, repo: repo),

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
                                          if (item is SinglePositionItem) {
                                            return (
                                              id: item.pos.id,
                                              isGroup: false
                                            );
                                          } else {
                                            return (
                                              id: (item as PositionGroupItem).group.id,
                                              isGroup: true
                                            );
                                          }
                                        }).toList(),
                                      );
                                    },
                              itemBuilder: (_, i) {
                                final item = items[i];
                                if (item is SinglePositionItem) {
                                  return PositionCard(
                                    key: ValueKey(item.listKey),
                                    index: i,
                                    position: item.pos,
                                    selected: selected.contains(item.listKey),
                                    onTap: () => controller.primaryTap(item.listKey),
                                    onSecondaryTap: () =>
                                        controller.multiToggle(item.listKey),
                                    onRename: repo != null
                                        ? (name) => controller.handlePositionRename(
                                            context, item.pos.id, item.pos, name,
                                            positions)
                                        : null,
                                  );
                                } else {
                                  final grp = item as PositionGroupItem;
                                  return PositionGroupCard(
                                    key: ValueKey(item.listKey),
                                    index: i,
                                    group: grp.group,
                                    members: grp.members,
                                    selected: selected.contains(item.listKey),
                                    selectedPositionKeys: selected,
                                    onGroupTap: () =>
                                        controller.primaryTap(item.listKey),
                                    onGroupSecondaryTap: () =>
                                        controller.multiToggle(item.listKey),
                                    onPositionTap: (pos) =>
                                        controller.primaryTap('pos_${pos.id}'),
                                    onPositionSecondaryTap: (pos) =>
                                        controller.multiToggle('pos_${pos.id}'),
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
