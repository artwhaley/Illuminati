/// The top toolbar for the spreadsheet. 
/// Handles searching, multi-level sorting, and column management access.
import 'package:flutter/material.dart';
import '../column_spec.dart';

class SpreadsheetToolbar extends StatelessWidget {
  const SpreadsheetToolbar({
    super.key,
    required this.theme,
    required this.searchCtrl,
    required this.sortSpecs,
    required this.onSortLevel,
    required this.onToggleDirection,
    required this.availableCols,
    required this.onColumnsPressed,
  });

  final ThemeData theme;
  final TextEditingController searchCtrl;
  final List<SortSpec> sortSpecs;
  final void Function(int, String?) onSortLevel;
  final void Function(int) onToggleDirection;
  final List<String> availableCols;
  final void Function(BuildContext) onColumnsPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _searchBox(),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                _buildSortLevel(0, '1st'),
                const SizedBox(width: 12),
                _buildSortLevel(1, '2nd'),
                const SizedBox(width: 12),
                _buildSortLevel(2, '3rd'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Builder(
            builder: (ctx) => _chip(
              ctx,
              Icons.view_column_outlined,
              'Columns',
              () => onColumnsPressed(ctx),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortLevel(int level, String label) {
    final spec = level < sortSpecs.length ? sortSpecs[level] : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        )),
        const SizedBox(width: 6),
        SizedBox(
          width: 90,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isDense: true,
              value: spec?.column,
              hint: const Text('None', style: TextStyle(fontSize: 10)),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
              icon: Icon(Icons.arrow_drop_down, size: 14, color: theme.colorScheme.onSurfaceVariant),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('None', style: TextStyle(fontSize: 10))),
                ...availableCols.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(kColLabels[c] ?? c, style: const TextStyle(fontSize: 10)),
                )),
              ],
              onChanged: (val) => onSortLevel(level, val),
            ),
          ),
        ),
        if (spec != null)
          IconButton(
            icon: Icon(spec.ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 12),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            onPressed: () => onToggleDirection(level),
          ),
      ],
    );
  }

  Widget _searchBox() => SizedBox(
        width: 200,
        height: 28,
        child: TextField(
          controller: searchCtrl,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurface),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLowest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            hintText: 'Search…',
            hintStyle: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            prefixIcon: Icon(Icons.search, size: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 28, minHeight: 28),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      );

  Widget _chip(BuildContext ctx, IconData icon, String label, VoidCallback onTap,
          {bool active = false}) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: active
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 15,
                  color: active
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 5),
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: active
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            ],
          ),
        ),
      );
}
