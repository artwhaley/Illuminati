import 'dart:async';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:flutter/material.dart';

final class CueStackTab extends StatefulWidget {
  const CueStackTab({required this.client, required this.active, super.key});
  final EosClient client;
  final bool active;

  @override
  State<CueStackTab> createState() => _CueStackTabState();
}

final class _CueStackTabState extends State<CueStackTab> {
  late EosCuePlaybackState _state;
  StreamSubscription<EosClientEvent>? _events;
  bool _activated = false;
  bool _busy = false;
  String? _localStatus;

  @override
  void initState() {
    super.initState();
    _state = widget.client.playbackState;
    _events = widget.client.events.listen((event) {
      if (!mounted) return;
      if (event case EosCuePlaybackChangedEvent(:final playbackState)) {
        setState(() => _state = playbackState);
      } else if (event
          case EosFeedbackListeningChangedEvent(:final listening)) {
        _activated = false;
        if (listening) _activateIfNeeded();
        setState(() {});
      } else if (event is EosFeedbackDatagramEvent) {
        setState(() {});
      }
    });
    _activateIfNeeded();
  }

  @override
  void didUpdateWidget(covariant CueStackTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _activateIfNeeded();
  }

  void _activateIfNeeded() {
    if (!widget.active || _activated) return;
    if (widget.client case EosOscClient(:final isFeedbackListening)) {
      if (!isFeedbackListening) return;
    }
    _activated = true;
    final playback = widget.client is EosPlaybackClient
        ? widget.client as EosPlaybackClient
        : null;
    if (playback != null) unawaited(playback.activateCueStack());
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    super.dispose();
  }

  Future<void> _run(String name, Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) setState(() => _localStatus = '$name sent');
    } on Object catch (error) {
      if (mounted) setState(() => _localStatus = '$name failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final playback = widget.client is EosPlaybackClient
        ? widget.client as EosPlaybackClient
        : null;
    final stale = _state.lastFeedbackAt == null ||
        DateTime.now().difference(_state.lastFeedbackAt!) >
            const Duration(seconds: 3);
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
                                Text('Cue Stack',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                                const SizedBox(height: 8),
                                _cueCard(
                                    'Previous',
                                    _identity(
                                        _state.previousCueList,
                                        _state.previousCue,
                                        _state.previousPart),
                                    _state.previousText),
                                _cueCard(
                                    'Current',
                                    _identity(_state.activeCueList,
                                        _state.activeCue, _state.activePart),
                                    _state.activeText,
                                    detail: _state.currentDetail),
                                _cueCard(
                                    'Next',
                                    _identity(_state.pendingCueList,
                                        _state.pendingCue, _state.pendingPart),
                                    _state.pendingText,
                                    detail: _state.nextDetail),
                                const SizedBox(height: 10),
                                if (_state.fadeProgress != null) ...[
                                  Text(
                                      'Fade progress: ${(_state.fadeProgress! * 100).round()}%'),
                                  LinearProgressIndicator(
                                      value: _state.fadeProgress)
                                ],
                                if (_state.lastFeedbackAt == null)
                                  const Text(
                                      'Progress unavailable; no feedback received.'),
                                const SizedBox(height: 8),
                                Text(
                                    'Feedback: ${widget.client is EosOscClient ? (widget.client as EosOscClient).feedbackState.name : 'injected'}${stale ? ' (stale)' : ''}'),
                                if (widget.client case EosOscClient client) ...[
                                  Text(
                                      'UDP listener: 0.0.0.0:${client.feedbackPort ?? '—'}'),
                                  Text(
                                      'Raw UDP packets: ${client.feedbackDatagramCount}   Decode errors: ${client.feedbackDecodeErrorCount}'),
                                  Text(
                                      'Last raw packet: ${client.lastFeedbackDatagramAt?.toLocal() ?? 'never'}${client.lastFeedbackSourceAddress == null ? '' : ' from ${client.lastFeedbackSourceAddress}:${client.lastFeedbackSourcePort}'}'),
                                ],
                                Text(
                                    'Last feedback: ${_state.lastFeedbackAt?.toLocal() ?? 'never'}'),
                                if (_state.latestEventAction != null)
                                  Text(
                                      'Latest cue event: ${_state.latestEventAction}'),
                                if (stale)
                                  const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                          'Start feedback in Setup to refresh cue status. Playback controls remain available.')),
                              ]))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: FilledButton.icon(
                            key: const Key('cue_go_button'),
                            onPressed: playback == null
                                ? null
                                : () => _run('GO', playback.goMainPlayback),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('GO'),
                            style: _controlStyle())),
                    const SizedBox(width: 8),
                    Expanded(
                        child: FilledButton.tonalIcon(
                            key: const Key('cue_back_button'),
                            onPressed: playback == null
                                ? null
                                : () => _run('Back', playback.backMainPlayback),
                            icon: const Icon(Icons.skip_previous),
                            label: const Text('Back'),
                            style: _controlStyle())),
                    const SizedBox(width: 8),
                    Expanded(
                        child: OutlinedButton.icon(
                            key: const Key('cue_stop_button'),
                            onPressed: playback == null
                                ? null
                                : () => _run('Stop', playback.stopMainPlayback),
                            icon: const Icon(Icons.stop),
                            label: const Text('Stop'),
                            style: _controlStyle())),
                  ]),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    key: const Key('cue_zero_button'),
                    onPressed: playback == null
                        ? null
                        : () => _run('Go to Cue 0', playback.goToCueZero),
                    icon: const Icon(Icons.first_page),
                    label: const Text('Go to Cue 0'),
                    style: _cueZeroStyle(context),
                  ),
                  if (_localStatus != null)
                    Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(_localStatus!,
                            key: const Key('cue_local_status'))),
                ])));
  }

  Widget _cueCard(String title, String identity, String text,
          {EosCueBankRow? detail}) =>
      Card(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(identity.isEmpty ? '—' : identity,
                        style: Theme.of(context).textTheme.titleLarge),
                    Text(text.isEmpty ? '—' : text),
                    if (detail != null)
                      Text(
                          'Label: ${detail.label.isEmpty ? '—' : detail.label}   Duration: ${_time(detail.durationMs)}   Remaining: ${_time(detail.remainingMs)}\nNotes: ${detail.notes.isEmpty ? '—' : detail.notes}\nScene: ${detail.scene.isEmpty ? '—' : detail.scene}${detail.sceneEnd ? ' (end)' : ''}')
                  ])));
  String _identity(
          EosTargetNumber? list, EosTargetNumber? cue, EosTargetNumber? part) =>
      list == null || cue == null
          ? ''
          : 'List ${list.value}  Cue ${cue.value}${part == null ? '' : '  Part ${part.value}'}';
  String _time(int? milliseconds) => milliseconds == null
      ? '—'
      : '${(milliseconds / 1000).toStringAsFixed(1)}s';
  static ButtonStyle _controlStyle() => const ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size.fromHeight(64)));

  static ButtonStyle _cueZeroStyle(BuildContext context) => ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(56)),
      backgroundColor:
          WidgetStatePropertyAll(Theme.of(context).colorScheme.errorContainer),
      foregroundColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.onErrorContainer));
}
