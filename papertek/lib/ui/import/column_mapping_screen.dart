import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/import/row_reader.dart';
import '../../services/import/row_matcher.dart';
import '../../services/import/import_service.dart';
import '../spreadsheet/column_spec.dart';

class ColumnMappingScreen extends ConsumerStatefulWidget {
  const ColumnMappingScreen({
    super.key,
    required this.path,
    required this.rowReader,
    required this.importHeaders,
    required this.suggestions,
    required this.initialMapping,
    required this.headersWithData,
    required this.importServiceProvider,
  });

  final String path;
  final RowReader rowReader;
  final List<String> importHeaders;
  final Map<ColumnSpec, List<MatchSuggestion>> suggestions;
  final Map<ColumnSpec, String?> initialMapping;
  final Set<String> headersWithData;
  final ProviderBase<ImportService?> importServiceProvider;

  @override
  ConsumerState<ColumnMappingScreen> createState() =>
      _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends ConsumerState<ColumnMappingScreen> {
  late Map<ColumnSpec, String?> _mapping;
  bool _isLoading = false;
  late final List<ColumnSpec> _importableColumns;

  @override
  void initState() {
    super.initState();
    _importableColumns = kColumns.where((c) => c.isImportable).toList();
    _mapping = Map<ColumnSpec, String?>.from(widget.initialMapping);
    for (final col in _importableColumns) {
      _mapping.putIfAbsent(col, () => null);
    }
  }

  bool get _canImport {
    final posSpec = kColumns.firstWhere((c) => c.id == 'position');
    return _mapping[posSpec] != null && !_isLoading;
  }

  Future<void> _runImport() async {
    Navigator.of(context).pop(Map<ColumnSpec, String?>.from(_mapping));
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Match each PaperTek field to a column from your file.',
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
                    currentHeader: _mapping[col],
                    allHeaders: widget.importHeaders,
                    suggestions: widget.suggestions[col] ?? [],
                    headersWithData: widget.headersWithData,
                    onChanged: (newValue) => setState(() {
                      // Release any other field that holds this header.
                      if (newValue != null) {
                        for (final key in _mapping.keys) {
                          if (key != col && _mapping[key] == newValue) {
                            _mapping[key] = null;
                          }
                        }
                      }
                      _mapping[col] = newValue;
                    }),
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
    required this.currentHeader,
    required this.allHeaders,
    required this.suggestions,
    required this.headersWithData,
    required this.onChanged,
  });

  final ColumnSpec column;
  final String? currentHeader;
  final List<String> allHeaders;
  final List<MatchSuggestion> suggestions;
  final Set<String> headersWithData;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final suggestionHeaders = suggestions.map((s) => s.importHeader).toSet();

    final withData = allHeaders
        .where((h) => !suggestionHeaders.contains(h) && headersWithData.contains(h))
        .toList()
      ..sort();

    final withoutData = allHeaders
        .where((h) => !suggestionHeaders.contains(h) && !headersWithData.contains(h))
        .toList()
      ..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Text(
              column.label,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 260,
            child: DropdownButton<String?>(
              value: currentHeader,
              isExpanded: true,
              onChanged: (v) => onChanged(v == '\x00' ? null : v),
              items: [
                // Always-present null option
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— none —'),
                ),

                // Tier 1: auto-match suggestions — amber text
                // Tier 1: auto-match suggestions — amber color provides
                // visual separation; no divider needed here.
                ...suggestions.map((s) => DropdownMenuItem<String?>(
                      value: s.importHeader,
                      child: Text(
                        s.importHeader,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFC8960C)),
                      ),
                    )),

                // Tier 2: headers with data — normal text
                ...withData.map((h) => DropdownMenuItem<String?>(
                      value: h,
                      child: Text(h, overflow: TextOverflow.ellipsis),
                    )),

                // Divider only when both populated and empty tiers are present.
                if (withData.isNotEmpty && withoutData.isNotEmpty)
                  const DropdownMenuItem<String?>(
                    value: '\x00',
                    enabled: false,
                    child: Divider(),
                  ),

                // Tier 3: headers without data — grey text
                ...withoutData.map((h) => DropdownMenuItem<String?>(
                      value: h,
                      child: Text(
                        h,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF9E9E9E)),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
