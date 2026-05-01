// ── addresses_tab.dart ────────────────────────────────────────────────────────
//
// The Addresses sub-tab of the venue infrastructure panel.
// Addresses represent DMX universe/address slots (e.g. "1/001").
// Each address can be soft-linked to a channel by name.
//
// Public: AddressesTab

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/show_provider.dart';
import '../../../repositories/venue_repository.dart';
import 'venue_shared_widgets.dart';
import 'venue_dialogs.dart';
import 'venue_field_widgets.dart';

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

    return VenueShell(
      infoPanel: _AddressInfoPanel(
          address: single,
          repo: repo,
          channelNames: channels.map((c) => c.name).toList()),
      onAdd: repo != null
          ? () async {
              final name = await venueNameDialog(context,
                  title: 'New Address', hint: 'Address (e.g. 1/001)');
              if (name == null) return;
              final id = await repo.addAddress(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await venueConfirmDelete(context, 'address');
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
        itemBuilder: (_, i) => VenueCard(
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

  // When the selection changes (new id), we reset the controller entirely.
  // When the same item updates from the stream while the user is not typing
  // (!selection.isValid), we sync the new value in.  We deliberately do nothing
  // if the user has the field focused — their in-progress edit takes priority.
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

    return VenueInfoPanelShell(
      title: a?.name,
      emptyLabel: 'Select an\naddress',
      children: [
        VenueInfoField(label: 'TYPE', controller: _typeCtrl, onSave: _saveType),
        const SizedBox(height: 12),
        VenueDropdownField(
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
