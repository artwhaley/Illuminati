import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/reports/report_theme.dart';
import '../../features/reports/report_field_registry.dart';
import '../../features/reports/report_template.dart';
import '../../providers/show_provider.dart';
import 'template_selector.dart';
import 'report_template_notifier.dart';

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
          const TemplateSelector(),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                // 2. GROUPING
                const _SectionHeader(label: 'GROUPING'),
                const SizedBox(height: 8),
                _buildGroupingSection(template, notifier, appTheme),
                const Divider(height: 32),

                // 3. SORTING
                const _SectionHeader(label: 'SORTING'),
                const SizedBox(height: 8),
                _buildSortingSection(template, notifier, appTheme),
                const Divider(height: 32),

                // 4. COLUMNS (Unified Picker)
                const _SectionHeader(label: 'COLUMNS (DRAG TO REORDER)'),
                const SizedBox(height: 8),
                _UnifiedColumnPicker(template: template, notifier: notifier),
                const Divider(height: 32),

                // 5. COLUMN FORMATTING
                if (template.columns.isNotEmpty) ...[
                  const _SectionHeader(label: 'COLUMN FORMATTING'),
                  const SizedBox(height: 8),
                  _ColumnFormattingTable(template: template, notifier: notifier),
                  const Divider(height: 32),
                ],

                // 6. TYPOGRAPHY
                const _SectionHeader(label: 'TYPOGRAPHY'),
                const SizedBox(height: 8),
                _buildTypographySection(template, notifier, appTheme),
                const Divider(height: 32),

                // 7. ORIENTATION
                const _SectionHeader(label: 'ORIENTATION'),
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

  Widget _buildGroupingSection(ReportTemplate template, ReportTemplateNotifier notifier, ThemeData appTheme) {
    return DropdownButtonFormField<String?>(
      value: template.groupByFieldKey,
      decoration: const InputDecoration(
        labelText: 'Group by',
        isDense: true,
        border: OutlineInputBorder(),
      ),
      style: GoogleFonts.jetBrainsMono(fontSize: 12, color: appTheme.colorScheme.onSurface),
      items: [
        const DropdownMenuItem(value: null, child: Text('None')),
        ...kReportFields.values.map((f) => DropdownMenuItem(value: f.key, child: Text(f.label))),
      ],
      onChanged: (v) => notifier.setGroupBy(v),
    );
  }

  Widget _buildSortingSection(ReportTemplate template, ReportTemplateNotifier notifier, ThemeData appTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...template.sortLevels.asMap().entries.map((entry) {
          final idx = entry.key;
          final level = entry.value;
          final usedKeys = template.sortLevels.map((l) => l.fieldKey).where((k) => k != level.fieldKey).toSet();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: level.fieldKey.isEmpty ? null : level.fieldKey,
                    decoration: InputDecoration(
                      labelText: 'Level ${idx + 1}',
                      isDense: true,
                      border: const OutlineInputBorder(),
                    ),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: appTheme.colorScheme.onSurface),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('None')),
                      ...kReportFields.values.map((f) {
                        final isUsed = usedKeys.contains(f.key);
                        return DropdownMenuItem(
                          value: f.key,
                          enabled: !isUsed,
                          child: Text(
                            f.label,
                            style: TextStyle(color: isUsed ? appTheme.disabledColor : null),
                          ),
                        );
                      }),
                    ],
                    onChanged: (v) => notifier.setSortLevel(idx, v ?? '', ascending: level.ascending),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  icon: Icon(level.ascending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                  onPressed: () => notifier.setSortLevel(idx, level.fieldKey, ascending: !level.ascending),
                  visualDensity: VisualDensity.compact,
                ),
                if (idx > 0)
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () => notifier.removeSortLevel(idx),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          );
        }),
        if (template.sortLevels.length < 3)
          TextButton.icon(
            onPressed: notifier.addSortLevel,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Sort Level', style: TextStyle(fontSize: 12)),
          ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: template.multipartHeader,
          onChanged: (v) => notifier.setMultipartHeader(v ?? false),
          title: const Text('Use header-mode multipart sorting', style: TextStyle(fontSize: 12)),
          contentPadding: EdgeInsets.zero,
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildTypographySection(ReportTemplate template, ReportTemplateNotifier notifier, ThemeData appTheme) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: template.fontFamily,
          decoration: const InputDecoration(
            labelText: 'Data Font',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: appTheme.colorScheme.onSurface),
          items: kFontFamilyPaths.keys.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
          onChanged: (v) {
            if (v != null) notifier.setFontFamily(v);
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<double>(
          value: template.dataFontSize,
          decoration: const InputDecoration(
            labelText: 'Default Size',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          style: GoogleFonts.jetBrainsMono(fontSize: 12, color: appTheme.colorScheme.onSurface),
          items: [7, 7.5, 8, 8.5, 9, 9.5, 10, 10.5, 11, 12]
              .map((s) => DropdownMenuItem(value: s.toDouble(), child: Text('$s pt')))
              .toList(),
          onChanged: (v) {
            if (v != null) notifier.setDataFontSize(v);
          },
        ),
      ],
    );
  }
}

class _UnifiedColumnPicker extends StatelessWidget {
  const _UnifiedColumnPicker({required this.template, required this.notifier});
  final ReportTemplate template;
  final ReportTemplateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final allItems = allPickerItems;
    final selectedIds = template.columns.map((c) => c.id).toList();

    // Sort items: selected first (in order), then unselected
    final List<ReportPickerItem> sortedList = [];
    for (final id in selectedIds) {
      final item = allItems.firstWhere((i) => i.id == id);
      sortedList.add(item);
    }
    for (final item in allItems) {
      if (!selectedIds.contains(item.id)) {
        sortedList.add(item);
      }
    }

    final selectedCount = selectedIds.length;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.dividerColor),
        borderRadius: BorderRadius.circular(4),
      ),
      height: 400,
      child: ReorderableListView.builder(
        itemCount: sortedList.length + 1, // +1 for the divider
        onReorder: (oldIndex, newIndex) {
          // If we're dragging an unselected item or dragging into unselected zone
          if (oldIndex >= selectedCount) return; // Only reorder selected

          // Clamp newIndex to the selected zone
          if (newIndex > selectedCount) newIndex = selectedCount;
          if (newIndex == oldIndex || newIndex == oldIndex + 1) return;

          notifier.reorderColumns(oldIndex, newIndex);
        },
        itemBuilder: (context, index) {
          if (index == selectedCount) {
            return ListTile(
              key: const ValueKey('__divider__'),
              dense: true,
              tileColor: appTheme.colorScheme.surfaceVariant.withOpacity(0.3),
              title: Center(
                child: Text(
                  'AVAILABLE COLUMNS',
                  style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: appTheme.disabledColor),
                ),
              ),
            );
          }

          final displayIndex = index > selectedCount ? index - 1 : index;
          final item = sortedList[displayIndex];
          final isSelected = index < selectedCount;

          return ListTile(
            key: ValueKey(item.id),
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: isSelected ? const Icon(Icons.drag_handle, size: 16) : const SizedBox(width: 16),
            title: Text(item.label, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
            subtitle: item.isStack
                ? Text(item.subLabels.join(' + '),
                    style: GoogleFonts.jetBrainsMono(fontSize: 9, color: appTheme.disabledColor))
                : null,
            trailing: Checkbox(
              value: isSelected,
              onChanged: (v) {
                if (v == true) {
                  notifier.addColumn(item.id);
                } else {
                  notifier.removeColumn(item.id);
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _ColumnFormattingTable extends StatelessWidget {
  const _ColumnFormattingTable({required this.template, required this.notifier});
  final ReportTemplate template;
  final ReportTemplateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onSurface.withOpacity(0.55),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header row ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              const Expanded(flex: 5, child: SizedBox()),
              SizedBox(width: 32, child: Text('Sz', style: headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 26, child: Text('B', style: headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 26, child: Text('I', style: headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 72, child: Text('Align', style: headerStyle, textAlign: TextAlign.center)),
              SizedBox(width: 30, child: Text('Box', style: headerStyle, textAlign: TextAlign.center)),
            ],
          ),
        ),
        const Divider(height: 1),

        // ── Data rows ────────────────────────────────────────────────────────
        ...template.columns.map((col) => _ColumnRow(col: col, notifier: notifier, theme: theme)),
      ],
    );
  }
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({required this.col, required this.notifier, required this.theme});
  final ReportColumn col;
  final ReportTemplateNotifier notifier;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Column name
          Expanded(
            flex: 5,
            child: Text(
              col.label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Font size — PopupMenuButton, no arrow, just the number
          SizedBox(
            width: 32,
            child: _SizePopup(
              value: col.fontSize,
              onChanged: (v) => notifier.setColumnFontSize(col.id, v),
            ),
          ),

          // Bold toggle
          SizedBox(
            width: 26,
            child: InkWell(
              borderRadius: BorderRadius.circular(3),
              onTap: () => notifier.toggleColumnBold(col.id),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.format_bold,
                  size: 14,
                  color: col.isBold ? theme.colorScheme.primary : theme.disabledColor,
                ),
              ),
            ),
          ),

          // Italic toggle
          SizedBox(
            width: 26,
            child: InkWell(
              borderRadius: BorderRadius.circular(3),
              onTap: () => notifier.toggleColumnItalic(col.id),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  Icons.format_italic,
                  size: 14,
                  color: col.isItalic ? theme.colorScheme.primary : theme.disabledColor,
                ),
              ),
            ),
          ),

          // Alignment — three mini toggle buttons
          SizedBox(
            width: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _AlignBtn(icon: Icons.format_align_left,   align: 'left',   current: col.textAlign, colId: col.id, notifier: notifier),
                _AlignBtn(icon: Icons.format_align_center, align: 'center', current: col.textAlign, colId: col.id, notifier: notifier),
                _AlignBtn(icon: Icons.format_align_right,  align: 'right',  current: col.textAlign, colId: col.id, notifier: notifier),
              ],
            ),
          ),

          // Box toggle
          SizedBox(
            width: 30,
            child: InkWell(
              borderRadius: BorderRadius.circular(3),
              onTap: () => notifier.toggleColumnBoxed(col.id),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Icon(
                  col.isBoxed ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                  size: 14,
                  color: col.isBoxed ? theme.colorScheme.primary : theme.disabledColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact font-size picker: just the number, tap to open a popup menu.
class _SizePopup extends StatelessWidget {
  const _SizePopup({required this.value, required this.onChanged});
  final double value;
  final ValueChanged<double> onChanged;

  static const _sizes = [7.0, 7.5, 8.0, 8.5, 9.0, 9.5, 10.0, 10.5, 11.0, 12.0];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<double>(
      initialValue: value,
      onSelected: onChanged,
      tooltip: '',
      padding: EdgeInsets.zero,
      itemBuilder: (_) => _sizes
          .map((s) => PopupMenuItem<double>(
                value: s,
                height: 28,
                child: Text(
                  s == s.truncateToDouble() ? s.toInt().toString() : s.toString(),
                  style: const TextStyle(fontSize: 11),
                ),
              ))
          .toList(),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(3),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Text(
          value == value.truncateToDouble() ? value.toInt().toString() : value.toString(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Single alignment icon button (active = primary color, inactive = disabled).
class _AlignBtn extends StatelessWidget {
  const _AlignBtn({
    required this.icon,
    required this.align,
    required this.current,
    required this.colId,
    required this.notifier,
  });
  final IconData icon;
  final String align;
  final String current;
  final String colId;
  final ReportTemplateNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = current == align;
    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: () => notifier.setColumnTextAlign(colId, align),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(
          icon,
          size: 14,
          color: isActive ? theme.colorScheme.primary : theme.disabledColor,
        ),
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
