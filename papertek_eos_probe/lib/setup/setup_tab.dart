import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:flutter/material.dart';

import '../osc_log_view.dart';
import '../settings/udp_settings.dart';
import '../settings/udp_settings_store.dart';

final class SetupTab extends StatefulWidget {
  const SetupTab(
      {required this.client,
      required this.store,
      required this.initialSettings,
      required this.logs,
      this.onSaved,
      super.key});
  final EosClient client;
  final UdpSettingsStore store;
  final UdpSettings? initialSettings;
  final List<UiLogEntry> logs;
  final ValueChanged<UdpSettings>? onSaved;

  @override
  State<SetupTab> createState() => _SetupTabState();
}

final class _SetupTabState extends State<SetupTab> {
  late final TextEditingController _host;
  late final TextEditingController _consolePort;
  late final TextEditingController _local;
  late final TextEditingController _feedbackPort;
  final ScrollController _logScroll = ScrollController();
  String? _message;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = widget.initialSettings;
    _host = TextEditingController(text: settings?.host ?? '');
    _consolePort =
        TextEditingController(text: '${settings?.consoleRxPort ?? 8000}');
    _local = TextEditingController(text: settings?.localAddress ?? '');
    _feedbackPort =
        TextEditingController(text: '${settings?.feedbackRxPort ?? 8001}');
  }

  @override
  void dispose() {
    _host.dispose();
    _consolePort.dispose();
    _local.dispose();
    _feedbackPort.dispose();
    _logScroll.dispose();
    super.dispose();
  }

  UdpSettings? _read() {
    final settings = UdpSettings(
        host: _host.text,
        consoleRxPort: int.tryParse(_consolePort.text) ?? -1,
        localAddress: _local.text,
        feedbackRxPort: int.tryParse(_feedbackPort.text) ?? -1);
    if (!settings.isValid) {
      setState(() => _message =
          'Enter a host, valid ports, and an optional IPv4 source address.');
      return null;
    }
    return settings;
  }

  Future<void> _save() async {
    final settings = _read();
    if (settings == null) return;
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await widget.store.save(settings);
      if (widget.client is EosOscClient)
        await (widget.client as EosOscClient)
            .connect(settings.toConnectionConfig());
      widget.onSaved?.call(settings);
      if (mounted)
        setState(() => _message = 'Settings saved. No datagram was sent.');
    } on Object catch (error) {
      if (mounted) setState(() => _message = 'Could not save settings: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _startFeedback() async {
    if (widget.client is! EosOscClient) {
      setState(() => _message = 'Feedback is controlled by the UDP client.');
      return;
    }
    try {
      final client = widget.client as EosOscClient;
      await client.startFeedback();
      if (mounted) {
        setState(() => _message =
            'Feedback listening on UDP 0.0.0.0:${client.feedbackPort}.');
      }
    } on Object catch (error) {
      if (mounted) setState(() => _message = 'Feedback unavailable: $error');
    }
  }

  Future<void> _stopFeedback() async {
    if (widget.client is EosOscClient)
      await (widget.client as EosOscClient).stopFeedback();
    if (mounted)
      setState(() => _message = 'Feedback stopped. Sending remains available.');
  }

  @override
  Widget build(BuildContext context) {
    final feedback = widget.client is EosOscClient
        ? (widget.client as EosOscClient).feedbackState
        : EosFeedbackState.stopped;
    return SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('UDP Setup',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                                const SizedBox(height: 6),
                                const Text(
                                    'Sending is unframed UDP and does not require Connect, Start, or feedback. Feedback is an optional receive socket.'),
                                const SizedBox(height: 14),
                                _field(_host, 'Console IP/host'),
                                const SizedBox(height: 10),
                                _field(_consolePort,
                                    'Console OSC UDP RX (app sends here)',
                                    number: true),
                                const SizedBox(height: 10),
                                _field(_local, 'Local/source IPv4 (optional)',
                                    hint:
                                        'Blank lets the OS choose the route.'),
                                const SizedBox(height: 10),
                                _field(_feedbackPort,
                                    'App UDP RX (console sends here)',
                                    number: true),
                                const SizedBox(height: 12),
                                Wrap(spacing: 10, runSpacing: 10, children: [
                                  FilledButton.icon(
                                      key: const Key('save_settings_button'),
                                      onPressed: _saving ? null : _save,
                                      icon: const Icon(Icons.save),
                                      label: Text(_saving
                                          ? 'Saving…'
                                          : 'Save settings')),
                                  FilledButton.tonalIcon(
                                      key: const Key('start_feedback_button'),
                                      onPressed:
                                          feedback == EosFeedbackState.listening
                                              ? null
                                              : _startFeedback,
                                      icon: const Icon(Icons.sensors),
                                      label: const Text('Start feedback')),
                                  OutlinedButton.icon(
                                      key: const Key('stop_feedback_button'),
                                      onPressed:
                                          feedback == EosFeedbackState.stopped
                                              ? null
                                              : _stopFeedback,
                                      icon: const Icon(Icons.sensors_off),
                                      label: const Text('Stop feedback')),
                                ]),
                                const SizedBox(height: 10),
                                Wrap(spacing: 16, runSpacing: 8, children: [
                                  _status(
                                      'Send configured',
                                      widget.initialSettings?.isValid == true ||
                                          widget.client.connectionState ==
                                              EosConnectionState.ready,
                                      context),
                                  _status(
                                      'Feedback listening',
                                      feedback == EosFeedbackState.listening,
                                      context)
                                ]),
                                if (_message != null)
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(_message!,
                                          key: const Key('setup_message'))),
                              ]))),
                  const SizedBox(height: 10),
                  _checklist(context),
                  const SizedBox(height: 10),
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text('Diagnostics',
                                    style:
                                        Theme.of(context).textTheme.titleLarge),
                                const SizedBox(height: 8),
                                SizedBox(
                                    height: 260,
                                    child: OscLogView(
                                        entries: widget.logs,
                                        scrollController: _logScroll,
                                        onAutoScrollChanged: (_) {},
                                        onClear: () {},
                                        autoScroll: true))
                              ]))),
                ])));
  }

  Widget _field(TextEditingController controller, String label,
          {bool number = false, String? hint}) =>
      TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              border: const OutlineInputBorder()));
  Widget _status(String label, bool value, BuildContext context) => Chip(
      avatar: Icon(value ? Icons.check_circle : Icons.circle_outlined,
          color: value ? Colors.green : Theme.of(context).colorScheme.outline),
      label: Text('$label: ${value ? 'yes' : 'no'}'));
  Widget _checklist(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Console feedback checklist',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
                '• Enable Eos OSC RX for commands.\n• Enable Eos OSC TX for feedback.\n• Set the console OSC TX destination IP to this computer.\n• Set the console OSC TX port to the App UDP RX port above.\n• Local send success means only that Windows accepted the datagram; it is not an Eos acknowledgement.')
          ])));
}
