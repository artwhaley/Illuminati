/// A horizontal bar that displays active filters and provides "Quick Filter" 
/// and "Clear Filter" actions.
import 'package:flutter/material.dart';

class SpreadsheetFilterStrip extends StatelessWidget {
  const SpreadsheetFilterStrip({
    super.key,
    required this.theme,
    required this.filterActive,
    required this.filterLabel,
    required this.onQuickFilter,
    required this.onClearFilter,
  });

  final ThemeData theme;
  final bool filterActive;
  final String? filterLabel;
  final VoidCallback onQuickFilter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _quickFilterChip(),
          if (filterActive) ...[
            const SizedBox(width: 12),
            _filterBadge(),
          ],
        ],
      ),
    );
  }

  Widget _quickFilterChip() {
    final active = filterActive;
    return InkWell(
      onTap: onQuickFilter,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 24,
        padding: const EdgeInsets.symmetric(horizontal: 8),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, size: 12,
                color: active
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text('Quick Filter',
                style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: active
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }

  Widget _filterBadge() => InkWell(
        onTap: onClearFilter,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(filterLabel ?? '',
                  style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 4),
              Icon(Icons.close, size: 10,
                  color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      );
}
