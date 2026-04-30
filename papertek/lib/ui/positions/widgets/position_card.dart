import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../database/database.dart';

class PositionCard extends StatefulWidget {
  const PositionCard({
    super.key,
    required this.index,
    required this.position,
    required this.selected,
    required this.onTap,
    required this.onSecondaryTap,
    this.onRename,
  });

  final int index;
  final LightingPosition position;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSecondaryTap;
  final Future<void> Function(String)? onRename;

  @override
  State<PositionCard> createState() => _PositionCardState();
}

class _PositionCardState extends State<PositionCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.position.name);
  }

  @override
  void didUpdateWidget(PositionCard old) {
    super.didUpdateWidget(old);
    if (widget.position.name != old.position.name && !_ctrl.selection.isValid) {
      _ctrl.text = widget.position.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commitRename() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty && v != widget.position.name) {
      widget.onRename?.call(v);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: widget.selected
            ? theme.colorScheme.primary.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _editing ? null : widget.onTap,
          onSecondaryTap: _editing ? null : widget.onSecondaryTap,
          onDoubleTap: widget.onRename == null
              ? null
              : () {
                  _ctrl.text = widget.position.name;
                  setState(() => _editing = true);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _editing
                      ? CallbackShortcuts(
                          bindings: {
                            const SingleActivator(LogicalKeyboardKey.escape):
                                () => setState(() => _editing = false),
                          },
                          child: Focus(
                            onFocusChange: (has) {
                              if (!has) _commitRename();
                            },
                            child: TextField(
                              controller: _ctrl,
                              autofocus: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.selected
                                    ? theme.colorScheme.primary
                                    : null,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _commitRename(),
                            ),
                          ),
                        )
                      : Text(
                          widget.position.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: widget.selected
                                ? theme.colorScheme.primary
                                : null,
                            fontWeight: widget.selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                ),
                const SizedBox(width: 8),
                ReorderableDragStartListener(
                  index: widget.index,
                  child: const Icon(Icons.drag_indicator,
                      size: 18, color: Color(0xFF4B5263)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
