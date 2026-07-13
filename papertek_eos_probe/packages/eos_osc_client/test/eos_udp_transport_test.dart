import 'dart:async';
import 'dart:io';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:test/test.dart';

void main() {
  test('sends unframed UDP OSC with integer channel percentages', () async {
    final console =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final receivePortProbe =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final receivePort = receivePortProbe.port;
    receivePortProbe.close();

    final received = Completer<({OscMessage message, int sourcePort})>();
    final subscription = console.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = console.receive();
      if (datagram == null) return;
      final message = const OscCodec().decode(datagram.data);
      if (message.address == '/eos/chan/1' && !received.isCompleted) {
        received.complete((message: message, sourcePort: datagram.port));
      }
    });

    final client = EosOscClient(transport: EosUdpTransport());
    try {
      await client.connect(
        EosConnectionConfig(
          host: InternetAddress.loopbackIPv4.address,
          localAddress: InternetAddress.loopbackIPv4.address,
          port: console.port,
          receivePort: receivePort,
          requireHandshake: false,
        ),
      );
      await client.setChannelLevel(channel: 1, level: 50);
      final result = await received.future.timeout(const Duration(seconds: 2));
      expect((result.message.arguments.single as OscInt32).data, 50);
      expect(result.sourcePort, isNot(receivePort));
    } finally {
      await client.dispose();
      await subscription.cancel();
      console.close();
    }
  });
}
