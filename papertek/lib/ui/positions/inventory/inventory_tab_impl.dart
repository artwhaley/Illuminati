// -- inventory_tab_impl.dart ---------------------------------------------------
//
// Orchestrator for Inventory tab.
//
// Layout:
// - Tool rail (left)
// - Type info panel (middle)
// - Type list (right)
//
// Includes scroll-driven toolbar padding via _toolbarPad.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/database.dart';
import '../../../providers/show_provider.dart';
import '../../../repositories/fixture_type_repository.dart';
import 'inventory_dialogs.dart';
import 'inventory_shared_widgets.dart';
import 'type_card.dart';
import 'type_info_panel.dart';

class InventoryTab extends ConsumerStatefulWidget {
  const InventoryTab({super.key});

  @override
  ConsumerState<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<InventoryTab> {
  final _selected = <int>{};
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

  // -- Selection ------------------------------------------------------------

  void _primaryTap(int id) {
    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    setState(() {
      if (isCtrl) {
        _toggle(id);
      } else {
        _selected
          ..clear()
          ..add(id);
      }
    });
  }

  void _secondaryTap(int id) => setState(() => _toggle(id));

  void _toggle(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
  }

  FixtureType? _singleSelected(List<FixtureType> types) {
    if (_selected.length == 1) {
      final id = _selected.first;
      for (final t in types) {
        if (t.id == id) return t;
      }
    }
    return null;
  }

  // -- Actions ---------------------------------------------------------------

  Future<void> _addType(FixtureTypeRepository repo) async {
    final name = await inventoryNameDialog(context,
        title: 'New Fixture Type', hint: 'Type name');
    if (name == null) return;
    final id = await repo.addType(name);
    setState(() {
      _selected.clear();
      _selected.add(id);
    });
  }

  Future<void> _deleteSelected(FixtureTypeRepository repo) async {
    if (_selected.isEmpty) return;
    final ok = await inventoryConfirmDialog(
      context,
      title: 'Delete',
      message: 'Delete ${_selected.length} fixture type(s)?\n'
          'Fixtures of these types will lose their type assignment.',
    );
    if (!ok) return;
    for (final id in _selected) {
      await repo.deleteType(id);
    }
    setState(() => _selected.clear());
  }

  Future<void> _mergeSelected(
      FixtureTypeRepository repo, List<FixtureType> types) async {
    if (_selected.length != 2) return;
    final ids = _selected.toList();
    final a = types.firstWhere((t) => t.id == ids[0]);
    final b = types.firstWhere((t) => t.id == ids[1]);

    // Expected return shape: ({int keepId, String? newName})
    final result = await showDialog<({int keepId, String? newName})>(
      context: context,
      builder: (_) => MergeTypeDialog(typeA: a, typeB: b),
    );
    if (result == null) return;

    final deleteId = result.keepId == a.id ? b.id : a.id;
    await repo.mergeTypes(
      keepId: result.keepId,
      deleteId: deleteId,
      newName: result.newName,
    );
    setState(() {
      _selected.clear();
      _selected.add(result.keepId);
    });
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(fixtureTypesProvider);
    final repo = ref.watch(fixtureTypeRepoProvider);
    final types = typesAsync.valueOrNull ?? [];
    final single = _singleSelected(types);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // -- Tool sidebar (LEFT) ---------------------------------------
        Container(
          width: 52,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFF23272E))),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: _toolbarPad),
                InventoryToolButton(
                  icon: Icons.add,
                  tooltip: 'Add Fixture Type',
                  onPressed: repo != null ? () => _addType(repo) : null,
                ),
                InventoryToolButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete Selected',
                  onPressed: (repo != null && _selected.isNotEmpty)
                      ? () => _deleteSelected(repo)
                      : null,
                ),
                const Divider(indent: 8, endIndent: 8),
                InventoryToolButton(
                  icon: Icons.merge,
                  tooltip: 'Merge 2 Types',
                  onPressed: (repo != null && _selected.length == 2)
                      ? () => _mergeSelected(repo, types)
                      : null,
                ),
              ],
            ),
          ),
        ),

        // -- Type info panel (MIDDLE) -----------------------------------
        TypeInfoPanel(
          type: single,
          repo: repo,
          fetchCount: single != null && repo != null
              ? () => repo.getFixtureCount(single.id)
              : null,
        ),

        // -- Type list (RIGHT) -----------------------------------------
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: typesAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : types.isEmpty
                        ? Center(
                            child: Text(
                              'No fixture types yet.\nUse + to add one.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: const Color(0xFF6B7280)),
                            ),
                          )
                        : Scrollbar(
                            controller: _scrollCtrl,
                            child: ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              itemCount: types.length,
                              itemBuilder: (_, i) => TypeCard(
                                key: ValueKey(types[i].id),
                                type: types[i],
                                selected: _selected.contains(types[i].id),
                                onTap: () => _primaryTap(types[i].id),
                                onSecondaryTap: () => _secondaryTap(types[i].id),
                                onRename: repo != null
                                    ? (name) =>
                                        repo.updateName(types[i].id, name)
                                    : null,
                              ),
                            ),
                          ),
              ),
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
