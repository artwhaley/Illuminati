import 'dart:io';
import 'dart:convert';
import 'row_reader.dart';

class DelimitedRowReader implements RowReader {
  const DelimitedRowReader();

  String _detectDelimiter(String firstLine) {
    final tab = '\t'.allMatches(firstLine).length;
    final comma = ','.allMatches(firstLine).length;
    final semicolon = ';'.allMatches(firstLine).length;
    final pipe = '|'.allMatches(firstLine).length;

    if (tab == 0 && comma == 0 && semicolon == 0 && pipe == 0) {
      throw const FormatException('Could not detect delimiter in file header');
    }

    // Tie-break: tab > comma > semicolon > pipe
    if (tab >= comma && tab >= semicolon && tab >= pipe) return '\t';
    if (comma >= semicolon && comma >= pipe) return ',';
    if (semicolon >= pipe) return ';';
    return '|';
  }

  Future<String> _readFileContent(String path) async {
    try {
      return await File(path).readAsString(encoding: utf8);
    } catch (e) {
      throw FormatException('Failed to read file as UTF-8: $e');
    }
  }

  List<String> _splitLines(String content) {
    final normalized = content.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    return normalized
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  @override
  Future<List<String>> readHeaders(String path) async {
    final content = await _readFileContent(path);
    final lines = _splitLines(content);
    if (lines.isEmpty) {
      throw const FormatException('File is empty');
    }
    final delimiter = _detectDelimiter(lines[0]);
    return lines[0].split(delimiter).map((h) => h.trim()).toList();
  }

  @override
  Future<List<Map<String, String>>> readRows(String path) async {
    final content = await _readFileContent(path);
    final lines = _splitLines(content);
    if (lines.length < 2) return [];

    final delimiter = _detectDelimiter(lines[0]);
    final headers = lines[0].split(delimiter).map((h) => h.trim()).toList();
    final result = <Map<String, String>>[];

    for (var i = 1; i < lines.length; i++) {
      final cells = lines[i].split(delimiter);
      final row = <String, String>{};

      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = j < cells.length ? cells[j].trim() : '';
      }

      // Skip blank/placeholder rows
      if (row.values.every((v) => v.isEmpty || v == '-')) continue;

      result.add(row);
    }

    return result;
  }
}
