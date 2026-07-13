import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'eos_models.dart';
import 'osc_codec.dart';

sealed class EosTransportEvent {
  const EosTransportEvent();
}

abstract interface class EosTransport {
  Stream<EosTransportEvent> get events;
  bool get isConnected;
  Future<void> connect(EosConnectionConfig config);
  Future<void> send(OscMessage message, {bool flush = false});
  Future<void> close();
  Future<void> dispose();
}

final class EosTransportMessage extends EosTransportEvent {
  const EosTransportMessage(this.message);

  final OscMessage message;
}

final class EosTransportProblem extends EosTransportEvent {
  const EosTransportProblem({
    required this.error,
    required this.stackTrace,
    required this.fatal,
  });

  final Object error;
  final StackTrace stackTrace;
  final bool fatal;
}

final class EosTransportClosed extends EosTransportEvent {
  const EosTransportClosed({this.remote = false});

  final bool remote;
}

final class EosTcpFrameDecoder {
  static const int maximumFrameLength = 4 * 1024 * 1024;

  final List<int> _buffer = <int>[];

  List<Uint8List> add(Uint8List chunk) {
    _buffer.addAll(chunk);
    final frames = <Uint8List>[];

    while (_buffer.length >= 4) {
      final header = Uint8List.fromList(_buffer.sublist(0, 4));
      final frameLength = ByteData.sublistView(header).getUint32(0, Endian.big);
      if (frameLength == 0) {
        throw const OscFramingException(
            'Received a zero-length OSC TCP frame.');
      }
      if (frameLength > maximumFrameLength) {
        throw OscFramingException(
          'OSC TCP frame length $frameLength exceeds the 4 MiB safety limit.',
        );
      }
      final totalLength = 4 + frameLength;
      if (_buffer.length < totalLength) {
        break;
      }
      frames.add(
        Uint8List.fromList(_buffer.sublist(4, totalLength)),
      );
      _buffer.removeRange(0, totalLength);
    }

    return frames;
  }

  void clear() => _buffer.clear();

  static Uint8List frame(Uint8List payload) {
    if (payload.isEmpty) {
      throw const OscFramingException('Cannot frame an empty OSC payload.');
    }
    if (payload.length > maximumFrameLength) {
      throw OscFramingException(
        'OSC payload length ${payload.length} exceeds the 4 MiB safety limit.',
      );
    }
    final result = Uint8List(4 + payload.length);
    ByteData.sublistView(result, 0, 4).setUint32(0, payload.length, Endian.big);
    result.setRange(4, result.length, payload);
    return result;
  }
}

final class EosTcpTransport implements EosTransport {
  EosTcpTransport({OscCodec codec = const OscCodec()}) : _codec = codec;

  final OscCodec _codec;
  final EosTcpFrameDecoder _frameDecoder = EosTcpFrameDecoder();
  final StreamController<EosTransportEvent> _events =
      StreamController<EosTransportEvent>.broadcast(sync: true);

  Socket? _socket;
  StreamSubscription<Uint8List>? _socketSubscription;
  bool _closingLocally = false;
  bool _disposed = false;

  Stream<EosTransportEvent> get events => _events.stream;
  bool get isConnected => _socket != null;

  Future<void> connect(EosConnectionConfig config) async {
    if (_disposed) {
      throw const EosConnectionException(
          'Transport has already been disposed.');
    }
    if (_socket != null) {
      throw const EosConnectionException('Transport is already connected.');
    }
    final host = config.host.trim();
    if (host.isEmpty) {
      throw const EosValidationException('Console host may not be empty.');
    }
    if (config.port < 1 || config.port > 65535) {
      throw EosValidationException('Invalid TCP port: ${config.port}.');
    }

    try {
      final localAddress = config.localAddress?.trim();
      final socket = await Socket.connect(
        host,
        config.port,
        sourceAddress:
            localAddress == null || localAddress.isEmpty ? null : localAddress,
        timeout: config.connectTimeout,
      );
      _socket = socket;
      _closingLocally = false;
      _frameDecoder.clear();
      socket.setOption(SocketOption.tcpNoDelay, true);
      _socketSubscription = socket.listen(
        _handleChunk,
        onError: (Object error, StackTrace stackTrace) {
          _events.add(
            EosTransportProblem(
              error: error,
              stackTrace: stackTrace,
              fatal: true,
            ),
          );
          unawaited(_closeSocket(remote: true));
        },
        onDone: () {
          final remote = !_closingLocally;
          unawaited(_closeSocket(remote: remote));
        },
        cancelOnError: true,
      );
    } on Object catch (error) {
      throw EosConnectionException(
        'Could not connect to $host:${config.port}: $error',
      );
    }
  }

  Future<void> send(OscMessage message, {bool flush = false}) async {
    final socket = _socket;
    if (socket == null) {
      throw const EosConnectionException('OSC TCP socket is not connected.');
    }
    final payload = _codec.encode(message);
    final framed = EosTcpFrameDecoder.frame(payload);
    try {
      socket.add(framed);
      if (flush) {
        await socket.flush();
      }
    } on Object catch (error) {
      throw EosConnectionException('Failed to send OSC message: $error');
    }
  }

  void _handleChunk(Uint8List chunk) {
    try {
      final frames = _frameDecoder.add(chunk);
      for (final frame in frames) {
        try {
          final message = _codec.decode(frame);
          _events.add(EosTransportMessage(message));
        } on OscUnsupportedBundleException catch (error, stackTrace) {
          _events.add(
            EosTransportProblem(
              error: error,
              stackTrace: stackTrace,
              fatal: false,
            ),
          );
        } on OscDecodeException catch (error, stackTrace) {
          _events.add(
            EosTransportProblem(
              error: error,
              stackTrace: stackTrace,
              fatal: false,
            ),
          );
        }
      }
    } on OscFramingException catch (error, stackTrace) {
      _events.add(
        EosTransportProblem(
          error: error,
          stackTrace: stackTrace,
          fatal: true,
        ),
      );
      unawaited(_closeSocket(remote: true));
    }
  }

  Future<void> close() async {
    _closingLocally = true;
    await _closeSocket(remote: false);
  }

  Future<void> _closeSocket({required bool remote}) async {
    final socket = _socket;
    if (socket == null) {
      return;
    }
    _socket = null;
    final subscription = _socketSubscription;
    _socketSubscription = null;
    await subscription?.cancel();
    try {
      await socket.flush();
    } on Object {
      // The peer may already be gone.
    }
    try {
      await socket.close();
    } on Object {
      socket.destroy();
    }
    _frameDecoder.clear();
    if (!_events.isClosed) {
      _events.add(EosTransportClosed(remote: remote));
    }
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await close();
    await _events.close();
  }
}

/// Unframed OSC-over-UDP transport for Eos consoles configured with separate
/// receive and transmit ports.
final class EosUdpTransport implements EosTransport {
  EosUdpTransport({OscCodec codec = const OscCodec()}) : _codec = codec;

  final OscCodec _codec;
  final StreamController<EosTransportEvent> _events =
      StreamController<EosTransportEvent>.broadcast(sync: true);

  RawDatagramSocket? _receiveSocket;
  RawDatagramSocket? _sendSocket;
  StreamSubscription<RawSocketEvent>? _socketSubscription;
  InternetAddress? _remoteAddress;
  int? _remotePort;
  bool _disposed = false;

  Stream<EosTransportEvent> get events => _events.stream;
  bool get isConnected => _sendSocket != null;

  Future<void> connect(EosConnectionConfig config) async {
    if (_disposed) {
      throw const EosConnectionException(
          'Transport has already been disposed.');
    }
    if (_sendSocket != null || _receiveSocket != null) {
      throw const EosConnectionException('Transport is already connected.');
    }
    if (config.port < 1 ||
        config.port > 65535 ||
        config.receivePort < 0 ||
        config.receivePort > 65535) {
      throw const EosValidationException('Invalid UDP port configuration.');
    }

    try {
      final addresses = await InternetAddress.lookup(
        config.host.trim(),
        type: InternetAddressType.IPv4,
      );
      if (addresses.isEmpty) {
        throw EosConnectionException('Could not resolve ${config.host}.');
      }
      final localText = config.localAddress?.trim();
      final localAddress = localText == null || localText.isEmpty
          ? InternetAddress.anyIPv4
          : InternetAddress(localText);
      final receiveSocket = config.receivePort == 0
          ? null
          : await RawDatagramSocket.bind(localAddress, config.receivePort);
      final sendSocket = await RawDatagramSocket.bind(localAddress, 0);
      _receiveSocket = receiveSocket;
      _sendSocket = sendSocket;
      _remoteAddress = addresses.first;
      _remotePort = config.port;
      if (receiveSocket != null) {
        _socketSubscription = receiveSocket.listen(
          _handleSocketEvent,
          onError: (Object error, StackTrace stackTrace) {
            _events.add(
              EosTransportProblem(
                error: error,
                stackTrace: stackTrace,
                fatal: false,
              ),
            );
          },
        );
      }
    } on Object catch (error) {
      throw EosConnectionException(
        'Could not open UDP sender for ${config.host}:${config.port}: $error',
      );
    }
  }

  Future<void> send(OscMessage message, {bool flush = false}) async {
    final socket = _sendSocket;
    final remoteAddress = _remoteAddress;
    final remotePort = _remotePort;
    if (socket == null || remoteAddress == null || remotePort == null) {
      throw const EosConnectionException('OSC UDP socket is not connected.');
    }
    final payload = _codec.encode(message);
    final sent = socket.send(payload, remoteAddress, remotePort);
    if (sent != payload.length) {
      throw EosConnectionException(
        'UDP sent $sent of ${payload.length} OSC bytes.',
      );
    }
  }

  void _handleSocketEvent(RawSocketEvent event) {
    if (event != RawSocketEvent.read) return;
    Datagram? datagram;
    while ((datagram = _receiveSocket?.receive()) != null) {
      try {
        _events.add(EosTransportMessage(_codec.decode(datagram!.data)));
      } on Object catch (error, stackTrace) {
        _events.add(
          EosTransportProblem(
            error: error,
            stackTrace: stackTrace,
            fatal: false,
          ),
        );
      }
    }
  }

  Future<void> close() async {
    final receiveSocket = _receiveSocket;
    final sendSocket = _sendSocket;
    if (receiveSocket == null && sendSocket == null) return;
    _receiveSocket = null;
    _sendSocket = null;
    _remoteAddress = null;
    _remotePort = null;
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    receiveSocket?.close();
    sendSocket?.close();
    if (!_events.isClosed) {
      _events.add(const EosTransportClosed(remote: false));
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await close();
    await _events.close();
  }
}

final class OscFramingException extends EosClientException {
  const OscFramingException(super.message);
}
