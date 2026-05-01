// ── venue_field_widgets.dart ──────────────────────────────────────────────────
//
// Shared labeled field widgets used by all four venue sub-tabs.
// _InfoField: a save-on-blur underline text field.
// _DropdownField: a labeled dropdown that handles stale option values gracefully.
//
// These are private widgets (underscore prefix), intended only for use within
// the venue/ sub-package.

import 'package:flutter/material.dart';

class VenueInfoField extends StatelessWidget {
  const VenueInfoField({
    required this.label,
    required this.controller,
    required this.onSave,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final int maxLines;

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
            maxLines: maxLines,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF23272E), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1.5),
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

class VenueDropdownField extends StatelessWidget {
  const VenueDropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.theme,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<String> options;
  final ThemeData theme;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    // Show the current value even if it's not in the option list (stale soft-link).
    final items = {
      if (value != null && !options.contains(value)) value!,
      ...options,
    }.toList();

    return Column(
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
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF23272E), width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: theme.colorScheme.primary, width: 1.5),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 4),
          ),
          style: theme.textTheme.bodyMedium,
          dropdownColor: theme.colorScheme.surface,
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('— none —',
                  style: TextStyle(color: Color(0xFF6B7280))),
            ),
            ...items.map((n) => DropdownMenuItem(value: n, child: Text(n))),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
