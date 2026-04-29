import 'package:flutter/material.dart';
import '../column_spec.dart';
import 'column_checkbox_list.dart';

class ColumnPickerMenuEntry extends PopupMenuEntry<Never> {
  const ColumnPickerMenuEntry({
    super.key,
    required this.hidden,
    required this.onChanged,
  });

  final Set<String> hidden;
  final void Function(Set<String>) onChanged;

  @override
  double get height => kColumns.where((c) => !c.isAlwaysVisible).length * 40.0;

  @override
  bool represents(Never? value) => false;

  @override
  State<ColumnPickerMenuEntry> createState() => _ColumnPickerMenuEntryState();
}

class _ColumnPickerMenuEntryState extends State<ColumnPickerMenuEntry> {
  @override
  Widget build(BuildContext context) {
    // Visibility picker uses selected = visible = NOT hidden.
    final selected = kColumns
        .where((c) => !c.isAlwaysVisible && !widget.hidden.contains(c.id))
        .map((c) => c.id)
        .toSet();

    return ColumnCheckboxList(
      selected: selected,
      onChanged: (newSelected) {
        // Convert back: hidden = all non-alwaysVisible columns NOT in newSelected.
        final newHidden = kColumns
            .where((c) => !c.isAlwaysVisible && !newSelected.contains(c.id))
            .map((c) => c.id)
            .toSet();
        widget.onChanged(newHidden);
      },
    );
  }
}
