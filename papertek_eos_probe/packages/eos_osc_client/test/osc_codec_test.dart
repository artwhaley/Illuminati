import 'dart:typed_data';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:test/test.dart';

void main() {
  const codec = OscCodec();

  test('round-trips a message with no arguments', () {
    final decoded = codec.decode(codec.encode(OscMessage('/eos/get/version')));
    expect(decoded.address, '/eos/get/version');
    expect(decoded.arguments, isEmpty);
  });

  test('round-trips all supported argument types', () {
    final original = OscMessage('/test', <OscArgument>[
      const OscInt32(-42),
      const OscFloat32(12.5),
      const OscString('hello'),
      OscBlob(Uint8List.fromList(<int>[1, 2, 3, 4, 5])),
      const OscBool(true),
      const OscBool(false),
      const OscNil(),
      const OscFloat64(123.25),
    ]);

    final decoded = codec.decode(codec.encode(original));
    expect(decoded.address, '/test');
    expect((decoded.arguments[0] as OscInt32).data, -42);
    expect((decoded.arguments[1] as OscFloat32).data, closeTo(12.5, 0.0001));
    expect((decoded.arguments[2] as OscString).data, 'hello');
    expect((decoded.arguments[3] as OscBlob).data, <int>[1, 2, 3, 4, 5]);
    expect((decoded.arguments[4] as OscBool).data, isTrue);
    expect((decoded.arguments[5] as OscBool).data, isFalse);
    expect(decoded.arguments[6], isA<OscNil>());
    expect((decoded.arguments[7] as OscFloat64).data, 123.25);
  });

  test('preserves unicode strings and four-byte padding boundaries', () {
    for (final value in <String>['a', 'abc', 'abcd', 'abcde', 'Café 🎭']) {
      final decoded = codec.decode(
        codec.encode(
          OscMessage('/text', <OscArgument>[OscString(value)]),
        ),
      );
      expect((decoded.arguments.single as OscString).data, value);
    }
  });

  test('rejects an address without a leading slash', () {
    expect(() => OscMessage('eos/ping'), throwsA(isA<OscEncodeException>()));
  });

  test('rejects a truncated numeric payload', () {
    final valid = codec.encode(
      OscMessage('/test', const <OscArgument>[OscInt32(1)]),
    );
    expect(
      () =>
          codec.decode(Uint8List.fromList(valid.sublist(0, valid.length - 1))),
      throwsA(isA<OscDecodeException>()),
    );
  });

  test('reports OSC bundles as unsupported', () {
    final bundleHeader = Uint8List.fromList(<int>[
      35,
      98,
      117,
      110,
      100,
      108,
      101,
      0,
    ]);
    expect(
      () => codec.decode(bundleHeader),
      throwsA(isA<OscUnsupportedBundleException>()),
    );
  });
}
