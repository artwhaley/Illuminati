// ── venue_shared_widgets.dart ─────────────────────────────────────────────────
//
// Shared layout and interactive widgets used by all four venue sub-tabs.
//
// _VenueShell:     outer layout (tool rail + info panel + list)
// _InfoPanelShell: 180px detail panel with title-or-hint content
// _VenueCard:      selectable, renameable list card
// _ToolButton:     icon button for the tool sidebar
//
// All items here are private, used only within the venue/ sub-package.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VenueShell extends StatelessWidget {
  const VenueShell({
    required this.infoPanel,
    required this.child,
    required this.emptyHint,
    required this.isLoading,
    this.onAdd,
    this.onDelete,
  });

  final Widget infoPanel;
  final Widget child;
  final String emptyHint;
  final bool isLoading;
  final VoidCallback? onAdd;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sidebar
        Container(
          width: 52,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFF23272E))),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              VenueToolButton(
                  icon: Icons.add, tooltip: 'Add', onPressed: onAdd),
              VenueToolButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete Selected',
                  onPressed: onDelete),
            ],
          ),
        ),
        // Info panel
        infoPanel,
        // List
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : child,
        ),
      ],
    );
  }
}

class VenueInfoPanelShell extends StatelessWidget {
  const VenueInfoPanelShell({
    required this.title,
    required this.emptyLabel,
    required this.children,
  });

  final String? title;
  final String emptyLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF23272E))),
      ),
      padding: const EdgeInsets.all(12),
      child: title != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ...children,
              ],
            )
          : Center(
              child: Text(
                emptyLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: const Color(0xFF4B5263)),
              ),
            ),
    );
  }
}

class VenueCard extends StatefulWidget {
  const VenueCard({
    super.key,
    required this.name,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.onRename,
  });

  final String name;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Future<void> Function(String)? onRename;

  @override
  State<VenueCard> createState() => _VenueCardState();
}

class _VenueCardState extends State<VenueCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void didUpdateWidget(VenueCard old) {
    super.didUpdateWidget(old);
    if (widget.name != old.name && !_ctrl.selection.isValid) {
      _ctrl.text = widget.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commit() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty && v != widget.name) widget.onRename?.call(v);
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
          onDoubleTap: widget.onRename == null
              ? null
              : () {
                  _ctrl.text = widget.name;
                  setState(() => _editing = true);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: _editing
                ? CallbackShortcuts(
                    bindings: {
                      const SingleActivator(LogicalKeyboardKey.escape):
                          () => setState(() => _editing = false),
                    },
                    child: Focus(
                      onFocusChange: (has) {
                        if (!has) _commit();
                      },
                      child: TextField(
                        controller: _ctrl,
                        autofocus: true,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: widget.selected ? amber : null),
                        decoration: const InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (_) => _commit(),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: widget.selected ? amber : null,
                          fontWeight: widget.selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle!,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class VenueToolButton extends StatelessWidget {
  const VenueToolButton(
      {required this.icon, required this.tooltip, this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: onPressed != null
          ? Theme.of(context).colorScheme.primary
          : const Color(0xFF3A3F4A),
    );
  }
}
