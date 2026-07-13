import 'dart:async';

import 'osc_codec.dart';

enum EosConnectionState {
  disconnected,
  connecting,
  connected,
  ready,
  disconnecting,
  faulted,
}

final class EosConnectionConfig {
  const EosConnectionConfig({
    required this.host,
    this.localAddress,
    this.port = 8000,
    this.receivePort = 8001,
    this.requireHandshake = false,
    this.connectTimeout = const Duration(seconds: 3),
    this.queryTimeout = const Duration(seconds: 2),
  });

  final String host;

  /// Optional numeric local IP address to bind before connecting.
  /// Use this to force traffic through a specific network interface.
  final String? localAddress;
  final int port;
  final int receivePort;
  final bool requireHandshake;
  final Duration connectTimeout;
  final Duration queryTimeout;
}

final class EosTargetNumber implements Comparable<EosTargetNumber> {
  EosTargetNumber(String value) : value = _validate(value);

  final String value;

  static final RegExp _pattern = RegExp(r'^\d+(?:\.\d+)?$');

  static String _validate(String raw) {
    final value = raw.trim();
    if (!_pattern.hasMatch(value)) {
      throw EosValidationException(
        'Eos target numbers must be positive whole or decimal numbers: "$raw".',
      );
    }
    return value;
  }

  @override
  int compareTo(EosTargetNumber other) {
    final leftParts = value.split('.');
    final rightParts = other.value.split('.');
    final wholeComparison =
        int.parse(leftParts.first).compareTo(int.parse(rightParts.first));
    if (wholeComparison != 0) {
      return wholeComparison;
    }
    final leftFraction = leftParts.length > 1 ? leftParts[1] : '';
    final rightFraction = rightParts.length > 1 ? rightParts[1] : '';
    final width = leftFraction.length > rightFraction.length
        ? leftFraction.length
        : rightFraction.length;
    final leftPadded = leftFraction.padRight(width, '0');
    final rightPadded = rightFraction.padRight(width, '0');
    final fractionComparison = leftPadded.compareTo(rightPadded);
    if (fractionComparison != 0) {
      return fractionComparison;
    }
    return value.compareTo(other.value);
  }

  @override
  bool operator ==(Object other) =>
      other is EosTargetNumber && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

final class PingResult {
  const PingResult({required this.token, required this.roundTrip});

  final String token;
  final Duration roundTrip;
}

final class EosVersionInfo {
  const EosVersionInfo({
    this.softwareVersion,
    this.fixtureLibraryVersion,
    this.gelOnlyMode,
  });

  final String? softwareVersion;
  final String? fixtureLibraryVersion;
  final bool? gelOnlyMode;

  bool get hasAnyValue =>
      softwareVersion != null ||
      fixtureLibraryVersion != null ||
      gelOnlyMode != null;

  EosVersionInfo copyWith({
    String? softwareVersion,
    String? fixtureLibraryVersion,
    bool? gelOnlyMode,
    bool preserveSoftwareVersion = true,
    bool preserveFixtureLibraryVersion = true,
    bool preserveGelOnlyMode = true,
  }) {
    return EosVersionInfo(
      softwareVersion: preserveSoftwareVersion
          ? softwareVersion ?? this.softwareVersion
          : softwareVersion,
      fixtureLibraryVersion: preserveFixtureLibraryVersion
          ? fixtureLibraryVersion ?? this.fixtureLibraryVersion
          : fixtureLibraryVersion,
      gelOnlyMode:
          preserveGelOnlyMode ? gelOnlyMode ?? this.gelOnlyMode : gelOnlyMode,
    );
  }
}

final class EosCueList {
  const EosCueList({
    required this.number,
    required this.sourceIndex,
    required this.uid,
    required this.label,
    required this.playbackMode,
    required this.faderMode,
    required this.independent,
    required this.isHtp,
    required this.asserted,
    required this.blocked,
    required this.background,
    required this.soloMode,
    required this.timecodeList,
    required this.outOfSequenceSync,
  });

  final EosTargetNumber number;
  final int sourceIndex;
  final String uid;
  final String label;
  final String playbackMode;
  final String faderMode;
  final bool independent;
  final bool isHtp;
  final bool asserted;
  final bool blocked;
  final bool background;
  final bool soloMode;
  final int timecodeList;
  final bool outOfSequenceSync;
}

final class EosCue {
  const EosCue({
    required this.cueListNumber,
    required this.cueNumber,
    required this.partNumber,
    required this.sourceIndex,
    required this.uid,
    required this.label,
    required this.upTimeMs,
    required this.upDelayMs,
    required this.downTimeMs,
    required this.downDelayMs,
    required this.focusTimeMs,
    required this.focusDelayMs,
    required this.colorTimeMs,
    required this.colorDelayMs,
    required this.beamTimeMs,
    required this.beamDelayMs,
    required this.followTimeMs,
    required this.hangTimeMs,
    required this.partCount,
    required this.notes,
    required this.scene,
    required this.sceneEnd,
  });

  final EosTargetNumber cueListNumber;
  final EosTargetNumber cueNumber;
  final EosTargetNumber? partNumber;
  final int sourceIndex;
  final String uid;
  final String label;
  final int upTimeMs;
  final int upDelayMs;
  final int downTimeMs;
  final int downDelayMs;
  final int focusTimeMs;
  final int focusDelayMs;
  final int colorTimeMs;
  final int colorDelayMs;
  final int beamTimeMs;
  final int beamDelayMs;
  final int followTimeMs;
  final int hangTimeMs;
  final int partCount;
  final String notes;
  final String scene;
  final bool sceneEnd;
}

final class EosSubmaster {
  const EosSubmaster({
    required this.number,
    required this.sourceIndex,
    required this.uid,
    required this.label,
    required this.mode,
    required this.faderMode,
    required this.isHtp,
    required this.exclusive,
    required this.background,
    required this.restore,
    required this.priority,
    required this.upTime,
    required this.dwellTime,
    required this.downTime,
  });

  final EosTargetNumber number;
  final int sourceIndex;
  final String uid;
  final String label;
  final String mode;
  final String faderMode;
  final bool isHtp;
  final bool exclusive;
  final bool background;
  final bool restore;
  final String priority;
  final String upTime;
  final String dwellTime;
  final String downTime;
}

final class EosPatchPart {
  const EosPatchPart({
    required this.channel,
    required this.part,
    required this.sourceIndex,
    required this.uid,
    required this.label,
    required this.manufacturer,
    required this.fixtureModel,
    required this.startAddress,
    required this.intensityAddress,
    required this.currentIntensity,
    required this.gel,
    required this.textFields,
    required this.partCount,
    this.endAddress,
  });

  final int channel;
  final int part;
  final int sourceIndex;
  final String uid;
  final String label;
  final String manufacturer;
  final String fixtureModel;
  final int startAddress;
  final int intensityAddress;
  final int currentIntensity;
  final String gel;
  final List<String> textFields;
  final int partCount;
  final int? endAddress;
}

final class EosParameterValue {
  const EosParameterValue({
    required this.name,
    required this.currentValue,
    required this.minimum,
    required this.maximum,
  });

  final String name;
  final double currentValue;
  final double minimum;
  final double maximum;
}

final class EosFixtureParameters {
  const EosFixtureParameters({
    required this.channel,
    required this.manufacturer,
    required this.fixtureModel,
    required this.parameters,
  });

  final int channel;
  final String manufacturer;
  final String fixtureModel;
  final List<EosParameterValue> parameters;
}

final class EosCuePlaybackState {
  const EosCuePlaybackState({
    this.previousText = '',
    this.activeText = '',
    this.pendingText = '',
    this.previousCueList,
    this.previousCue,
    this.activeCueList,
    this.activeCue,
    this.pendingCueList,
    this.pendingCue,
    this.previousPart,
    this.activePart,
    this.pendingPart,
    this.fadeProgress,
    this.latestEventAction,
    this.lastFeedbackAt,
    this.lastProgressAt,
    this.currentDetail,
    this.nextDetail,
  });

  final String previousText;
  final String activeText;
  final String pendingText;
  final EosTargetNumber? previousCueList;
  final EosTargetNumber? previousCue;
  final EosTargetNumber? activeCueList;
  final EosTargetNumber? activeCue;
  final EosTargetNumber? pendingCueList;
  final EosTargetNumber? pendingCue;
  final EosTargetNumber? previousPart;
  final EosTargetNumber? activePart;
  final EosTargetNumber? pendingPart;
  final double? fadeProgress;
  final String? latestEventAction;
  final DateTime? lastFeedbackAt;
  final DateTime? lastProgressAt;
  final EosCueBankRow? currentDetail;
  final EosCueBankRow? nextDetail;

  EosCuePlaybackState copyWith({
    String? previousText,
    String? activeText,
    String? pendingText,
    EosTargetNumber? previousCueList,
    EosTargetNumber? previousCue,
    EosTargetNumber? activeCueList,
    EosTargetNumber? activeCue,
    EosTargetNumber? pendingCueList,
    EosTargetNumber? pendingCue,
    EosTargetNumber? previousPart,
    EosTargetNumber? activePart,
    EosTargetNumber? pendingPart,
    double? fadeProgress,
    String? latestEventAction,
    DateTime? lastFeedbackAt,
    DateTime? lastProgressAt,
    EosCueBankRow? currentDetail,
    EosCueBankRow? nextDetail,
    bool preserveFadeProgress = true,
  }) {
    return EosCuePlaybackState(
      previousText: previousText ?? this.previousText,
      activeText: activeText ?? this.activeText,
      pendingText: pendingText ?? this.pendingText,
      previousCueList: previousCueList ?? this.previousCueList,
      previousCue: previousCue ?? this.previousCue,
      activeCueList: activeCueList ?? this.activeCueList,
      activeCue: activeCue ?? this.activeCue,
      pendingCueList: pendingCueList ?? this.pendingCueList,
      pendingCue: pendingCue ?? this.pendingCue,
      previousPart: previousPart ?? this.previousPart,
      activePart: activePart ?? this.activePart,
      pendingPart: pendingPart ?? this.pendingPart,
      fadeProgress: preserveFadeProgress
          ? fadeProgress ?? this.fadeProgress
          : fadeProgress,
      latestEventAction: latestEventAction ?? this.latestEventAction,
      lastFeedbackAt: lastFeedbackAt ?? this.lastFeedbackAt,
      lastProgressAt: lastProgressAt ?? this.lastProgressAt,
      currentDetail: currentDetail ?? this.currentDetail,
      nextDetail: nextDetail ?? this.nextDetail,
    );
  }
}

/// A row emitted by Eos cue-list bank 1.
final class EosCueBankRow {
  const EosCueBankRow({
    required this.row,
    required this.cueNumber,
    this.partNumber,
    this.label = '',
    this.notes = '',
    this.scene = '',
    this.sceneEnd = false,
    this.durationMs,
    this.remainingMs,
  });

  final int row;
  final EosTargetNumber cueNumber;
  final EosTargetNumber? partNumber;
  final String label;
  final String notes;
  final String scene;
  final bool sceneEnd;
  final int? durationMs;
  final int? remainingMs;
}

enum EosOscDirection { transmit, receive }

enum EosDiagnosticLevel { info, warning, error }

sealed class EosClientEvent {
  EosClientEvent() : timestamp = DateTime.now();

  final DateTime timestamp;
}

final class EosConnectionStateChanged extends EosClientEvent {
  EosConnectionStateChanged(this.state, {this.detail});

  final EosConnectionState state;
  final String? detail;
}

final class EosOscMessageEvent extends EosClientEvent {
  EosOscMessageEvent({required this.direction, required this.message});

  final EosOscDirection direction;
  final OscMessage message;
}

final class EosDiagnosticEvent extends EosClientEvent {
  EosDiagnosticEvent({required this.level, required this.message});

  final EosDiagnosticLevel level;
  final String message;
}

final class EosFeedbackListeningChangedEvent extends EosClientEvent {
  EosFeedbackListeningChangedEvent({required this.listening, this.port});

  final bool listening;
  final int? port;
}

final class EosFeedbackDatagramEvent extends EosClientEvent {
  EosFeedbackDatagramEvent({
    required this.sourceAddress,
    required this.sourcePort,
    required this.byteLength,
    this.decodeError,
  });

  final String sourceAddress;
  final int sourcePort;
  final int byteLength;
  final Object? decodeError;
  bool get decoded => decodeError == null;
}

final class EosVersionChangedEvent extends EosClientEvent {
  EosVersionChangedEvent(this.versionInfo);

  final EosVersionInfo versionInfo;
}

final class EosCuePlaybackChangedEvent extends EosClientEvent {
  EosCuePlaybackChangedEvent(this.playbackState);

  final EosCuePlaybackState playbackState;
}

final class EosShowDataNotificationEvent extends EosClientEvent {
  EosShowDataNotificationEvent(this.address);

  final String address;
}

final class EosQueryEvent extends EosClientEvent {
  EosQueryEvent({
    required this.name,
    required this.phase,
    this.detail,
  });

  final String name;
  final EosQueryPhase phase;
  final String? detail;
}

enum EosQueryPhase { started, completed, partial, failed }

abstract interface class EosPlaybackClient {
  Future<void> sendCommand(String command);
  Future<void> goMainPlayback();
  Future<void> backMainPlayback();
  Future<void> goToCueZero();
  Future<void> stopMainPlayback();
  Future<void> activateCueStack();
}

abstract interface class EosClient {
  Stream<EosClientEvent> get events;
  EosConnectionState get connectionState;
  EosVersionInfo get versionInfo;
  EosCuePlaybackState get playbackState;

  Future<void> connect(EosConnectionConfig config);
  Future<void> disconnect();
  Future<PingResult> ping();

  Future<void> setChannelLevel({required int channel, required double level});
  Future<void> setChannelFull(int channel);
  Future<void> setChannelOut(int channel);
  Future<void> releaseChannel(int channel);

  Future<void> goMainPlayback();
  Future<void> stopBackMainPlayback();

  Future<void> fireCue({
    required EosTargetNumber cueList,
    required EosTargetNumber cue,
  });

  Future<EosVersionInfo> getVersion();
  Future<String?> getShowPath();
  Future<List<EosCueList>> getCueLists();
  Future<List<EosCue>> getCues(EosTargetNumber cueList);
  Future<List<EosSubmaster>> getSubmasters();
  Future<List<EosPatchPart>> getPatch(int channel);
  Future<EosFixtureParameters> getParameters(int channel);

  Future<void> dispose();
}

class EosClientException implements Exception {
  const EosClientException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class EosConnectionException extends EosClientException {
  const EosConnectionException(super.message);
}

final class EosProtocolException extends EosClientException {
  const EosProtocolException(super.message);
}

final class EosQueryTimeoutException extends EosClientException {
  const EosQueryTimeoutException(super.message);
}

final class EosValidationException extends EosClientException {
  const EosValidationException(super.message);
}
