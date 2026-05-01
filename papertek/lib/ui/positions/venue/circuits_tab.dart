// ── circuits_tab.dart ─────────────────────────────────────────────────────────
//
// The Circuits sub-tab of the venue infrastructure panel.
// Circuits represent physical wiring runs that connect to dimmers.
//
// Public: CircuitsTab

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/show_provider.dart';
import '../../../repositories/venue_repository.dart';
import 'venue_shared_widgets.dart';
import 'venue_dialogs.dart';
import 'venue_field_widgets.dart';

class CircuitsTab extends ConsumerStatefulWidget {
  const CircuitsTab({super.key});

  @override
  ConsumerState<CircuitsTab> createState() => _CircuitsTabState();
}

class _CircuitsTabState extends ConsumerState<CircuitsTab> {
  int? _selectedId;

  Circuit? _single(List<Circuit> list) =>
      _selectedId == null ? null : list.cast<Circuit?>().firstWhere(
            (c) => c!.id == _selectedId,
            orElse: () => null,
          );

  @override
  Widget build(BuildContext context) {
    final circuitsAsync = ref.watch(circuitsProvider);
    final dimmersAsync = ref.watch(dimmersProvider);
    final repo = ref.watch(venueRepoProvider);
    final items = circuitsAsync.valueOrNull ?? [];
    final dimmers = dimmersAsync.valueOrNull ?? [];
    final single = _single(items);

    return VenueShell(
      infoPanel: _CircuitInfoPanel(
          circuit: single,
          repo: repo,
          dimmerNames: dimmers.map((d) => d.name).toList()),
      onAdd: repo != null
          ? () async {
              final name = await venueNameDialog(context,
                  title: 'New Circuit', hint: 'Circuit name or number');
              if (name == null) return;
              final id = await repo.addCircuit(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await venueConfirmDelete(context, 'circuit');
              if (!ok) return;
              await repo.deleteCircuit(_selectedId!);
              setState(() => _selectedId = null);
            }
          : null,
      emptyHint: 'No circuits yet.\nUse + to add one.',
      isLoading: circuitsAsync.isLoading,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: items.length,
        itemBuilder: (_, i) => VenueCard(
          key: ValueKey(items[i].id),
          name: items[i].name,
          subtitle: items[i].dimmer != null ? 'Dim: ${items[i].dimmer}' : null,
          selected: _selectedId == items[i].id,
          onTap: () => setState(() => _selectedId = items[i].id),
          onRename: repo != null
              ? (name) => repo.renameCircuit(items[i].id, name)
              : null,
        ),
      ),
    );
  }
}

class _CircuitInfoPanel extends StatefulWidget {
  const _CircuitInfoPanel(
      {required this.circuit, required this.repo, required this.dimmerNames});

  final Circuit? circuit;
  final VenueRepository? repo;
  final List<String> dimmerNames;

  @override
  State<_CircuitInfoPanel> createState() => _CircuitInfoPanelState();
}

class _CircuitInfoPanelState extends State<_CircuitInfoPanel> {
  late final TextEditingController _capacityCtrl;
  int? _lastId;

  @override
  void initState() {
    super.initState();
    _capacityCtrl = TextEditingController(text: widget.circuit?.capacity ?? '');
    _lastId = widget.circuit?.id;
  }

  // When the selection changes (new id), we reset the controller entirely.
  // When the same item updates while the user is not typing
  // (!selection.isValid), we sync the controller.
  // We deliberately keep focused edits untouched.
  @override
  void didUpdateWidget(_CircuitInfoPanel old) {
    super.didUpdateWidget(old);
    final c = widget.circuit;
    if (c?.id != _lastId) {
      _lastId = c?.id;
      _capacityCtrl.text = c?.capacity ?? '';
    } else if (c != null && !_capacityCtrl.selection.isValid) {
      _capacityCtrl.text = c.capacity ?? '';
    }
  }

  @override
  void dispose() {
    _capacityCtrl.dispose();
    super.dispose();
  }

  void _saveCapacity() {
    if (widget.circuit == null || widget.repo == null) return;
    final v = _capacityCtrl.text.trim();
    widget.repo!.updateCircuitCapacity(widget.circuit!.id, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.circuit;

    return VenueInfoPanelShell(
      title: c?.name,
      emptyLabel: 'Select a\ncircuit',
      children: [
        VenueDropdownField(
          label: 'DIMMER',
          value: c?.dimmer,
          options: widget.dimmerNames,
          theme: theme,
          onChanged: c == null || widget.repo == null
              ? null
              : (v) => widget.repo!.updateCircuitDimmer(c.id, v),
        ),
        const SizedBox(height: 12),
        VenueInfoField(
            label: 'CAPACITY',
            controller: _capacityCtrl,
            onSave: _saveCapacity),
      ],
    );
  }
}
