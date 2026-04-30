import 'package:flutter/material.dart';
import '../column_spec.dart';
import 'column_checkbox_list.dart';
import 'custom_field_dialog.dart';

class ColumnPickerMenuEntry extends PopupMenuEntry<Never> {
  const ColumnPickerMenuEntry({
    super.key,
    required this.columns,
    required this.hidden,
    required this.onChanged,
  });

  final List<ColumnSpec> columns;
  final Set<String> hidden;
  final void Function(Set<String>) onChanged;

  @override
  double get height => columns.where((c) => !c.isAlwaysVisible).length * 40.0;

  @override
  bool represents(Never? value) => false;

  @override
  State<ColumnPickerMenuEntry> createState() => _ColumnPickerMenuEntryState();
}

class _ColumnPickerMenuEntryState extends State<ColumnPickerMenuEntry> {
  @override
  Widget build(BuildContext context) {
    // Visibility picker uses selected = visible = NOT hidden.
    final selected = widget.columns
        .where((c) => !c.isAlwaysVisible && !widget.hidden.contains(c.id))
        .map((c) => c.id)
        .toSet();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ColumnCheckboxList(
          selected: selected,
          onChanged: (newSelected) {
            // Convert back: hidden = all non-alwaysVisible columns NOT in newSelected.
            final newHidden = widget.columns
                .where((c) => !c.isAlwaysVisible && !newSelected.contains(c.id))
                .map((c) => c.id)
                .toSet();
            widget.onChanged(newHidden);
          },
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (context) => const CustomFieldManagerDialog(),
              );
            },
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('Manage Custom Fields'),
          ),
        ),
      ],
    );
  }
}
