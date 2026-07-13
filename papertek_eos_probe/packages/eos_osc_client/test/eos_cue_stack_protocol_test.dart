import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:eos_osc_client/src/eos_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('GO, Stop/Back, and Stop use official Eos key addresses', () {
    expect(EosProtocol.goMainPlayback().address, '/eos/key/Go_Main_CueList');
    expect(EosProtocol.backMainPlayback().address,
        '/eos/key/Stop_Back_Main_CueList');
    expect(EosProtocol.stopMainPlayback().address, '/eos/key/Stop_CueList');
    expect({
      EosProtocol.goMainPlayback().address,
      EosProtocol.backMainPlayback().address,
      EosProtocol.stopMainPlayback().address
    }, hasLength(3));
  });

  test('Go to Cue 0 uses one explicit command-line message', () {
    final message = EosProtocol.goToCueZero();
    expect(message.address, '/eos/newcmd');
    expect(message.arguments, hasLength(1));
    expect((message.arguments.single as OscString).data, 'Go To Cue 0 Enter');
  });

  test(
      'cue feedback identities, optional parts, progress, event, and bank rows parse',
      () {
    final state = EosCuePlaybackState(
      activeCueList: EosTargetNumber('1'),
      activeCue: EosTargetNumber('2'),
      activePart: EosTargetNumber('3'),
      fadeProgress: 0.5,
    );
    expect(state.activeCueList!.value, '1');
    expect(state.activePart!.value, '3');
    final row = EosProtocol.parseCueListBankRow(
        OscMessage('/eos/out/cuelist/1/2', const <OscArgument>[
      OscString('2'),
      OscString('1'),
      OscString('Blackout'),
      OscString('notes'),
      OscString('Act I'),
      OscBool(true),
      OscInt32(3000),
      OscInt32(1200),
    ]));
    expect(row.cueNumber.value, '2');
    expect(row.partNumber!.value, '1');
    expect(row.label, 'Blackout');
    expect(row.notes, 'notes');
    expect(row.sceneEnd, isTrue);
    expect(row.durationMs, 3000);
    expect(row.remainingMs, 1200);
  });

  test('progress input clamps to the documented range', () {
    final message =
        OscMessage('/eos/out/active/cue', const <OscArgument>[OscFloat32(2.5)]);
    final value = EosProtocol.numberAt(message, 0).clamp(0.0, 1.0).toDouble();
    expect(value, 1.0);
  });
}
