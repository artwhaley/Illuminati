import 'dart:convert';

class ReportColumn {
  const ReportColumn({
    required this.id,
    required this.label,
    required this.fieldKeys,
    this.widthPercent = 10.0,
    this.isBold = false,
    this.isItalic = false,
    this.fontSize = 9.0,
    this.textAlign = 'left',
    this.isBoxed = false,
  });

  final String id;
  final String label;
  final List<String> fieldKeys;
  final double widthPercent;
  final bool isBold;
  final bool isItalic;
  final double fontSize;
  final String textAlign; // 'left', 'center', or 'right'
  final bool isBoxed; // draw a thin border box inset from cell edges

  bool get isStacked => fieldKeys.length > 1;

  ReportColumn copyWith({
    String? id,
    String? label,
    List<String>? fieldKeys,
    double? widthPercent,
    bool? isBold,
    bool? isItalic,
    double? fontSize,
    String? textAlign,
    bool? isBoxed,
  }) {
    return ReportColumn(
      id: id ?? this.id,
      label: label ?? this.label,
      fieldKeys: fieldKeys ?? this.fieldKeys,
      widthPercent: widthPercent ?? this.widthPercent,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      fontSize: fontSize ?? this.fontSize,
      textAlign: textAlign ?? this.textAlign,
      isBoxed: isBoxed ?? this.isBoxed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'fieldKeys': fieldKeys,
    'widthPercent': widthPercent,
    'isBold': isBold,
    'isItalic': isItalic,
    'fontSize': fontSize,
    'textAlign': textAlign,
    'isBoxed': isBoxed,
  };

  // Maps old field key IDs to their v22 replacements.
  static const _fieldKeyMigrations = {
    'function': 'purpose',
    'focus': 'area',
    'type': 'instrument',
  };

  static String _migrateKey(String k) => _fieldKeyMigrations[k] ?? k;

  factory ReportColumn.fromJson(Map<String, dynamic> json) {
    // Migration: convert old fixedWidth/flex to widthPercent
    // widthPercent takes precedence if present
    double widthPercent = 10.0;
    if (json.containsKey('widthPercent')) {
      widthPercent = (json['widthPercent'] as num).toDouble();
    }
    // (Old fixedWidth/flex keys are silently ignored after this point)

    final rawId = json['id'] as String;
    final migratedId = _migrateKey(rawId);
    final rawFieldKeys = (json['fieldKeys'] as List).cast<String>();
    final migratedFieldKeys = rawFieldKeys.map(_migrateKey).toList();

    return ReportColumn(
      id: migratedId,
      label: json['label'] as String,
      fieldKeys: migratedFieldKeys,
      widthPercent: widthPercent,
      isBold: (json['isBold'] as bool?) ?? false,
      isItalic: (json['isItalic'] as bool?) ?? false,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 9.0,
      textAlign: (json['textAlign'] as String?) ?? 'left',
      isBoxed: (json['isBoxed'] as bool?) ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportColumn &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          _listEquals(fieldKeys, other.fieldKeys) &&
          widthPercent == other.widthPercent &&
          isBold == other.isBold &&
          isItalic == other.isItalic &&
          fontSize == other.fontSize &&
          textAlign == other.textAlign &&
          isBoxed == other.isBoxed;

  @override
  int get hashCode =>
      id.hashCode ^
      label.hashCode ^
      fieldKeys.length.hashCode ^
      widthPercent.hashCode ^
      isBold.hashCode ^
      isItalic.hashCode ^
      fontSize.hashCode ^
      textAlign.hashCode ^
      isBoxed.hashCode;
}

bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class SortLevel {
  const SortLevel({
    required this.fieldKey,
    this.ascending = true,
  });

  final String fieldKey;
  final bool ascending;

  SortLevel copyWith({
    String? fieldKey,
    bool? ascending,
  }) {
    return SortLevel(
      fieldKey: fieldKey ?? this.fieldKey,
      ascending: ascending ?? this.ascending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortLevel &&
          runtimeType == other.runtimeType &&
          fieldKey == other.fieldKey &&
          ascending == other.ascending;

  @override
  int get hashCode => fieldKey.hashCode ^ ascending.hashCode;

  Map<String, dynamic> toJson() => {
    'fieldKey': fieldKey,
    'ascending': ascending,
  };

  factory SortLevel.fromJson(Map<String, dynamic> json) => SortLevel(
    fieldKey: json['fieldKey'] as String,
    ascending: (json['ascending'] as bool?) ?? true,
  );
}

class ReportTemplate {
  const ReportTemplate({
    required this.name,
    required this.columns,
    this.groupByFieldKey,
    this.sortLevels = const [],
    this.orientation = 'portrait',
    this.fontFamily = 'IBM Plex Sans',
    this.dataFontSize = 9.0,
    this.rowHeight,  // null = auto-detect based on stacked columns
    this.multipartHeader = false,
  });

  final String name;
  final List<ReportColumn> columns;
  final String? groupByFieldKey;
  final List<SortLevel> sortLevels;
  final String orientation;
  final String fontFamily;
  final double dataFontSize;
  final double? rowHeight;
  final bool multipartHeader;

  /// Auto-detect row height: 26 if any column is stacked, 22 otherwise.
  double get effectiveRowHeight {
    if (rowHeight != null) return rowHeight!;
    return columns.any((c) => c.isStacked) ? 26.0 : 22.0;
  }

  ReportTemplate copyWith({
    String? name,
    List<ReportColumn>? columns,
    String? Function()? groupByFieldKey,
    List<SortLevel>? sortLevels,
    String? orientation,
    String? fontFamily,
    double? dataFontSize,
    double? Function()? rowHeight,
    bool? multipartHeader,
  }) {
    return ReportTemplate(
      name: name ?? this.name,
      columns: columns ?? this.columns,
      groupByFieldKey: groupByFieldKey != null ? groupByFieldKey() : this.groupByFieldKey,
      sortLevels: sortLevels ?? this.sortLevels,
      orientation: orientation ?? this.orientation,
      fontFamily: fontFamily ?? this.fontFamily,
      dataFontSize: dataFontSize ?? this.dataFontSize,
      rowHeight: rowHeight != null ? rowHeight() : this.rowHeight,
      multipartHeader: multipartHeader ?? this.multipartHeader,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportTemplate &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          _listEquals(columns, other.columns) &&
          groupByFieldKey == other.groupByFieldKey &&
          _listEquals(sortLevels, other.sortLevels) &&
          orientation == other.orientation &&
          fontFamily == other.fontFamily &&
          dataFontSize == other.dataFontSize &&
          rowHeight == other.rowHeight &&
          multipartHeader == other.multipartHeader;

  @override
  int get hashCode =>
      name.hashCode ^
      columns.length.hashCode ^
      groupByFieldKey.hashCode ^
      sortLevels.length.hashCode ^
      orientation.hashCode ^
      fontFamily.hashCode ^
      dataFontSize.hashCode ^
      rowHeight.hashCode ^
      multipartHeader.hashCode;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'name': name,
    'columns': columns.map((c) => c.toJson()).toList(),
    if (groupByFieldKey != null) 'groupByFieldKey': groupByFieldKey,
    'sortLevels': sortLevels.map((s) => s.toJson()).toList(),
    'orientation': orientation,
    'fontFamily': fontFamily,
    'dataFontSize': dataFontSize,
    if (rowHeight != null) 'rowHeight': rowHeight,
    'multipartHeader': multipartHeader,
  };

  factory ReportTemplate.fromJson(Map<String, dynamic> json) {
    // Migration: single sort to multi-level
    List<SortLevel> sortLevels = [];
    if (json.containsKey('sortLevels')) {
      sortLevels = (json['sortLevels'] as List)
          .map((s) => SortLevel.fromJson(s as Map<String, dynamic>))
          .toList();
    } else if (json.containsKey('sortByFieldKey')) {
      sortLevels = [
        SortLevel(
          fieldKey: json['sortByFieldKey'] as String,
          ascending: (json['sortAscending'] as bool?) ?? true,
        )
      ];
    }

    final columns = (json['columns'] as List)
        .map((c) => ReportColumn.fromJson(c as Map<String, dynamic>))
        .toList();

    // Auto-normalize loaded widths to 100%
    if (columns.isNotEmpty) {
      final currentTotal = columns.fold(0.0, (sum, c) => sum + c.widthPercent);
      if (currentTotal > 0) {
        final ratio = 100.0 / currentTotal;
        for (int i = 0; i < columns.length; i++) {
          columns[i] = columns[i].copyWith(widthPercent: columns[i].widthPercent * ratio);
        }
      } else {
        final equal = 100.0 / columns.length;
        for (int i = 0; i < columns.length; i++) {
          columns[i] = columns[i].copyWith(widthPercent: equal);
        }
      }
    }

    final rawGroupBy = json['groupByFieldKey'] as String?;
    final migratedGroupBy = rawGroupBy != null
        ? ReportColumn._migrateKey(rawGroupBy)
        : null;
    final migratedSortLevels = sortLevels
        .map((s) => SortLevel(
              fieldKey: ReportColumn._migrateKey(s.fieldKey),
              ascending: s.ascending,
            ))
        .toList();

    return ReportTemplate(
      name: json['name'] as String,
      columns: columns,
      groupByFieldKey: migratedGroupBy,
      sortLevels: migratedSortLevels,
      orientation: (json['orientation'] as String?) ?? 'portrait',
      fontFamily: (json['fontFamily'] as String?) ?? 'IBM Plex Sans',
      dataFontSize: (json['dataFontSize'] as num?)?.toDouble() ?? 9.0,
      rowHeight: (json['rowHeight'] as num?)?.toDouble(),
      multipartHeader: (json['multipartHeader'] as bool?) ?? false,
    );
  }
}
