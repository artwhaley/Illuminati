import 'csv_field_definitions.dart';

/// Contract for mapping CSV/spreadsheet headers to PaperTek fields.
///
/// Implement this interface to support a new source format — Vectorworks,
/// ETC Eos, custom spreadsheets, etc. — without touching [CsvImportParser]
/// or [ImportService].
abstract class ColumnDetector {
  /// Given the list of raw header strings from row 1 of the file, return a
  /// map from PaperTek field → 0-based column index.
  ///
  /// Fields with no confident match are omitted; the mapping UI fills gaps
  /// interactively before the import runs.
  Map<PaperTekImportField, int> detectColumns(List<String> headers);
}

/// Detects column positions for standard Lightwright hookup CSV exports.
///
/// Matching is case-insensitive and trims surrounding whitespace.
/// Variants are listed explicitly so the match set is easy to audit and
/// extend — add new strings to [_knownNames] as real-world exports surface
/// unexpected column names.
///
/// Coverage: Lightwright 5, Lightwright 6 default exports.
/// Unknown columns are silently ignored; the user can map them manually.
class LightwrightColumnDetector implements ColumnDetector {
  const LightwrightColumnDetector();

  // Each entry lists known header strings for that field, most-common first.
  // First match wins, so put the most canonical name at the top.
  static const Map<PaperTekImportField, List<String>> _knownNames = {
    PaperTekImportField.channel: [
      'chan', 'channel', 'ch', 'chan#', 'channel#', 'ch#',
    ],
    PaperTekImportField.dimmer: [
      'dimmer', 'dim', 'dmr', 'dimmable', 'dimmer#', 'dim#',
    ],
    PaperTekImportField.circuit: [
      'circuit', 'circ', 'ckt', 'circuit name', 'circ#', 'circuit#', 'circuit no',
    ],
    PaperTekImportField.position: [
      'position', 'pos', 'hanging position', 'location', 'truss', 'pipe', 'bar',
    ],
    PaperTekImportField.unitNumber: [
      'unit#', 'unit', 'unit num', 'unit number', 'unit no', '#', 'no', 'no.',
    ],
    PaperTekImportField.fixtureType: [
      'type', 'fixture type', 'inst type', 'instrument type',
      'instrument', 'fixture', 'unit type', 'ltype',
    ],
    PaperTekImportField.wattage: [
      'wattage', 'watts', 'watt', 'lamp', 'lamp type', 'w',
    ],
    PaperTekImportField.color: [
      'color', 'colour', 'clr', 'gel', 'filter', 'color/gel', 'colour/gel',
    ],
    PaperTekImportField.gobo1: [
      'gobo', 'gobo1', 'gobo 1', 'gobo#1', 'g1', 'pattern', 'pattern1', 'pattern 1',
    ],
    PaperTekImportField.gobo2: [
      'gobo2', 'gobo 2', 'gobo#2', 'g2', 'pattern2', 'pattern 2',
    ],
    PaperTekImportField.function: [
      'function', 'purpose', 'use', 'use/function', 'func',
    ],
    PaperTekImportField.focus: [
      'focus', 'foc', 'focus point', 'focus area', 'area',
    ],
    PaperTekImportField.notes: [
      'notes', 'note', 'memo', 'comments', 'comment', 'remarks',
    ],
  };

  @override
  Map<PaperTekImportField, int> detectColumns(List<String> headers) {
    final result = <PaperTekImportField, int>{};
    // Normalise once so the per-candidate loop is cheap.
    final normalized = headers.map((h) => h.trim().toLowerCase()).toList();

    for (final entry in _knownNames.entries) {
      for (final candidate in entry.value) {
        final idx = normalized.indexOf(candidate);
        if (idx != -1) {
          result[entry.key] = idx;
          break; // first match wins; remaining variants skipped
        }
      }
    }
    return result;
  }
}
