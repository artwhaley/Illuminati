/// ── SCHEMA-DRIVEN COLUMN DEFINITIONS ──────────────────────────────────────
///
/// This file defines the "Source of Truth" for every column in the spreadsheet.
/// We use a "Schema-Driven UI" pattern where metadata, formatting logic, 
/// and database update handlers are centralized in [ColumnSpec] objects.
///
/// ADVANTAGES:
/// 1. Centralization: Adding a new column only requires one entry here.
/// 2. Decoupling: The UI widgets and the DataGridSource don't need to know 
///    the specifics of the database schema; they just consume the spec.
/// 3. Consistency: Labels, widths, and edit logic are identical across the 
///    grid, the sidebar, and any export tools.
/// ─────────────────────────────────────────────────────────────────────────────

import '../../../repositories/fixture_repository.dart';
import '../../../repositories/custom_field_repository.dart';

/// Describes the category of the column for sidebar grouping.
enum ColumnSection {
  number,
  patch,
  fixture,
  network,
  status,
  other,
}

/// A comprehensive definition of a single spreadsheet column.
class ColumnSpec {
  const ColumnSpec({
    required this.id,
    required this.label,
    required this.defaultWidth,
    required this.getValue,
    this.dbField,
    this.section = ColumnSection.other,
    this.isReadOnly = false,
    this.isBoolean = false,
    this.isNumeric = false,
    this.isAlwaysVisible = false,
    this.isPartLevel = false,
    this.getPartValue,
    this.onEdit,
    this.isCollection = false,
    this.customFieldId,
  });

  /// Factory for dynamic columns based on user-defined fields.
  factory ColumnSpec.custom(int dbId, String name) {
    return ColumnSpec(
      id: 'custom_$dbId',
      label: name.toUpperCase(),
      defaultWidth: 100.0,
      section: ColumnSection.other,
      customFieldId: dbId,
      getValue: (f) => f.customFieldValues[dbId],
      onEdit: (fid, val, repo, {partOrder, customRepo}) {
        return customRepo?.updateValue(
          fixtureId: fid,
          fieldId: dbId,
          value: val,
          fieldName: name,
        ) ?? Future.value();
      },
    );
  }

  final String id;
  final String label;
  final double defaultWidth;
  final String? Function(FixtureRow) getValue;
  final String? dbField;
  final ColumnSection section;
  final bool isReadOnly;
  final bool isBoolean;
  final bool isNumeric;
  final bool isAlwaysVisible;
  
  /// Whether this field is tied to an individual part (intensity) or the 
  /// fixture itself.
  final bool isPartLevel;
  
  /// Accessor for part-level data (for child rows).
  final String? Function(FixtureRow, FixturePartRow)? getPartValue;

  /// Callback to update the database for this column.
  final Future<void> Function(
    int fixtureId,
    String? value,
    FixtureRepository repo, {
    int? partOrder,
    CustomFieldRepository? customRepo,
  })? onEdit;

  /// Whether this column represents a collection (Gel, Gobo, etc) that
  /// requires a specialized editor rather than a simple text field.
  final bool isCollection;

  /// If this is a custom field, the DB ID of the field definition.
  final int? customFieldId;

  bool get isCustomField => customFieldId != null;
}

/// The single, canonical list of all columns in the spreadsheet.
final List<ColumnSpec> kColumns = [
  // ColumnSpec(
  //   id: '#',
  //   label: '#',
  //   defaultWidth: 40.0,
  //   section: ColumnSection.number,
  //   getValue: (f) => f.id.toString(),
  //   isReadOnly: true,
  //   isNumeric: true,
  //   isAlwaysVisible: true,
  // ),
  ColumnSpec(
    id: 'chan',
    label: 'CHAN',
    dbField: 'channel',
    defaultWidth: 60.0,
    section: ColumnSection.patch,
    getValue: (f) => f.channel,
    isNumeric: true,
    isPartLevel: true,
    getPartValue: (f, p) => p.channel,
    onEdit: (id, val, repo, {partOrder, customRepo}) => partOrder != null 
        ? repo.updatePartChannel(id, partOrder, val)
        : repo.updateIntensityChannel(id, val),
  ),
  ColumnSpec(
    id: 'dimmer',
    label: 'ADDRESS',
    dbField: 'address',
    defaultWidth: 80.0,
    section: ColumnSection.patch,
    getValue: (f) => f.dimmer,
    isPartLevel: true,
    getPartValue: (f, p) => p.address,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updatePartAddress(id, partOrder ?? 0, val),
  ),
  ColumnSpec(
    id: 'circuit',
    label: 'CIRCUIT',
    dbField: 'circuit',
    defaultWidth: 80.0,
    section: ColumnSection.patch,
    getValue: (f) => f.circuit,
    isPartLevel: true,
    getPartValue: (f, p) => p.circuit,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updatePartCircuit(id, partOrder ?? 0, val),
  ),
  ColumnSpec(
    id: 'position',
    label: 'POSITION',
    dbField: 'position',
    defaultWidth: 140.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.position,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updatePosition(id, val),
  ),
  ColumnSpec(
    id: 'unit',
    label: 'U#',
    dbField: 'unit_number',
    defaultWidth: 50.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.unitNumber?.toString(),
    isNumeric: true,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateUnitNumber(id, int.tryParse(val ?? '')),
  ),
  ColumnSpec(
    id: 'type',
    label: 'FIXTURE TYPE',
    dbField: 'fixture_type',
    defaultWidth: 160.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.fixtureType,
    getPartValue: (f, p) {
      final name = p.partName ?? 'Part ${p.partOrder + 1}';
      return '${f.fixtureType ?? "Fixture"} $name';
    },
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateFixtureType(id, val),
  ),
  ColumnSpec(
    id: 'wattage',
    label: 'WATTAGE',
    dbField: 'wattage',
    defaultWidth: 60.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.wattage,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateWattage(id, val),
  ),
  ColumnSpec(
    id: 'function',
    label: 'PURPOSE',
    dbField: 'function',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.function,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateFunction(id, val),
  ),
  ColumnSpec(
    id: 'focus',
    label: 'FOCUS AREA',
    dbField: 'focus',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.focus,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateFocus(id, val),
  ),
  ColumnSpec(
    id: 'accessories',
    label: 'ACCESSORIES',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.accessories,
    isPartLevel: true,
    getPartValue: (f, p) => p.accessories,
    isCollection: true,
  ),
  ColumnSpec(
    id: 'color',
    label: 'COLOR',
    defaultWidth: 100.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.color,
    isPartLevel: true,
    getPartValue: (f, p) => p.color,
    isCollection: true,
  ),
  ColumnSpec(
    id: 'gobo',
    label: 'GOBO',
    defaultWidth: 100.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.gobo,
    isPartLevel: true,
    getPartValue: (f, p) => p.gobo,
    isCollection: true,
  ),
  ColumnSpec(
    id: 'ip',
    label: 'IP ADDRESS',
    dbField: 'ip_address',
    defaultWidth: 120.0,
    section: ColumnSection.network,
    getValue: (f) => f.ipAddress,
    isPartLevel: true,
    getPartValue: (f, p) => p.ipAddress,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensityIp(id, val),
  ),
  ColumnSpec(
    id: 'subnet',
    label: 'SUBNET',
    dbField: 'subnet',
    defaultWidth: 110.0,
    section: ColumnSection.network,
    getValue: (f) => f.subnet,
    isPartLevel: true,
    getPartValue: (f, p) => p.subnet,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensitySubnet(id, val),
  ),
  ColumnSpec(
    id: 'mac',
    label: 'MAC ADDRESS',
    dbField: 'mac_address',
    defaultWidth: 130.0,
    section: ColumnSection.network,
    getValue: (f) => f.macAddress,
    isPartLevel: true,
    getPartValue: (f, p) => p.macAddress,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensityMac(id, val),
  ),
  ColumnSpec(
    id: 'ipv6',
    label: 'IPV6',
    dbField: 'ipv6',
    defaultWidth: 150.0,
    section: ColumnSection.network,
    getValue: (f) => f.ipv6,
    isPartLevel: true,
    getPartValue: (f, p) => p.ipv6,
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensityIpv6(id, val),
  ),
  ColumnSpec(
    id: 'hung',
    label: 'HUNG',
    dbField: 'hung',
    defaultWidth: 55.0,
    section: ColumnSection.status,
    getValue: (f) => f.hung ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'patch',
    label: 'PATCHED',
    dbField: 'patched',
    defaultWidth: 60.0,
    section: ColumnSection.status,
    getValue: (f) => f.patched ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'focused',
    label: 'FOCUSED',
    dbField: 'focused',
    defaultWidth: 65.0,
    section: ColumnSection.status,
    getValue: (f) => f.focused ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'notes',
    label: 'NOTES',
    dbField: null,
    defaultWidth: 120.0,
    section: ColumnSection.other,
    getValue: (f) => '', // Notes are not currently backed by a field
  ),
];

/// Fast lookup by ID.
final Map<String, ColumnSpec> kColumnById = {
  for (final c in kColumns) c.id: c,
};

/// Reverse lookup: DB field name → ColumnSpec.
/// Useful in the maintenance tab for mapping revision.fieldName → display column.
final Map<String, ColumnSpec> kColumnByDbField = {
  for (final c in kColumns)
    if (c.dbField != null) c.dbField!: c,
};

/// Default column order (just the IDs).
final List<String> kDefaultColumnOrder = kColumns.map((c) => c.id).toList();

/// Default widths map (for SharedPreferences compatibility).
final Map<String, double> kDefaultWidths = {
  for (final c in kColumns) c.id: c.defaultWidth,
};

/// Column labels map (for backward compatibility).
final Map<String, String> kColLabels = {
  for (final c in kColumns) c.id: c.label,
};

/// A simple record used to track multi-level sorting preferences.
class SortSpec {
  final String column;
  final bool ascending;
  SortSpec({required this.column, this.ascending = true});

  SortSpec toggle() => SortSpec(column: column, ascending: !ascending);

  Map<String, dynamic> toJson() => {'column': column, 'direction': ascending ? 'asc' : 'desc'};
  static SortSpec fromJson(Map<String, dynamic> json) => 
      SortSpec(column: json['column'] as String, ascending: json['direction'] == 'asc');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortSpec && runtimeType == other.runtimeType && column == other.column && ascending == other.ascending;

  @override
  int get hashCode => column.hashCode ^ ascending.hashCode;
}
