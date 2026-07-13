import 'dart:async';
import 'dart:math';

import 'eos_models.dart';
import 'eos_protocol.dart';
import 'eos_tcp_transport.dart';
import 'eos_udp_receiver.dart';
import 'eos_udp_sender.dart';
import 'osc_codec.dart';

/// UDP-first Eos client. The optional [transport] exists only for dormant,
/// explicitly injected legacy TCP tests; the application constructs the
/// default UDP sender/receiver path.
final class EosOscClient implements EosClient, EosPlaybackClient {
  EosOscClient({
    EosTransport? transport,
    EosUdpSender? sender,
    EosUdpReceiver? receiver,
  })  : _legacyTransport = transport,
        _sender = sender ?? EosUdpSender(),
        _receiver = receiver ?? EosUdpReceiver() {
    if (_legacyTransport != null) {
      _transportSubscription =
          _legacyTransport.events.listen(_handleTransportEvent);
    }
    _receiverSubscription = _receiver.messages.listen(_handleReceivedMessage);
    _receiverDatagramSubscription =
        _receiver.datagrams.listen(_handleFeedbackDatagram);
  }

  final EosTransport? _legacyTransport;
  final EosUdpSender _sender;
  final EosUdpReceiver _receiver;
  final StreamController<EosClientEvent> _events =
      StreamController<EosClientEvent>.broadcast(sync: true);
  final List<_MessageWaiter> _waiters = <_MessageWaiter>[];
  final List<_MessageCollector> _collectors = <_MessageCollector>[];
  final Set<String> _requestedCueDetails = <String>{};
  final EosListReassembler _listReassembler = EosListReassembler();
  StreamSubscription<EosTransportEvent>? _transportSubscription;
  late final StreamSubscription<OscMessage> _receiverSubscription;
  late final StreamSubscription<EosUdpDatagramEvent>
      _receiverDatagramSubscription;
  EosConnectionState _connectionState = EosConnectionState.disconnected;
  EosFeedbackState _feedbackState = EosFeedbackState.stopped;
  Object? _feedbackError;
  EosConnectionConfig? _config;
  EosVersionInfo _versionInfo = const EosVersionInfo();
  EosCuePlaybackState _playbackState = const EosCuePlaybackState();
  Future<void> _queryTail = Future<void>.value();
  bool _cueStackActivated = false;
  bool _disposed = false;
  int _pingCounter = 0;

  @override
  Stream<EosClientEvent> get events => _events.stream;
  @override
  EosConnectionState get connectionState => _connectionState;
  @override
  EosVersionInfo get versionInfo => _versionInfo;
  @override
  EosCuePlaybackState get playbackState => _playbackState;
  EosFeedbackState get feedbackState => _feedbackState;
  Object? get feedbackError => _feedbackError;
  bool get isFeedbackListening => _feedbackState == EosFeedbackState.listening;
  int? get feedbackPort => _config?.receivePort;
  int get feedbackDatagramCount => _receiver.datagramCount;
  int get feedbackDecodeErrorCount => _receiver.decodeErrorCount;
  DateTime? get lastFeedbackDatagramAt => _receiver.lastDatagramAt;
  String? get lastFeedbackSourceAddress => _receiver.lastSourceAddress;
  int? get lastFeedbackSourcePort => _receiver.lastSourcePort;

  Future<void> connect(EosConnectionConfig config) async {
    _ensureNotDisposed();
    _config = config;
    _versionInfo = const EosVersionInfo();
    _playbackState = const EosCuePlaybackState();
    _setConnectionState(EosConnectionState.connecting);
    try {
      if (_legacyTransport != null) {
        await _legacyTransport.connect(config);
      } else {
        await _sender.configure(config);
      }
      _setConnectionState(EosConnectionState.ready);
    } on Object catch (error) {
      _setConnectionState(EosConnectionState.faulted, detail: '$error');
      rethrow;
    }
  }

  Future<void> startFeedback() async {
    _ensureConfigured();
    if (_legacyTransport != null) {
      throw const EosConnectionException(
        'Feedback lifecycle is unavailable on the dormant legacy transport.',
      );
    }
    try {
      await _receiver.start(_config!);
      _cueStackActivated = false;
      _requestedCueDetails.clear();
      _feedbackState = EosFeedbackState.listening;
      _feedbackError = null;
      _emitDiagnostic(EosDiagnosticLevel.info,
          'Feedback listening on UDP 0.0.0.0:${_config!.receivePort}.');
      _events.add(EosFeedbackListeningChangedEvent(
          listening: true, port: _config!.receivePort));
    } on Object catch (error) {
      _feedbackState = EosFeedbackState.faulted;
      _feedbackError = error;
      _emitDiagnostic(EosDiagnosticLevel.error, 'Feedback bind failed: $error');
      rethrow;
    }
  }

  Future<void> stopFeedback() async {
    if (_legacyTransport == null) await _receiver.stop();
    _cueStackActivated = false;
    _feedbackState = EosFeedbackState.stopped;
    _emitDiagnostic(EosDiagnosticLevel.info, 'Feedback stopped.');
    _events.add(EosFeedbackListeningChangedEvent(
        listening: false, port: _config?.receivePort));
    _cancelPending(const EosConnectionException('Feedback stopped.'));
  }

  Future<void> disconnect() async {
    if (_connectionState == EosConnectionState.disconnected) return;
    await stopFeedback();
    _cancelPending(const EosConnectionException('OSC client disconnected.'));
    _listReassembler.clear();
    if (_legacyTransport != null) {
      await _legacyTransport.close();
    } else {
      await _sender.disposeSocket();
    }
    _config = null;
    _cueStackActivated = false;
    _setConnectionState(EosConnectionState.disconnected);
  }

  Future<PingResult> ping() async {
    _ensureConfigured();
    if (!isFeedbackListening && _legacyTransport == null) {
      throw const EosConnectionException(
          'Start feedback before requesting a ping.');
    }
    final token = 'papertek-${Random().nextInt(0xffff)}-${_pingCounter++}';
    final stopwatch = Stopwatch()..start();
    final waiter = _MessageWaiter(
      predicate: (message) =>
          message.address == '/eos/out/ping' &&
          message.arguments.any(
              (argument) => argument is OscString && argument.data == token),
      description: 'ping response',
      timeout: _queryTimeout,
      onFinished: _removeWaiter,
    );
    _waiters.add(waiter);
    await _send(EosProtocol.ping(token));
    await waiter.completer.future;
    stopwatch.stop();
    return PingResult(token: token, roundTrip: stopwatch.elapsed);
  }

  @override
  Future<void> setChannelLevel(
      {required int channel, required double level}) async {
    _validateChannel(channel);
    if (!level.isFinite || level < 0 || level > 100) {
      throw EosValidationException(
          'Channel intensity must be between 0 and 100: $level.');
    }
    await _send(EosProtocol.setChannelLevel(channel, level));
  }

  @override
  Future<void> setChannelFull(int channel) async {
    _validateChannel(channel);
    await _send(EosProtocol.setChannelLevel(channel, 100));
  }

  @override
  Future<void> setChannelOut(int channel) async {
    _validateChannel(channel);
    await _send(EosProtocol.setChannelLevel(channel, 0));
  }

  @override
  Future<void> releaseChannel(int channel) async {
    _validateChannel(channel);
    await _send(EosProtocol.releaseChannel(channel));
  }

  @override
  Future<void> sendCommand(String command) =>
      _send(OscMessage('/eos/newcmd', <OscArgument>[OscString(command)]));

  @override
  Future<void> goMainPlayback() => _send(EosProtocol.goMainPlayback());

  @override
  Future<void> backMainPlayback() => _send(EosProtocol.backMainPlayback());

  @override
  Future<void> goToCueZero() => _send(EosProtocol.goToCueZero());

  @override
  Future<void> stopMainPlayback() => _send(EosProtocol.stopMainPlayback());

  @override
  Future<void> stopBackMainPlayback() =>
      _send(EosProtocol.stopBackMainPlayback());

  @override
  Future<void> activateCueStack() async {
    if (!isFeedbackListening || _cueStackActivated) return;
    _cueStackActivated = true;
    await _send(EosProtocol.configureCueStackBank());
    final state = _playbackState;
    for (final identity in <(EosTargetNumber?, EosTargetNumber?)>[
      (state.activeCueList, state.activeCue),
      (state.pendingCueList, state.pendingCue),
    ]) {
      if (identity.$1 != null && identity.$2 != null) {
        await _requestCueDetail(identity.$1!, identity.$2!);
      }
    }
  }

  @override
  Future<void> fireCue(
          {required EosTargetNumber cueList, required EosTargetNumber cue}) =>
      _send(EosProtocol.fireCue(cueList, cue));

  Future<EosVersionInfo> getVersion() async {
    await _sendAndWaitFor(
      request: EosProtocol.getVersion(),
      predicate: (message) => message.address == '/eos/out/get/version',
      description: 'version response',
    );
    return _versionInfo;
  }

  Future<String?> getShowPath() async {
    final message = await _sendAndWaitFor(
      request: EosProtocol.getShowPath(),
      predicate: (message) => message.address == '/eos/out/get/show/path',
      description: 'show path response',
    );
    return message.arguments.isEmpty ? null : EosProtocol.stringAt(message, 0);
  }

  Future<List<EosCueList>> getCueLists() =>
      _enqueueQuery('cue lists', () async {
        final count = await _requestCount(
            EosProtocol.getCueListCount(), '/eos/out/get/cuelist/count');
        final results = <EosCueList>[];
        for (var index = 0; index < count; index++) {
          final message = await _sendAndWaitFor(
            request: EosProtocol.getCueListAtIndex(index),
            predicate: (item) =>
                EosProtocol.isPrimaryCueListResponse(item) &&
                EosProtocol.intAt(item, 0) == index,
            description: 'cue list $index',
          );
          results.add(EosProtocol.parseCueList(message));
        }
        return List<EosCueList>.unmodifiable(results);
      });

  Future<List<EosCue>> getCues(EosTargetNumber cueList) =>
      _enqueueQuery('cues $cueList', () async {
        final count = await _requestCount(EosProtocol.getCueCount(cueList),
            '/eos/out/get/cue/$cueList/count');
        final results = <EosCue>[];
        for (var index = 0; index < count; index++) {
          final message = await _sendAndWaitFor(
            request: EosProtocol.getCueAtIndex(cueList, index),
            predicate: (item) =>
                EosProtocol.isPrimaryCueResponse(item, cueList) &&
                EosProtocol.intAt(item, 0) == index,
            description: 'cue $index',
          );
          results.add(EosProtocol.parseCue(message));
        }
        return List<EosCue>.unmodifiable(results);
      });

  Future<List<EosSubmaster>> getSubmasters() =>
      _enqueueQuery('submasters', () async {
        final count = await _requestCount(
            EosProtocol.getSubmasterCount(), '/eos/out/get/sub/count');
        final results = <EosSubmaster>[];
        for (var index = 0; index < count; index++) {
          final message = await _sendAndWaitFor(
            request: EosProtocol.getSubmasterAtIndex(index),
            predicate: (item) =>
                EosProtocol.isPrimarySubmasterResponse(item) &&
                EosProtocol.intAt(item, 0) == index,
            description: 'submaster $index',
          );
          results.add(EosProtocol.parseSubmaster(message));
        }
        return List<EosSubmaster>.unmodifiable(results);
      });

  Future<List<EosPatchPart>> getPatch(int channel) async {
    _validateChannel(channel);
    final messages = await _sendAndCollect(
      request: EosProtocol.getPatch(channel),
      predicate: (message) =>
          EosProtocol.isPrimaryPatchResponse(message, channel),
      description: 'patch for channel $channel',
    );
    return List<EosPatchPart>.unmodifiable(
        messages.map(EosProtocol.parsePatchPart));
  }

  Future<EosFixtureParameters> getParameters(int channel) async {
    _validateChannel(channel);
    final message = await _sendAndWaitFor(
      request: EosProtocol.getParameters(channel),
      predicate: (item) => item.address == '/eos/out/get/params/$channel',
      description: 'parameters for channel $channel',
    );
    return EosProtocol.parseParameters(message);
  }

  Future<void> _send(OscMessage message) async {
    _ensureConfigured();
    try {
      if (_legacyTransport != null) {
        await _legacyTransport.send(message);
      } else {
        await _sender.send(message);
      }
      _events.add(EosOscMessageEvent(
          direction: EosOscDirection.transmit, message: message));
    } on Object catch (error) {
      _emitDiagnostic(EosDiagnosticLevel.error, 'UDP send failed: $error');
      rethrow;
    }
  }

  Future<void> _requestCueDetail(
      EosTargetNumber list, EosTargetNumber cue) async {
    final key = '$list/$cue';
    if (!_requestedCueDetails.add(key)) return;
    await _send(EosProtocol.getCue(list, cue));
  }

  Future<T> _enqueueQuery<T>(String name, Future<T> Function() operation) {
    _ensureConfigured();
    final completer = Completer<T>();
    _queryTail = _queryTail.then((_) async {
      _events.add(EosQueryEvent(name: name, phase: EosQueryPhase.started));
      try {
        completer.complete(await operation());
        _events.add(EosQueryEvent(name: name, phase: EosQueryPhase.completed));
      } on Object catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
        _events.add(EosQueryEvent(
            name: name, phase: EosQueryPhase.failed, detail: '$error'));
      }
    });
    return completer.future;
  }

  Future<int> _requestCount(OscMessage request, String address) async {
    final response = await _sendAndWaitFor(
        request: request,
        predicate: (item) => item.address == address,
        description: address);
    return EosProtocol.intAt(response, 0);
  }

  Future<OscMessage> _sendAndWaitFor(
      {required OscMessage request,
      required bool Function(OscMessage) predicate,
      required String description}) async {
    final waiter = _MessageWaiter(
        predicate: predicate,
        description: description,
        timeout: _queryTimeout,
        onFinished: _removeWaiter);
    _waiters.add(waiter);
    try {
      await _send(request);
      return await waiter.completer.future;
    } on Object catch (error, stackTrace) {
      waiter.cancel(error);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<List<OscMessage>> _sendAndCollect(
      {required OscMessage request,
      required bool Function(OscMessage) predicate,
      required String description}) async {
    final collector = _MessageCollector(
        predicate: predicate,
        description: description,
        timeout: _queryTimeout,
        onFinished: _removeCollector);
    _collectors.add(collector);
    try {
      await _send(request);
      return await collector.completer.future;
    } on Object {
      collector.cancel();
      rethrow;
    }
  }

  void _handleTransportEvent(EosTransportEvent event) {
    switch (event) {
      case EosTransportMessage(:final message):
        _handleReceivedMessage(message);
      case EosTransportProblem(:final error, :final fatal):
        _emitDiagnostic(
            fatal ? EosDiagnosticLevel.error : EosDiagnosticLevel.warning,
            '$error');
      case EosTransportClosed():
        if (!_disposed)
          _setConnectionState(EosConnectionState.faulted,
              detail: 'Legacy transport closed.');
    }
  }

  void _handleReceivedMessage(OscMessage message) {
    _events.add(EosOscMessageEvent(
        direction: EosOscDirection.receive, message: message));
    final logical = _listReassembler.accept(message,
        timeout: _queryTimeout,
        onExpired: (detail) =>
            _emitDiagnostic(EosDiagnosticLevel.warning, detail));
    if (logical == null) return;
    _applyGlobalMessage(logical);
    for (final collector in List<_MessageCollector>.from(_collectors))
      collector.accept(logical);
    for (final waiter in List<_MessageWaiter>.from(_waiters)) {
      if (waiter.accept(logical)) break;
    }
  }

  void _handleFeedbackDatagram(EosUdpDatagramEvent datagram) {
    _events.add(EosFeedbackDatagramEvent(
      sourceAddress: datagram.sourceAddress,
      sourcePort: datagram.sourcePort,
      byteLength: datagram.byteLength,
      decodeError: datagram.decodeError,
    ));
  }

  void _applyGlobalMessage(OscMessage message) {
    if (message.address == '/eos/out/get/version') {
      var updated = _versionInfo;
      for (final argument in message.arguments) {
        if (argument case OscString(:final data)) {
          if (updated.softwareVersion == null) {
            updated = updated.copyWith(softwareVersion: data);
          } else if (updated.fixtureLibraryVersion == null &&
              data != updated.softwareVersion) {
            updated = updated.copyWith(fixtureLibraryVersion: data);
          }
        } else if (argument case OscBool(:final data)) {
          updated = updated.copyWith(gelOnlyMode: data);
        }
      }
      _versionInfo = updated;
      _events.add(EosVersionChangedEvent(updated));
    }
    if (message.address.startsWith('/eos/out/notify/'))
      _events.add(EosShowDataNotificationEvent(message.address));
    if (_applyPlaybackMessage(message))
      _events.add(EosCuePlaybackChangedEvent(_playbackState));
  }

  bool _applyPlaybackMessage(OscMessage message) {
    final now = DateTime.now();
    final segments = EosProtocol.addressSegments(message.address);
    var changed = false;
    if (message.address.endsWith('/text') &&
        segments.length == 5 &&
        segments[0] == 'eos' &&
        segments[1] == 'out' &&
        segments[3] == 'cue') {
      final text = _firstString(message);
      _playbackState = switch (segments[2]) {
        'previous' =>
          _playbackState.copyWith(previousText: text, lastFeedbackAt: now),
        'active' =>
          _playbackState.copyWith(activeText: text, lastFeedbackAt: now),
        'pending' =>
          _playbackState.copyWith(pendingText: text, lastFeedbackAt: now),
        _ => _playbackState,
      };
      return segments[2] == 'previous' ||
          segments[2] == 'active' ||
          segments[2] == 'pending';
    }
    if (segments.length >= 6 &&
        segments[0] == 'eos' &&
        segments[1] == 'out' &&
        segments[3] == 'cue') {
      final list = _tryTarget(segments[4]);
      final cue = _tryTarget(segments[5]);
      final part = segments.length > 6 ? _tryTarget(segments[6]) : null;
      if (list == null || cue == null) return false;
      switch (segments[2]) {
        case 'previous':
          _playbackState = _playbackState.copyWith(
              previousCueList: list,
              previousCue: cue,
              previousPart: part,
              lastFeedbackAt: now);
          changed = true;
        case 'active':
          final progress =
              message.arguments.isEmpty ? null : _clampedProgress(message);
          _playbackState = _playbackState.copyWith(
              activeCueList: list,
              activeCue: cue,
              activePart: part,
              fadeProgress: progress,
              preserveFadeProgress: progress != null,
              lastFeedbackAt: now,
              lastProgressAt: progress == null ? null : now);
          changed = true;
          if (isFeedbackListening) unawaited(_requestCueDetail(list, cue));
        case 'pending':
          _playbackState = _playbackState.copyWith(
              pendingCueList: list,
              pendingCue: cue,
              pendingPart: part,
              lastFeedbackAt: now);
          changed = true;
      }
    } else if (message.address == '/eos/out/active/cue' &&
        message.arguments.isNotEmpty) {
      final progress = _clampedProgress(message);
      if (progress == null) return false;
      _playbackState = _playbackState.copyWith(
          fadeProgress: progress, lastFeedbackAt: now, lastProgressAt: now);
      changed = true;
    } else if (segments.length >= 7 &&
        segments[0] == 'eos' &&
        segments[1] == 'out' &&
        segments[2] == 'event' &&
        segments[3] == 'cue') {
      _playbackState = _playbackState.copyWith(
          latestEventAction: segments.last, lastFeedbackAt: now);
      changed = true;
    } else if (segments.length == 5 &&
        segments[0] == 'eos' &&
        segments[1] == 'out' &&
        segments[2] == 'cuelist' &&
        segments[3] == '1') {
      try {
        final row = EosProtocol.parseCueListBankRow(message);
        _playbackState = _playbackState.copyWith(
            currentDetail: row.row == 1 ? row : null,
            nextDetail: row.row == 2 ? row : null,
            lastFeedbackAt: now);
        changed = true;
      } on Object {
        return false;
      }
    }
    return changed;
  }

  double? _clampedProgress(OscMessage message) {
    try {
      return EosProtocol.numberAt(message, 0).clamp(0.0, 1.0).toDouble();
    } on Object {
      return null;
    }
  }

  String _firstString(OscMessage message) {
    for (final argument in message.arguments) {
      if (argument case OscString(:final data)) return data;
    }
    return '';
  }

  EosTargetNumber? _tryTarget(String value) {
    try {
      return EosTargetNumber(value);
    } on EosValidationException {
      return null;
    }
  }

  Duration get _queryTimeout =>
      _config?.queryTimeout ?? const Duration(seconds: 2);
  bool get feedbackStale =>
      _playbackState.lastFeedbackAt == null ||
      DateTime.now().difference(_playbackState.lastFeedbackAt!) >
          const Duration(seconds: 3);
  void _removeWaiter(_MessageWaiter waiter) => _waiters.remove(waiter);
  void _removeCollector(_MessageCollector collector) =>
      _collectors.remove(collector);
  void _cancelPending(Object error) {
    for (final waiter in List<_MessageWaiter>.from(_waiters))
      waiter.cancel(error);
    for (final collector in List<_MessageCollector>.from(_collectors))
      collector.cancel(error);
  }

  void _ensureConfigured() {
    _ensureNotDisposed();
    if (_config == null)
      throw const EosConnectionException(
          'Save a valid UDP endpoint before sending.');
  }

  void _ensureNotDisposed() {
    if (_disposed)
      throw const EosConnectionException('Eos client has been disposed.');
  }

  void _validateChannel(int channel) {
    if (channel <= 0)
      throw EosValidationException(
          'Channel number must be positive: $channel.');
  }

  void _setConnectionState(EosConnectionState state, {String? detail}) {
    _connectionState = state;
    _events.add(EosConnectionStateChanged(state, detail: detail));
  }

  void _emitDiagnostic(EosDiagnosticLevel level, String message) {
    _events.add(EosDiagnosticEvent(level: level, message: message));
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _cancelPending(const EosConnectionException('Eos client disposed.'));
    await _receiverDatagramSubscription.cancel();
    await _receiverSubscription.cancel();
    await _transportSubscription?.cancel();
    await _legacyTransport?.dispose();
    await _sender.dispose();
    await _receiver.dispose();
    await _events.close();
  }
}

final class _MessageWaiter {
  _MessageWaiter(
      {required this.predicate,
      required this.description,
      required Duration timeout,
      required this.onFinished}) {
    _timer = Timer(timeout, () {
      if (!completer.isCompleted)
        completer.completeError(
            EosQueryTimeoutException('Timed out waiting for $description.'));
      onFinished(this);
    });
  }
  final bool Function(OscMessage) predicate;
  final String description;
  final void Function(_MessageWaiter) onFinished;
  final Completer<OscMessage> completer = Completer<OscMessage>();
  late final Timer _timer;
  bool accept(OscMessage message) {
    if (completer.isCompleted || !predicate(message)) return false;
    _timer.cancel();
    completer.complete(message);
    onFinished(this);
    return true;
  }

  void cancel(Object error) {
    if (completer.isCompleted) return;
    _timer.cancel();
    completer.completeError(error);
    onFinished(this);
  }
}

final class _MessageCollector {
  _MessageCollector(
      {required this.predicate,
      required this.description,
      required Duration timeout,
      required this.onFinished}) {
    _totalTimer = Timer(timeout, _complete);
  }
  final bool Function(OscMessage) predicate;
  final String description;
  final void Function(_MessageCollector) onFinished;
  final Completer<List<OscMessage>> completer = Completer<List<OscMessage>>();
  final List<OscMessage> messages = <OscMessage>[];
  late final Timer _totalTimer;
  Timer? _quietTimer;
  void accept(OscMessage message) {
    if (completer.isCompleted || !predicate(message)) return;
    messages.add(message);
    _quietTimer?.cancel();
    _quietTimer = Timer(const Duration(milliseconds: 300), _complete);
  }

  void _complete() {
    if (completer.isCompleted) return;
    _totalTimer.cancel();
    _quietTimer?.cancel();
    completer.complete(List<OscMessage>.unmodifiable(messages));
    onFinished(this);
  }

  void cancel([Object? error]) {
    if (completer.isCompleted) return;
    if (error == null)
      _complete();
    else {
      _totalTimer.cancel();
      _quietTimer?.cancel();
      completer.completeError(error);
      onFinished(this);
    }
  }
}

final class EosListReassembler {
  static final RegExp _listSuffix = RegExp(r'^(.*)/list/(\d+)/(\d+)$');
  final Map<String, _ListAssembly> _assemblies = <String, _ListAssembly>{};
  OscMessage? accept(OscMessage message,
      {required Duration timeout, required void Function(String) onExpired}) {
    final match = _listSuffix.firstMatch(message.address);
    if (match == null) return message;
    final base = match.group(1)!;
    final offset = int.parse(match.group(2)!);
    final total = int.parse(match.group(3)!);
    if (offset < 0 || total < 0 || offset + message.arguments.length > total) {
      onExpired('Ignored invalid OSC List fragment ${message.address}.');
      return null;
    }
    if (total == 0) return OscMessage(base);
    final key = '$base|$total';
    final assembly = _assemblies.putIfAbsent(
        key,
        () => _ListAssembly(base, total, timeout, () {
              _assemblies.remove(key);
              onExpired('Timed out reassembling $base.');
            }));
    assembly.add(offset, message.arguments);
    if (!assembly.isComplete) return null;
    _assemblies.remove(key);
    return assembly.complete();
  }

  void clear() {
    for (final item in _assemblies.values) item.cancel();
    _assemblies.clear();
  }
}

final class _ListAssembly {
  _ListAssembly(
      this.baseAddress, this.total, Duration timeout, void Function() onExpired)
      : _arguments = List<OscArgument?>.filled(total, null),
        _timer = Timer(timeout, onExpired);
  final String baseAddress;
  final int total;
  final List<OscArgument?> _arguments;
  final Timer _timer;
  bool get isComplete => !_arguments.contains(null);
  void add(int offset, List<OscArgument> args) {
    for (var i = 0; i < args.length; i++) _arguments[offset + i] = args[i];
  }

  OscMessage complete() {
    _timer.cancel();
    return OscMessage(baseAddress, _arguments.cast<OscArgument>());
  }

  void cancel() => _timer.cancel();
}
