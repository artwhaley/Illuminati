import 'package:eos_osc_client/eos_osc_client.dart';

enum FocusSemanticToken {
  at,
  full,
  out,
  release,
  color,
  position,
  beam,
  record,
  update,
  cueOnly,
  enter
}

final class FocusCompiledCommand {
  const FocusCompiledCommand(this.text);
  final String text;
}

final class FocusCommandCompiler {
  const FocusCommandCompiler._();

  static FocusCompiledCommand compile(List<String> input) {
    final tokens = input
        .map((token) => token.trim())
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty)
      throw const EosValidationException('Enter a command first.');
    if (tokens.contains('Thru') ||
        tokens.contains('+') ||
        tokens.contains('-')) {
      throw const EosValidationException(
          'Ranges, groups, Thru, +, and - are not supported.');
    }
    if (tokens.last == 'Enter') {
      return _compileEntered(tokens.sublist(0, tokens.length - 1));
    }
    if (tokens.length == 2 &&
        _isPositiveWhole(tokens[0]) &&
        const {'Full', 'Out', 'Release'}.contains(tokens[1])) {
      return _compileImmediate(tokens);
    }
    throw const EosValidationException('Press Enter to complete this command.');
  }

  static FocusCompiledCommand _compileImmediate(List<String> tokens) {
    final channel = _channel(tokens[0]);
    return FocusCompiledCommand(switch (tokens[1]) {
      'Full' => 'Chan $channel Full Enter',
      'Out' => 'Chan $channel Out Enter',
      'Release' => 'Chan $channel Sneak Time 0 Enter',
      _ => throw const EosValidationException('Unknown terminal action.'),
    });
  }

  static FocusCompiledCommand _compileEntered(List<String> tokens) {
    if (tokens.isEmpty)
      throw const EosValidationException('Enter a command first.');
    if (tokens.first == 'Update') {
      if (tokens.length == 1) return const FocusCompiledCommand('Update Enter');
      if (tokens.length == 2 && tokens[1] == 'Cue Only') {
        return const FocusCompiledCommand('Update CueOnly Enter');
      }
      throw const EosValidationException(
          'Update accepts only Cue Only before Enter.');
    }
    if (tokens.first == 'Record') {
      if (tokens.length < 2 || !_isPositiveNumber(tokens[1])) {
        throw const EosValidationException(
            'Record needs one positive cue number.');
      }
      if (tokens.length == 2)
        return FocusCompiledCommand('Record Cue ${tokens[1]} Enter');
      if (tokens.length == 3 && tokens[2] == 'Cue Only') {
        return FocusCompiledCommand('Record Cue ${tokens[1]} CueOnly Enter');
      }
      throw const EosValidationException(
          'Record accepts one cue number and optional Cue Only.');
    }
    if (!_isPositiveWhole(tokens.first)) {
      throw const EosValidationException(
          'A command must start with one channel.');
    }
    final channel = _channel(tokens.first);
    if (tokens.length == 3 && tokens[1] == '@' && _isLevel(tokens[2])) {
      return FocusCompiledCommand(
          'Chan $channel At ${_normalizeNumber(tokens[2])} Enter');
    }
    if (tokens.length == 3 &&
        const {'Color', 'Position', 'Beam'}.contains(tokens[1]) &&
        _isPositiveNumber(tokens[2])) {
      final eosName = switch (tokens[1]) {
        'Position' => 'Focus',
        _ => tokens[1],
      };
      return FocusCompiledCommand(
          'Chan $channel $eosName Palette ${tokens[2]} Enter');
    }
    throw const EosValidationException(
        'Incomplete or ambiguous Focus command.');
  }

  static int _channel(String value) {
    final channel = int.tryParse(value);
    if (channel == null || channel <= 0) {
      throw const EosValidationException(
          'Channel must be a positive whole number.');
    }
    return channel;
  }

  static bool _isPositiveWhole(String value) =>
      int.tryParse(value) != null && int.parse(value) > 0;

  static bool _isPositiveNumber(String value) {
    final number = double.tryParse(value);
    return number != null && number.isFinite && number > 0;
  }

  static bool _isLevel(String value) {
    final level = double.tryParse(value);
    return level != null && level.isFinite && level >= 0 && level <= 100;
  }

  static String _normalizeNumber(String value) {
    final number = double.parse(value);
    return number == number.roundToDouble() ? number.toInt().toString() : value;
  }
}

/// Token buffer used by both touch and physical keyboard input.
final class FocusCommandBuffer {
  final List<String> _tokens = <String>[];

  List<String> get tokens => List<String>.unmodifiable(_tokens);
  String get display => _tokens.join(' ');

  void appendChannel(int channel) {
    if (_tokens.isEmpty && channel > 0) _tokens.add(channel.toString());
  }

  void appendDigit(String digit) {
    if (!RegExp(r'^\d$').hasMatch(digit)) return;
    _appendToNumber(digit);
  }

  void appendDecimal() {
    if (_tokens.isEmpty ||
        !_isNumber(_tokens.last) ||
        _tokens.last.contains('.')) return;
    _tokens[_tokens.length - 1] = '${_tokens.last}.';
  }

  void appendSymbol(String symbol) {
    if (symbol == '@') _tokens.add('@');
  }

  void appendSemantic(FocusSemanticToken token) {
    _tokens.add(switch (token) {
      FocusSemanticToken.at => '@',
      FocusSemanticToken.full => 'Full',
      FocusSemanticToken.out => 'Out',
      FocusSemanticToken.release => 'Release',
      FocusSemanticToken.color => 'Color',
      FocusSemanticToken.position => 'Position',
      FocusSemanticToken.beam => 'Beam',
      FocusSemanticToken.record => 'Record',
      FocusSemanticToken.update => 'Update',
      FocusSemanticToken.cueOnly => 'Cue Only',
      FocusSemanticToken.enter => 'Enter',
    });
  }

  void backspace() {
    if (_tokens.isEmpty) return;
    final last = _tokens.last;
    if (_isNumber(last) && last.length > 1) {
      _tokens[_tokens.length - 1] = last.substring(0, last.length - 1);
    } else {
      _tokens.removeLast();
    }
  }

  void clear() => _tokens.clear();

  bool _isNumber(String value) => RegExp(r'^\d*\.?\d*$').hasMatch(value);

  void _appendToNumber(String digit) {
    if (_tokens.isNotEmpty && _isNumber(_tokens.last) && _tokens.last != '.') {
      _tokens[_tokens.length - 1] += digit;
    } else {
      _tokens.add(digit);
    }
  }
}
