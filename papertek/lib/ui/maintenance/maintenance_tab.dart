import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' show Value;
import '../../providers/show_provider.dart';
import '../../repositories/revision_repository.dart';
import '../../repositories/fixture_repository.dart';
import '../../services/commit_service.dart';
import '../../database/database.dart';

// ── Column definition ─────────────────────────────────────────────────────────
//
// _ColDef is the unit of layout flexibility.  Each card receives a List<_ColDef>
// so callers can swap column sets without touching the card widget — e.g., a
// position-only card or a network-info card would just pass a different list.
// fieldNames maps revision.fieldName values to this column so the history rows
// know which cell to highlight when a revision touches a given DB column.

class _ColDef {
  const _ColDef({
    required this.key,
    required this.label,
    required this.width,
    this.fieldNames = const [],
  });

  final String key;
  final String label;
  final double width;
  final List<String> fieldNames; // revision.fieldName values that belong here
}

// Default fixture column set — extendable; swap per card type in the future.
const _kFixtureCols = <_ColDef>[
  _ColDef(key: 'chan',     label: 'CHAN',         width:  60, fieldNames: ['channel']),
  _ColDef(key: 'dimmer',  label: 'ADDRESS',      width:  80, fieldNames: ['address']),
  _ColDef(key: 'position',label: 'POSITION',     width: 130, fieldNames: ['position']),
  _ColDef(key: 'unit',    label: 'UNIT #',       width:  55, fieldNames: ['unit_number']),
  _ColDef(key: 'type',    label: 'FIXTURE TYPE', width: 130, fieldNames: ['fixture_type']),
  _ColDef(key: 'function',label: 'PURPOSE',      width: 110, fieldNames: ['function']),
  _ColDef(key: 'focus',   label: 'FOCUS AREA',   width: 110, fieldNames: ['focus']),
];

// ── Color palette ─────────────────────────────────────────────────────────────

const _bgBaseline = Color(0x14546E7A);
const _bgPurple   = Color(0x28CE93D8);
const _bgCyan     = Color(0x2200BCD4);
const _fgBaseline = Color(0xFF78909C);
const _fgPurple   = Color(0xFFCE93D8);
const _fgCyan     = Color(0xFF80DEEA);
const _fgChanged  = Color(0xFFFFFFFF);

// staging row colors by decision state
const _stagingBgNone    = Color(0x10B0BEC5);
const _stagingBgApprove = Color(0x1E81C784);
const _stagingBgReject  = Color(0x1EEF9A9A);
const _stagingFgNone    = Color(0xFFB0BEC5);
const _stagingFgApprove = Color(0xFF81C784);
const _stagingFgReject  = Color(0xFFEF9A9A);
const _stagingBarNone   = Color(0xFF546E7A);
const _stagingBarApprove= Color(0xFF66BB6A);
const _stagingBarReject = Color(0xFFEF5350);

// ── History row data ──────────────────────────────────────────────────────────

class _HistoryRow {
  const _HistoryRow({
    required this.cells,
    required this.bgColor,
    required this.textColor,
    this.attribution,
    this.changedCol,
  });

  final Map<String, String?> cells;
  final Color bgColor;
  final Color textColor;
  final String? attribution;
  final String? changedCol; // which col key was changed by this revision
}

// ── Utilities ─────────────────────────────────────────────────────────────────

Map<String, String> _buildFieldMap(List<_ColDef> cols) => {
  for (final col in cols)
    for (final field in col.fieldNames)
      field: col.key,
};

String? _getFixtureVal(FixtureRow f, String colKey) => switch (colKey) {
  'chan'     => f.channel,
  'dimmer'   => f.dimmer,
  'position' => f.position,
  'unit'     => f.unitNumber?.toString(),
  'type'     => f.fixtureType,
  'function' => f.function,
  'focus'    => f.focus,
  _          => null,
};

String _formatTs(String ts) {
  try {
    final dt  = DateTime.parse(ts).toLocal();
    final mm  = dt.month.toString().padLeft(2, '0');
    final dd  = dt.day.toString().padLeft(2, '0');
    final yy  = (dt.year % 100).toString().padLeft(2, '0');
    final hh  = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$mm-$dd-$yy  $hh:$min';
  } catch (_) {
    return ts;
  }
}

/// Builds history rows for a tabular card: grey baseline at top, then revision
/// rows oldest→newest.  The staging row (editable, at the bottom) is separate.
List<_HistoryRow> _buildHistoryRows(
    FixtureRow f, List<RevisionView> revs, List<_ColDef> cols) {
  final fieldMap = _buildFieldMap(cols);
  final sorted   = List<RevisionView>.from(revs)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  // Baseline: oldValue of each col's earliest revision; current value otherwise.
  final baseline = <String, String?>{
    for (final col in cols) col.key: _getFixtureVal(f, col.key)
  };
  final earliestByCol = <String, RevisionView>{};
  for (final rev in sorted) {
    final col = fieldMap[rev.fieldName ?? ''];
    if (col != null) { earliestByCol.putIfAbsent(col, () => rev); }
  }
  for (final e in earliestByCol.entries) {
    baseline[e.key] = e.value.oldValue?.toString();
  }

  // Latest revision per col drives cyan vs purple.
  final latestByCol = <String, RevisionView>{};
  for (final rev in sorted) {
    final col = fieldMap[rev.fieldName ?? ''];
    if (col != null) { latestByCol[col] = rev; }
  }
  final latestIds = latestByCol.values.map((r) => r.id).toSet();

  // Grey baseline at the TOP, revision rows below.
  final rows = <_HistoryRow>[
    _HistoryRow(
      cells: Map.of(baseline),
      bgColor: _bgBaseline,
      textColor: _fgBaseline,
    ),
  ];

  for (final rev in sorted) {
    final col   = fieldMap[rev.fieldName ?? ''];
    final cells = Map<String, String?>.from(baseline);
    if (col != null) { cells[col] = rev.newValue?.toString(); }

    final isLatest = latestIds.contains(rev.id);
    rows.add(_HistoryRow(
      cells: cells,
      bgColor:    isLatest ? _bgCyan   : _bgPurple,
      textColor:  isLatest ? _fgCyan   : _fgPurple,
      attribution: '${_formatTs(rev.timestamp)}    ${rev.userId}',
      changedCol: col,
    ));
  }

  return rows;
}

/// Returns the initial staging row values: current fixture state (which already
/// reflects all applied pending revisions).
Map<String, String?> _initialStagingValues(FixtureRow f, List<_ColDef> cols) =>
    { for (final col in cols) col.key: _getFixtureVal(f, col.key) };

// ── Tab shell ─────────────────────────────────────────────────────────────────

class MaintenanceTab extends ConsumerStatefulWidget {
  const MaintenanceTab({super.key});

  @override
  ConsumerState<MaintenanceTab> createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends ConsumerState<MaintenanceTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            tabs: const [Tab(text: 'Edit Review'), Tab(text: 'Flagged / Issues')],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              const EditReviewTab(),
              const Center(child: Text('Maintenance Log / Issues (Coming Soon)')),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Edit review tab ───────────────────────────────────────────────────────────

class EditReviewTab extends ConsumerStatefulWidget {
  const EditReviewTab({super.key});

  @override
  ConsumerState<EditReviewTab> createState() => _EditReviewTabState();
}

class _EditReviewTabState extends ConsumerState<EditReviewTab> {
  final Map<int, ReviewDecision> _decisions = {};
  bool _committing = false;

  void _setCardDecision(List<RevisionView> revisions, ReviewDecision decision) {
    setState(() {
      final allSame = revisions.every((r) => _decisions[r.id] == decision);
      if (allSame) {
        for (final r in revisions) { _decisions.remove(r.id); }
      } else {
        for (final r in revisions) { _decisions[r.id] = decision; }
      }
    });
  }

  ReviewDecision? _cardDecision(List<RevisionView> revisions) {
    if (revisions.isEmpty) return null;
    final first = _decisions[revisions.first.id];
    return revisions.every((r) => _decisions[r.id] == first) ? first : null;
  }

  @override
  Widget build(BuildContext context) {
    final groupedAsync  = ref.watch(pendingGroupedRevisionsProvider);
    final fixturesAsync = ref.watch(fixtureRowsProvider);

    return groupedAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return const Center(child: Text('No pending revisions to review.'));
        }

        final fixtures   = fixturesAsync.valueOrNull ?? [];
        final fixtureMap = {for (final f in fixtures) f.id: f};

        final sortedKeys = groups.keys.toList()
          ..sort((a, b) {
            if (a == null) return 1;
            if (b == null) return -1;
            return a.compareTo(b);
          });

        final allRevIds     = groups.values.expand((l) => l).map((r) => r.id).toList();
        final decisionCount = _decisions.length;

        return Column(
          children: [
            _buildHeader(allRevIds, decisionCount),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sortedKeys.length,
                itemBuilder: (ctx, idx) {
                  final fixtureId = sortedKeys[idx];
                  final revisions = groups[fixtureId]!;
                  final fixture   = fixtureId != null ? fixtureMap[fixtureId] : null;

                  return _RevisionCard(
                    key: ValueKey('card_$fixtureId'),
                    fixture:      fixture,
                    fixtureId:    fixtureId,
                    revisions:    revisions,
                    cardDecision: _cardDecision(revisions),
                    onApprove: () => _setCardDecision(revisions, ReviewDecision.approve),
                    onReject:  () => _setCardDecision(revisions, ReviewDecision.reject),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => Center(child: Text('Error loading revisions: $e')),
    );
  }

  Widget _buildHeader(List<int> allRevIds, int decisionCount) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text('${allRevIds.length} Pending Revisions',
              style: theme.textTheme.titleMedium),
          const Spacer(),
          if (decisionCount > 0) ...[
            Text('$decisionCount decided',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
          ],
          TextButton(
            onPressed: () => setState(() {
              for (final id in allRevIds) { _decisions[id] = ReviewDecision.approve; }
            }),
            child: const Text('Approve All'),
          ),
          const SizedBox(width: 4),
          TextButton(
            onPressed: () => setState(() {
              for (final id in allRevIds) { _decisions[id] = ReviewDecision.reject; }
            }),
            child: const Text('Reject All'),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: decisionCount == 0 || _committing ? null : _handleCommit,
            icon: _committing
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Commit Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCommit() async {
    final service = ref.read(commitServiceProvider);
    if (service == null) return;
    setState(() => _committing = true);
    try {
      await service.commitBatch(decisions: _decisions);
      setState(() { _decisions.clear(); _committing = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Changes committed.')));
      }
    } catch (e) {
      setState(() => _committing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Commit failed: $e')));
      }
    }
  }
}

// ── Revision card ─────────────────────────────────────────────────────────────
//
// Accepts a List<_ColDef> so layouts can be changed per-card type without
// modifying this widget.  Non-fixture revisions (fixtureId == null or fixture
// not found) fall back to a field-by-field diff list rather than the tabular
// grid, since we have no known column structure for arbitrary tables.

class _RevisionCard extends ConsumerWidget {
  const _RevisionCard({
    super.key,
    required this.fixture,
    required this.fixtureId,
    required this.revisions,
    required this.cardDecision,
    required this.onApprove,
    required this.onReject,
    this.columns = _kFixtureCols,
  });

  final FixtureRow? fixture;
  final int? fixtureId;
  final List<RevisionView> revisions;
  final ReviewDecision? cardDecision;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final List<_ColDef> columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme      = Theme.of(context);
    final isApproved = cardDecision == ReviewDecision.approve;
    final isRejected = cardDecision == ReviewDecision.reject;
    final f          = fixture;

    final label = f != null
        ? 'Ch ${f.channel ?? "—"}  ·  ${f.position ?? "No Position"}  ·  U#${f.unitNumber ?? "?"}  ·  ${f.fixtureType ?? "No Type"}'
        : fixtureId == null
            ? 'Global / Other'
            : 'Fixture #$fixtureId (Deleted)';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isApproved
              ? Colors.green.withValues(alpha: 0.5)
              : isRejected
                  ? Colors.red.withValues(alpha: 0.5)
                  : theme.dividerColor.withValues(alpha: 0.15),
          width: isApproved || isRejected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── header ──────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              children: [
                Text(label,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                const Spacer(),
                _ActionButton(
                  label: 'REJECT',
                  color: Colors.red,
                  isActive: isRejected,
                  onPressed: onReject,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'APPROVE',
                  color: Colors.green,
                  isActive: isApproved,
                  icon: Icons.chevron_right,
                  onPressed: onApprove,
                ),
              ],
            ),
          ),

          // ── body: tabular (fixture) or generic (other) ───────────────────
          if (f != null)
            _TabularCardBody(
              fixture:      f,
              revisions:    revisions,
              columns:      columns,
              cardDecision: cardDecision,
            )
          else
            _GenericCardBody(revisions: revisions),
        ],
      ),
    );
  }
}

// ── Tabular body (fixture revisions) ─────────────────────────────────────────

class _TabularCardBody extends ConsumerWidget {
  const _TabularCardBody({
    super.key,
    required this.fixture,
    required this.revisions,
    required this.columns,
    required this.cardDecision,
  });

  final FixtureRow fixture;
  final List<RevisionView> revisions;
  final List<_ColDef> columns;
  final ReviewDecision? cardDecision;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyRows = _buildHistoryRows(fixture, revisions, columns);
    final stagingInit = _initialStagingValues(fixture, columns);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // column headers
            _HeaderRow(columns: columns),
            // grey baseline + revision rows (top → bottom, oldest → newest)
            for (final row in historyRows) _ReadOnlyRow(row: row, columns: columns),
            // editable staging row at the bottom
            _StagingRow(
              key: ValueKey('staging_${fixture.id}'),
              columns:       columns,
              initialValues: stagingInit,
              decision:      cardDecision,
              revisions:     revisions,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Column headers ────────────────────────────────────────────────────────────

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.columns});
  final List<_ColDef> columns;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final col in columns)
          SizedBox(
            width: col.width,
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

// ── Read-only history row ─────────────────────────────────────────────────────

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({super.key, required this.row, required this.columns});
  final _HistoryRow row;
  final List<_ColDef> columns;

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

  Widget _cell(_ColDef col) {
    final isChanged  = row.changedCol == col.key;
    final textColor  = isChanged ? _fgChanged : row.textColor;
    final value      = row.cells[col.key];
    final display    = (value == null || value.isEmpty) ? '—' : value;

    return SizedBox(
      width: col.width,
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

// ── Editable staging row ──────────────────────────────────────────────────────
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

  final List<_ColDef> columns;
  final Map<String, String?> initialValues;
  final ReviewDecision? decision;
  final List<RevisionView> revisions;

  @override
  ConsumerState<_StagingRow> createState() => _StagingRowState();
}

class _StagingRowState extends ConsumerState<_StagingRow> {
  String? _editingCol;
  final Map<String, TextEditingController> _ctrls    = {};
  final Map<String, FocusNode>             _focusNodes = {};

  @override
  void initState() {
    super.initState();
    for (final col in widget.columns) {
      _ctrls[col.key]     = TextEditingController(
          text: widget.initialValues[col.key] ?? '');
      final fn = FocusNode();
      fn.addListener(() {
        if (!fn.hasFocus && _editingCol == col.key) { _commit(col.key); }
      });
      _focusNodes[col.key] = fn;
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values)     { c.dispose(); }
    for (final f in _focusNodes.values) { f.dispose(); }
    super.dispose();
  }

  void _activate(String colKey) {
    setState(() => _editingCol = colKey);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[colKey]?.requestFocus();
      final ctrl = _ctrls[colKey];
      if (ctrl != null) {
        ctrl.selection = TextSelection(
            baseOffset: 0, extentOffset: ctrl.text.length);
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
    final db          = ref.read(databaseProvider);
    final fixtureRepo = ref.read(fixtureRepoProvider);
    if (db == null) return;

    // If a pending revision already covers this column, update its newValue
    // in-place rather than creating an additional revision row.
    final fieldMap     = _buildFieldMap(widget.columns);
    final pendingMatch = widget.revisions
        .where((r) => fieldMap[r.fieldName ?? ''] == colKey)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (pendingMatch.isNotEmpty) {
      await (db.update(db.revisions)
            ..where((r) => r.id.equals(pendingMatch.last.id)))
          .write(RevisionsCompanion(newValue: Value(jsonEncode(newValue))));
      return;
    }

    // No existing revision for this col — create one via the fixture repo so it
    // enters the normal revision/approval flow.
    // NOTE: this block is fixture-specific; non-fixture card types should pass
    // a custom save handler instead of relying on this switch.
    if (fixtureRepo == null) return;
    final fid = widget.revisions.firstOrNull?.targetId;
    if (fid == null) return;

    switch (colKey) {
      case 'chan':     await fixtureRepo.updateIntensityChannel(fid, newValue);
      case 'dimmer':  await fixtureRepo.updatePartAddress(fid, 0, newValue);
      case 'position':await fixtureRepo.updatePosition(fid, newValue);
      case 'unit':    await fixtureRepo.updateUnitNumber(
                            fid, int.tryParse(newValue ?? ''));
      case 'type':    await fixtureRepo.updateFixtureType(fid, newValue);
      case 'function':await fixtureRepo.updateFunction(fid, newValue);
      case 'focus':   await fixtureRepo.updateFocus(fid, newValue);
    }
  }

  // ── Visual helpers ────────────────────────────────────────────────────────

  Color get _bg => switch (widget.decision) {
    ReviewDecision.approve => _stagingBgApprove,
    ReviewDecision.reject  => _stagingBgReject,
    _                      => _stagingBgNone,
  };

  Color get _fg => switch (widget.decision) {
    ReviewDecision.approve => _stagingFgApprove,
    ReviewDecision.reject  => _stagingFgReject,
    _                      => _stagingFgNone,
  };

  Color get _bar => switch (widget.decision) {
    ReviewDecision.approve => _stagingBarApprove,
    ReviewDecision.reject  => _stagingBarReject,
    _                      => _stagingBarNone,
  };

  // ── Build ─────────────────────────────────────────────────────────────────

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

  Widget _buildCell(_ColDef col) {
    final isEditing = _editingCol == col.key;
    final fg        = _fg;
    final bar       = _bar;

    return SizedBox(
      width: col.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: GestureDetector(
          onDoubleTap: () => _activate(col.key),
          child: isEditing ? _editField(col, fg, bar) : _labelField(col, fg, bar),
        ),
      ),
    );
  }

  Widget _labelField(_ColDef col, Color fg, Color bar) {
    final text = _ctrls[col.key]?.text ?? '';
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
        isEmpty ? '—' : text,
        style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            color: isEmpty ? fg.withValues(alpha: 0.35) : fg,
            fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _editField(_ColDef col, Color fg, Color bar) {
    return SizedBox(
      height: 28,
      child: TextField(
        controller: _ctrls[col.key],
        focusNode:  _focusNodes[col.key],
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
        onSubmitted: (_) => _commit(col.key),
      ),
    );
  }
}

// ── Generic card body (non-fixture revisions) ─────────────────────────────────
//
// For revisions that aren't tied to a fixture row (show_meta, global edits, etc.)
// we can't use a fixed column grid — render a plain field-by-field diff list.

class _GenericCardBody extends StatelessWidget {
  const _GenericCardBody({super.key, required this.revisions});
  final List<RevisionView> revisions;

  @override
  Widget build(BuildContext context) {
    final sorted = List<RevisionView>.from(revisions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rev in sorted) _RevisionDiffRow(revision: rev),
        ],
      ),
    );
  }
}

class _RevisionDiffRow extends StatelessWidget {
  const _RevisionDiffRow({super.key, required this.revision});
  final RevisionView revision;

  @override
  Widget build(BuildContext context) {
    final fieldLabel = revision.fieldName ?? revision.operation;
    final oldVal     = revision.oldValue?.toString();
    final newVal     = revision.newValue?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fieldLabel,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF78909C))),
          const SizedBox(height: 2),
          Row(
            children: [
              _ValueChip(label: oldVal ?? '—', fg: _fgPurple, bg: _bgPurple),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
              ),
              _ValueChip(label: newVal ?? '—', fg: _fgCyan,   bg: _bgCyan),
              const SizedBox(width: 12),
              Text('${_formatTs(revision.timestamp)}  ${revision.userId}',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 10, color: const Color(0xFF546E7A))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.fg, required this.bg});
  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(3)),
      child: Text(label,
          style: GoogleFonts.jetBrainsMono(
              fontSize: 11, color: fg, fontWeight: FontWeight.bold)),
    );
  }
}

// ── APPROVE / REJECT toggle button ────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.icon,
  });

  final String     label;
  final Color      color;
  final bool       isActive;
  final VoidCallback onPressed;
  final IconData?  icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
              color: isActive ? color : color.withValues(alpha: 0.35), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : color.withValues(alpha: 0.6),
                    letterSpacing: 0.5)),
            if (icon != null) ...[
              const SizedBox(width: 2),
              Icon(icon, size: 14,
                  color: isActive ? color : color.withValues(alpha: 0.6)),
            ],
          ],
        ),
      ),
    );
  }
}
