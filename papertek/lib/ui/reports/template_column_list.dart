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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.drag_handle, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(column.label, style: GoogleFonts.jetBrainsMono(
                    fontSize: 11, 
                    fontWeight: FontWeight.w500,
                  )),
                  if (column.fieldKeys.length > 1)
                    Text(
                      column.fieldKeys.join(' + '),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9, 
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
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
              constraints: const BoxConstraints(minWidth: 32, minHeight: 24),
              borderRadius: BorderRadius.circular(4),
              children: const [
                Text('px', style: TextStyle(fontSize: 9)),
                Text('flx', style: TextStyle(fontSize: 9)),
              ],
            ),
            const SizedBox(width: 6),
            // Width/flex value
            SizedBox(
              width: 44,
              child: isFixed
                ? TextFormField(
                    initialValue: column.fixedWidth?.toInt().toString() ?? '80',
                    decoration: const InputDecoration(
                      isDense: true, 
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      border: OutlineInputBorder(),
                    ),
                    style: GoogleFonts.jetBrainsMono(fontSize: 10),
                    keyboardType: TextInputType.number,
                    onFieldSubmitted: (v) {
                      final w = double.tryParse(v);
                      if (w != null && w > 0) onWidthChanged(w);
                    },
                  )
                : DropdownButtonFormField<int>(
                    value: column.flex.clamp(1, 10),
                    decoration: const InputDecoration(
                      isDense: true, 
                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    items: [1, 2, 3, 4, 5].map((i) => 
                      DropdownMenuItem(value: i, child: Text('$i', style: const TextStyle(fontSize: 10)))
                    ).toList(),
                    onChanged: (v) { if (v != null) onFlexChanged(v); },
                  ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.close, size: 14),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              splashRadius: 16,
            ),
          ],
        ),
      ),
    );
  }
}
