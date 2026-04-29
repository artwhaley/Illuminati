import '../../repositories/fixture_repository.dart';
import 'report_template.dart';

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
List<ReportPickerItem> get allPickerItems {
  return [
    for (final f in kReportFields.values)
      ReportPickerItem(id: f.key, label: f.label, isStack: false),
    for (final s in kStackedColumns.values)
      ReportPickerItem(
        id: s.id,
        label: s.label,
        isStack: true,
        subLabels: s.fieldKeys.map((k) => kReportFields[k]?.label ?? k).toList(),
      ),
  ];
}

class ReportPickerItem {
  const ReportPickerItem({
    required this.id,
    required this.label,
    required this.isStack,
    this.subLabels = const [],
  });
  final String id;
  final String label;
  final bool isStack;
  final List<String> subLabels;
}
