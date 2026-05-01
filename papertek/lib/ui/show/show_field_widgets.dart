// -- show_field_widgets.dart -------------------------------------------------
//
// Leaf widgets for simple labeled underline fields used in the show info card.

import 'package:flutter/material.dart';

class SimpleField extends StatefulWidget {
  const SimpleField({
    required this.label,
    required this.value,
    required this.onSave,
  });

  final String label;
  final String? value;
  final Future<void> Function(String) onSave;

  @override
  State<SimpleField> createState() => _SimpleFieldState();
}

class _SimpleFieldState extends State<SimpleField> {
  late final TextEditingController _ctrl;
  late String _lastSaved;

  @override
  void initState() {
    super.initState();
    _lastSaved = widget.value ?? '';
    _ctrl = TextEditingController(text: _lastSaved);
  }

  @override
  void didUpdateWidget(SimpleField old) {
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
    if (v == _lastSaved) return;
    _lastSaved = v;
    widget.onSave(v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      onFocusChange: (has) {
        if (!has) _save();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: _ctrl,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF23272E), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
    );
  }
}

