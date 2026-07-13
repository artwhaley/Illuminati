import 'dart:async';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papertek_eos_probe/cue_stack/cue_stack_tab.dart';

void main() {
  testWidgets('Back and Go to Cue 0 call their explicit playback actions',
      (tester) async {
    final client = _FakePlaybackClient();
    await tester.pumpWidget(
      MaterialApp(home: CueStackTab(client: client, active: true)),
    );

    await tester.ensureVisible(find.byKey(const Key('cue_back_button')));
    await tester.tap(find.byKey(const Key('cue_back_button')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('cue_zero_button')));
    await tester.tap(find.byKey(const Key('cue_zero_button')));
    await tester.pump();

    expect(client.actions, containsAllInOrder(['activate', 'back', 'cue0']));
  });
}

final class _FakePlaybackClient implements EosClient, EosPlaybackClient {
  final StreamController<EosClientEvent> _events =
      StreamController<EosClientEvent>.broadcast(sync: true);
  final List<String> actions = <String>[];

  @override
  Stream<EosClientEvent> get events => _events.stream;
  @override
  EosConnectionState get connectionState => EosConnectionState.ready;
  @override
  EosCuePlaybackState get playbackState => const EosCuePlaybackState();
  @override
  EosVersionInfo get versionInfo => const EosVersionInfo();
  @override
  Future<void> activateCueStack() async => actions.add('activate');
  @override
  Future<void> backMainPlayback() async => actions.add('back');
  @override
  Future<void> goToCueZero() async => actions.add('cue0');
  @override
  Future<void> goMainPlayback() async => actions.add('go');
  @override
  Future<void> stopMainPlayback() async => actions.add('stop');
  @override
  Future<void> sendCommand(String command) async {}
  @override
  Future<void> connect(EosConnectionConfig config) async {}
  @override
  Future<void> disconnect() async {}
  @override
  Future<void> dispose() => _events.close();
  @override
  Future<void> fireCue(
      {required EosTargetNumber cueList, required EosTargetNumber cue}) async {}
  @override
  Future<List<EosCueList>> getCueLists() async => const [];
  @override
  Future<List<EosCue>> getCues(EosTargetNumber cueList) async => const [];
  @override
  Future<List<EosPatchPart>> getPatch(int channel) async => const [];
  @override
  Future<EosFixtureParameters> getParameters(int channel) async =>
      EosFixtureParameters(
          channel: channel,
          manufacturer: '',
          fixtureModel: '',
          parameters: const []);
  @override
  Future<String?> getShowPath() async => null;
  @override
  Future<List<EosSubmaster>> getSubmasters() async => const [];
  @override
  Future<EosVersionInfo> getVersion() async => versionInfo;
  @override
  Future<PingResult> ping() async =>
      const PingResult(token: 'fake', roundTrip: Duration.zero);
  @override
  Future<void> releaseChannel(int channel) async {}
  @override
  Future<void> setChannelFull(int channel) async {}
  @override
  Future<void> setChannelLevel(
      {required int channel, required double level}) async {}
  @override
  Future<void> setChannelOut(int channel) async {}
  @override
  Future<void> stopBackMainPlayback() async {}
}
