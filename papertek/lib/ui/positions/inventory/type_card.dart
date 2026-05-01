// -- type_card.dart ------------------------------------------------------------
//
// List card widget for a fixture type in the Inventory tab.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../database/database.dart';

class TypeCard extends StatefulWidget {
  const TypeCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
    required this.onSecondaryTap,
    this.onRename,
  });

  final FixtureType type;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSecondaryTap;
  final Future<void> Function(String)? onRename;

  @override
  State<TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<TypeCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.type.name);
  }

  @override
  void didUpdateWidget(TypeCard old) {
    super.didUpdateWidget(old);
    if (widget.type.name != old.type.name && !_ctrl.selection.isValid) {
      _ctrl.text = widget.type.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commitRename() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty && v != widget.type.name) {
      widget.onRename?.call(v);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: widget.selected
            ? amber.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _editing ? null : widget.onTap,
          onSecondaryTap: _editing ? null : widget.onSecondaryTap,
          onDoubleTap: widget.onRename == null
              ? null
              : () {
                  _ctrl.text = widget.type.name;
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
                                color: widget.selected ? amber : null,
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
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.type.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.selected ? amber : null,
                                fontWeight: widget.selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (widget.type.wattage != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.type.wattage!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                if (!_editing)
                  Text(
                    '${widget.type.partCount}p',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF4B5263),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
