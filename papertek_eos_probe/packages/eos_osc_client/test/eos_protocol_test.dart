import 'package:eos_osc_client/eos_osc_client.dart';
import 'package:eos_osc_client/src/eos_client.dart' show EosListReassembler;
import 'package:eos_osc_client/src/eos_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('builds direct channel and playback commands', () {
    final level = EosProtocol.setChannelLevel(12, 50);
    expect(level.address, '/eos/chan/12');
    expect((level.arguments.single as OscInt32).data, 50);
    expect(EosProtocol.setChannelFull(12).address, '/eos/chan/12/full');
    expect(EosProtocol.setChannelOut(12).address, '/eos/chan/12/out');
    final release = EosProtocol.releaseChannel(12);
    expect(release.address, '/eos/newcmd');
    expect(
      (release.arguments.single as OscString).data,
      'Chan 12 Sneak Time 0 Enter',
    );
    expect(EosProtocol.goMainPlayback().address, '/eos/key/Go_Main_CueList');
    expect(EosProtocol.backMainPlayback().address,
        '/eos/key/Stop_Back_Main_CueList');
    expect(EosProtocol.stopMainPlayback().address, '/eos/key/Stop_CueList');
    expect(EosProtocol.stopBackMainPlayback().address,
        '/eos/key/Stop_Back_Main_CueList');
    final cueZero = EosProtocol.goToCueZero();
    expect(cueZero.address, '/eos/newcmd');
    expect((cueZero.arguments.single as OscString).data, 'Go To Cue 0 Enter');
  });

  test('preserves decimal cue spelling in cue-fire address', () {
    final message = EosProtocol.fireCue(
      EosTargetNumber('1'),
      EosTargetNumber('1.10'),
    );
    expect(message.address, '/eos/cue/1/1.10/fire');
  });

  test('reassembles a split Eos OSC List', () {
    final reassembler = EosListReassembler();
    final warnings = <String>[];
    final first = reassembler.accept(
      OscMessage(
        '/eos/out/get/cuelist/1/list/0/13',
        const <OscArgument>[
          OscInt32(0),
          OscString('uid'),
          OscString('Main'),
          OscString('Cue List'),
          OscString('Proportional'),
          OscBool(false),
          OscBool(true),
        ],
      ),
      timeout: const Duration(seconds: 1),
      onExpired: warnings.add,
    );
    expect(first, isNull);

    final second = reassembler.accept(
      OscMessage(
        '/eos/out/get/cuelist/1/list/7/13',
        const <OscArgument>[
          OscBool(false),
          OscBool(false),
          OscBool(false),
          OscBool(false),
          OscInt32(0),
          OscBool(true),
        ],
      ),
      timeout: const Duration(seconds: 1),
      onExpired: warnings.add,
    );

    expect(second, isNotNull);
    expect(second!.address, '/eos/out/get/cuelist/1');
    expect(second.arguments, hasLength(13));
    expect(warnings, isEmpty);
  });

  test('parses a cue-list primary response', () {
    final result = EosProtocol.parseCueList(
      OscMessage(
        '/eos/out/get/cuelist/2',
        const <OscArgument>[
          OscInt32(0),
          OscString('uid-2'),
          OscString('Main Stack'),
          OscString('Cue List'),
          OscString('Proportional'),
          OscBool(false),
          OscBool(true),
          OscBool(false),
          OscBool(false),
          OscBool(false),
          OscBool(false),
          OscInt32(0),
          OscBool(true),
        ],
      ),
    );
    expect(result.number.value, '2');
    expect(result.label, 'Main Stack');
    expect(result.isHtp, isTrue);
  });

  test('parses cue, submaster, patch, and parameter data', () {
    final cueArgs = <OscArgument>[
      const OscInt32(3),
      const OscString('cue-uid'),
      const OscString('Blackout'),
      const OscInt32(2000),
      const OscInt32(0),
      const OscInt32(1500),
      const OscInt32(0),
      const OscInt32(2000),
      const OscInt32(0),
      const OscInt32(2000),
      const OscInt32(0),
      const OscInt32(2000),
      const OscInt32(0),
      const OscBool(false),
      const OscInt32(0),
      const OscInt32(100),
      const OscString(''),
      const OscString(''),
      const OscString(''),
      const OscString(''),
      const OscInt32(0),
      const OscInt32(0),
      const OscBool(false),
      const OscInt32(0),
      const OscBool(false),
      const OscString(''),
      const OscInt32(0),
      const OscString('note'),
      const OscString('Act I'),
      const OscBool(false),
      const OscInt32(-1),
    ];
    final cue = EosProtocol.parseCue(
      OscMessage('/eos/out/get/cue/1/1.10/0', cueArgs),
    );
    expect(cue.cueNumber.value, '1.10');
    expect(cue.label, 'Blackout');
    expect(cue.upTimeMs, 2000);

    final sub = EosProtocol.parseSubmaster(
      OscMessage(
        '/eos/out/get/sub/5',
        const <OscArgument>[
          OscInt32(0),
          OscString('sub-uid'),
          OscString('House'),
          OscString('Additive'),
          OscString('Proportional'),
          OscBool(true),
          OscBool(false),
          OscBool(false),
          OscBool(true),
          OscString('5'),
          OscString('2'),
          OscString('0'),
          OscString('2'),
        ],
      ),
    );
    expect(sub.label, 'House');

    final patchArguments = <OscArgument>[
      const OscInt32(0),
      const OscString('patch-uid'),
      const OscString('SL Spot'),
      const OscString('ETC'),
      const OscString('Source Four LED'),
      const OscInt32(101),
      const OscInt32(101),
      const OscInt32(50),
      const OscString('R80'),
      ...List<OscArgument>.generate(10, (_) => const OscString('')),
      const OscInt32(1),
    ];
    final patch = EosProtocol.parsePatchPart(
      OscMessage('/eos/out/get/patch/12/1', patchArguments),
    );
    expect(patch.channel, 12);
    expect(patch.fixtureModel, 'Source Four LED');

    final parameters = EosProtocol.parseParameters(
      OscMessage(
        '/eos/out/get/params/12',
        const <OscArgument>[
          OscString('ETC'),
          OscString('Source Four LED'),
          OscString('Intens'),
          OscFloat32(50),
          OscFloat32(0),
          OscFloat32(100),
          OscString('Red'),
          OscFloat32(20),
          OscFloat32(0),
          OscFloat32(100),
        ],
      ),
    );
    expect(parameters.parameters, hasLength(2));
    expect(parameters.parameters.last.name, 'Red');
  });
}
