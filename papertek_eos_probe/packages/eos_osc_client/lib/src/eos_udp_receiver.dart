import 'dart:async';
import 'dart:io';

import 'eos_models.dart';
import 'osc_codec.dart';

enum EosFeedbackState { stopped, listening, faulted }

final class EosUdpDatagramEvent {
  const EosUdpDatagramEvent({
    required this.sourceAddress,
    required this.sourcePort,
    required this.byteLength,
    this.decodeError,
  });

  final String sourceAddress;
  final int sourcePort;
  final int byteLength;
  final Object? decodeError;
}

/// Optional OSC feedback listener. It owns only the receive socket.
final class EosUdpReceiver {
  EosUdpReceiver({
    OscCodec codec = const OscCodec(),
    InternetAddress? bindAddress,
  })  : _codec = codec,
        _bindAddress = bindAddress;

  final OscCodec _codec;
  final InternetAddress? _bindAddress;
  final StreamController<OscMessage> _messages =
      StreamController<OscMessage>.broadcast(sync: true);
  final StreamController<EosUdpDatagramEvent> _datagrams =
      StreamController<EosUdpDatagramEvent>.broadcast(sync: true);
  RawDatagramSocket? _socket;
  StreamSubscription<RawSocketEvent>? _subscription;
  EosFeedbackState _state = EosFeedbackState.stopped;
  Object? _lastError;
  int _datagramCount = 0;
  int _decodeErrorCount = 0;
  DateTime? _lastDatagramAt;
  String? _lastSourceAddress;
  int? _lastSourcePort;
  bool _disposed = false;

  Stream<OscMessage> get messages => _messages.stream;
  Stream<EosUdpDatagramEvent> get datagrams => _datagrams.stream;
  EosFeedbackState get state => _state;
  Object? get lastError => _lastError;
  int get datagramCount => _datagramCount;
  int get decodeErrorCount => _decodeErrorCount;
  DateTime? get lastDatagramAt => _lastDatagramAt;
  String? get lastSourceAddress => _lastSourceAddress;
  int? get lastSourcePort => _lastSourcePort;

  Future<void> start(EosConnectionConfig config) async {
    if (_disposed) {
      throw const EosConnectionException('UDP receiver has been disposed.');
    }
    if (config.receivePort < 1 || config.receivePort > 65535) {
      throw EosValidationException(
        'Invalid UDP feedback-listen port: ${config.receivePort}.',
      );
    }
    await stop();
    try {
      // The optional local address constrains outbound traffic only. Feedback
      // must listen on every local IPv4 interface so a stale or unavailable
      // send/source address cannot prevent subscription.
      final socket = await RawDatagramSocket.bind(
        _bindAddress ?? InternetAddress.anyIPv4,
        config.receivePort,
      );
      _socket = socket;
      _lastError = null;
      _datagramCount = 0;
      _decodeErrorCount = 0;
      _lastDatagramAt = null;
      _lastSourceAddress = null;
      _lastSourcePort = null;
      _state = EosFeedbackState.listening;
      _subscription = socket.listen(
        _handleSocketEvent,
        onError: (Object error, StackTrace stackTrace) {
          _lastError = error;
          _state = EosFeedbackState.faulted;
        },
      );
    } on Object catch (error) {
      _lastError = error;
      _state = EosFeedbackState.faulted;
      throw EosConnectionException(
        'Could not listen for Eos feedback on UDP port '
        '${config.receivePort}: $error',
      );
    }
  }

  void _handleSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    Datagram? datagram;
    while ((datagram = _socket?.receive()) != null) {
      final packet = datagram!;
      _datagramCount++;
      _lastDatagramAt = DateTime.now();
      _lastSourceAddress = packet.address.address;
      _lastSourcePort = packet.port;
      try {
        final message = _codec.decode(packet.data);
        _datagrams.add(EosUdpDatagramEvent(
          sourceAddress: packet.address.address,
          sourcePort: packet.port,
          byteLength: packet.data.length,
        ));
        _messages.add(message);
      } on Object catch (error) {
        _lastError = error;
        _decodeErrorCount++;
        _datagrams.add(EosUdpDatagramEvent(
          sourceAddress: packet.address.address,
          sourcePort: packet.port,
          byteLength: packet.data.length,
          decodeError: error,
        ));
      }
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _socket?.close();
    _socket = null;
    _state = EosFeedbackState.stopped;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stop();
    await _messages.close();
    await _datagrams.close();
  }
}
