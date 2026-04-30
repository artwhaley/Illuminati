/// A vertical-expanding selector for Spreadsheet View Presets and Filter controls.
import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../spreadsheet_view_controller.dart';

class SpreadsheetPresetsStrip extends StatelessWidget {
  const SpreadsheetPresetsStrip({
    super.key,
    required this.theme,
    required this.presets,
    required this.controller,
    required this.onCreatePressed,
    required this.filterActive,
    required this.filterLabel,
    required this.onQuickFilter,
    required this.onClearFilter,
  });

  final ThemeData theme;
  final List<SpreadsheetViewPreset> presets;
  final SpreadsheetViewController controller;
  final VoidCallback onCreatePressed;
  final bool filterActive;
  final String? filterLabel;
  final VoidCallback onQuickFilter;
  final VoidCallback onClearFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween, // Presets Left, Filters Right
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 20,
          runSpacing: 10,
          children: [
            // ── PRESETS GROUP (Left Justified) ───────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PRESETS',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  tooltip: 'Save current as preset',
                  onPressed: onCreatePressed,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 450),
                  child: SizedBox(
                    height: 28,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      children: [
                        for (final p in presets)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _buildPresetButton(theme, p),
                          ),
                      ],
                    ),
                  ),
                ),
                if (controller.activePreset != null) ...[
                  const SizedBox(width: 8),
                  if (controller.isPresetDirty)
                    IconButton(
                      icon: const Icon(Icons.save, size: 18),
                      tooltip: 'Update active preset',
                      onPressed: controller.updateActivePreset,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      color: theme.colorScheme.primary,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    tooltip: 'Delete active preset',
                    onPressed: () => controller.deletePreset(controller.activePreset!.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    color: theme.colorScheme.error,
                  ),
                ],
              ],
            ),

            // ── FILTER GROUP (Right Justified) ───────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (filterActive) ...[
                  _filterBadge(),
                  const SizedBox(width: 12),
                ],
                _quickFilterChip(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(ThemeData theme, SpreadsheetViewPreset preset) {
    final isActive = controller.activePreset?.id == preset.id;
    final isDirty = controller.isPresetDirty;
    final color = isActive
        ? (isDirty ? Colors.yellow[800] : Colors.orange[800])
        : theme.colorScheme.surfaceContainerHighest;
    final textColor = isActive ? Colors.white : theme.colorScheme.onSurfaceVariant;

    return ActionChip(
      label: Text(preset.name,
          style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
      onPressed: () => controller.applyPreset(preset),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }

  Widget _quickFilterChip() {
    final active = filterActive;
    return InkWell(
      onTap: onQuickFilter,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 24,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined, size: 12,
                color: active
                    ? theme.colorScheme.onPrimaryContainer // Darker font color when active
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
            const SizedBox(width: 6),
            Text('Quick Filter',
                style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? theme.colorScheme.onPrimaryContainer // Darker font color when active
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
          height: 22,
          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                      fontWeight: FontWeight.w700)),
              const SizedBox(width: 6),
              Icon(Icons.close, size: 12,
                  color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      );
}
