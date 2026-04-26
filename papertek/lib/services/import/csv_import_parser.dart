import 'dart:io';
import 'package:csv/csv.dart';
import 'csv_field_definitions.dart';

/// One CSV data row normalised into PaperTek field values.
class NormalizedRow {
  const NormalizedRow({
    required this.fields,
    required this.csvRowIndex,
    this.warnings = const [],
  });

  /// Values keyed by PaperTek field.
  /// null means the field was empty or the column was not mapped.
  final Map<PaperTekImportField, String?> fields;

  /// 1-based row number in the source file (row 1 = header).
  final int csvRowIndex;

  /// Non-fatal warnings generated while parsing this specific row.
  final List<String> warnings;

  String? get(PaperTekImportField field) => fields[field];
}

/// Reads a CSV file and converts rows using a caller-supplied column mapping.
///
/// Intentionally knows nothing about PaperTek's database schema.
/// [ImportService] is responsible for converting [NormalizedRow]s to records.
///
/// Typical usage:
/// ```dart
/// final parser = CsvImportParser();
/// final headers = await parser.readHeaders(path);
/// // … show mapping UI …
/// final (rows, warnings) = await parser.parseRows(path, confirmedMapping);
/// ```
class CsvImportParser {
  const CsvImportParser();

  /// Returns only the header row (row 1) as a list of strings.
  /// Returns an empty list if the file is unreadable or empty.
  Future<List<String>> readHeaders(String filePath) async {
    final rows = await _readAllRows(filePath);
    if (rows.isEmpty) return [];
    return rows.first.map((cell) => cell.toString().trim()).toList();
  }

  /// Parses every data row (rows 2+) using [columnMapping].
  ///
  /// [columnMapping] maps each PaperTek field to a 0-based column index,
  /// or null if that field should not be imported.
  ///
  /// Returns (parsedRows, file-level warnings).
  /// Rows with no Position value are skipped with a warning.
  /// Completely empty rows are silently dropped.
  Future<(List<NormalizedRow>, List<String>)> parseRows(
    String filePath,
    Map<PaperTekImportField, int?> columnMapping,
  ) async {
    final allRows = await _readAllRows(filePath);
    if (allRows.length < 2) {
      return (<NormalizedRow>[], ['File has no data rows.']);
    }

    final dataRows = allRows.skip(1).toList();
    final results = <NormalizedRow>[];
    final fileWarnings = <String>[];

    for (var i = 0; i < dataRows.length; i++) {
      final raw = dataRows[i];
      final rowNum = i + 2; // 1-based, accounting for header

      // Silently skip blank rows.
      if (raw.every((cell) => cell.toString().trim().isEmpty)) continue;

      final rowWarnings = <String>[];
      final fields = <PaperTekImportField, String?>{};

      for (final entry in columnMapping.entries) {
        final colIdx = entry.value;
        if (colIdx == null || colIdx >= raw.length) {
          fields[entry.key] = null;
          continue;
        }
        final value = raw[colIdx].toString().trim();
        fields[entry.key] = value.isEmpty ? null : value;
      }

      // Position is required — skip the row without it.
      if (fields[PaperTekImportField.position]?.isEmpty ?? true) {
        if (fields[PaperTekImportField.position] == null) {
          fileWarnings.add('Row $rowNum: skipped — Position column is not mapped or empty.');
        } else {
          fileWarnings.add('Row $rowNum: skipped — Position value is empty.');
        }
        continue;
      }

      results.add(NormalizedRow(
        fields: fields,
        csvRowIndex: rowNum,
        warnings: rowWarnings,
      ));
    }

    return (results, fileWarnings);
  }

  Future<List<List<dynamic>>> _readAllRows(String filePath) async {
    try {
      // Use '\n' as eol so the converter handles both LF and CRLF files.
      final content = await File(filePath).readAsString();
      final normalised = content.replaceAll('\r\n', '\n');
      return const CsvToListConverter(eol: '\n').convert(normalised);
    } catch (e) {
      return [];
    }
  }
}
