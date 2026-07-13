import 'dart:convert';
import 'dart:typed_data';

sealed class OscArgument {
  const OscArgument();

  String get typeTag;
  Object? get value;

  String toDebugString() => '$typeTag:${value ?? 'nil'}';
}

final class OscInt32 extends OscArgument {
  const OscInt32(this.data);

  final int data;

  @override
  String get typeTag => 'i';

  @override
  int get value => data;
}

final class OscFloat32 extends OscArgument {
  const OscFloat32(this.data);

  final double data;

  @override
  String get typeTag => 'f';

  @override
  double get value => data;
}

final class OscString extends OscArgument {
  const OscString(this.data);

  final String data;

  @override
  String get typeTag => 's';

  @override
  String get value => data;

  @override
  String toDebugString() => 's:"$data"';
}

final class OscBlob extends OscArgument {
  OscBlob(Uint8List data) : data = Uint8List.fromList(data);

  final Uint8List data;

  @override
  String get typeTag => 'b';

  @override
  Uint8List get value => Uint8List.fromList(data);

  @override
  String toDebugString() => 'b:${data.length} bytes';
}

final class OscBool extends OscArgument {
  const OscBool(this.data);

  final bool data;

  @override
  String get typeTag => data ? 'T' : 'F';

  @override
  bool get value => data;
}

final class OscNil extends OscArgument {
  const OscNil();

  @override
  String get typeTag => 'N';

  @override
  Object? get value => null;
}

final class OscFloat64 extends OscArgument {
  const OscFloat64(this.data);

  final double data;

  @override
  String get typeTag => 'd';

  @override
  double get value => data;
}

final class OscMessage {
  OscMessage(String address, [Iterable<OscArgument> arguments = const []])
      : address = _validateAddress(address),
        arguments = List<OscArgument>.unmodifiable(arguments);

  final String address;
  final List<OscArgument> arguments;

  static String _validateAddress(String address) {
    if (!address.startsWith('/')) {
      throw OscEncodeException('OSC addresses must begin with "/": $address');
    }
    if (address.contains('\u0000')) {
      throw OscEncodeException(
          'OSC addresses may not contain null characters.');
    }
    return address;
  }

  String toDebugString() {
    if (arguments.isEmpty) {
      return address;
    }
    return '$address ${arguments.map((argument) => argument.toDebugString()).join(', ')}';
  }

  @override
  String toString() => toDebugString();
}

class OscCodec {
  const OscCodec();

  Uint8List encode(OscMessage message) {
    final builder = BytesBuilder(copy: false);
    builder.add(_encodePaddedString(message.address));
    builder.add(
      _encodePaddedString(
        ',${message.arguments.map((argument) => argument.typeTag).join()}',
      ),
    );

    for (final argument in message.arguments) {
      switch (argument) {
        case OscInt32(:final data):
          if (data < -0x80000000 || data > 0x7fffffff) {
            throw OscEncodeException('OSC int32 is out of range: $data');
          }
          final bytes = ByteData(4)..setInt32(0, data, Endian.big);
          builder.add(bytes.buffer.asUint8List());
        case OscFloat32(:final data):
          final bytes = ByteData(4)..setFloat32(0, data, Endian.big);
          builder.add(bytes.buffer.asUint8List());
        case OscString(:final data):
          builder.add(_encodePaddedString(data));
        case OscBlob(:final data):
          final length = ByteData(4)..setInt32(0, data.length, Endian.big);
          builder.add(length.buffer.asUint8List());
          builder.add(data);
          final padding = _paddingFor(data.length);
          if (padding > 0) {
            builder.add(Uint8List(padding));
          }
        case OscBool():
        case OscNil():
          break;
        case OscFloat64(:final data):
          final bytes = ByteData(8)..setFloat64(0, data, Endian.big);
          builder.add(bytes.buffer.asUint8List());
      }
    }

    return builder.takeBytes();
  }

  OscMessage decode(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw OscDecodeException('OSC packet is empty.');
    }

    final reader = _OscReader(bytes);
    final address = reader.readPaddedString();
    if (address == '#bundle') {
      throw OscUnsupportedBundleException(
        'OSC bundles are not supported by this proof of concept.',
      );
    }
    if (!address.startsWith('/')) {
      throw OscDecodeException('Invalid OSC address: $address');
    }

    final tags = reader.readPaddedString();
    if (!tags.startsWith(',')) {
      throw OscDecodeException('OSC type-tag string must begin with a comma.');
    }

    final arguments = <OscArgument>[];
    for (final codeUnit in tags.substring(1).codeUnits) {
      final tag = String.fromCharCode(codeUnit);
      switch (tag) {
        case 'i':
          arguments.add(OscInt32(reader.readInt32()));
        case 'f':
          arguments.add(OscFloat32(reader.readFloat32()));
        case 's':
          arguments.add(OscString(reader.readPaddedString()));
        case 'b':
          arguments.add(OscBlob(reader.readBlob()));
        case 'T':
          arguments.add(const OscBool(true));
        case 'F':
          arguments.add(const OscBool(false));
        case 'N':
          arguments.add(const OscNil());
        case 'd':
          arguments.add(OscFloat64(reader.readFloat64()));
        default:
          throw OscDecodeException('Unsupported OSC type tag: $tag');
      }
    }

    if (!reader.isAtEnd) {
      throw OscDecodeException(
        'OSC packet contains ${reader.remaining} trailing byte(s).',
      );
    }

    return OscMessage(address, arguments);
  }

  static Uint8List _encodePaddedString(String value) {
    if (value.contains('\u0000')) {
      throw OscEncodeException('OSC strings may not contain null characters.');
    }
    final encoded = utf8.encode(value);
    final rawLength = encoded.length + 1;
    final paddedLength = rawLength + _paddingFor(rawLength);
    final result = Uint8List(paddedLength);
    result.setRange(0, encoded.length, encoded);
    return result;
  }

  static int _paddingFor(int length) => (4 - (length % 4)) % 4;
}

final class _OscReader {
  _OscReader(this.bytes);

  final Uint8List bytes;
  int offset = 0;

  bool get isAtEnd => offset == bytes.length;
  int get remaining => bytes.length - offset;

  String readPaddedString() {
    if (offset >= bytes.length) {
      throw OscDecodeException(
          'Unexpected end of OSC packet while reading string.');
    }

    var terminator = -1;
    for (var index = offset; index < bytes.length; index++) {
      if (bytes[index] == 0) {
        terminator = index;
        break;
      }
    }
    if (terminator < 0) {
      throw OscDecodeException('OSC string is missing its null terminator.');
    }

    final valueBytes = bytes.sublist(offset, terminator);
    final rawLength = (terminator - offset) + 1;
    final paddedLength = rawLength + OscCodec._paddingFor(rawLength);
    final nextOffset = offset + paddedLength;
    if (nextOffset > bytes.length) {
      throw OscDecodeException(
          'OSC string padding extends past packet boundary.');
    }
    for (var index = terminator + 1; index < nextOffset; index++) {
      if (bytes[index] != 0) {
        throw OscDecodeException('OSC string contains non-zero padding bytes.');
      }
    }

    offset = nextOffset;
    try {
      return utf8.decode(valueBytes);
    } on FormatException catch (error) {
      throw OscDecodeException('OSC string is not valid UTF-8: $error');
    }
  }

  int readInt32() {
    _require(4, 'int32');
    final value =
        ByteData.sublistView(bytes, offset, offset + 4).getInt32(0, Endian.big);
    offset += 4;
    return value;
  }

  double readFloat32() {
    _require(4, 'float32');
    final value = ByteData.sublistView(bytes, offset, offset + 4)
        .getFloat32(0, Endian.big);
    offset += 4;
    return value;
  }

  double readFloat64() {
    _require(8, 'float64');
    final value = ByteData.sublistView(bytes, offset, offset + 8)
        .getFloat64(0, Endian.big);
    offset += 8;
    return value;
  }

  Uint8List readBlob() {
    final length = readInt32();
    if (length < 0) {
      throw OscDecodeException('OSC blob has a negative length: $length');
    }
    _require(length, 'blob payload');
    final value = Uint8List.fromList(bytes.sublist(offset, offset + length));
    offset += length;
    final padding = OscCodec._paddingFor(length);
    _require(padding, 'blob padding');
    for (var index = 0; index < padding; index++) {
      if (bytes[offset + index] != 0) {
        throw OscDecodeException('OSC blob contains non-zero padding bytes.');
      }
    }
    offset += padding;
    return value;
  }

  void _require(int count, String type) {
    if (remaining < count) {
      throw OscDecodeException(
        'Unexpected end of OSC packet while reading $type: '
        'needed $count byte(s), found $remaining.',
      );
    }
  }
}

class OscCodecException implements Exception {
  const OscCodecException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class OscEncodeException extends OscCodecException {
  const OscEncodeException(super.message);
}

class OscDecodeException extends OscCodecException {
  const OscDecodeException(super.message);
}

final class OscUnsupportedBundleException extends OscDecodeException {
  const OscUnsupportedBundleException(super.message);
}
