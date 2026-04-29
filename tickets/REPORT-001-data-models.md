# REPORT-001: Data Models & Field Registry

## Execution Guardrails (Must Follow)
- All paths in this ticket are under `papertek/`:
  - `papertek/lib/features/reports/report_template.dart`
  - `papertek/lib/features/reports/report_field_registry.dart`
- Do not create or modify root-level `lib/` files for app implementation.
- `ReportPickerItem` must be a **public** type (no leading underscore).
- Add normalization helpers for invalid JSON inputs (invalid orientation/flex/empty field keys/duplicate column IDs).

## Summary
Create the foundational data models (`ReportTemplate`, `ReportColumn`, `ReportFieldDef`) and the field registry (`kReportFields`, `kStackedColumns`) that the entire report engine depends on.

## Depends On
None — this is the first ticket.

## Files to Create
1. `papertek/lib/features/reports/report_template.dart`
2. `papertek/lib/features/reports/report_field_registry.dart`

## File to Delete
None.

## Detailed Instructions

### 1. `report_template.dart`

Create two classes: `ReportColumn` and `ReportTemplate`. Both must be immutable and JSON-serializable.

```dart
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
```

### 2. `report_field_registry.dart`

Create the field registry and stacked column definitions.

```dart
import '../../repositories/fixture_repository.dart';

class ReportFieldDef {
  const ReportFieldDef({
    required this.key,
    required this.label,
    required this.getValue,
    this.defaultWidth = 80.0,
  });

  final String key;
  final String label;
  final String? Function(FixtureRow) getValue;
  final double defaultWidth;
}

/// All fields available for reports. Keyed by the canonical field key.
final Map<String, ReportFieldDef> kReportFields = {
  'chan': ReportFieldDef(key: 'chan', label: 'Channel', getValue: (f) => f.channel, defaultWidth: 40),
  'dimmer': ReportFieldDef(key: 'dimmer', label: 'Address', getValue: (f) => f.dimmer, defaultWidth: 50),
  'circuit': ReportFieldDef(key: 'circuit', label: 'Circuit', getValue: (f) => f.circuit, defaultWidth: 50),
  'position': ReportFieldDef(key: 'position', label: 'Position', getValue: (f) => f.position, defaultWidth: 100),
  'unit': ReportFieldDef(key: 'unit', label: 'U#', getValue: (f) => f.unitNumber?.toString(), defaultWidth: 30),
  'type': ReportFieldDef(key: 'type', label: 'Fixture Type', getValue: (f) => f.fixtureType, defaultWidth: 120),
  'function': ReportFieldDef(key: 'function', label: 'Purpose', getValue: (f) => f.function, defaultWidth: 100),
  'focus': ReportFieldDef(key: 'focus', label: 'Focus Area', getValue: (f) => f.focus, defaultWidth: 100),
  'accessories': ReportFieldDef(key: 'accessories', label: 'Accessories', getValue: (f) => f.accessories, defaultWidth: 100),
  'color': ReportFieldDef(key: 'color', label: 'Color', getValue: (f) => f.color, defaultWidth: 60),
  'gobo1': ReportFieldDef(key: 'gobo1', label: 'Gobo 1', getValue: (f) => f.gobo1, defaultWidth: 60),
  'gobo2': ReportFieldDef(key: 'gobo2', label: 'Gobo 2', getValue: (f) => f.gobo2, defaultWidth: 60),
  'wattage': ReportFieldDef(key: 'wattage', label: 'Wattage', getValue: (f) => f.wattage, defaultWidth: 60),
  'notes': ReportFieldDef(key: 'notes', label: 'Notes', getValue: (f) => '', defaultWidth: 100),
};

/// Helper to read a field value from a FixtureRow by key.
/// Returns empty string if key is unknown or value is null.
String getFieldValue(FixtureRow fixture, String fieldKey) {
  final def = kReportFields[fieldKey];
  if (def == null) return '';
  return def.getValue(fixture) ?? '';
}

/// Pre-built stacked column definitions.
/// These appear in the column picker alongside simple fields.
import 'report_template.dart';

final Map<String, ReportColumn> kStackedColumns = {
  'stack_instrument': const ReportColumn(
    id: 'stack_instrument',
    label: 'Full Definition',
    fieldKeys: ['type', 'wattage'],
    flex: 2,
  ),
  'stack_color_template': const ReportColumn(
    id: 'stack_color_template',
    label: 'Color / Template',
    fieldKeys: ['color', 'gobo1'],
    flex: 1,
  ),
  'stack_purpose_area': const ReportColumn(
    id: 'stack_purpose_area',
    label: 'Purpose and Area',
    fieldKeys: ['function', 'focus'],
    flex: 2,
  ),
};

/// Returns a list of all selectable items for the column picker.
/// Simple fields first, then stacked columns.
List<_PickerItem> get allPickerItems {
  return [
    for (final f in kReportFields.values)
      _PickerItem(id: f.key, label: f.label, isStack: false),
    for (final s in kStackedColumns.values)
      _PickerItem(
        id: s.id,
        label: s.label,
        isStack: true,
        subLabels: s.fieldKeys.map((k) => kReportFields[k]?.label ?? k).toList(),
      ),
  ];
}

class _PickerItem {
  const _PickerItem({required this.id, required this.label, required this.isStack, this.subLabels = const []});
  final String id;
  final String label;
  final bool isStack;
  final List<String> subLabels;
}
```

> **IMPORTANT:** Use `ReportPickerItem` directly (public type). Do not declare `_PickerItem`.

## Acceptance Criteria
- `ReportTemplate.fromJson(template.toJson())` round-trips without data loss
- `ReportColumn.fromJson(column.toJson())` round-trips without data loss
- `kReportFields` contains exactly 14 entries
- `kStackedColumns` contains exactly 3 entries
- `getFieldValue()` returns empty string for unknown keys and null field values
- `effectiveRowHeight` returns 36.0 when any column is stacked, 22.0 otherwise
- `ReportTemplate.fromJson` normalizes invalid values:
  - unknown orientation -> `'portrait'`
  - flex < 1 -> 1
  - empty fieldKeys columns are dropped
  - duplicate column IDs are deduped (keep first)
