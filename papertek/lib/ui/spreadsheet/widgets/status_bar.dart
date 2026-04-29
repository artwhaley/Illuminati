/// A thin bar at the bottom of the spreadsheet showing row counts and show name.
import 'package:flutter/material.dart';

class SpreadsheetStatusBar extends StatelessWidget {
  const SpreadsheetStatusBar({
    super.key,
    required this.totalFixtures,
    required this.visibleCount,
    required this.filterActive,
    required this.showName,
    required this.theme,
  });

  final int totalFixtures;
  final int visibleCount;
  final bool filterActive;
  final String showName;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final muted = theme.colorScheme.onSurfaceVariant;
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 7, color: Colors.green),
          const SizedBox(width: 8),
          Text('LOCAL',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: muted, fontWeight: FontWeight.bold)),
          const Spacer(),
          if (filterActive) ...[
            Text('$visibleCount of $totalFixtures fixtures',
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600)),
          ] else ...[
            Text('$totalFixtures fixtures',
                style: theme.textTheme.labelSmall?.copyWith(color: muted)),
          ],
          const Spacer(),
          if (showName.isNotEmpty)
            Text(showName,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: muted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
