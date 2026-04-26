import 'package:flutter/material.dart';
import '../../services/import/import_service.dart';

/// Read-only summary shown after a completed import.
class ImportSummaryDialog extends StatelessWidget {
  const ImportSummaryDialog({
    super.key,
    required this.result,
    this.fileWarnings = const [],
  });

  final ImportResult result;

  /// Warnings generated at the file-parsing stage (before DB writes).
  final List<String> fileWarnings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allWarnings = [...fileWarnings, ...result.warnings];

    return AlertDialog(
      title: const Text('Import Complete'),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Counts ──────────────────────────────────────────────────
            _CountRow(
              icon: Icons.lightbulb_outline,
              label: 'Fixtures created',
              value: result.fixturesCreated,
              highlight: true,
            ),
            _CountRow(
              icon: Icons.place_outlined,
              label: 'Positions created',
              value: result.positionsCreated,
            ),
            _CountRow(
              icon: Icons.category_outlined,
              label: 'Fixture types created',
              value: result.fixtureTypesCreated,
            ),
            if (result.rowsSkipped > 0)
              _CountRow(
                icon: Icons.warning_amber_outlined,
                label: 'Rows skipped',
                value: result.rowsSkipped,
                color: theme.colorScheme.error,
              ),

            // ── Warnings ─────────────────────────────────────────────────
            if (allWarnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Warnings', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: allWarnings.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      allWarnings[i],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
    this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final bool highlight;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor =
        color ?? (highlight ? theme.colorScheme.primary : null);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            '$value',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
