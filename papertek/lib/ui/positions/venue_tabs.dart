import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/show_provider.dart';
import '../../repositories/venue_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Channels tab
// ─────────────────────────────────────────────────────────────────────────────

class ChannelsTab extends ConsumerStatefulWidget {
  const ChannelsTab({super.key});

  @override
  ConsumerState<ChannelsTab> createState() => _ChannelsTabState();
}

class _ChannelsTabState extends ConsumerState<ChannelsTab> {
  int? _selectedId;

  Channel? _single(List<Channel> list) =>
      _selectedId == null ? null : list.cast<Channel?>().firstWhere(
            (c) => c!.id == _selectedId,
            orElse: () => null,
          );

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsProvider);
    final repo = ref.watch(venueRepoProvider);
    final items = channelsAsync.valueOrNull ?? [];
    final single = _single(items);

    return _VenueShell(
      infoPanel: _ChannelInfoPanel(channel: single, repo: repo),
      onAdd: repo != null
          ? () async {
              final name = await _nameDialog(context,
                  title: 'New Channel', hint: 'Channel number or name');
              if (name == null) return;
              final id = await repo.addChannel(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await _confirmDelete(context, 'channel');
              if (!ok) return;
              await repo.deleteChannel(_selectedId!);
              setState(() => _selectedId = null);
            }
          : null,
      emptyHint: 'No channels yet.\nUse + to add one.',
      isLoading: channelsAsync.isLoading,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: items.length,
        itemBuilder: (_, i) => _VenueCard(
          key: ValueKey(items[i].id),
          name: items[i].name,
          subtitle: items[i].notes,
          selected: _selectedId == items[i].id,
          onTap: () => setState(() => _selectedId = items[i].id),
          onRename: repo != null
              ? (name) => repo.renameChannel(items[i].id, name)
              : null,
        ),
      ),
    );
  }
}

class _ChannelInfoPanel extends StatefulWidget {
  const _ChannelInfoPanel({required this.channel, required this.repo});

  final Channel? channel;
  final VenueRepository? repo;

  @override
  State<_ChannelInfoPanel> createState() => _ChannelInfoPanelState();
}

class _ChannelInfoPanelState extends State<_ChannelInfoPanel> {
  late final TextEditingController _notesCtrl;
  int? _lastId;

  @override
  void initState() {
    super.initState();
    _notesCtrl = TextEditingController(text: widget.channel?.notes ?? '');
    _lastId = widget.channel?.id;
  }

  @override
  void didUpdateWidget(_ChannelInfoPanel old) {
    super.didUpdateWidget(old);
    final c = widget.channel;
    if (c?.id != _lastId) {
      _lastId = c?.id;
      _notesCtrl.text = c?.notes ?? '';
    } else if (c != null && !_notesCtrl.selection.isValid) {
      _notesCtrl.text = c.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _saveNotes() {
    if (widget.channel == null || widget.repo == null) return;
    final v = _notesCtrl.text.trim();
    widget.repo!.updateChannelNotes(widget.channel!.id, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) => _InfoPanelShell(
        title: widget.channel?.name,
        emptyLabel: 'Select a\nchannel',
        children: [
          _InfoField(label: 'NOTES', controller: _notesCtrl, onSave: _saveNotes,
              maxLines: 3),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Addresses tab
// ─────────────────────────────────────────────────────────────────────────────

class AddressesTab extends ConsumerStatefulWidget {
  const AddressesTab({super.key});

  @override
  ConsumerState<AddressesTab> createState() => _AddressesTabState();
}

class _AddressesTabState extends ConsumerState<AddressesTab> {
  int? _selectedId;

  AddressesData? _single(List<AddressesData> list) =>
      _selectedId == null ? null : list.cast<AddressesData?>().firstWhere(
            (a) => a!.id == _selectedId,
            orElse: () => null,
          );

  @override
  Widget build(BuildContext context) {
    final addressesAsync = ref.watch(addressesProvider);
    final channelsAsync = ref.watch(channelsProvider);
    final repo = ref.watch(venueRepoProvider);
    final items = addressesAsync.valueOrNull ?? [];
    final channels = channelsAsync.valueOrNull ?? [];
    final single = _single(items);

    return _VenueShell(
      infoPanel: _AddressInfoPanel(
          address: single, repo: repo, channelNames: channels.map((c) => c.name).toList()),
      onAdd: repo != null
          ? () async {
              final name = await _nameDialog(context,
                  title: 'New Address', hint: 'Address (e.g. 1/001)');
              if (name == null) return;
              final id = await repo.addAddress(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await _confirmDelete(context, 'address');
              if (!ok) return;
              await repo.deleteAddress(_selectedId!);
              setState(() => _selectedId = null);
            }
          : null,
      emptyHint: 'No addresses yet.\nUse + to add one.',
      isLoading: addressesAsync.isLoading,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        itemCount: items.length,
        itemBuilder: (_, i) => _VenueCard(
          key: ValueKey(items[i].id),
          name: items[i].name,
          subtitle: items[i].channel != null ? 'Ch: ${items[i].channel}' : null,
          selected: _selectedId == items[i].id,
          onTap: () => setState(() => _selectedId = items[i].id),
          onRename: repo != null
              ? (name) => repo.renameAddress(items[i].id, name)
              : null,
        ),
      ),
    );
  }
}

class _AddressInfoPanel extends StatefulWidget {
  const _AddressInfoPanel(
      {required this.address, required this.repo, required this.channelNames});

  final AddressesData? address;
  final VenueRepository? repo;
  final List<String> channelNames;

  @override
  State<_AddressInfoPanel> createState() => _AddressInfoPanelState();
}

class _AddressInfoPanelState extends State<_AddressInfoPanel> {
  late final TextEditingController _typeCtrl;
  int? _lastId;

  @override
  void initState() {
    super.initState();
    _typeCtrl = TextEditingController(text: widget.address?.type ?? '');
    _lastId = widget.address?.id;
  }

  @override
  void didUpdateWidget(_AddressInfoPanel old) {
    super.didUpdateWidget(old);
    final a = widget.address;
    if (a?.id != _lastId) {
      _lastId = a?.id;
      _typeCtrl.text = a?.type ?? '';
    } else if (a != null && !_typeCtrl.selection.isValid) {
      _typeCtrl.text = a.type ?? '';
    }
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    super.dispose();
  }

  void _saveType() {
    if (widget.address == null || widget.repo == null) return;
    final v = _typeCtrl.text.trim();
    widget.repo!.updateAddressType(widget.address!.id, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = widget.address;

    return _InfoPanelShell(
      title: a?.name,
      emptyLabel: 'Select an\naddress',
      children: [
        _InfoField(label: 'TYPE', controller: _typeCtrl, onSave: _saveType),
        const SizedBox(height: 12),
        _DropdownField(
          label: 'CHANNEL',
          value: a?.channel,
          options: widget.channelNames,
          theme: theme,
          onChanged: a == null || widget.repo == null
              ? null
              : (v) => widget.repo!.updateAddressChannel(a.id, v),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dimmers tab
// ─────────────────────────────────────────────────────────────────────────────

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

    return _VenueShell(
      infoPanel: _DimmerInfoPanel(
          dimmer: single,
          repo: repo,
          addressNames: addresses.map((a) => a.name).toList()),
      onAdd: repo != null
          ? () async {
              final name = await _nameDialog(context,
                  title: 'New Dimmer', hint: 'Dimmer name or number');
              if (name == null) return;
              final id = await repo.addDimmer(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await _confirmDelete(context, 'dimmer');
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
        itemBuilder: (_, i) => _VenueCard(
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

    return _InfoPanelShell(
      title: d?.name,
      emptyLabel: 'Select a\ndimmer',
      children: [
        _DropdownField(
          label: 'ADDRESS',
          value: d?.address,
          options: widget.addressNames,
          theme: theme,
          onChanged: d == null || widget.repo == null
              ? null
              : (v) => widget.repo!.updateDimmerAddress(d.id, v),
        ),
        const SizedBox(height: 12),
        _InfoField(
            label: 'PACK',
            controller: _packCtrl,
            onSave: () => _save(widget.repo!.updateDimmerPack, _packCtrl.text)),
        const SizedBox(height: 12),
        _InfoField(
            label: 'RACK',
            controller: _rackCtrl,
            onSave: () => _save(widget.repo!.updateDimmerRack, _rackCtrl.text)),
        const SizedBox(height: 12),
        _InfoField(
            label: 'LOCATION',
            controller: _locationCtrl,
            onSave: () =>
                _save(widget.repo!.updateDimmerLocation, _locationCtrl.text)),
        const SizedBox(height: 12),
        _InfoField(
            label: 'CAPACITY',
            controller: _capacityCtrl,
            onSave: () =>
                _save(widget.repo!.updateDimmerCapacity, _capacityCtrl.text)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circuits tab
// ─────────────────────────────────────────────────────────────────────────────

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

    return _VenueShell(
      infoPanel: _CircuitInfoPanel(
          circuit: single,
          repo: repo,
          dimmerNames: dimmers.map((d) => d.name).toList()),
      onAdd: repo != null
          ? () async {
              final name = await _nameDialog(context,
                  title: 'New Circuit', hint: 'Circuit name or number');
              if (name == null) return;
              final id = await repo.addCircuit(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await _confirmDelete(context, 'circuit');
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
        itemBuilder: (_, i) => _VenueCard(
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

    return _InfoPanelShell(
      title: c?.name,
      emptyLabel: 'Select a\ncircuit',
      children: [
        _DropdownField(
          label: 'DIMMER',
          value: c?.dimmer,
          options: widget.dimmerNames,
          theme: theme,
          onChanged: c == null || widget.repo == null
              ? null
              : (v) => widget.repo!.updateCircuitDimmer(c.id, v),
        ),
        const SizedBox(height: 12),
        _InfoField(
            label: 'CAPACITY',
            controller: _capacityCtrl,
            onSave: _saveCapacity),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared layout shell
// ─────────────────────────────────────────────────────────────────────────────

class _VenueShell extends StatelessWidget {
  const _VenueShell({
    required this.infoPanel,
    required this.child,
    required this.emptyHint,
    required this.isLoading,
    this.onAdd,
    this.onDelete,
  });

  final Widget infoPanel;
  final Widget child;
  final String emptyHint;
  final bool isLoading;
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar
        Container(
          width: 52,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFF23272E))),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _ToolButton(
                  icon: Icons.add, tooltip: 'Add', onPressed: onAdd),
              _ToolButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete Selected',
                  onPressed: onDelete),
            ],
          ),
        ),
        // Info panel
        infoPanel,
        // List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : child,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared info panel shell
// ─────────────────────────────────────────────────────────────────────────────

class _InfoPanelShell extends StatelessWidget {
  const _InfoPanelShell({
    required this.title,
    required this.emptyLabel,
    required this.children,
  });

  final String? title;
  final String emptyLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF23272E))),
      ),
      padding: const EdgeInsets.all(12),
      child: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            )
          : Center(
              child: Text(
                emptyLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: const Color(0xFF4B5263)),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared card with inline rename
// ─────────────────────────────────────────────────────────────────────────────

class _VenueCard extends StatefulWidget {
  const _VenueCard({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.onRename,
  });

  final String name;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Future<void> Function(String)? onRename;

  @override
  State<_VenueCard> createState() => _VenueCardState();
}

class _VenueCardState extends State<_VenueCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(_VenueCard old) {
    super.didUpdateWidget(old);
    if (widget.name != old.name && !_ctrl.selection.isValid) {
      _ctrl.text = widget.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty && v != widget.name) widget.onRename?.call(v);
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: widget.selected
            ? amber.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _editing ? null : widget.onTap,
          onDoubleTap: widget.onRename == null
              ? null
              : () {
                  _ctrl.text = widget.name;
                  setState(() => _editing = true);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _editing
                ? CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.escape):
                          () => setState(() => _editing = false),
                    },
                    child: Focus(
                      onFocusChange: (has) {
                        if (!has) _commit();
                      },
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: widget.selected ? amber : null),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _commit(),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.selected ? amber : null,
                          fontWeight: widget.selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared field widgets
// ─────────────────────────────────────────────────────────────────────────────

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.controller,
    required this.onSave,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final int maxLines;

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
            maxLines: maxLines,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF23272E), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.5),
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

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.theme,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ThemeData theme;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    // Show the current value even if it's not in the option list (stale soft-link).
    final items = {
      if (value != null && !options.contains(value)) value!,
      ...options,
    }.toList();

    return Column(
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
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF23272E), width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
          ),
          style: theme.textTheme.bodyMedium,
          dropdownColor: theme.colorScheme.surface,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('— none —',
                  style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ...items.map((n) => DropdownMenuItem(value: n, child: Text(n))),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared tool button
// ─────────────────────────────────────────────────────────────────────────────

class _ToolButton extends StatelessWidget {
  const _ToolButton(
      {required this.icon, required this.tooltip, this.onPressed});

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

// ─────────────────────────────────────────────────────────────────────────────
// Dialogs
// ─────────────────────────────────────────────────────────────────────────────

Future<String?> _nameDialog(BuildContext context,
        {required String title, required String hint}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: title, hint: hint),
    );

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
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
            child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }
}

Future<bool> _confirmDelete(BuildContext context, String itemType) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete'),
      content: Text('Delete this $itemType?'),
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
