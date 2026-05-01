// -- playbill_field.dart --------------------------------------------------------
//
// Centered, optional autosizing heading and detail fields for the show info card.

import 'package:flutter/material.dart';

class PlaybillField extends StatefulWidget {
  const PlaybillField({
    required this.value,
    required this.style,
    required this.hint,
    required this.onSave,
    this.autoSize = false,
  });

  final String? value;
  final TextStyle style;
  final String hint;
  final Future<void> Function(String) onSave;

  /// When true, displays as a FittedBox (scales down long text) and switches to
  /// a TextField only when tapped.
  final bool autoSize;

  @override
  State<PlaybillField> createState() => _PlaybillFieldState();
}

class _PlaybillFieldState extends State<PlaybillField> {
  late final TextEditingController _ctrl;
  late String _lastSaved;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _lastSaved = widget.value ?? '';
    _ctrl = TextEditingController(text: _lastSaved);
  }

  @override
  void didUpdateWidget(PlaybillField old) {
    super.didUpdateWidget(old);
    final incoming = widget.value ?? '';
    if (incoming != _lastSaved && !_ctrl.selection.isValid) {
      _lastSaved = incoming;
      _ctrl.text = incoming;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final v = _ctrl.text.trim();
    if (v != _lastSaved) {
      // Fixed: was v.widget.onSave(v) - typo
      _lastSaved = v;
      widget.onSave(v);
    }
  }

  void _commitAndClose() {
    _save();
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final amber = Theme.of(context).colorScheme.primary;

    // Display-only mode: FittedBox scales long text down to fit in one line.
    if (widget.autoSize && !_editing) {
      final displayText = _lastSaved.isEmpty ? widget.hint : _lastSaved;
      final displayStyle = _lastSaved.isEmpty
          ? widget.style.copyWith(color: const Color(0xFF2E3340))
          : widget.style;
      return GestureDetector(
        onTap: () => setState(() => _editing = true),
        child: SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayText,
              style: displayStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Focus(
      onFocusChange: (has) {
        if (!has) _commitAndClose();
      },
      child: TextField(
        controller: _ctrl,
        autofocus: widget.autoSize && _editing,
        style: widget.style,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: widget.style.copyWith(color: const Color(0xFF2E3340)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: amber.withValues(alpha: 0.4), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          isDense: true,
        ),
        onSubmitted: (_) => _commitAndClose(),
      ),
    );
  }
}

