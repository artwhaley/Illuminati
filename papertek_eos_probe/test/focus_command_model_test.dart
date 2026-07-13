import 'package:flutter_test/flutter_test.dart';
import 'package:papertek_eos_probe/focus/command_model.dart';

void main() {
  test('compiles every Phase 1 grammar row', () {
    final cases = <List<String>, String>{
      ['1', '@', '55', 'Enter']: 'Chan 1 At 55 Enter',
      ['1', 'Full']: 'Chan 1 Full Enter',
      ['1', 'Out']: 'Chan 1 Out Enter',
      ['1', 'Release']: 'Chan 1 Sneak Time 0 Enter',
      ['45', 'Color', '5', 'Enter']: 'Chan 45 Color Palette 5 Enter',
      ['45', 'Position', '5', 'Enter']: 'Chan 45 Focus Palette 5 Enter',
      ['45', 'Beam', '5', 'Enter']: 'Chan 45 Beam Palette 5 Enter',
      ['Record', '4', 'Enter']: 'Record Cue 4 Enter',
      ['Update', 'Enter']: 'Update Enter',
      ['Update', 'Cue Only', 'Enter']: 'Update CueOnly Enter',
      ['Record', '4', 'Cue Only', 'Enter']: 'Record Cue 4 CueOnly Enter',
    };
    for (final entry in cases.entries)
      expect(FocusCommandCompiler.compile(entry.key).text, entry.value);
  });

  test('rejects unsafe or incomplete syntax and never emits Record_Only', () {
    for (final input in <List<String>>[
      ['1'],
      ['1', '@', '101', 'Enter'],
      ['0', '@', '5', 'Enter'],
      ['1', 'Color', '0', 'Enter'],
      ['1', 'Thru', '2', 'Enter'],
      ['Record', '4'],
      ['Update'],
      ['1', '@', '5', 'Enter', 'Enter'],
    ]) {
      expect(() => FocusCommandCompiler.compile(input), throwsA(isA<Object>()));
    }
    expect(
        FocusCommandCompiler.compile(['Record', '4', 'Cue Only', 'Enter']).text,
        isNot(contains('Record_Only')));
  });

  test('clear and backspace are deterministic semantic operations', () {
    final buffer = FocusCommandBuffer()
      ..appendDigit('4')
      ..appendDigit('5')
      ..appendSemantic(FocusSemanticToken.position)
      ..appendDigit('6');
    expect(buffer.display, '45 Position 6');
    buffer.backspace();
    expect(buffer.display, '45 Position');
    buffer.backspace();
    expect(buffer.display, '45');
    buffer.clear();
    expect(buffer.tokens, isEmpty);
  });
}
