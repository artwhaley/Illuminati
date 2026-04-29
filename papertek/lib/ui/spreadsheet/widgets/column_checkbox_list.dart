/// A reusable checkbox list for selecting a subset of columns.
/// Used by both the column-visibility popup and the add-mode donor mask.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../column_spec.dart';

class ColumnCheckboxList extends StatefulWidget {
  const ColumnCheckboxList({
    super.key,
    required this.selected,
    required this.onChanged,
    this.columns,
  });

  /// The set of currently selected column IDs.
  final Set<String> selected;

  /// Called whenever the selection changes.
  final void Function(Set<String> selected) onChanged;

  /// Columns to show. Defaults to all non-alwaysVisible columns in [kColumns].
  final List<ColumnSpec>? columns;

  @override
  State<ColumnCheckboxList> createState() => _ColumnCheckboxListState();
}

class _ColumnCheckboxListState extends State<ColumnCheckboxList> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set.of(widget.selected);
  }

  @override
  void didUpdateWidget(ColumnCheckboxList old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) {
      _selected = Set.of(widget.selected);
    }
  }

  List<ColumnSpec> get _cols =>
      widget.columns ?? kColumns.where((c) => !c.isAlwaysVisible).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final col in _cols)
          CheckboxListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(col.label, style: GoogleFonts.jetBrainsMono(fontSize: 13)),
            value: _selected.contains(col.id),
            onChanged: (v) {
              setState(() {
                v == true ? _selected.add(col.id) : _selected.remove(col.id);
              });
              widget.onChanged(Set.of(_selected));
            },
          ),
      ],
    );
  }
}
