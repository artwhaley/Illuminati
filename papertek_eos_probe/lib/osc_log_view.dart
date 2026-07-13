import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class UiLogEntry {
  const UiLogEntry({
    required this.timestamp,
    required this.kind,
    required this.category,
    required this.message,
  });

  final DateTime timestamp;
  final String kind;
  final String category;
  final String message;

  String format() {
    String two(int value) => value.toString().padLeft(2, '0');
    String three(int value) => value.toString().padLeft(3, '0');
    final time = '${two(timestamp.hour)}:${two(timestamp.minute)}:'
        '${two(timestamp.second)}.${three(timestamp.millisecond)}';
    return '$time  ${kind.padRight(5)}  ${category.padRight(20)}  $message';
  }
}

final class OscLogView extends StatelessWidget {
  const OscLogView({
    required this.entries,
    required this.scrollController,
    required this.autoScroll,
    required this.onAutoScrollChanged,
    required this.onClear,
    super.key,
  });

  final List<UiLogEntry> entries;
  final ScrollController scrollController;
  final bool autoScroll;
  final ValueChanged<bool> onAutoScrollChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
            child: Row(
              children: [
                Text(
                  'OSC Diagnostic Log (${entries.length}/5000)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Checkbox(
                      value: autoScroll,
                      onChanged: (value) => onAutoScrollChanged(value ?? false),
                    ),
                    const Text('Auto-scroll'),
                  ],
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: entries.isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text: entries
                                  .map((entry) => entry.format())
                                  .join('\n'),
                            ),
                          );
                        },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy All'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: entries.isEmpty ? null : onClear,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SelectionArea(
              child: ListView.builder(
                controller: scrollController,
                itemCount: entries.length,
                itemExtent: 22,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  final color = switch (entry.kind) {
                    'ERROR' => Theme.of(context).colorScheme.error,
                    'WARN' => Theme.of(context).colorScheme.tertiary,
                    'TX' => Theme.of(context).colorScheme.primary,
                    'RX' => Theme.of(context).colorScheme.secondary,
                    _ => Theme.of(context).colorScheme.onSurface,
                  };
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      entry.format(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
