import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/reports/report_theme.dart';
import '../../features/reports/report_field_registry.dart';
import '../../providers/show_provider.dart';
import 'template_selector.dart';
import 'template_column_list.dart';

class TemplateEditorPanel extends ConsumerWidget {
  const TemplateEditorPanel({super.key, this.theme});
  final ReportTheme? theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final template = ref.watch(activeReportTemplateProvider);
    final notifier = ref.read(activeReportTemplateProvider.notifier);
    final appTheme = Theme.of(context);

    return Container(
      color: appTheme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Template selector at top
          const TemplateSelector(),
          const Divider(height: 1),

          // Scrollable body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Section: Available Columns
                _SectionHeader(label: 'COLUMNS'),
                const SizedBox(height: 8),

                // Column checkboxes: simple fields
                ...kReportFields.values.map((field) {
                  final isChecked = template.columns.any((c) => c.id == field.key);
                  return CheckboxListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(field.label, style: GoogleFonts.jetBrainsMono(fontSize: 12)),
                    value: isChecked,
                    onChanged: (v) {
                      if (v == true) {
                        notifier.addColumn(field.key);
                      } else {
                        notifier.removeColumn(field.key);
                      }
                    },
                  );
                }),

                const Divider(height: 32),

                // Column checkboxes: stacked columns
                _SectionHeader(label: 'STACKED COLUMNS'),
                const SizedBox(height: 8),
                ...kStackedColumns.values.map((stack) {
                  final isChecked = template.columns.any((c) => c.id == stack.id);
                  final subLabels = stack.fieldKeys
                      .map((k) => kReportFields[k]?.label ?? k)
                      .join(' + ');
                  return CheckboxListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(stack.label, style: GoogleFonts.jetBrainsMono(fontSize: 12)),
                    subtitle: Text(subLabels, style: GoogleFonts.jetBrainsMono(
                      fontSize: 10, color: appTheme.colorScheme.onSurface.withOpacity(0.5),
                    )),
                    value: isChecked,
                    onChanged: (v) {
                      if (v == true) {
                        notifier.addColumn(stack.id);
                      } else {
                        notifier.removeColumn(stack.id);
                      }
                    },
                  );
                }),

                if (template.columns.isNotEmpty) ...[
                  const Divider(height: 32),
                  _SectionHeader(label: 'COLUMN ORDER & WIDTH'),
                  const SizedBox(height: 8),
                  TemplateColumnList(template: template, notifier: notifier),
                ],

                const Divider(height: 32),

                // Grouping
                _SectionHeader(label: 'GROUPING'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: template.groupByFieldKey,
                  decoration: const InputDecoration(
                    labelText: 'Group by',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: appTheme.colorScheme.onSurface),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...kReportFields.values.map((f) =>
                      DropdownMenuItem(value: f.key, child: Text(f.label)),
                    ),
                  ],
                  onChanged: (v) => notifier.setGroupBy(v),
                ),

                const Divider(height: 32),

                // Sorting
                _SectionHeader(label: 'SORTING'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: template.sortByFieldKey,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: appTheme.colorScheme.onSurface),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...kReportFields.values.map((f) =>
                      DropdownMenuItem(value: f.key, child: Text(f.label)),
                    ),
                  ],
                  onChanged: (v) => notifier.setSortBy(v, ascending: template.sortAscending),
                ),
                SwitchListTile(
                  dense: true,
                  title: Text('Ascending', style: GoogleFonts.jetBrainsMono(fontSize: 12)),
                  value: template.sortAscending,
                  onChanged: (v) => notifier.setSortBy(template.sortByFieldKey, ascending: v),
                ),

                const Divider(height: 32),

                // Orientation
                _SectionHeader(label: 'ORIENTATION'),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'portrait', label: Text('Portrait', style: TextStyle(fontSize: 12))),
                    ButtonSegment(value: 'landscape', label: Text('Landscape', style: TextStyle(fontSize: 12))),
                  ],
                  selected: {template.orientation},
                  onSelectionChanged: (v) => notifier.setOrientation(v.first),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      label,
      style: GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary.withOpacity(0.8),
        letterSpacing: 0.5,
      ),
    );
  }
}
