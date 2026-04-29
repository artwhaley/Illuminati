/// A checkbox-based menu for toggling column visibility in the spreadsheet.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../column_spec.dart';

class ColumnPickerMenuEntry extends PopupMenuEntry<Never> {
  const ColumnPickerMenuEntry({
    super.key,
    required this.hidden,
    required this.onChanged,
  });

  final Set<String> hidden;
  final void Function(Set<String>) onChanged;

  @override
  double get height => (kColumns.length - 1) * 40.0;

  @override
  bool represents(Never? value) => false;

  @override
  State<ColumnPickerMenuEntry> createState() => _ColumnPickerMenuEntryState();
}

class _ColumnPickerMenuEntryState extends State<ColumnPickerMenuEntry> {
  late Set<String> _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = Set.of(widget.hidden);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final col in kColumns)
          if (!col.isAlwaysVisible)
            CheckboxListTile(
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(col.label,
                  style: GoogleFonts.jetBrainsMono(fontSize: 13)),
              value: !_hidden.contains(col.id),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _hidden.remove(col.id);
                  } else {
                    _hidden.add(col.id);
                  }
                });
                widget.onChanged(_hidden);
              },
            ),
      ],
    );
  }
}
