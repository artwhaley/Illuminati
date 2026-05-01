// ── dimmers_tab.dart ──────────────────────────────────────────────────────────
//
// The Dimmers sub-tab of the venue infrastructure panel.
// Dimmers (dimmer packs/racks) can be linked to addresses and have metadata
// fields for pack, rack, location, and capacity.
//
// Public: DimmersTab

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/show_provider.dart';
import '../../../repositories/venue_repository.dart';
import 'venue_shared_widgets.dart';
import 'venue_dialogs.dart';
import 'venue_field_widgets.dart';

class DimmersTab extends ConsumerStatefulWidget {
  const DimmersTab({super.key});

  @override
  ConsumerState<DimmersTab> createState() => _DimmersTabState();
}

class _DimmersTabState extends ConsumerState<DimmersTab> {
  int? _selectedId;

  Dimmer? _single(List<Dimmer> list) =>
      _selectedId == null ? null : list.cast<Dimmer?>().firstWhere(
            (d) => d!.id == _selectedId,
            orElse: () => null,
          );

  @override
  Widget build(BuildContext context) {
    final dimmersAsync = ref.watch(dimmersProvider);
    final addressesAsync = ref.watch(addressesProvider);
    final repo = ref.watch(venueRepoProvider);
    final items = dimmersAsync.valueOrNull ?? [];
    final addresses = addressesAsync.valueOrNull ?? [];
    final single = _single(items);

    return VenueShell(
      infoPanel: _DimmerInfoPanel(
          dimmer: single,
          repo: repo,
          addressNames: addresses.map((a) => a.name).toList()),
      onAdd: repo != null
          ? () async {
              final name = await venueNameDialog(context,
                  title: 'New Dimmer', hint: 'Dimmer name or number');
              if (name == null) return;
              final id = await repo.addDimmer(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await venueConfirmDelete(context, 'dimmer');
              if (!ok) return;
              await repo.deleteDimmer(_selectedId!);
              setState(() => _selectedId = null);
            }
          : null,
      emptyHint: 'No dimmers yet.\nUse + to add one.',
      isLoading: dimmersAsync.isLoading,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: items.length,
        itemBuilder: (_, i) => VenueCard(
          key: ValueKey(items[i].id),
          name: items[i].name,
          subtitle: items[i].address != null ? 'Addr: ${items[i].address}' : null,
          selected: _selectedId == items[i].id,
          onTap: () => setState(() => _selectedId = items[i].id),
          onRename: repo != null
              ? (name) => repo.renameDimmer(items[i].id, name)
              : null,
        ),
      ),
    );
  }
}

class _DimmerInfoPanel extends StatefulWidget {
  const _DimmerInfoPanel(
      {required this.dimmer, required this.repo, required this.addressNames});

  final Dimmer? dimmer;
  final VenueRepository? repo;
  final List<String> addressNames;

  @override
  State<_DimmerInfoPanel> createState() => _DimmerInfoPanelState();
}

class _DimmerInfoPanelState extends State<_DimmerInfoPanel> {
  late final TextEditingController _packCtrl;
  late final TextEditingController _rackCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _capacityCtrl;
  int? _lastId;

  @override
  void initState() {
    super.initState();
    final d = widget.dimmer;
    _packCtrl = TextEditingController(text: d?.pack ?? '');
    _rackCtrl = TextEditingController(text: d?.rack ?? '');
    _locationCtrl = TextEditingController(text: d?.location ?? '');
    _capacityCtrl = TextEditingController(text: d?.capacity ?? '');
    _lastId = d?.id;
  }

  // When the selection changes (new id), we reset all controllers entirely.
  // When the same item updates while not focused, we sync each controller.
  // We deliberately leave fields alone if focused to avoid clobbering edits in-flight.
  @override
  void didUpdateWidget(_DimmerInfoPanel old) {
    super.didUpdateWidget(old);
    final d = widget.dimmer;
    if (d?.id != _lastId) {
      _lastId = d?.id;
      _packCtrl.text = d?.pack ?? '';
      _rackCtrl.text = d?.rack ?? '';
      _locationCtrl.text = d?.location ?? '';
      _capacityCtrl.text = d?.capacity ?? '';
    } else if (d != null) {
      if (!_packCtrl.selection.isValid) _packCtrl.text = d.pack ?? '';
      if (!_rackCtrl.selection.isValid) _rackCtrl.text = d.rack ?? '';
      if (!_locationCtrl.selection.isValid) _locationCtrl.text = d.location ?? '';
      if (!_capacityCtrl.selection.isValid) _capacityCtrl.text = d.capacity ?? '';
    }
  }

  @override
  void dispose() {
    _packCtrl.dispose();
    _rackCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  void _save(Future<void> Function(int, String?) fn, String raw) {
    if (widget.dimmer == null || widget.repo == null) return;
    final v = raw.trim();
    fn(widget.dimmer!.id, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.dimmer;

    return VenueInfoPanelShell(
      title: d?.name,
      emptyLabel: 'Select a\ndimmer',
      children: [
        VenueDropdownField(
          label: 'ADDRESS',
          value: d?.address,
          options: widget.addressNames,
          theme: theme,
          onChanged: d == null || widget.repo == null
              ? null
              : (v) => widget.repo!.updateDimmerAddress(d.id, v),
        ),
        const SizedBox(height: 12),
        VenueInfoField(
            label: 'PACK',
            controller: _packCtrl,
            onSave: () {
              if (widget.repo == null) return;
              _save(widget.repo!.updateDimmerPack, _packCtrl.text);
            }),
        const SizedBox(height: 12),
        VenueInfoField(
            label: 'RACK',
            controller: _rackCtrl,
            onSave: () {
              if (widget.repo == null) return;
              _save(widget.repo!.updateDimmerRack, _rackCtrl.text);
            }),
        const SizedBox(height: 12),
        VenueInfoField(
            label: 'LOCATION',
            controller: _locationCtrl,
            onSave: () {
              if (widget.repo == null) return;
              _save(widget.repo!.updateDimmerLocation, _locationCtrl.text);
            }),
        const SizedBox(height: 12),
        VenueInfoField(
            label: 'CAPACITY',
            controller: _capacityCtrl,
            onSave: () {
              if (widget.repo == null) return;
              _save(widget.repo!.updateDimmerCapacity, _capacityCtrl.text);
            }),
      ],
    );
  }
}
