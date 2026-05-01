import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/import/row_reader.dart';
import '../../services/import/row_matcher.dart';
import '../../services/import/import_service.dart';
import '../spreadsheet/column_spec.dart';

/// Modal dialog: maps import file columns → PaperTek fields, then triggers import.
///
/// Supports multi-header assignment per field via removable chips.
class ColumnMappingScreen extends ConsumerStatefulWidget {
  const ColumnMappingScreen({
    super.key,
    required this.path,
    required this.rowReader,
    required this.importHeaders,
    required this.suggestions,
    required this.initialMapping,
    required this.importServiceProvider,
  });

  final String path;
  final RowReader rowReader;

  /// All column headers from the import file (row 1).
  final List<String> importHeaders;

  /// Per-ColumnSpec ranked suggestions from RowMatcher.
  final Map<ColumnSpec, List<MatchSuggestion>> suggestions;

  /// Initial mapping (deep-copied into state).
  final Map<ColumnSpec, List<String>> initialMapping;

  final ProviderBase<ImportService?> importServiceProvider;

  @override
  ConsumerState<ColumnMappingScreen> createState() =>
      _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends ConsumerState<ColumnMappingScreen> {
  late Map<ColumnSpec, List<String>> _mapping;
  bool _isLoading = false;

  late final List<ColumnSpec> _importableColumns;

  @override
  void initState() {
    super.initState();
    _importableColumns = kColumns.where((c) => c.isImportable).toList();
    _mapping = {
      for (final e in widget.initialMapping.entries)
        e.key: List<String>.from(e.value),
    };
    for (final col in _importableColumns) {
      _mapping.putIfAbsent(col, () => []);
    }
  }

  bool get _canImport {
    final posSpec = kColumns.firstWhere((c) => c.id == 'position');
    return (_mapping[posSpec]?.isNotEmpty == true) && !_isLoading;
  }

  Future<void> _runImport() async {
    // Return the confirmed mapping to the caller; import is orchestrated by main_shell.
    Navigator.of(context).pop(Map<ColumnSpec, List<String>>.from(_mapping));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Map Import Columns'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 640,
        height: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match each PaperTek field to one or more columns from your file. '
              'Auto-detected matches are pre-filled.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _importableColumns.length,
                itemBuilder: (_, i) {
                  final col = _importableColumns[i];
                  return _ColumnMappingRow(
                    column: col,
                    assignedHeaders: List.from(_mapping[col] ?? []),
                    allHeaders: widget.importHeaders,
                    suggestions: widget.suggestions[col] ?? [],
                    onAddHeader: (h) => setState(
                        () => (_mapping[col] ??= []).add(h)),
                    onRemoveHeader: (h) =>
                        setState(() => _mapping[col]?.remove(h)),
                  );
                },
              ),
            ),
            const Divider(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canImport ? _runImport : null,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import'),
        ),
      ],
    );
  }
}

class _ColumnMappingRow extends StatelessWidget {
  const _ColumnMappingRow({
    required this.column,
    required this.assignedHeaders,
    required this.allHeaders,
    required this.suggestions,
    required this.onAddHeader,
    required this.onRemoveHeader,
  });

  final ColumnSpec column;
  final List<String> assignedHeaders;
  final List<String> allHeaders;
  final List<MatchSuggestion> suggestions;
  final ValueChanged<String> onAddHeader;
  final ValueChanged<String> onRemoveHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredSuggestions =
        suggestions.where((s) => !assignedHeaders.contains(s.importHeader)).toList();

    final sortedRemaining = ([...allHeaders]..sort())
        .where((h) => !assignedHeaders.contains(h))
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                column.label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (assignedHeaders.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: assignedHeaders
                        .map(
                          (h) => Chip(
                            label: Text(
                              h,
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => onRemoveHeader(h),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                          ),
                        )
                        .toList(),
                  ),
                PopupMenuButton<String>(
                  tooltip: 'Add a column',
                  onSelected: (value) {
                    if (value.isNotEmpty) onAddHeader(value);
                  },
                  itemBuilder: (_) {
                    final items = <PopupMenuEntry<String>>[];

                    if (filteredSuggestions.isNotEmpty) {
                      for (final s in filteredSuggestions) {
                        items.add(PopupMenuItem<String>(
                          value: s.importHeader,
                          child: Row(
                            children: [
                              Icon(Icons.auto_awesome,
                                  size: 14,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  s.importHeader,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ));
                      }
                      items.add(const PopupMenuDivider());
                    }

                    for (final h in sortedRemaining) {
                      items.add(PopupMenuItem<String>(
                        value: h,
                        child: Text(h, overflow: TextOverflow.ellipsis),
                      ));
                    }

                    if (items.isEmpty || (items.length == 1 && items.first is PopupMenuDivider)) {
                      return [
                        const PopupMenuItem<String>(
                          value: '',
                          child: Text('— not imported —'),
                        ),
                      ];
                    }

                    return items;
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 16,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Add column',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
