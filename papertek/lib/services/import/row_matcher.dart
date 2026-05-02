import '../../../ui/spreadsheet/column_spec.dart';

class MatchSuggestion {
  final String importHeader;
  final int score; // 0–100
  final bool isExact;
  const MatchSuggestion({
    required this.importHeader,
    required this.score,
    required this.isExact,
  });
}

class RowMatcher {
  static const int _threshold = 30;

  String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

  int _score(String importHeader, List<String> aliases) {
    final h = _normalize(importHeader);
    final normalizedAliases = aliases.map(_normalize).toList();

    // Exact match
    if (normalizedAliases.contains(h)) return 100;

    // Contains match
    var containsScore = 0;
    for (final a in normalizedAliases) {
      if (h.contains(a) || a.contains(h)) {
        final candidate = 60 + (a.length * 0.4).clamp(0.0, 30.0).toInt();
        if (candidate > containsScore) containsScore = candidate;
      }
    }

    // Word overlap
    final aliasWordSet = <String>{};
    for (final a in normalizedAliases) {
      aliasWordSet.addAll(a.split(' '));
    }
    final headerWords = h.split(' ');
    final matchingWordCount =
        headerWords.where((w) => aliasWordSet.contains(w)).length;
    final overlapScore = aliasWordSet.isEmpty
        ? 0
        : ((matchingWordCount / aliasWordSet.length) * 50).toInt();

    return containsScore > overlapScore ? containsScore : overlapScore;
  }

  Map<ColumnSpec, List<MatchSuggestion>> suggest(List<String> importHeaders) {
    final result = <ColumnSpec, List<MatchSuggestion>>{};

    for (final column in kColumns) {
      if (!column.isImportable || column.importAliases == null) continue;

      final suggestions = <MatchSuggestion>[];
      for (final header in importHeaders) {
        final score = _score(header, column.importAliases!);
        if (score >= _threshold) {
          suggestions.add(MatchSuggestion(
            importHeader: header,
            score: score,
            isExact: score == 100,
          ));
        }
      }
      suggestions.sort((a, b) => b.score.compareTo(a.score));
      result[column] = suggestions;
    }

    return result;
  }

  Map<ColumnSpec, String?> greedyAssign(List<String> importHeaders) {
    final pairs = <({ColumnSpec column, String header, int score})>[];

    for (final column in kColumns) {
      if (!column.isImportable || column.importAliases == null) continue;
      for (final header in importHeaders) {
        final score = _score(header, column.importAliases!);
        if (score >= _threshold) {
          pairs.add((column: column, header: header, score: score));
        }
      }
    }

    pairs.sort((a, b) {
      final s = b.score.compareTo(a.score);
      if (s != 0) return s;
      return b.header.length.compareTo(a.header.length);
    });

    final result = <ColumnSpec, String?>{
      for (final col in kColumns)
        if (col.isImportable && col.importAliases != null) col: null,
    };

    final usedHeaders = <String>{};
    final usedColumns = <ColumnSpec>{};

    for (final pair in pairs) {
      if (usedColumns.contains(pair.column) || usedHeaders.contains(pair.header)) {
        continue;
      }
      result[pair.column] = pair.header;
      usedColumns.add(pair.column);
      usedHeaders.add(pair.header);
    }

    return result;
  }
}
