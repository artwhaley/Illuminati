import 'dart:async';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'command_model.dart';

final class FocusRemoteTab extends StatefulWidget {
  const FocusRemoteTab({
    required this.client,
    this.sendConfigured = false,
    this.onOpenSetup,
    super.key,
  });

  final EosClient client;
  final bool sendConfigured;
  final VoidCallback? onOpenSetup;

  @override
  State<FocusRemoteTab> createState() => _FocusRemoteTabState();
}

final class _FocusRemoteTabState extends State<FocusRemoteTab> {
  final FocusNode _keyboardFocus = FocusNode();
  final FocusCommandBuffer _buffer = FocusCommandBuffer();
  String? _error;
  String? _lastTransmitted;
  bool _busy = false;
  int? _lastChannel;
  double? _lastLevel;
  bool _stepping = false;

  bool get _canSend =>
      widget.sendConfigured ||
      widget.client.connectionState == EosConnectionState.ready;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _keyboardFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    super.dispose();
  }

  void _key(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.backspace) return _backspace();
    if (key == LogicalKeyboardKey.escape) return _clear();
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      return _append(FocusSemanticToken.enter);
    }
    if (key == LogicalKeyboardKey.at) return _append(FocusSemanticToken.at);
    final label = key.keyLabel;
    if (RegExp(r'^\d$').hasMatch(label)) return _digit(label);
    if (label == '.') return _decimal();
  }

  void _digit(String digit) => setState(() {
        _buffer.appendDigit(digit);
        _error = null;
      });

  void _decimal() => setState(() {
        _buffer.appendDecimal();
        _error = null;
      });

  void _append(FocusSemanticToken token) {
    if (_buffer.tokens.isEmpty && _isChannelOriented(token)) {
      if (_lastChannel == null) {
        setState(() => _error =
            'Enter a channel first; no previous channel is available.');
        return;
      }
      _buffer.appendChannel(_lastChannel!);
    }
    setState(() {
      _buffer.appendSemantic(token);
      _error = null;
    });
    if (token == FocusSemanticToken.full ||
        token == FocusSemanticToken.out ||
        token == FocusSemanticToken.release ||
        token == FocusSemanticToken.enter) {
      _tryCompileAndSend();
    }
  }

  bool _isChannelOriented(FocusSemanticToken token) => const {
        FocusSemanticToken.at,
        FocusSemanticToken.full,
        FocusSemanticToken.out,
        FocusSemanticToken.release,
        FocusSemanticToken.position,
        FocusSemanticToken.color,
        FocusSemanticToken.beam,
      }.contains(token);

  void _backspace() => setState(() {
        _buffer.backspace();
        _error = null;
      });

  void _clear() => setState(() {
        _buffer.clear();
        _error = null;
      });

  Future<void> _tryCompileAndSend() async {
    FocusCompiledCommand compiled;
    try {
      compiled = FocusCommandCompiler.compile(_buffer.tokens);
    } on EosClientException catch (error) {
      setState(() => _error = error.message);
      return;
    }
    if (!_canSend) {
      setState(() => _error = 'Save a valid send endpoint in Setup first.');
      return;
    }
    final sender = widget.client is EosPlaybackClient
        ? widget.client as EosPlaybackClient
        : null;
    if (sender == null) {
      setState(() =>
          _error = 'This client does not expose the command-send boundary.');
      return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await sender.sendCommand(compiled.text);
      if (!mounted) return;
      setState(() {
        _lastTransmitted = compiled.text;
        _error = null;
        _buffer.clear();
        final channelMatch = RegExp(r'^Chan (\d+)').firstMatch(compiled.text);
        if (channelMatch != null) {
          _lastChannel = int.parse(channelMatch.group(1)!);
        }
        final levelMatch =
            RegExp(r'^Chan \d+ At ([0-9.]+) Enter$').firstMatch(compiled.text);
        if (levelMatch != null) {
          _lastLevel = double.parse(levelMatch.group(1)!);
        } else if (compiled.text.endsWith(' Full Enter')) {
          _lastLevel = 100;
        } else if (compiled.text.endsWith(' Out Enter')) {
          _lastLevel = 0;
        }
      });
    } on Object catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _step(int delta) async {
    final channel = _lastChannel;
    final level = _lastLevel;
    if (_stepping ||
        !_canSend ||
        channel == null ||
        level == null ||
        channel + delta < 1) {
      return;
    }
    setState(() => _stepping = true);
    try {
      await widget.client.releaseChannel(channel);
      final next = channel + delta;
      await widget.client.setChannelLevel(channel: next, level: level);
      if (mounted) setState(() => _lastChannel = next);
    } on Object catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _stepping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: KeyboardListener(
        focusNode: _keyboardFocus,
        onKeyEvent: _key,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Command line',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          InputDecorator(
                            decoration: const InputDecoration(
                                border: OutlineInputBorder()),
                            child: Text(
                              _buffer.display.isEmpty ? '—' : _buffer.display,
                              key: const Key('command_line'),
                            ),
                          ),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                _error!,
                                key: const Key('command_error'),
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          if (_lastTransmitted != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Last locally sent: $_lastTransmitted',
                                key: const Key('last_transmitted'),
                              ),
                            ),
                          if (_lastChannel != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                'Selected channel: $_lastChannel',
                                key: const Key('selected_channel'),
                              ),
                            ),
                          if (!_canSend)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: OutlinedButton(
                                onPressed: widget.onOpenSetup,
                                child: const Text(
                                    'Open Setup to configure sending'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _keypad(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _keypad() => Column(children: [
        _row([
          _button('1', () => _digit('1')),
          _button('2', () => _digit('2')),
          _button('3', () => _digit('3')),
        ]),
        _row([
          _button('4', () => _digit('4')),
          _button('5', () => _digit('5')),
          _button('6', () => _digit('6')),
        ]),
        _row([
          _button('7', () => _digit('7')),
          _button('8', () => _digit('8')),
          _button('9', () => _digit('9')),
        ]),
        _row([
          _button('.', _decimal),
          _button('0', () => _digit('0')),
          const SizedBox(height: 56),
        ]),
        _row([
          _button('@', () => _append(FocusSemanticToken.at),
              filled: true, compact: true),
          _button('Full', () => _append(FocusSemanticToken.full),
              filled: true, compact: true),
          _button('Out', () => _append(FocusSemanticToken.out),
              filled: true, compact: true),
          _button('Release', () => _append(FocusSemanticToken.release),
              filled: true, compact: true),
          _button('Enter', () => _append(FocusSemanticToken.enter),
              filled: true, compact: true),
        ]),
        _row([
          _button('Clear', _clear),
          _button('Backspace', _backspace),
          _button('Thru', () => _append(FocusSemanticToken.thru),
              filled: true, compact: true),
        ]),
        _row([
          OutlinedButton.icon(
            key: const Key('previous_channel_button'),
            onPressed: _canSend &&
                    !_stepping &&
                    _lastChannel != null &&
                    _lastLevel != null &&
                    _lastChannel! > 1
                ? () => unawaited(_step(-1))
                : null,
            icon: const Icon(Icons.skip_previous),
            label: const Text('Previous'),
            style: _largeButtonStyle(),
          ),
          OutlinedButton.icon(
            key: const Key('next_channel_button'),
            onPressed: _canSend &&
                    !_stepping &&
                    _lastChannel != null &&
                    _lastLevel != null
                ? () => unawaited(_step(1))
                : null,
            icon: const Icon(Icons.skip_next),
            label: const Text('Next'),
            style: _largeButtonStyle(),
          ),
        ]),
        _row([
          _button('Position', () => _append(FocusSemanticToken.position)),
          _button('Color', () => _append(FocusSemanticToken.color)),
          _button('Beam', () => _append(FocusSemanticToken.beam)),
        ]),
        _row([
          _button('Record', () => _append(FocusSemanticToken.record)),
          _button('Update', () => _append(FocusSemanticToken.update)),
          _button('Cue Only', () => _append(FocusSemanticToken.cueOnly)),
        ], bottomSpacing: 0),
      ]);

  Widget _row(List<Widget> children, {double bottomSpacing = 8}) {
    final spaced = <Widget>[];
    for (final child in children) {
      if (spaced.isNotEmpty) spaced.add(const SizedBox(width: 8));
      spaced.add(Expanded(child: child));
    }
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Row(children: spaced),
    );
  }

  Widget _button(
    String label,
    VoidCallback onPressed, {
    bool filled = false,
    bool compact = false,
  }) =>
      filled
          ? FilledButton(
              onPressed: onPressed,
              style: compact ? _compactButtonStyle() : _largeButtonStyle(),
              child: Text(
                label,
                maxLines: 1,
                style: compact ? const TextStyle(fontSize: 12) : null,
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: _largeButtonStyle(),
              child: Text(label),
            );

  static ButtonStyle _largeButtonStyle() => const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size.fromHeight(56)),
      );

  static ButtonStyle _compactButtonStyle() => const ButtonStyle(
        minimumSize: WidgetStatePropertyAll(Size(0, 56)),
        padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 3)),
      );
}
