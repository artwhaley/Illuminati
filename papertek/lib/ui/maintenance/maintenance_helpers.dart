// -- maintenance_helpers.dart --------------------------------------------------
//
// Shared data types, color constants, and pure helper functions for the
// Maintenance tab.
//
// Nothing in this file has a Flutter widget dependency  it is safe to import
// from any widget file in the maintenance/ folder.
//
// Public surface:
//   kMaintenanceFixtureCols  the ColumnSpec list for review cards
//   formatMaintenanceTs()     ISO timestamp ? readable string
//   buildHistoryRows()        builds the list of history rows for a card
//   buildInitialStagingValues()  builds the initial staging row value map
//   HistoryRow                data class for one history grid row
//   (color constants)        all kBg*, kFg*, kStaging* constants

import 'package:flutter/material.dart';

import '../../repositories/fixture_repository.dart';
import '../../repositories/revision_repository.dart';
import '../spreadsheet/column_spec.dart';

// Columns shown on fixture review cards in the Maintenance tab.
// This is an intentionally reduced view  not every spreadsheet column
// belongs on a maintenance card.
final List<ColumnSpec> kMaintenanceFixtureCols = [
  kColumnById['chan']!,
  kColumnById['dimmer']!,
  kColumnById['position']!,
  kColumnById['unit']!,
  kColumnById['instrument']!,
  kColumnById['purpose']!,
  kColumnById['area']!,
];

// -- Color palette -------------------------------------------------------------

const kBgBaseline = Color(0x14546E7A);
const kBgPurple = Color(0x28CE93D8);
const kBgCyan = Color(0x2200BCD4);
const kFgBaseline = Color(0xFF78909C);
const kFgPurple = Color(0xFFCE93D8);
const kFgCyan = Color(0xFF80DEEA);
const kFgChanged = Color(0xFFFFFFFF);

// staging row colors by decision state
const kStagingBgNone = Color(0x10B0BEC5);
const kStagingBgApprove = Color(0x1E81C784);
const kStagingBgReject = Color(0x1EEF9A9A);
const kStagingFgNone = Color(0xFFB0BEC5);
const kStagingFgApprove = Color(0xFF81C784);
const kStagingFgReject = Color(0xFFEF9A9A);
const kStagingBarNone = Color(0xFF546E7A);
const kStagingBarApprove = Color(0xFF66BB6A);
const kStagingBarReject = Color(0xFFEF5350);

// -- History row data --------------------------------------------------------

class HistoryRow {
  const HistoryRow({
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

String? _getFixtureVal(FixtureRow f, String colKey) =>
    kColumnById[colKey]?.getValue(f);

String formatMaintenanceTs(String ts) {
  try {
    final dt = DateTime.parse(ts).toLocal();
    final mm = dt.month.toString().padLeft(2, '0');
    final dd = dt.day.toString().padLeft(2, '0');
    final yy = (dt.year % 100).toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$mm-$dd-$yy  $hh:$min';
  } catch (_) {
    return ts;
  }
}

/// Builds history rows for a tabular card: grey baseline at top, then revision
/// rows oldest?newest.  The staging row (editable, at the bottom) is separate.
List<HistoryRow> buildHistoryRows(
    FixtureRow f, List<RevisionView> revs, List<ColumnSpec> cols) {
  final sorted = List<RevisionView>.from(revs)
    ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  // Baseline: oldValue of each col's earliest revision; current value otherwise.
  final baseline = <String, String?>{
    for (final col in cols) col.id: _getFixtureVal(f, col.id)
  };
  final earliestByCol = <String, RevisionView>{};
  for (final rev in sorted) {
    final col = kColumnByDbField[rev.fieldName ?? '']?.id;
    if (col != null) {
      earliestByCol.putIfAbsent(col, () => rev);
    }
  }
  for (final e in earliestByCol.entries) {
    baseline[e.key] = e.value.oldValue?.toString();
  }

  // Latest revision per col drives cyan vs purple.
  final latestByCol = <String, RevisionView>{};
  for (final rev in sorted) {
    final col = kColumnByDbField[rev.fieldName ?? '']?.id;
    if (col != null) {
      latestByCol[col] = rev;
    }
  }
  final latestIds = latestByCol.values.map((r) => r.id).toSet();

  // Grey baseline at the TOP, revision rows below.
  final rows = <HistoryRow>[
    HistoryRow(
      cells: Map.of(baseline),
      bgColor: kBgBaseline,
      textColor: kFgBaseline,
    ),
  ];

  for (final rev in sorted) {
    final col = kColumnByDbField[rev.fieldName ?? '']?.id;
    final cells = Map<String, String?>.from(baseline);
    if (col != null) {
      cells[col] = rev.newValue?.toString();
    }

    final isLatest = latestIds.contains(rev.id);
    rows.add(HistoryRow(
      cells: cells,
      bgColor: isLatest ? kBgCyan : kBgPurple,
      textColor: isLatest ? kFgCyan : kFgPurple,
      attribution: '${formatMaintenanceTs(rev.timestamp)}    ${rev.userId}',
      changedCol: col,
    ));
  }

  return rows;
}

/// Returns the initial staging row values: current fixture state (which already
/// reflects all applied pending revisions).
Map<String, String?> buildInitialStagingValues(
        FixtureRow f, List<ColumnSpec> cols) =>
    {for (final col in cols) col.id: _getFixtureVal(f, col.id)};
