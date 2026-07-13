import 'dart:async';
import 'dart:io';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:test/test.dart';

void main() {
  test('playback sends without feedback and emits one distinct datagram each',
      () async {
    final socket =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final addresses = <String>[];
    final done = Completer<void>();
    final subscription = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      addresses.add(const OscCodec().decode(datagram.data).address);
      if (addresses.length == 4 && !done.isCompleted) done.complete();
    });
    final client = EosOscClient();
    try {
      await client.connect(EosConnectionConfig(
          host: '127.0.0.1',
          port: socket.port,
          localAddress: '127.0.0.1',
          receivePort: 0));
      await client.goMainPlayback();
      await client.backMainPlayback();
      await client.stopMainPlayback();
      await client.goToCueZero();
      await done.future.timeout(const Duration(seconds: 2));
      expect(addresses, <String>[
        '/eos/key/Go_Main_CueList',
        '/eos/key/Stop_Back_Main_CueList',
        '/eos/key/Stop_CueList',
        '/eos/newcmd'
      ]);
    } finally {
      await client.dispose();
      await subscription.cancel();
      socket.close();
    }
  });

  test('cue bank can be configured again after feedback restarts', () async {
    final console =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final feedbackReservation =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final feedbackPort = feedbackReservation.port;
    feedbackReservation.close();
    final addresses = <String>[];
    final twoConfigs = Completer<void>();
    final subscription = console.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = console.receive();
      if (datagram == null) return;
      addresses.add(const OscCodec().decode(datagram.data).address);
      if (addresses.length == 2 && !twoConfigs.isCompleted) {
        twoConfigs.complete();
      }
    });
    final client = EosOscClient();
    try {
      await client.connect(EosConnectionConfig(
        host: '127.0.0.1',
        port: console.port,
        localAddress: '127.0.0.1',
        receivePort: feedbackPort,
      ));
      await client.startFeedback();
      await client.activateCueStack();
      await client.stopFeedback();
      await client.startFeedback();
      await client.activateCueStack();
      await twoConfigs.future.timeout(const Duration(seconds: 2));
      expect(addresses, <String>[
        '/eos/cuelist/1/config/0/1/1',
        '/eos/cuelist/1/config/0/1/1',
      ]);
    } finally {
      await client.dispose();
      await subscription.cancel();
      console.close();
    }
  });
}
