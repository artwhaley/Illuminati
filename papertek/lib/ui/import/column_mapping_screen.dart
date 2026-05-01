import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/import/csv_field_definitions.dart';
import '../../services/import/csv_import_parser.dart';
import '../../services/import/import_service.dart';
import 'import_summary_dialog.dart';

/// Modal dialog: maps CSV columns → PaperTek fields, then triggers the import.
///
/// [initialMapping] comes from the auto-detector; the user can override each
/// dropdown. Null means "don't import this field".
class ColumnMappingScreen extends ConsumerStatefulWidget {
  const ColumnMappingScreen({
    super.key,
    required this.csvPath,
    required this.headers,
    required this.initialMapping,
    required this.importServiceProvider,
  });

  final String csvPath;

  /// Column headers from row 1 of the CSV.
  final List<String> headers;

  /// Field → 0-based column index (null = not mapped).
  final Map<PaperTekImportField, int?> initialMapping;

  /// Provider resolved by the caller; passed in so this widget stays testable.
  final ProviderBase<ImportService?> importServiceProvider;

  @override
  ConsumerState<ColumnMappingScreen> createState() =>
      _ColumnMappingScreenState();
}

class _ColumnMappingScreenState extends ConsumerState<ColumnMappingScreen> {
  late Map<PaperTekImportField, int?> _mapping;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _mapping = Map.of(widget.initialMapping);
  }

  bool get _canImport =>
      _mapping[PaperTekImportField.position] != null && !_importing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Dropdown items: null = "Not imported" + one entry per CSV column.
    final columnItems = [
      const DropdownMenuItem<int?>(value: null, child: Text('— not imported —')),
      ...widget.headers.asMap().entries.map(
            (e) => DropdownMenuItem<int?>(
              value: e.key,
              child: Text(e.value, overflow: TextOverflow.ellipsis),
            ),
          ),
    ];

    return AlertDialog(
      title: const Text('Map CSV Columns'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 560,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match each PaperTek field to the right column from your CSV. '
              'Auto-detected matches are pre-filled.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: PaperTekImportField.values.length,
                itemBuilder: (_, i) {
                  final field = PaperTekImportField.values[i];
                  return _MappingRow(
                    field: field,
                    columnItems: columnItems,
                    currentValue: _mapping[field],
                    onChanged: (v) => setState(() => _mapping[field] = v),
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
          onPressed: _importing ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canImport ? _runImport : null,
          child: _importing
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

  Future<void> _runImport() async {
    final service = ref.read(widget.importServiceProvider);
    if (service == null) return;

    setState(() => _importing = true);

    try {
      const parser = CsvImportParser();
      final (rows, fileWarnings) = await parser.parseRows(
        widget.csvPath,
        Map.of(_mapping),
      );

      final result = await service.importRows(
        rows: rows,
        sourceFileName: widget.csvPath.split(RegExp(r'[/\\]')).last,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // close mapping dialog
      await showDialog<void>(
        context: context,
        builder: (_) => ImportSummaryDialog(
          result: result,
          fileWarnings: fileWarnings,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _importing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }
}

class _MappingRow extends StatelessWidget {
  const _MappingRow({
    required this.field,
    required this.columnItems,
    required this.currentValue,
    required this.onChanged,
  });

  final PaperTekImportField field;
  final List<DropdownMenuItem<int?>> columnItems;
  final int? currentValue;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(field.displayName,
                        style: theme.textTheme.bodyMedium),
                    if (field.isRequired) ...[
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
                Text(
                  field.hint,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFF6B7280)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<int?>(
              initialValue: currentValue,
              items: columnItems,
              onChanged: onChanged,
              isExpanded: true,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
