import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/show_provider.dart';
import 'position_list_item.dart';
import 'widgets/position_dialogs.dart';

class PositionsState {
  const PositionsState({this.selected = const {}});
  final Set<String> selected;

  PositionsState copyWith({Set<String>? selected}) =>
      PositionsState(selected: selected ?? this.selected);
}

class PositionsController extends StateNotifier<PositionsState> {
  PositionsController(this._ref) : super(const PositionsState());

  final Ref _ref;

  // ── Selection ──────────────────────────────────────────────────────────────

  Set<int> get selectedPositionIds => state.selected
      .where((k) => k.startsWith('pos_'))
      .map((k) => int.parse(k.substring(4)))
      .toSet();

  Set<int> get selectedGroupIds => state.selected
      .where((k) => k.startsWith('group_'))
      .map((k) => int.parse(k.substring(6)))
      .toSet();

  void primaryTap(String key) {
    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (isCtrl) {
      _applyToggle(key);
    } else {
      state = PositionsState(selected: {key});
    }
  }

  void multiToggle(String key) => _applyToggle(key);

  void _applyToggle(String key) {
    final next = Set<String>.from(state.selected);
    if (next.contains(key)) {
      next.remove(key);
    } else {
      next.add(key);
    }
    state = state.copyWith(selected: next);
  }

  void clearSelection() => state = const PositionsState();

  // ── List building ──────────────────────────────────────────────────────────

  List<PositionListItem> buildTopItems(
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

    final items = <PositionListItem>[
      ...ungrouped.map(SinglePositionItem.new),
      ...groups.map((g) => PositionGroupItem(g, grouped[g.id] ?? [])),
    ];
    items.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> addPosition(BuildContext context) async {
    final repo = _ref.read(positionRepoProvider);
    if (repo == null) return;

    final name = await showPositionNameDialog(context,
        title: 'New Position', hint: 'Position name');
    if (name == null) return;
    await repo.addPosition(name);
  }

  Future<void> deleteSelected(
      BuildContext context, List<PositionListItem> items) async {
    final repo = _ref.read(positionRepoProvider);
    if (repo == null) return;

    final posIds = selectedPositionIds;
    final grpIds = selectedGroupIds;
    if (posIds.isEmpty && grpIds.isEmpty) return;

    final ok = await showPositionConfirmDialog(
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
    clearSelection();
  }

  Future<void> combineSelected(
      BuildContext context, List<LightingPosition> positions) async {
    final repo = _ref.read(positionRepoProvider);
    if (repo == null) return;

    final posIds = selectedPositionIds.toList();
    if (posIds.length != 2) return;

    final a = positions.firstWhere((p) => p.id == posIds[0]);
    final b = positions.firstWhere((p) => p.id == posIds[1]);

    final result = await showDialog<({int keepId, String? newName})>(
      context: context,
      builder: (_) => PositionCombineDialog(posA: a, posB: b),
    );
    if (result == null) return;

    final deleteId = result.keepId == a.id ? b.id : a.id;
    await repo.combinePositions(
      keepId: result.keepId,
      deleteId: deleteId,
      newName: result.newName,
    );
    clearSelection();
  }

  Future<void> groupSelected(
      BuildContext context, List<LightingPosition> positions) async {
    final repo = _ref.read(positionRepoProvider);
    if (repo == null) return;

    final posIds = selectedPositionIds.toList();
    if (posIds.length < 2) return;

    final name = await showPositionNameDialog(context,
        title: 'New Group', hint: 'Group name');
    if (name == null) return;

    await repo.createGroup(name, posIds);
    clearSelection();
  }

  Future<void> ungroupSelected() async {
    final repo = _ref.read(positionRepoProvider);
    if (repo == null) return;

    for (final id in selectedPositionIds) {
      await repo.removeFromGroup(id);
    }
    clearSelection();
  }

  Future<void> handlePositionRename(
    BuildContext context,
    int id,
    LightingPosition beingRenamed,
    String newName,
    List<LightingPosition> allPositions,
  ) async {
    final repo = _ref.read(positionRepoProvider);
    if (repo == null) return;

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
    final result = await showDialog<PositionConflictResolution>(
      context: context,
      builder: (_) => PositionRenameConflictDialog(
        beingRenamed: beingRenamed,
        existing: existing,
        targetName: newName,
        suggested: suggested,
      ),
    );

    if (result == null || !mounted) return;

    switch (result) {
      case MergeKeepExisting():
        // Keep the already-named position; move beingRenamed's fixtures into it.
        await repo.combinePositions(keepId: existing.id, deleteId: id);
        clearSelection();
      case MergeKeepNew():
        // Keep beingRenamed's metadata; rename it to targetName; absorb existing.
        await repo.combinePositions(
            keepId: id, deleteId: existing.id, newName: newName);
      case UseAlternateName(:final name):
        await repo.renamePosition(id, name);
    }
  }
}

final positionsControllerProvider =
    StateNotifierProvider.autoDispose<PositionsController, PositionsState>(
  (ref) => PositionsController(ref),
);
