import 'dart:typed_data';

import 'package:eos_osc_client/src/eos_tcp_transport.dart';
import 'package:test/test.dart';

void main() {
  test('decodes a header split across chunks', () {
    final decoder = EosTcpFrameDecoder();
    final framed = EosTcpFrameDecoder.frame(Uint8List.fromList(<int>[1, 2, 3]));
    expect(decoder.add(Uint8List.fromList(framed.sublist(0, 2))), isEmpty);
    final frames = decoder.add(Uint8List.fromList(framed.sublist(2)));
    expect(frames, hasLength(1));
    expect(frames.single, <int>[1, 2, 3]);
  });

  test('decodes a payload split across chunks', () {
    final decoder = EosTcpFrameDecoder();
    final framed =
        EosTcpFrameDecoder.frame(Uint8List.fromList(<int>[1, 2, 3, 4]));
    expect(decoder.add(Uint8List.fromList(framed.sublist(0, 6))), isEmpty);
    final frames = decoder.add(Uint8List.fromList(framed.sublist(6)));
    expect(frames.single, <int>[1, 2, 3, 4]);
  });

  test('decodes multiple frames from one chunk', () {
    final first = EosTcpFrameDecoder.frame(Uint8List.fromList(<int>[1]));
    final second = EosTcpFrameDecoder.frame(Uint8List.fromList(<int>[2, 3]));
    final decoder = EosTcpFrameDecoder();
    final frames = decoder.add(
      Uint8List.fromList(<int>[...first, ...second]),
    );
    expect(frames, hasLength(2));
    expect(frames[0], <int>[1]);
    expect(frames[1], <int>[2, 3]);
  });

  test('rejects zero-length and oversized frames', () {
    final decoder = EosTcpFrameDecoder();
    expect(
      () => decoder.add(Uint8List(4)),
      throwsA(isA<OscFramingException>()),
    );

    final header = ByteData(4)
      ..setUint32(0, EosTcpFrameDecoder.maximumFrameLength + 1, Endian.big);
    expect(
      () => EosTcpFrameDecoder().add(header.buffer.asUint8List()),
      throwsA(isA<OscFramingException>()),
    );
  });
}
