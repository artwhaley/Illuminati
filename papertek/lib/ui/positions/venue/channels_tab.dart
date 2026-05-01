// ── channels_tab.dart ─────────────────────────────────────────────────────────
//
// The Channels sub-tab of the venue infrastructure panel.
// Channels represent logical DMX channels that can be assigned to addresses.
//
// Public: ChannelsTab

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../database/database.dart';
import '../../../providers/show_provider.dart';
import '../../../repositories/venue_repository.dart';
import 'venue_shared_widgets.dart';
import 'venue_dialogs.dart';
import 'venue_field_widgets.dart';

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

    return VenueShell(
      infoPanel: _ChannelInfoPanel(channel: single, repo: repo),
      onAdd: repo != null
          ? () async {
              final name = await venueNameDialog(context,
                  title: 'New Channel', hint: 'Channel number or name');
              if (name == null) return;
              final id = await repo.addChannel(name);
              setState(() => _selectedId = id);
            }
          : null,
      onDelete: (repo != null && _selectedId != null)
          ? () async {
              final ok = await venueConfirmDelete(context, 'channel');
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
        itemBuilder: (_, i) => VenueCard(
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

  // When the selection changes (new id), we reset the controller entirely.
  // When the same item updates from the stream while the user is not typing
  // (!selection.isValid), we sync the new value in.  We deliberately do nothing
  // if the user has the field focused — their in-progress edit takes priority.
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
  Widget build(BuildContext context) => VenueInfoPanelShell(
        title: widget.channel?.name,
        emptyLabel: 'Select a\nchannel',
        children: [
          VenueInfoField(
              label: 'NOTES',
              controller: _notesCtrl,
              onSave: _saveNotes,
              maxLines: 3),
        ],
      );
}
