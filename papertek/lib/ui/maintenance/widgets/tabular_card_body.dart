// -- tabular_card_body.dart ----------------------------------------------------
//
// The tabular history grid used by fixture revision cards in the Edit Review tab.
//
// Layout (top to bottom):
//   _HeaderRow           � column labels
//   _ReadOnlyRow � N     � grey baseline + purple/cyan revision rows
//   _StagingRow          � editable bottom row; colors reflect approve/reject state
//
// _StagingRow saves edits either by updating an existing revision's newValue
// in-place (Drift direct write) or by creating a new revision via ColumnSpec.onEdit.

import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../database/database.dart';
import '../../../providers/show_provider.dart';
import '../../../repositories/fixture_repository.dart';
import '../../../repositories/revision_repository.dart';
import '../../../services/commit_service.dart';
import '../../../ui/spreadsheet/column_spec.dart';
import '../maintenance_helpers.dart';

class TabularCardBody extends ConsumerWidget {
  const TabularCardBody({
    required this.fixture,
    required this.revisions,
    required this.columns,
    required this.cardDecision,
  });

  final FixtureRow fixture;
  final List<RevisionView> revisions;
  final List<ColumnSpec> columns;
  final ReviewDecision? cardDecision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyRows = buildHistoryRows(fixture, revisions, columns);
    final stagingInit = buildInitialStagingValues(fixture, columns);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // column headers
            _HeaderRow(columns: columns),
            // grey baseline + revision rows (top ? bottom, oldest ? newest)
            for (final row in historyRows) _ReadOnlyRow(row: row, columns: columns),
            // editable staging row at the bottom
            _StagingRow(
              key: ValueKey('staging_${fixture.id}'),
              columns: columns,
              initialValues: stagingInit,
              decision: cardDecision,
              revisions: revisions,
            ),
          ],
        ),
      ),
    );
  }
}

// -- Column headers ------------------------------------------------------------

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.columns});
  final List<ColumnSpec> columns;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final col in columns)
          SizedBox(
            width: col.defaultWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(col.label,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF546E7A),
                      letterSpacing: 0.5)),
            ),
          ),
      ],
    );
  }
}

// -- Read-only history row -----------------------------------------------------

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.row, required this.columns});
  final HistoryRow row;
  final List<ColumnSpec> columns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: row.bgColor,
        border: Border(bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.06))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final col in columns) _cell(col),
            ],
          ),
          if (row.attribution != null)
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 3),
              child: Text(row.attribution!,
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: row.textColor.withValues(alpha: 0.7),
                      letterSpacing: 0.3)),
            ),
        ],
      ),
    );
  }

  Widget _cell(ColumnSpec col) {
    final isChanged = row.changedCol == col.id;
    final textColor = isChanged ? kFgChanged : row.textColor;
    final value = row.cells[col.id];
    final display = (value == null || value.isEmpty) ? '�' : value;

    return SizedBox(
      width: col.defaultWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Text(display,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 12,
                color: textColor,
                fontWeight: isChanged ? FontWeight.bold : FontWeight.normal),
            overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

// -- Editable staging row ------------------------------------------------------
//
// All cells show text with an underline to signal editability.
// Double-click on any cell activates an inline TextField for that cell.
// On blur or Enter the value is saved (updates existing revision.newValue
// if a pending revision exists for that column, otherwise calls the fixture
// repo to create a new tracked edit).
// Background and text color animate based on the card's approve/reject state.

class _StagingRow extends ConsumerStatefulWidget {
  const _StagingRow({
    super.key,
    required this.columns,
    required this.initialValues,
    required this.decision,
    required this.revisions,
  });

  final List<ColumnSpec> columns;
  final Map<String, String?> initialValues;
  final ReviewDecision? decision;
  final List<RevisionView> revisions;

  @override
  ConsumerState<_StagingRow> createState() => _StagingRowState();
}

class _StagingRowState extends ConsumerState<_StagingRow> {
  String? _editingCol;
  final Map<String, TextEditingController> _ctrls = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    for (final col in widget.columns) {
      _ctrls[col.id] = TextEditingController(text: widget.initialValues[col.id] ?? '');
      final fn = FocusNode();
      fn.addListener(() {
        if (!fn.hasFocus && _editingCol == col.id) {
          _commit(col.id);
        }
      });
      _focusNodes[col.id] = fn;
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    for (final f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _activate(String colKey) {
    setState(() => _editingCol = colKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[colKey]?.requestFocus();
      final ctrl = _ctrls[colKey];
      if (ctrl != null) {
        ctrl.selection = TextSelection(baseOffset: 0, extentOffset: ctrl.text.length);
      }
    });
  }

  void _commit(String colKey) {
    if (_editingCol != colKey) return;
    final val = _ctrls[colKey]?.text;
    final newVal = (val == null || val.isEmpty) ? null : val;
    setState(() => _editingCol = null);
    _save(colKey, newVal);
  }

  Future<void> _save(String colKey, String? newValue) async {
    final db = ref.read(databaseProvider);
    final fixtureRepo = ref.read(fixtureRepoProvider);
    if (db == null) return;

    // If a pending revision already covers this column, update its newValue
    // in-place rather than creating an additional revision row.
    final pendingMatch = widget.revisions
        .where((r) => kColumnByDbField[r.fieldName ?? '']?.id == colKey)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (pendingMatch.isNotEmpty) {
      await (db.update(db.revisions)
            ..where((r) => r.id.equals(pendingMatch.last.id)))
          .write(RevisionsCompanion(newValue: Value(jsonEncode(newValue))));
      return;
    }

    // No existing revision for this col � create one via the fixture repo so it
    // enters the normal revision/approval flow.
    if (fixtureRepo == null) return;
    final fid = widget.revisions.firstOrNull?.targetId;
    if (fid == null) return;

    final spec = kColumnById[colKey];
    if (spec?.onEdit != null) {
      await spec!.onEdit!(fid, newValue, fixtureRepo);
    }
  }

  // -- Visual helpers --------------------------------------------------------

  Color get _bg => switch (widget.decision) {
        ReviewDecision.approve => kStagingBgApprove,
        ReviewDecision.reject => kStagingBgReject,
        _ => kStagingBgNone,
      };

  Color get _fg => switch (widget.decision) {
        ReviewDecision.approve => kStagingFgApprove,
        ReviewDecision.reject => kStagingFgReject,
        _ => kStagingFgNone,
      };

  Color get _bar => switch (widget.decision) {
        ReviewDecision.approve => kStagingBarApprove,
        ReviewDecision.reject => kStagingBarReject,
        _ => kStagingBarNone,
      };

  // -- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(left: BorderSide(color: _bar, width: 3)),
      ),
      child: Row(
        children: [
          for (final col in widget.columns) _buildCell(col),
        ],
      ),
    );
  }

  Widget _buildCell(ColumnSpec col) {
    final isEditing = _editingCol == col.id;
    final fg = _fg;
    final bar = _bar;

    return SizedBox(
      width: col.defaultWidth,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: GestureDetector(
          onDoubleTap: () => _activate(col.id),
          child: isEditing ? _editField(col, fg, bar) : _labelField(col, fg, bar),
        ),
      ),
    );
  }

  Widget _labelField(ColumnSpec col, Color fg, Color bar) {
    final text = _ctrls[col.id]?.text ?? '';
    final isEmpty = text.isEmpty;
    return Container(
      height: 28,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: bar.withValues(alpha: 0.4), width: 1),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Text(
        isEmpty ? '�' : text,
        style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: isEmpty ? fg.withValues(alpha: 0.35) : fg,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _editField(ColumnSpec col, Color fg, Color bar) {
    return SizedBox(
      height: 28,
      child: TextField(
        controller: _ctrls[col.id],
        focusNode: _focusNodes[col.id],
        style: GoogleFonts.jetBrainsMono(fontSize: 12, color: fg),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.only(bottom: 2),
          border: InputBorder.none,
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: bar.withValues(alpha: 0.5))),
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: bar, width: 1.5)),
          filled: false,
        ),
        onSubmitted: (_) => _commit(col.id),
      ),
    );
  }
}
