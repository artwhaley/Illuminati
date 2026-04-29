/// A horizontal selector for Spreadsheet View Presets (saved layouts).
import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../../../repositories/spreadsheet_view_preset_repository.dart';
import '../spreadsheet_view_controller.dart';

class SpreadsheetPresetsStrip extends StatelessWidget {
  const SpreadsheetPresetsStrip({
    super.key,
    required this.theme,
    required this.presets,
    required this.controller,
    required this.onCreatePressed,
  });

  final ThemeData theme;
  final List<SpreadsheetViewPreset> presets;
  final SpreadsheetViewController controller;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Text('PRESETS',
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          const SizedBox(width: 12),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in presets)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _buildPresetButton(theme, p),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 18),
            tooltip: 'Save current as preset',
            onPressed: onCreatePressed,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            color: theme.colorScheme.primary,
          ),
          if (controller.activePreset != null && controller.isPresetDirty)
            IconButton(
              icon: const Icon(Icons.save, size: 18),
              tooltip: 'Update active preset',
              onPressed: controller.updateActivePreset,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: theme.colorScheme.primary,
            ),
          if (controller.activePreset != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              tooltip: 'Delete active preset',
              onPressed: () => controller.deletePreset(controller.activePreset!.id),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              color: theme.colorScheme.error,
            ),
        ],
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
}
