import 'dart:async';
import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:flutter/material.dart';
import 'cue_stack/cue_stack_tab.dart';
import 'focus/focus_remote_tab.dart';
import 'osc_log_view.dart';
import 'settings/udp_settings.dart';
import 'settings/udp_settings_store.dart';
import 'setup/setup_tab.dart';

final class RemoteShell extends StatefulWidget {
  const RemoteShell({this.client, this.settingsStore, super.key});
  final EosClient? client;
  final UdpSettingsStore? settingsStore;
  @override
  State<RemoteShell> createState() => _RemoteShellState();
}

final class _RemoteShellState extends State<RemoteShell> {
  late final EosClient _client;
  late final bool _ownsClient;
  late final UdpSettingsStore _store;
  StreamSubscription<EosClientEvent>? _events;
  UdpSettings? _settings;
  int _index = 0;
  bool _loading = true;
  final List<UiLogEntry> _logs = <UiLogEntry>[];

  @override
  void initState() {
    super.initState();
    _client = widget.client ?? EosOscClient();
    _ownsClient = widget.client == null;
    _store = widget.settingsStore ?? FileUdpSettingsStore();
    _events = _client.events.listen(_onEvent);
    _load();
  }

  Future<void> _load() async {
    final settings = await _store.load();
    if (settings != null && _client is EosOscClient) {
      try {
        await _client.connect(settings.toConnectionConfig());
      } on Object catch (error) {
        _log('ERROR', 'settings', '$error');
      }
    }
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _index = settings?.isValid == true ? 1 : 0;
      _loading = false;
    });
  }

  void _onEvent(EosClientEvent event) {
    final entry = switch (event) {
      EosOscMessageEvent(:final direction, :final message) => UiLogEntry(
          timestamp: event.timestamp,
          kind: direction == EosOscDirection.transmit ? 'TX' : 'RX',
          category: message.address,
          message:
              message.arguments.map((item) => item.toDebugString()).join(', ')),
      EosDiagnosticEvent(:final level, :final message) => UiLogEntry(
          timestamp: event.timestamp,
          kind: level.name.toUpperCase(),
          category: 'client',
          message: message),
      EosConnectionStateChanged(:final state, :final detail) => UiLogEntry(
          timestamp: event.timestamp,
          kind: 'INFO',
          category: 'state',
          message: detail == null ? state.name : '${state.name}: $detail'),
      EosQueryEvent(:final name, :final phase, :final detail) => UiLogEntry(
          timestamp: event.timestamp,
          kind: phase == EosQueryPhase.failed ? 'ERROR' : 'INFO',
          category: name,
          message: detail ?? phase.name),
      EosFeedbackListeningChangedEvent(:final listening, :final port) =>
        UiLogEntry(
          timestamp: event.timestamp,
          kind: 'INFO',
          category: 'feedback-socket',
          message: listening
              ? 'listening on UDP 0.0.0.0:$port'
              : 'stopped on UDP port $port',
        ),
      EosFeedbackDatagramEvent(
        :final sourceAddress,
        :final sourcePort,
        :final byteLength,
        :final decodeError
      ) =>
        UiLogEntry(
          timestamp: event.timestamp,
          kind: decodeError == null ? 'WIRE RX' : 'ERROR',
          category: '$sourceAddress:$sourcePort',
          message: decodeError == null
              ? '$byteLength UDP bytes'
              : '$byteLength UDP bytes could not decode: $decodeError',
        ),
      EosShowDataNotificationEvent(:final address) => UiLogEntry(
          timestamp: event.timestamp,
          kind: 'INFO',
          category: 'show-data',
          message: address),
      EosVersionChangedEvent() || EosCuePlaybackChangedEvent() => null,
    };
    if (entry != null)
      _log(entry.kind, entry.category, entry.message,
          timestamp: entry.timestamp);
  }

  void _log(String kind, String category, String message,
      {DateTime? timestamp}) {
    if (!mounted) return;
    setState(() {
      _logs.add(UiLogEntry(
          timestamp: timestamp ?? DateTime.now(),
          kind: kind,
          category: category,
          message: message));
      if (_logs.length > 5000) _logs.removeAt(0);
    });
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    if (_ownsClient) unawaited(_client.dispose());
    super.dispose();
  }

  void _select(int value) => setState(() => _index = value);

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    const destinations = <NavigationDestination>[
      NavigationDestination(icon: Icon(Icons.settings), label: 'Setup'),
      NavigationDestination(icon: Icon(Icons.tune), label: 'Focus Remote'),
      NavigationDestination(
          icon: Icon(Icons.playlist_play), label: 'Cue Stack'),
    ];
    final body = IndexedStack(index: _index, children: [
      SetupTab(
          key: ValueKey<String?>('setup-${_settings?.host}'),
          client: _client,
          store: _store,
          initialSettings: _settings,
          logs: _logs,
          onSaved: (value) => setState(() {
                _settings = value;
                _index = 1;
              })),
      FocusRemoteTab(
          client: _client,
          sendConfigured: _settings?.isValid == true,
          onOpenSetup: () => _select(0)),
      CueStackTab(client: _client, active: _index == 2),
    ]);
    return Scaffold(
      appBar: AppBar(title: const Text('PaperTek Eos Remote')),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 720)
          return Row(children: [
            NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                      icon: Icon(Icons.settings), label: Text('Setup')),
                  NavigationRailDestination(
                      icon: Icon(Icons.tune), label: Text('Focus Remote')),
                  NavigationRailDestination(
                      icon: Icon(Icons.playlist_play), label: Text('Cue Stack'))
                ]),
            const VerticalDivider(width: 1),
            Expanded(child: body)
          ]);
        return body;
      }),
      bottomNavigationBar: MediaQuery.sizeOf(context).width < 720
          ? NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _select,
              destinations: destinations)
          : null,
    );
  }
}
