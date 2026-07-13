import 'dart:async';
import 'dart:io';

import 'eos_models.dart';
import 'osc_codec.dart';

/// A stateless-at-the-API-boundary UDP command sender.
///
/// The socket is opened lazily by [send]. It is retained for subsequent
/// datagrams and discarded when the endpoint changes or a send fails.
final class EosUdpSender {
  EosUdpSender({OscCodec codec = const OscCodec()}) : _codec = codec;

  final OscCodec _codec;
  RawDatagramSocket? _socket;
  InternetAddress? _destination;
  int? _destinationPort;
  EosConnectionConfig? _config;
  bool _disposed = false;

  bool get hasSocket => _socket != null;

  Future<void> configure(EosConnectionConfig config) async {
    _ensureNotDisposed();
    _validate(config);
    final changed = _config == null || !_sameEndpoint(_config!, config);
    _config = config;
    if (changed) {
      await disposeSocket();
    }
  }

  Future<void> send(OscMessage message) async {
    _ensureNotDisposed();
    final config = _config;
    if (config == null) {
      throw const EosConnectionException(
        'UDP sender is not configured; save a valid endpoint first.',
      );
    }
    _validate(config);
    try {
      final socket = await _ensureSocket(config);
      final destination = _destination!;
      final payload = _codec.encode(message);
      final sent = socket.send(payload, destination, _destinationPort!);
      if (sent != payload.length) {
        throw EosConnectionException(
          'UDP sent $sent of ${payload.length} OSC bytes.',
        );
      }
    } on Object catch (error) {
      await disposeSocket();
      if (error is EosClientException) rethrow;
      throw EosConnectionException('Failed to send UDP OSC datagram: $error');
    }
  }

  Future<RawDatagramSocket> _ensureSocket(EosConnectionConfig config) async {
    if (_socket != null && _destination != null) return _socket!;
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
    final socket = await RawDatagramSocket.bind(localAddress, 0);
    _socket = socket;
    _destination = addresses.first;
    _destinationPort = config.port;
    return socket;
  }

  Future<void> disposeSocket() async {
    _socket?.close();
    _socket = null;
    _destination = null;
    _destinationPort = null;
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await disposeSocket();
  }

  static void _validate(EosConnectionConfig config) {
    if (config.host.trim().isEmpty) {
      throw const EosValidationException('Console host may not be empty.');
    }
    if (config.port < 1 || config.port > 65535) {
      throw EosValidationException(
          'Invalid UDP destination port: ${config.port}.');
    }
    final local = config.localAddress?.trim();
    if (local != null && local.isNotEmpty) {
      final address = InternetAddress.tryParse(local);
      if (address == null || address.type != InternetAddressType.IPv4) {
        throw const EosValidationException(
          'Local source address must be a valid IPv4 address.',
        );
      }
    }
  }

  static bool _sameEndpoint(
          EosConnectionConfig left, EosConnectionConfig right) =>
      left.host.trim() == right.host.trim() &&
      left.port == right.port &&
      (left.localAddress ?? '').trim() == (right.localAddress ?? '').trim();

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const EosConnectionException('UDP sender has been disposed.');
    }
  }
}
