import 'dart:async';
import 'dart:io';

import 'eos_models.dart';
import 'osc_codec.dart';

/// A stateless-at-the-API-boundary UDP command sender.
///
/// The socket is opened lazily by [send]. It is retained for subsequent
/// datagrams and discarded when the endpoint changes or a send fails.
final class EosUdpSender {
  EosUdpSender({
    OscCodec codec = const OscCodec(),
    Future<List<InternetAddress>> Function()? localAddresses,
  })  : _codec = codec,
        _localAddresses = localAddresses ?? _systemLocalAddresses;

  final OscCodec _codec;
  final Future<List<InternetAddress>> Function() _localAddresses;
  RawDatagramSocket? _socket;
  InternetAddress? _destination;
  InternetAddress? _source;
  int? _destinationPort;
  EosConnectionConfig? _config;
  bool _disposed = false;

  bool get hasSocket => _socket != null;
  InternetAddress? get sourceAddress => _source;
  InternetAddress? get destinationAddress => _destination;

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
        ? await _automaticSourceAddress(addresses.first)
        : InternetAddress(localText);
    final socket = await RawDatagramSocket.bind(localAddress, 0);
    _socket = socket;
    _source = localAddress;
    _destination = addresses.first;
    _destinationPort = config.port;
    return socket;
  }

  Future<void> disposeSocket() async {
    _socket?.close();
    _socket = null;
    _destination = null;
    _source = null;
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

  Future<InternetAddress> _automaticSourceAddress(
      InternetAddress destination) async {
    try {
      final candidates = await _localAddresses();
      for (final candidate in candidates) {
        if (candidate.type == InternetAddressType.IPv4 &&
            _sameIpv4Subnet24(candidate, destination)) {
          return candidate;
        }
      }
    } on Object {
      // Interface discovery is an optimization. Normal OS routing remains the
      // fallback when a platform cannot enumerate its local addresses.
    }
    return InternetAddress.anyIPv4;
  }

  static bool _sameIpv4Subnet24(
      InternetAddress left, InternetAddress right) {
    final a = left.rawAddress;
    final b = right.rawAddress;
    return a.length == 4 &&
        b.length == 4 &&
        a[0] == b[0] &&
        a[1] == b[1] &&
        a[2] == b[2];
  }

  static Future<List<InternetAddress>> _systemLocalAddresses() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    return <InternetAddress>[
      for (final interface in interfaces) ...interface.addresses,
    ];
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw const EosConnectionException('UDP sender has been disposed.');
    }
  }
}
