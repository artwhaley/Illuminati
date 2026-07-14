import 'dart:async';

import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papertek_eos_probe/focus_remote_screen.dart';

void main() {
  testWidgets('touch keypad sends normalized command without feedback',
      (tester) async {
    final client = _FakeClient();
    await tester
        .pumpWidget(MaterialApp(home: FocusRemoteScreen(client: client)));
    for (final key in <String>['1', '@', '5', '5', 'Enter']) {
      await tester.tap(find.text(key).last);
    }
    await tester.pump();
    expect(client.commands, ['Chan 1 At 55 Enter']);
    expect(find.text('Last locally sent: Chan 1 At 55 Enter'), findsOneWidget);
  });

  testWidgets('Full is terminal and Previous/Next remain separate',
      (tester) async {
    final client = _FakeClient();
    await tester
        .pumpWidget(MaterialApp(home: FocusRemoteScreen(client: client)));
    await tester.tap(find.text('1').last);
    await tester.tap(find.text('Full').last);
    await tester.pump();
    expect(client.commands, ['Chan 1 Full Enter']);
    await tester.ensureVisible(find.text('Next').last);
    await tester.tap(find.text('Next').last);
    await tester.pump();
    expect(client.channelOperations, ['release:1', 'level:2:100.0']);
    expect(find.text('Selected channel: 2'), findsOneWidget);
  });

  testWidgets('bare channel actions reuse the last successful channel',
      (tester) async {
    final client = _FakeClient();
    await tester
        .pumpWidget(MaterialApp(home: FocusRemoteScreen(client: client)));
    await tester.tap(find.text('4').last);
    await tester.tap(find.text('Full').last);
    await tester.pump();
    await tester.tap(find.text('Release').last);
    await tester.pump();
    await tester.tap(find.text('@').last);
    await tester.tap(find.text('5').last);
    await tester.tap(find.text('5').last);
    await tester.tap(find.text('Enter').last);
    await tester.pump();
    expect(client.commands, [
      'Chan 4 Full Enter',
      'Chan 4 Sneak Time 0 Enter',
      'Chan 4 At 55 Enter',
    ]);
  });

  testWidgets('touch keypad sends a Thru channel range', (tester) async {
    final client = _FakeClient();
    await tester
        .pumpWidget(MaterialApp(home: FocusRemoteScreen(client: client)));
    for (final key in <String>['1', 'Thru', '1', '0', '@', '5', '5', 'Enter']) {
      await tester.ensureVisible(find.text(key).last);
      await tester.tap(find.text(key).last);
      await tester.pump();
    }
    expect(client.commands, ['Chan 1 Thru 10 At 55 Enter']);
    expect(find.byKey(const Key('command_error')), findsNothing);
  });

  testWidgets('portrait keypad keeps each requested control row together',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1100));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
        MaterialApp(home: FocusRemoteScreen(client: _FakeClient())));

    void expectSameRow(List<String> labels) {
      final y = labels
          .map((label) => tester.getCenter(find.text(label).last).dy)
          .toList();
      expect(y.every((value) => (value - y.first).abs() < 1), isTrue,
          reason: '$labels must share one row');
    }

    expectSameRow(['1', '2', '3']);
    expectSameRow(['4', '5', '6']);
    expectSameRow(['7', '8', '9']);
    expectSameRow(['@', 'Full', 'Out', 'Release', 'Enter']);
    expect(find.text('Thru'), findsOneWidget);
    expectSameRow(['Clear', 'Backspace']);
    expectSameRow(['Previous', 'Next']);
    expectSameRow(['Position', 'Color', 'Beam']);
    expectSameRow(['Record', 'Update', 'Cue Only']);
  });
}

final class _FakeClient implements EosClient, EosPlaybackClient {
  final StreamController<EosClientEvent> _events =
      StreamController<EosClientEvent>.broadcast(sync: true);
  final List<String> commands = <String>[];
  final List<String> channelOperations = <String>[];
  @override
  Stream<EosClientEvent> get events => _events.stream;
  @override
  EosConnectionState get connectionState => EosConnectionState.ready;
  @override
  EosVersionInfo get versionInfo => const EosVersionInfo();
  @override
  EosCuePlaybackState get playbackState => const EosCuePlaybackState();
  @override
  Future<void> sendCommand(String command) async => commands.add(command);
  @override
  Future<void> goMainPlayback() async {}
  @override
  Future<void> backMainPlayback() async {}
  @override
  Future<void> goToCueZero() async {}
  @override
  Future<void> stopMainPlayback() async {}
  @override
  Future<void> activateCueStack() async {}
  @override
  Future<void> connect(EosConnectionConfig config) async {}
  @override
  Future<void> disconnect() async {}
  @override
  Future<void> dispose() => _events.close();
  @override
  Future<PingResult> ping() async =>
      const PingResult(token: 'fake', roundTrip: Duration.zero);
  @override
  Future<void> setChannelLevel(
          {required int channel, required double level}) async =>
      channelOperations.add('level:$channel:$level');
  @override
  Future<void> setChannelFull(int channel) async {}
  @override
  Future<void> setChannelOut(int channel) async {}
  @override
  Future<void> releaseChannel(int channel) async =>
      channelOperations.add('release:$channel');
  @override
  Future<void> stopBackMainPlayback() async {}
  @override
  Future<void> fireCue(
      {required EosTargetNumber cueList, required EosTargetNumber cue}) async {}
  @override
  Future<EosVersionInfo> getVersion() async => versionInfo;
  @override
  Future<String?> getShowPath() async => null;
  @override
  Future<List<EosCueList>> getCueLists() async => const <EosCueList>[];
  @override
  Future<List<EosCue>> getCues(EosTargetNumber cueList) async =>
      const <EosCue>[];
  @override
  Future<List<EosSubmaster>> getSubmasters() async => const <EosSubmaster>[];
  @override
  Future<List<EosPatchPart>> getPatch(int channel) async =>
      const <EosPatchPart>[];
  @override
  Future<EosFixtureParameters> getParameters(int channel) async =>
      EosFixtureParameters(
          channel: channel,
          manufacturer: '',
          fixtureModel: '',
          parameters: const <EosParameterValue>[]);
}
