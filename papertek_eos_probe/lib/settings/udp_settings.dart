import 'dart:io';

import 'package:eos_osc_client/eos_osc_client.dart';

final class UdpSettings {
  const UdpSettings({
    required this.host,
    this.consoleRxPort = 8000,
    this.localAddress = '',
    this.feedbackRxPort = 8001,
  });

  final String host;
  final int consoleRxPort;
  final String localAddress;
  final int feedbackRxPort;

  bool get isValid {
    final trimmedHost = host.trim();
    final local = localAddress.trim();
    return trimmedHost.isNotEmpty &&
        !trimmedHost.contains(RegExp(r'\s')) &&
        consoleRxPort >= 1 &&
        consoleRxPort <= 65535 &&
        feedbackRxPort >= 1 &&
        feedbackRxPort <= 65535 &&
        (local.isEmpty ||
            (InternetAddress.tryParse(local)?.type ==
                InternetAddressType.IPv4));
  }

  EosConnectionConfig toConnectionConfig() => EosConnectionConfig(
        host: host.trim(),
        port: consoleRxPort,
        localAddress: localAddress.trim().isEmpty ? null : localAddress.trim(),
        receivePort: feedbackRxPort,
      );

  Map<String, Object> toJson() => <String, Object>{
        'consoleHost': host.trim(),
        'consoleReceivePort': consoleRxPort,
        'localAddress': localAddress.trim(),
        'appFeedbackPort': feedbackRxPort,
      };

  static UdpSettings? fromJson(Map<String, dynamic> data) {
    final host =
        data['consoleHost'] as String? ?? data['host'] as String? ?? '';
    final consolePort =
        _asInt(data['consoleReceivePort'] ?? data['consoleRxPort']) ?? 8000;
    final feedbackPort =
        _asInt(data['appFeedbackPort'] ?? data['feedbackRxPort']) ?? 8001;
    final local = data['localAddress'] as String? ?? '';
    final result = UdpSettings(
      host: host,
      consoleRxPort: consolePort,
      localAddress: local,
      feedbackRxPort: feedbackPort,
    );
    return result.isValid ? result : null;
  }

  static int? _asInt(Object? value) =>
      value is int ? value : int.tryParse('$value');
}
