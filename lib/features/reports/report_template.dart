import 'dart:convert';

class ReportColumn {
  const ReportColumn({
    required this.id,
    required this.label,
    required this.fieldKeys,
    this.fixedWidth,
    this.flex = 1,
    this.isBold = false,
  });

  final String id;
  final String label;
  final List<String> fieldKeys;
  final double? fixedWidth;
  final int flex;
  final bool isBold;

  bool get isStacked => fieldKeys.length > 1;

  ReportColumn copyWith({
    String? id,
    String? label,
    List<String>? fieldKeys,
    double? Function()? fixedWidth,  // Use nullable function to allow setting to null
    int? flex,
    bool? isBold,
  }) {
    return ReportColumn(
      id: id ?? this.id,
      label: label ?? this.label,
      fieldKeys: fieldKeys ?? this.fieldKeys,
      fixedWidth: fixedWidth != null ? fixedWidth() : this.fixedWidth,
      flex: flex ?? this.flex,
      isBold: isBold ?? this.isBold,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'fieldKeys': fieldKeys,
    if (fixedWidth != null) 'fixedWidth': fixedWidth,
    'flex': flex,
    'isBold': isBold,
  };

  factory ReportColumn.fromJson(Map<String, dynamic> json) => ReportColumn(
    id: json['id'] as String,
    label: json['label'] as String,
    fieldKeys: (json['fieldKeys'] as List).cast<String>(),
    fixedWidth: (json['fixedWidth'] as num?)?.toDouble(),
    flex: (json['flex'] as int?) ?? 1,
    isBold: (json['isBold'] as bool?) ?? false,
  );
}

class ReportTemplate {
  const ReportTemplate({
    required this.name,
    required this.columns,
    this.groupByFieldKey,
    this.sortByFieldKey,
    this.sortAscending = true,
    this.orientation = 'portrait',
    this.dataFontSize = 9.0,
    this.rowHeight,  // null = auto-detect based on stacked columns
  });

  final String name;
  final List<ReportColumn> columns;
  final String? groupByFieldKey;
  final String? sortByFieldKey;
  final bool sortAscending;
  final String orientation;
  final double dataFontSize;
  final double? rowHeight;

  /// Auto-detect row height: 36 if any column is stacked, 22 otherwise.
  double get effectiveRowHeight {
    if (rowHeight != null) return rowHeight!;
    return columns.any((c) => c.isStacked) ? 36.0 : 22.0;
  }

  ReportTemplate copyWith({
    String? name,
    List<ReportColumn>? columns,
    String? Function()? groupByFieldKey,
    String? Function()? sortByFieldKey,
    bool? sortAscending,
    String? orientation,
    double? dataFontSize,
    double? Function()? rowHeight,
  }) {
    return ReportTemplate(
      name: name ?? this.name,
      columns: columns ?? this.columns,
      groupByFieldKey: groupByFieldKey != null ? groupByFieldKey() : this.groupByFieldKey,
      sortByFieldKey: sortByFieldKey != null ? sortByFieldKey() : this.sortByFieldKey,
      sortAscending: sortAscending ?? this.sortAscending,
      orientation: orientation ?? this.orientation,
      dataFontSize: dataFontSize ?? this.dataFontSize,
      rowHeight: rowHeight != null ? rowHeight() : this.rowHeight,
    );
  }

  Map<String, dynamic> toJson() => {
    'version': 1,
    'name': name,
    'columns': columns.map((c) => c.toJson()).toList(),
    if (groupByFieldKey != null) 'groupByFieldKey': groupByFieldKey,
    if (sortByFieldKey != null) 'sortByFieldKey': sortByFieldKey,
    'sortAscending': sortAscending,
    'orientation': orientation,
    'dataFontSize': dataFontSize,
    if (rowHeight != null) 'rowHeight': rowHeight,
  };

  factory ReportTemplate.fromJson(Map<String, dynamic> json) => ReportTemplate(
    name: json['name'] as String,
    columns: (json['columns'] as List).map((c) => ReportColumn.fromJson(c as Map<String, dynamic>)).toList(),
    groupByFieldKey: json['groupByFieldKey'] as String?,
    sortByFieldKey: json['sortByFieldKey'] as String?,
    sortAscending: (json['sortAscending'] as bool?) ?? true,
    orientation: (json['orientation'] as String?) ?? 'portrait',
    dataFontSize: (json['dataFontSize'] as num?)?.toDouble() ?? 9.0,
    rowHeight: (json['rowHeight'] as num?)?.toDouble(),
  );
}
