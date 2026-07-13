import 'eos_models.dart';
import 'osc_codec.dart';

final class EosProtocol {
  const EosProtocol._();

  static OscMessage ping(String token) =>
      OscMessage('/eos/ping', <OscArgument>[OscString(token)]);

  static OscMessage getVersion() => OscMessage('/eos/get/version');

  static OscMessage getShowPath() => OscMessage('/eos/get/show/path');

  static OscMessage setChannelLevel(int channel, double level) => OscMessage(
        '/eos/chan/$channel',
        <OscArgument>[OscInt32(level.round())],
      );

  static OscMessage setChannelFull(int channel) =>
      OscMessage('/eos/chan/$channel/full');

  static OscMessage setChannelOut(int channel) =>
      OscMessage('/eos/chan/$channel/out');

  static OscMessage releaseChannel(int channel) => OscMessage(
        '/eos/newcmd',
        <OscArgument>[OscString('Chan $channel Sneak Time 0 Enter')],
      );

  static OscMessage goMainPlayback() => OscMessage('/eos/key/Go_Main_CueList');

  /// Eos's combined Stop/Back key backs up when no fade is running.
  static OscMessage backMainPlayback() =>
      OscMessage('/eos/key/Stop_Back_Main_CueList');

  static OscMessage stopMainPlayback() => OscMessage('/eos/key/Stop_CueList');

  static OscMessage stopBackMainPlayback() =>
      OscMessage('/eos/key/Stop_Back_Main_CueList');

  static OscMessage goToCueZero() => OscMessage(
        '/eos/newcmd',
        <OscArgument>[OscString('Go To Cue 0 Enter')],
      );

  static OscMessage configureCueStackBank() =>
      OscMessage('/eos/cuelist/1/config/0/1/1');

  static OscMessage getCue(EosTargetNumber cueList, EosTargetNumber cue) =>
      OscMessage('/eos/get/cue/$cueList/$cue');

  static OscMessage fireCue(EosTargetNumber cueList, EosTargetNumber cue) =>
      OscMessage('/eos/cue/$cueList/$cue/fire');

  static OscMessage getCueListCount() => OscMessage('/eos/get/cuelist/count');

  static OscMessage getCueListAtIndex(int index) =>
      OscMessage('/eos/get/cuelist/index/$index');

  static OscMessage getCueCount(EosTargetNumber cueList) =>
      OscMessage('/eos/get/cue/$cueList/count');

  static OscMessage getCueAtIndex(EosTargetNumber cueList, int index) =>
      OscMessage('/eos/get/cue/$cueList/index/$index');

  static OscMessage getSubmasterCount() => OscMessage('/eos/get/sub/count');

  static OscMessage getSubmasterAtIndex(int index) =>
      OscMessage('/eos/get/sub/index/$index');

  static OscMessage getPatch(int channel) =>
      OscMessage('/eos/get/patch/$channel');

  static OscMessage getParameters(int channel) =>
      OscMessage('/eos/get/params/$channel');

  static EosCueList parseCueList(OscMessage message) {
    final segments = addressSegments(message.address);
    _requireAddress(segments, prefix: const ['eos', 'out', 'get', 'cuelist']);
    if (segments.length != 5) {
      throw EosProtocolException(
        'Unexpected cue-list response address: ${message.address}',
      );
    }
    _requireArguments(message, 13, 'cue-list');
    return EosCueList(
      number: EosTargetNumber(segments[4]),
      sourceIndex: intAt(message, 0),
      uid: stringAt(message, 1),
      label: stringAt(message, 2),
      playbackMode: stringAt(message, 3),
      faderMode: stringAt(message, 4),
      independent: boolAt(message, 5),
      isHtp: boolAt(message, 6),
      asserted: boolAt(message, 7),
      blocked: boolAt(message, 8),
      background: boolAt(message, 9),
      soloMode: boolAt(message, 10),
      timecodeList: intAt(message, 11),
      outOfSequenceSync: boolAt(message, 12),
    );
  }

  static EosCue parseCue(OscMessage message) {
    final segments = addressSegments(message.address);
    _requireAddress(segments, prefix: const ['eos', 'out', 'get', 'cue']);
    if (segments.length != 7) {
      throw EosProtocolException(
        'Unexpected cue response address: ${message.address}',
      );
    }
    _requireArguments(message, 30, 'cue');
    final partText = segments[6];
    return EosCue(
      cueListNumber: EosTargetNumber(segments[4]),
      cueNumber: EosTargetNumber(segments[5]),
      partNumber: partText == '0' ? null : EosTargetNumber(partText),
      sourceIndex: intAt(message, 0),
      uid: stringAt(message, 1),
      label: stringAt(message, 2),
      upTimeMs: intAt(message, 3),
      upDelayMs: intAt(message, 4),
      downTimeMs: intAt(message, 5),
      downDelayMs: intAt(message, 6),
      focusTimeMs: intAt(message, 7),
      focusDelayMs: intAt(message, 8),
      colorTimeMs: intAt(message, 9),
      colorDelayMs: intAt(message, 10),
      beamTimeMs: intAt(message, 11),
      beamDelayMs: intAt(message, 12),
      followTimeMs: intAt(message, 20),
      hangTimeMs: intAt(message, 21),
      partCount: intAt(message, 26),
      notes: stringAt(message, 27),
      scene: stringAt(message, 28),
      sceneEnd: boolAt(message, 29),
    );
  }

  static EosSubmaster parseSubmaster(OscMessage message) {
    final segments = addressSegments(message.address);
    _requireAddress(segments, prefix: const ['eos', 'out', 'get', 'sub']);
    if (segments.length != 5) {
      throw EosProtocolException(
        'Unexpected submaster response address: ${message.address}',
      );
    }
    _requireArguments(message, 13, 'submaster');
    return EosSubmaster(
      number: EosTargetNumber(segments[4]),
      sourceIndex: intAt(message, 0),
      uid: stringAt(message, 1),
      label: stringAt(message, 2),
      mode: stringAt(message, 3),
      faderMode: stringAt(message, 4),
      isHtp: boolAt(message, 5),
      exclusive: boolAt(message, 6),
      background: boolAt(message, 7),
      restore: boolAt(message, 8),
      priority: stringAt(message, 9),
      upTime: stringAt(message, 10),
      dwellTime: stringAt(message, 11),
      downTime: stringAt(message, 12),
    );
  }

  static EosPatchPart parsePatchPart(OscMessage message) {
    final segments = addressSegments(message.address);
    _requireAddress(segments, prefix: const ['eos', 'out', 'get', 'patch']);
    if (segments.length != 6) {
      throw EosProtocolException(
        'Unexpected patch response address: ${message.address}',
      );
    }
    _requireArguments(message, 20, 'patch');
    return EosPatchPart(
      channel: int.parse(segments[4]),
      part: int.parse(segments[5]),
      sourceIndex: intAt(message, 0),
      uid: stringAt(message, 1),
      label: stringAt(message, 2),
      manufacturer: stringAt(message, 3),
      fixtureModel: stringAt(message, 4),
      startAddress: intAt(message, 5),
      intensityAddress: intAt(message, 6),
      currentIntensity: intAt(message, 7),
      gel: stringAt(message, 8),
      textFields: List<String>.unmodifiable(
        List<String>.generate(10, (index) => stringAt(message, 9 + index)),
      ),
      partCount: intAt(message, 19),
    );
  }

  static EosFixtureParameters parseParameters(OscMessage message) {
    final segments = addressSegments(message.address);
    _requireAddress(segments, prefix: const ['eos', 'out', 'get', 'params']);
    if (segments.length != 5) {
      throw EosProtocolException(
        'Unexpected parameter response address: ${message.address}',
      );
    }
    _requireArguments(message, 2, 'parameter');
    final remaining = message.arguments.length - 2;
    if (remaining % 4 != 0) {
      throw EosProtocolException(
        'Parameter response has an incomplete parameter group: '
        '${message.arguments.length} argument(s).',
      );
    }
    final parameters = <EosParameterValue>[];
    for (var index = 2; index < message.arguments.length; index += 4) {
      parameters.add(
        EosParameterValue(
          name: stringAt(message, index),
          currentValue: numberAt(message, index + 1),
          minimum: numberAt(message, index + 2),
          maximum: numberAt(message, index + 3),
        ),
      );
    }
    return EosFixtureParameters(
      channel: int.parse(segments[4]),
      manufacturer: stringAt(message, 0),
      fixtureModel: stringAt(message, 1),
      parameters: List<EosParameterValue>.unmodifiable(parameters),
    );
  }

  static List<String> addressSegments(String address) =>
      address.split('/').where((segment) => segment.isNotEmpty).toList();

  static int intAt(OscMessage message, int index) {
    final argument = _argumentAt(message, index);
    return switch (argument) {
      OscInt32(:final data) => data,
      OscFloat32(:final data) when data == data.roundToDouble() => data.toInt(),
      OscFloat64(:final data) when data == data.roundToDouble() => data.toInt(),
      _ => throw EosProtocolException(
          'Expected integer at ${message.address} argument $index, '
          'received ${argument.typeTag}.',
        ),
    };
  }

  static double numberAt(OscMessage message, int index) {
    final argument = _argumentAt(message, index);
    return switch (argument) {
      OscInt32(:final data) => data.toDouble(),
      OscFloat32(:final data) => data,
      OscFloat64(:final data) => data,
      _ => throw EosProtocolException(
          'Expected number at ${message.address} argument $index, '
          'received ${argument.typeTag}.',
        ),
    };
  }

  static String stringAt(OscMessage message, int index) {
    final argument = _argumentAt(message, index);
    return switch (argument) {
      OscString(:final data) => data,
      _ => throw EosProtocolException(
          'Expected string at ${message.address} argument $index, '
          'received ${argument.typeTag}.',
        ),
    };
  }

  static EosTargetNumber _targetAt(OscMessage message, int index) {
    final argument = _argumentAt(message, index);
    final value = switch (argument) {
      OscString(:final data) => data,
      OscInt32(:final data) => data.toString(),
      OscFloat32(:final data) => data.toString(),
      OscFloat64(:final data) => data.toString(),
      _ => throw EosProtocolException(
          'Expected cue number at ${message.address} argument $index.',
        ),
    };
    return EosTargetNumber(value);
  }

  static EosTargetNumber? _targetOrNullAt(OscMessage message, int index) {
    if (index >= message.arguments.length) return null;
    try {
      final target = _targetAt(message, index);
      return target.value == '0' ? null : target;
    } on EosClientException {
      return null;
    }
  }

  static String _optionalStringAt(OscMessage message, int index) {
    if (index >= message.arguments.length) return '';
    try {
      return stringAt(message, index);
    } on EosClientException {
      return '';
    }
  }

  static bool _optionalBoolAt(OscMessage message, int index) {
    if (index >= message.arguments.length) return false;
    try {
      return boolAt(message, index);
    } on EosClientException {
      return false;
    }
  }

  static int? _optionalIntAt(OscMessage message, int index) {
    if (index >= message.arguments.length) return null;
    try {
      return intAt(message, index);
    } on EosClientException {
      try {
        return numberAt(message, index).round();
      } on EosClientException {
        return null;
      }
    }
  }

  static bool boolAt(OscMessage message, int index) {
    final argument = _argumentAt(message, index);
    return switch (argument) {
      OscBool(:final data) => data,
      OscInt32(:final data) => data != 0,
      _ => throw EosProtocolException(
          'Expected boolean at ${message.address} argument $index, '
          'received ${argument.typeTag}.',
        ),
    };
  }

  static bool isPrimaryCueListResponse(OscMessage message) {
    final segments = addressSegments(message.address);
    return segments.length == 5 &&
        _hasPrefix(segments, const ['eos', 'out', 'get', 'cuelist']);
  }

  static bool isPrimaryCueResponse(
    OscMessage message,
    EosTargetNumber cueList,
  ) {
    final segments = addressSegments(message.address);
    return segments.length == 7 &&
        _hasPrefix(segments, const ['eos', 'out', 'get', 'cue']) &&
        segments[4] == cueList.value;
  }

  static EosCueBankRow parseCueListBankRow(OscMessage message) {
    final segments = addressSegments(message.address);
    _requireAddress(segments, prefix: const ['eos', 'out', 'cuelist', '1']);
    if (segments.length != 5) {
      throw EosProtocolException(
        'Unexpected cue-list bank row address: ${message.address}',
      );
    }
    final row = int.tryParse(segments[4]);
    if (row == null || row < 0) {
      throw EosProtocolException('Invalid cue-list bank row: ${segments[4]}.');
    }
    if (message.arguments.length < 2) {
      throw const EosProtocolException(
        'Cue-list bank row must contain cue and part numbers.',
      );
    }
    return EosCueBankRow(
      row: row,
      cueNumber: _targetAt(message, 0),
      partNumber: _targetOrNullAt(message, 1),
      label: _optionalStringAt(message, 2),
      notes: _optionalStringAt(message, 3),
      scene: _optionalStringAt(message, 4),
      sceneEnd: _optionalBoolAt(message, 5),
      durationMs: _optionalIntAt(message, 6),
      remainingMs: _optionalIntAt(message, 7),
    );
  }

  static bool isPrimarySubmasterResponse(OscMessage message) {
    final segments = addressSegments(message.address);
    return segments.length == 5 &&
        _hasPrefix(segments, const ['eos', 'out', 'get', 'sub']);
  }

  static bool isPrimaryPatchResponse(OscMessage message, int channel) {
    final segments = addressSegments(message.address);
    return segments.length == 6 &&
        _hasPrefix(segments, const ['eos', 'out', 'get', 'patch']) &&
        segments[4] == channel.toString();
  }

  static OscArgument _argumentAt(OscMessage message, int index) {
    if (index < 0 || index >= message.arguments.length) {
      throw EosProtocolException(
        'Missing argument $index in ${message.address}.',
      );
    }
    return message.arguments[index];
  }

  static void _requireArguments(
    OscMessage message,
    int minimum,
    String objectName,
  ) {
    if (message.arguments.length < minimum) {
      throw EosProtocolException(
        'Expected at least $minimum arguments in $objectName response '
        '${message.address}, received ${message.arguments.length}.',
      );
    }
  }

  static void _requireAddress(
    List<String> segments, {
    required List<String> prefix,
  }) {
    if (!_hasPrefix(segments, prefix)) {
      throw EosProtocolException(
        'Unexpected Eos response address: /${segments.join('/')}',
      );
    }
  }

  static bool _hasPrefix(List<String> values, List<String> prefix) {
    if (values.length < prefix.length) {
      return false;
    }
    for (var index = 0; index < prefix.length; index++) {
      if (values[index] != prefix[index]) {
        return false;
      }
    }
    return true;
  }
}
