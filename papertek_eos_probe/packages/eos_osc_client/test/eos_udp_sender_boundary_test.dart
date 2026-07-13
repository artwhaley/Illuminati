import 'dart:async';
import 'dart:io';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:eos_osc_client/src/eos_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('first send works without connect and preserves int32 bytes', () async {
    final receiver =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final packet = Completer<OscMessage>();
    final subscription = receiver.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = receiver.receive();
      if (datagram != null && !packet.isCompleted)
        packet.complete(const OscCodec().decode(datagram.data));
    });
    final sender = EosUdpSender();
    try {
      await sender.configure(EosConnectionConfig(
          host: '127.0.0.1', port: receiver.port, localAddress: '127.0.0.1'));
      await sender.send(EosProtocol.setChannelLevel(1, 45));
      final message = await packet.future.timeout(const Duration(seconds: 2));
      expect(message.address, '/eos/chan/1');
      expect((message.arguments.single as OscInt32).data, 45);
    } finally {
      await sender.dispose();
      await subscription.cancel();
      receiver.close();
    }
  });

  test('endpoint changes route next packet and disposal does not replay',
      () async {
    final first = await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final second =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final firstCount = <int>[];
    final secondCount = <int>[];
    final a = first.listen((event) {
      if (event == RawSocketEvent.read) {
        first.receive();
        firstCount.add(1);
      }
    });
    final b = second.listen((event) {
      if (event == RawSocketEvent.read) {
        second.receive();
        secondCount.add(1);
      }
    });
    final sender = EosUdpSender();
    try {
      final base =
          EosConnectionConfig(host: '127.0.0.1', localAddress: '127.0.0.1');
      await sender.configure(base.copyWith(port: first.port));
      await sender.send(EosProtocol.getVersion());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      await sender.configure(base.copyWith(port: second.port));
      await sender.send(EosProtocol.getVersion());
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(firstCount, hasLength(1));
      expect(secondCount, hasLength(1));
      await sender.disposeSocket();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(secondCount, hasLength(1));
    } finally {
      await sender.dispose();
      await a.cancel();
      await b.cancel();
      first.close();
      second.close();
    }
  });

  test('receiver bind failure does not disable sender', () async {
    final receiver = EosUdpReceiver();
    final senderSocket =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final sender = EosUdpSender();
    try {
      await sender.configure(EosConnectionConfig(
          host: '127.0.0.1',
          port: senderSocket.port,
          localAddress: '127.0.0.1'));
      await expectLater(
          receiver.start(const EosConnectionConfig(
              host: '127.0.0.1', port: 9, receivePort: 70000)),
          throwsA(isA<EosValidationException>()));
      await sender.send(EosProtocol.getVersion());
    } finally {
      await receiver.dispose();
      await sender.dispose();
      senderSocket.close();
    }
  });

  test('feedback listener does not bind to outbound source address', () async {
    final reservation =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = reservation.port;
    reservation.close();
    final receiver = EosUdpReceiver();
    final received = Completer<OscMessage>();
    final wireEvent = Completer<EosUdpDatagramEvent>();
    final subscription = receiver.messages.listen((message) {
      if (!received.isCompleted) received.complete(message);
    });
    final datagramSubscription = receiver.datagrams.listen((event) {
      if (!wireEvent.isCompleted) wireEvent.complete(event);
    });
    final sender =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    try {
      await receiver.start(EosConnectionConfig(
        host: '127.0.0.1',
        localAddress: '192.0.2.123',
        receivePort: port,
      ));
      final bytes = const OscCodec().encode(OscMessage('/loopback/feedback'));
      sender.send(bytes, InternetAddress.loopbackIPv4, port);
      expect(
        (await received.future.timeout(const Duration(seconds: 2))).address,
        '/loopback/feedback',
      );
      final wire = await wireEvent.future.timeout(const Duration(seconds: 2));
      expect(wire.sourceAddress, '127.0.0.1');
      expect(wire.decodeError, isNull);
      expect(receiver.datagramCount, 1);
      expect(receiver.decodeErrorCount, 0);
    } finally {
      sender.close();
      await subscription.cancel();
      await datagramSubscription.cancel();
      await receiver.dispose();
    }
  });

  test('feedback listener reports undecodable UDP without hiding the packet',
      () async {
    final reservation =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = reservation.port;
    reservation.close();
    final receiver = EosUdpReceiver();
    final eventReceived = Completer<EosUdpDatagramEvent>();
    final subscription = receiver.datagrams.listen((event) {
      if (!eventReceived.isCompleted) eventReceived.complete(event);
    });
    final sender =
        await RawDatagramSocket.bind(InternetAddress.loopbackIPv4, 0);
    try {
      await receiver
          .start(EosConnectionConfig(host: '127.0.0.1', receivePort: port));
      sender.send(<int>[1, 2, 3], InternetAddress.loopbackIPv4, port);
      final event =
          await eventReceived.future.timeout(const Duration(seconds: 2));
      expect(event.byteLength, 3);
      expect(event.decodeError, isA<OscDecodeException>());
      expect(receiver.datagramCount, 1);
      expect(receiver.decodeErrorCount, 1);
    } finally {
      sender.close();
      await subscription.cancel();
      await receiver.dispose();
    }
  });

  test('invalid endpoint sends nothing', () async {
    final sender = EosUdpSender();
    await expectLater(
        sender.configure(const EosConnectionConfig(host: '', port: 8000)),
        throwsA(isA<EosValidationException>()));
    await sender.dispose();
  });
}

extension on EosConnectionConfig {
  EosConnectionConfig copyWith(
          {String? host, String? localAddress, int? port}) =>
      EosConnectionConfig(
          host: host ?? this.host,
          localAddress: localAddress ?? this.localAddress,
          port: port ?? this.port,
          receivePort: receivePort);
}
