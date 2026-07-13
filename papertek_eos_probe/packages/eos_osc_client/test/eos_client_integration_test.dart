import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:eos_osc_client/src/eos_tcp_transport.dart';
import 'package:test/test.dart';

void main() {
  test('handshakes with a local fake Eos server and sends a channel level',
      () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final receivedLevel = Completer<OscMessage>();
    Socket? acceptedSocket;
    StreamSubscription<Socket>? serverSubscription;
    StreamSubscription<Uint8List>? socketSubscription;
    const codec = OscCodec();

    serverSubscription = server.listen((socket) {
      acceptedSocket = socket;
      final decoder = EosTcpFrameDecoder();
      socketSubscription = socket.listen((chunk) {
        for (final frame in decoder.add(chunk)) {
          final message = codec.decode(frame);
          if (message.address == '/eos/get/version') {
            final response = codec.encode(
              OscMessage(
                '/eos/out/get/version',
                const <OscArgument>[OscString('3.3.8.0')],
              ),
            );
            socket.add(EosTcpFrameDecoder.frame(response));
          } else if (message.address == '/eos/ping') {
            final response = codec.encode(
              OscMessage('/eos/out/ping', message.arguments),
            );
            socket.add(EosTcpFrameDecoder.frame(response));
          } else if (message.address == '/eos/chan/12') {
            if (!receivedLevel.isCompleted) {
              receivedLevel.complete(message);
            }
          }
        }
      });
    });

    final client = EosOscClient(transport: EosTcpTransport());
    try {
      await client.connect(
        EosConnectionConfig(
          host: InternetAddress.loopbackIPv4.address,
          port: server.port,
        ),
      );
      expect(client.connectionState, EosConnectionState.ready);
      await client.setChannelLevel(channel: 12, level: 50);
      final levelMessage = await receivedLevel.future.timeout(
        const Duration(seconds: 2),
      );
      expect((levelMessage.arguments.single as OscInt32).data, 50);
    } finally {
      await client.dispose();
      if (socketSubscription != null) await socketSubscription!.cancel();
      await acceptedSocket?.close();
      await serverSubscription.cancel();
      await server.close();
    }
  });
}
