// -- inventory_shared_widgets.dart --------------------------------------------
//
// This file intentionally keeps local copies of widgets that mirror the same names
// in the venue tabs. Consolidation is deferred to a dedicated follow-up ticket.

import 'package:flutter/material.dart';

class InventoryInfoField extends StatelessWidget {
  const InventoryInfoField({
    required this.label,
    required this.controller,
    required this.onSave,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      onFocusChange: (has) {
        if (!has) onSave();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF6B7280),
              letterSpacing: 0.6,
              fontSize: 9,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.textTheme.bodySmall,
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
            onSubmitted: (_) => onSave(),
          ),
        ],
      ),
    );
  }
}

class InventoryToolButton extends StatelessWidget {
  const InventoryToolButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

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
