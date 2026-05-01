import 'package:flutter/material.dart';
import '../spreadsheet/column_spec.dart';

enum MultipartAction { merge, separate, skip }

enum MultipartConfidence { high, medium }

class MultipartGroup {
  final String position;
  final String unitNumber;
  final List<Map<String, String>> rows;
  final MultipartConfidence confidence;
  const MultipartGroup({
    required this.position,
    required this.unitNumber,
    required this.rows,
    required this.confidence,
  });
}

class MultipartDecision {
  final MultipartGroup group;
  final MultipartAction action;
  const MultipartDecision({required this.group, required this.action});
}

/// Detects rows that share the same position + unit number.
/// Returns only groups with 2+ rows (multipart candidates).
List<MultipartGroup> detectMultipartCandidates(
  List<Map<String, String>> rawRows,
  Map<ColumnSpec, List<String>> mapping,
) {
  final posHeaders = mapping.entries
      .where((e) => e.key.id == 'position')
      .expand((e) => e.value)
      .toList();
  final unitHeaders = mapping.entries
      .where((e) => e.key.id == 'unit')
      .expand((e) => e.value)
      .toList();

  final posHeader = posHeaders.isNotEmpty ? posHeaders.first : null;
  final unitHeader = unitHeaders.isNotEmpty ? unitHeaders.first : null;

  if (posHeader == null || unitHeader == null) return [];

  final groups = <(String, String), List<Map<String, String>>>{};
  for (final row in rawRows) {
    final pos = (row[posHeader] ?? '').toLowerCase().trim();
    final unit = (row[unitHeader] ?? '').toLowerCase().trim();
    if (pos.isEmpty || unit.isEmpty) continue;
    groups.putIfAbsent((pos, unit), () => []).add(row);
  }

  final allHeaders = mapping.values.expand((v) => v).toList();
  final partIndicator = RegExp(r'^[1-9][a-cA-C]?$|^[a-cA-C]$');

  final result = <MultipartGroup>[];
  for (final entry in groups.entries) {
    final rows = entry.value;
    if (rows.length < 2) continue;

    final firstRow = rows.first;
    final position = firstRow[posHeader] ?? entry.key.$1;
    final unitNumber = firstRow[unitHeader] ?? entry.key.$2;

    var confidence = MultipartConfidence.medium;
    outer:
    for (final row in rows) {
      for (final h in allHeaders) {
        final v = (row[h] ?? '').trim();
        if (partIndicator.hasMatch(v)) {
          confidence = MultipartConfidence.high;
          break outer;
        }
      }
    }

    result.add(MultipartGroup(
      position: position,
      unitNumber: unitNumber,
      rows: rows,
      confidence: confidence,
    ));
  }

  return result;
}

class MultipartDetectionScreen extends StatefulWidget {
  const MultipartDetectionScreen({super.key, required this.candidates});

  final List<MultipartGroup> candidates;

  @override
  State<MultipartDetectionScreen> createState() =>
      _MultipartDetectionScreenState();
}

class _MultipartDetectionScreenState extends State<MultipartDetectionScreen> {
  late List<MultipartAction> _actions;

  @override
  void initState() {
    super.initState();
    if (widget.candidates.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop(<MultipartDecision>[]);
      });
      _actions = [];
    } else {
      _actions = List.filled(widget.candidates.length, MultipartAction.merge);
    }
  }

  void _applyAll(MultipartAction action) {
    setState(() {
      _actions = List.filled(widget.candidates.length, action);
    });
  }

  void _popWithDecisions() {
    final decisions = [
      for (var i = 0; i < widget.candidates.length; i++)
        MultipartDecision(group: widget.candidates[i], action: _actions[i]),
    ];
    Navigator.of(context).pop(decisions);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.candidates.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final count = widget.candidates.length;

    return AlertDialog(
      title: const Text('Multipart Fixtures Detected'),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      content: SizedBox(
        width: 600,
        height: 480,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count group${count == 1 ? '' : 's'} of rows share the same '
              'position and unit number.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () => _applyAll(MultipartAction.merge),
                  child: const Text('Merge all'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _applyAll(MultipartAction.separate),
                  child: const Text('Keep all separate'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: count,
                itemBuilder: (_, i) {
                  final group = widget.candidates[i];
                  final isHigh = group.confidence == MultipartConfidence.high;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(group.position,
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600)),
                                Text('Unit: ${group.unitNumber}',
                                    style: theme.textTheme.bodySmall),
                                Text('${group.rows.length} rows',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(
                                            color: const Color(0xFF6B7280))),
                                const SizedBox(height: 4),
                                Chip(
                                  label: Text(
                                    isHigh ? 'High confidence' : 'Possible',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: isHigh
                                      ? Colors.green.shade600
                                      : Colors.amber.shade700,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                ),
                              ],
                            ),
                          ),
                          DropdownButton<MultipartAction>(
                            value: _actions[i],
                            onChanged: (v) =>
                                setState(() => _actions[i] = v!),
                            items: const [
                              DropdownMenuItem(
                                value: MultipartAction.merge,
                                child: Text('Merge as multipart'),
                              ),
                              DropdownMenuItem(
                                value: MultipartAction.separate,
                                child: Text('Import as separate fixtures'),
                              ),
                              DropdownMenuItem(
                                value: MultipartAction.skip,
                                child: Text('Skip these rows'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(<MultipartDecision>[]),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _popWithDecisions,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
