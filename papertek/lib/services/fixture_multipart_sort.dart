import '../repositories/fixture_repository.dart';
import '../ui/spreadsheet/column_spec.dart';

/// A lightweight descriptor for a row in the fixture grid/report.
class MultipartFixtureDescriptor {
  final FixtureRow f;
  final int? partOrder;
  
  const MultipartFixtureDescriptor({
    required this.f,
    this.partOrder,
  });
}

/// Natural comparison for strings, with numeric awareness.
int compareSortValue(String a, String b, bool ascending) {
  final res = _compareNatural(a, b);
  return ascending ? res : -res;
}

final _naturalRegExp = RegExp(r'(\d+|\D+)');

int _compareNatural(String a, String b) {
  final matchesA = _naturalRegExp.allMatches(a.toLowerCase()).toList();
  final matchesB = _naturalRegExp.allMatches(b.toLowerCase()).toList();

  for (var i = 0; i < matchesA.length && i < matchesB.length; i++) {
    final partA = matchesA[i].group(0)!;
    final partB = matchesB[i].group(0)!;

    final numA = int.tryParse(partA);
    final numB = int.tryParse(partB);

    if (numA != null && numB != null) {
      final cmp = numA.compareTo(numB);
      if (cmp != 0) return cmp;
    } else {
      final cmp = partA.compareTo(partB);
      if (cmp != 0) return cmp;
    }
  }
  return matchesA.length.compareTo(matchesB.length);
}

/// Resolves the sort value for a fixture in header mode.
/// Precedence: 
/// 1. Parent field value if present.
/// 2. First part value if present.
/// 3. Empty string.
String resolveHeaderModeSortValue(FixtureRow fixture, ColumnSpec spec) {
  final parentValue = spec.getValue(fixture);
  if (parentValue != null && parentValue.isNotEmpty) return parentValue;

  final firstPart = fixture.parts.firstOrNull;
  if (firstPart != null) {
    final partValue = spec.getPartValue?.call(fixture, firstPart);
    if (partValue != null && partValue.isNotEmpty) return partValue;
  }

  return '';
}

/// Compares two fixture descriptors for multipart header mode.
/// Ensures that each fixture remains grouped with its parts.
int compareFixtureDescriptors({
  required MultipartFixtureDescriptor left,
  required MultipartFixtureDescriptor right,
  required List<SortSpec> sortSpecs,
  required Map<String, ColumnSpec> colById,
}) {
  // If they are different fixtures, compare them by the sort columns using their header-mode keys
  if (left.f.id != right.f.id) {
    for (final sortSpec in sortSpecs) {
      final spec = colById[sortSpec.column];
      if (spec == null) continue;

      final valA = resolveHeaderModeSortValue(left.f, spec);
      final valB = resolveHeaderModeSortValue(right.f, spec);

      int cmp;
      if (spec.isNumeric) {
        final na = double.tryParse(valA);
        final nb = double.tryParse(valB);
        if (na != null && nb != null) {
          cmp = na.compareTo(nb);
        } else {
          cmp = _compareNatural(valA, valB);
        }
      } else {
        cmp = _compareNatural(valA, valB);
      }

      if (cmp != 0) {
        return sortSpec.ascending ? cmp : -cmp;
      }
    }
    
    // Tie-breaker: Fixture ID
    return left.f.id.compareTo(right.f.id);
  }

  // If they are the same fixture, the header row (partOrder == null) always comes first,
  // followed by parts in their partOrder.
  final aOrder = left.partOrder ?? -1;
  final bOrder = right.partOrder ?? -1;
  return aOrder.compareTo(bOrder);
}
