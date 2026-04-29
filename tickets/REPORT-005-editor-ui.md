# REPORT-005: Editor UI & Reports Tab Rewrite

## Summary
Rewrite `ReportsTab` as a split-panel layout: a template editor on the left and a live PDF preview on the right. Create the editor sub-widgets: template selector, column list with reorder/width controls, and grouping/sorting controls.

## Depends On
- REPORT-001 (data models)
- REPORT-002 (template renderer)
- REPORT-003 (persistence)
- REPORT-004 (state management)

## Files to Create
1. `lib/ui/reports/template_editor_panel.dart`
2. `lib/ui/reports/template_column_list.dart`
3. `lib/ui/reports/template_selector.dart`

## Files to Modify
1. `lib/ui/reports/reports_tab.dart` — complete rewrite

## Detailed Instructions

### 1. `reports_tab.dart` — Complete Rewrite

The tab becomes a horizontal split:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../providers/show_provider.dart';
import '../../features/reports/report_theme.dart';
import '../../features/reports/template_renderer.dart';
import '../../repositories/report_template_repository.dart';
import 'report_template_notifier.dart';  // if needed for ref
import 'template_editor_panel.dart';

class ReportsTab extends ConsumerStatefulWidget {
  const ReportsTab({super.key});
  @override
  ConsumerState<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<ReportsTab> {
  ReportTheme? _theme;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
    // Seed default templates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportTemplateRepoProvider)?.seedDefaults().then((_) {
        // After seeding, load the first template if none is loaded
        final templates = ref.read(reportTemplatesProvider).valueOrNull ?? [];
        if (templates.isNotEmpty) {
          final first = ReportTemplateRepository.parseTemplate(templates.first);
          ref.read(activeReportTemplateProvider.notifier).loadTemplate(first);
        }
      });
    });
  }

  Future<void> _loadTheme() async {
    try {
      final theme = await ReportTheme.load();
      if (mounted) setState(() { _theme = theme; _loading = false; });
    } catch (e) {
      // Font loading failed — use null theme, renderer will use fallbacks
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fixtures = ref.watch(fixtureRowsProvider).valueOrNull ?? [];
    final template = ref.watch(activeReportTemplateProvider);

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          // Left panel: editor
          SizedBox(
            width: 300,
            child: TemplateEditorPanel(theme: _theme),
          ),
          const VerticalDivider(width: 1),
          // Right panel: PDF preview
          Expanded(
            child: template.columns.isEmpty
              ? const Center(child: Text('Add at least one column to generate a report.'))
              : PdfPreview(
                  build: (format) => buildFromTemplate(format, fixtures, template, _theme!),
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  initialPageFormat: PdfPageFormat.letter,
                ),
          ),
        ],
      ),
    );
  }
}
```

### 2. `template_editor_panel.dart`

The left panel containing all editor controls.

```dart
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

          // Column picker + reorderable list (scrollable body)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // Section: Available Columns
                Text('COLUMNS', style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: appTheme.colorScheme.onSurface.withOpacity(0.6),
                )),
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

                const Divider(),

                // Column checkboxes: stacked columns
                Text('STACKED COLUMNS', style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: appTheme.colorScheme.onSurface.withOpacity(0.6),
                )),
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
                  const Divider(),
                  Text('COLUMN ORDER & WIDTH', style: GoogleFonts.jetBrainsMono(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: appTheme.colorScheme.onSurface.withOpacity(0.6),
                  )),
                  const SizedBox(height: 8),
                  TemplateColumnList(template: template, notifier: notifier),
                ],

                const Divider(),

                // Grouping
                Text('GROUPING', style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: appTheme.colorScheme.onSurface.withOpacity(0.6),
                )),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: template.groupByFieldKey,
                  decoration: const InputDecoration(
                    labelText: 'Group by',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...kReportFields.values.map((f) =>
                      DropdownMenuItem(value: f.key, child: Text(f.label)),
                    ),
                  ],
                  onChanged: (v) => notifier.setGroupBy(v),
                ),

                const SizedBox(height: 12),

                // Sorting
                Text('SORTING', style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: appTheme.colorScheme.onSurface.withOpacity(0.6),
                )),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: template.sortByFieldKey,
                  decoration: const InputDecoration(
                    labelText: 'Sort by',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
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

                const Divider(),

                // Orientation
                Text('ORIENTATION', style: GoogleFonts.jetBrainsMono(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: appTheme.colorScheme.onSurface.withOpacity(0.6),
                )),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'portrait', label: Text('Portrait')),
                    ButtonSegment(value: 'landscape', label: Text('Landscape')),
                  ],
                  selected: {template.orientation},
                  onSelectionChanged: (v) => notifier.setOrientation(v.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### 3. `template_column_list.dart`

A `ReorderableListView` showing the checked columns with drag handles and width controls.

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/reports/report_template.dart';
import 'report_template_notifier.dart';

class TemplateColumnList extends StatelessWidget {
  const TemplateColumnList({super.key, required this.template, required this.notifier});
  final ReportTemplate template;
  final ReportTemplateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: template.columns.length,
      onReorder: notifier.reorderColumns,
      itemBuilder: (context, index) {
        final col = template.columns[index];
        return _ColumnTile(
          key: ValueKey(col.id),
          column: col,
          onWidthChanged: (w) => notifier.setColumnFixedWidth(col.id, w),
          onFlexChanged: (f) => notifier.setColumnFlex(col.id, f),
          onRemove: () => notifier.removeColumn(col.id),
        );
      },
    );
  }
}

class _ColumnTile extends StatelessWidget {
  const _ColumnTile({
    super.key,
    required this.column,
    required this.onWidthChanged,
    required this.onFlexChanged,
    required this.onRemove,
  });

  final ReportColumn column;
  final ValueChanged<double> onWidthChanged;
  final ValueChanged<int> onFlexChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFixed = column.fixedWidth != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.drag_handle, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(column.label, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
                  if (column.isStacked)
                    Text(
                      column.fieldKeys.join(' + '),
                      style: GoogleFonts.jetBrainsMono(fontSize: 9, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                    ),
                ],
              ),
            ),
            // Width mode toggle
            ToggleButtons(
              isSelected: [isFixed, !isFixed],
              onPressed: (i) {
                if (i == 0) onWidthChanged(column.fixedWidth ?? 80);
                if (i == 1) onFlexChanged(column.flex > 0 ? column.flex : 1);
              },
              constraints: const BoxConstraints(minWidth: 36, minHeight: 28),
              children: const [
                Text('px', style: TextStyle(fontSize: 10)),
                Text('flex', style: TextStyle(fontSize: 10)),
              ],
            ),
            const SizedBox(width: 4),
            // Width/flex value
            SizedBox(
              width: 44,
              child: isFixed
                ? TextFormField(
                    initialValue: column.fixedWidth?.toInt().toString() ?? '80',
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (v) {
                      final w = double.tryParse(v);
                      if (w != null && w > 0) onWidthChanged(w);
                    },
                  )
                : DropdownButtonFormField<int>(
                    value: column.flex.clamp(1, 3),
                    decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                    items: [1, 2, 3].map((i) => DropdownMenuItem(value: i, child: Text('$i'))).toList(),
                    onChanged: (v) { if (v != null) onFlexChanged(v); },
                  ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. `template_selector.dart`

Dropdown for selecting, saving, and deleting templates.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/show_provider.dart';
import '../../repositories/report_template_repository.dart';

class TemplateSelector extends ConsumerStatefulWidget {
  const TemplateSelector({super.key});
  @override
  ConsumerState<TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends ConsumerState<TemplateSelector> {
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(reportTemplatesProvider).valueOrNull ?? [];
    final repo = ref.read(reportTemplateRepoProvider);
    final notifier = ref.read(activeReportTemplateProvider.notifier);
    final currentTemplate = ref.watch(activeReportTemplateProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: _selectedId,
            decoration: InputDecoration(
              labelText: 'Template',
              isDense: true,
              border: const OutlineInputBorder(),
              labelStyle: GoogleFonts.jetBrainsMono(fontSize: 12),
            ),
            items: templates.map((t) =>
              DropdownMenuItem(value: t.id, child: Text(t.name, style: GoogleFonts.jetBrainsMono(fontSize: 12))),
            ).toList(),
            onChanged: (id) {
              if (id == null) return;
              setState(() => _selectedId = id);
              final row = templates.firstWhere((t) => t.id == id);
              final template = ReportTemplateRepository.parseTemplate(row);
              notifier.loadTemplate(template);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save, size: 14),
                  label: const Text('Save'),
                  onPressed: _selectedId == null ? null : () {
                    repo?.updateTemplate(_selectedId!, currentTemplate);
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save_as, size: 14),
                  label: const Text('Save As'),
                  onPressed: () async {
                    final name = await _showNameDialog(context, currentTemplate.name);
                    if (name != null && name.isNotEmpty) {
                      final newTemplate = currentTemplate.copyWith(name: name);
                      notifier.setName(name);
                      final id = await repo?.createTemplate(name, newTemplate);
                      if (id != null) setState(() => _selectedId = id);
                    }
                  },
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: _selectedId == null ? null : () async {
                  await repo?.deleteTemplate(_selectedId!);
                  setState(() => _selectedId = null);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _showNameDialog(BuildContext context, String defaultName) {
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Template As'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Template Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
        ],
      ),
    );
  }
}
```

## Testing
- Hot restart the app
- Verify the Reports tab shows a split panel: editor on left, PDF preview on right
- Verify the template dropdown lists the 3 default templates
- Verify selecting a template updates the PDF preview
- Verify checking/unchecking columns adds/removes them from the report
- Verify dragging columns in the order list reorders them in the PDF
- Verify changing group-by and sort-by updates the PDF
- Verify switching orientation updates the PDF
- Verify "Save As" creates a new template that appears in the dropdown
- Verify deleting a template removes it from the dropdown
- Verify removing all columns shows the "Add at least one column" message instead of crashing
