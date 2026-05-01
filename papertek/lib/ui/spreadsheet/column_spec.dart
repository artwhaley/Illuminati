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
library;

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
  ColumnSpec({
    required this.id,
    required this.defaultLabel,
    String? label,
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
    this.importAliases,
  }) : label = label ?? defaultLabel;

  /// Factory for dynamic columns based on user-defined fields.
  factory ColumnSpec.custom(int dbId, String name) {
    return ColumnSpec(
      id: 'custom_$dbId',
      defaultLabel: name.toUpperCase(),
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
  final String defaultLabel;
  String label;  // mutable; overridden at runtime by FieldNameNotifier
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
  final List<String>? importAliases;

  bool get isCustomField => customFieldId != null;
  bool get isImportable => !isReadOnly && !isBoolean;
}

/// The single, canonical list of all columns in the spreadsheet.
final List<ColumnSpec> kColumns = [
  ColumnSpec(
    id: 'chan',
    defaultLabel: 'CHAN',
    dbField: 'channel',
    defaultWidth: 60.0,
    section: ColumnSection.patch,
    getValue: (f) => f.channel,
    isNumeric: true,
    isPartLevel: true,
    getPartValue: (f, p) => p.channel,
    importAliases: ['channel', 'chan', 'ch', 'ch#'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => partOrder != null
        ? repo.updatePartChannel(id, partOrder, val)
        : repo.updateIntensityChannel(id, val),
  ),
  ColumnSpec(
    id: 'dimmer',
    defaultLabel: 'Dimmer',
    dbField: 'dimmer',
    defaultWidth: 80.0,
    section: ColumnSection.patch,
    getValue: (f) => f.dimmer,
    isPartLevel: true,
    getPartValue: (f, p) => p.dimmer,
    importAliases: ['dimmer', 'dim', 'dim#', 'dimmer number', 'dimmer no', 'dimmer #'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => partOrder != null
        ? repo.updatePartDimmer(id, partOrder, val)
        : repo.updateIntensityDimmer(id, val),
  ),
  ColumnSpec(
    id: 'address',
    defaultLabel: 'Address',
    dbField: 'address',
    defaultWidth: 80.0,
    section: ColumnSection.patch,
    getValue: (f) => f.address,
    isPartLevel: true,
    getPartValue: (f, p) => p.address,
    importAliases: ['address', 'addr', 'dmx address', 'dmx addr', 'dmx#', 'u address', 'start address', 'dmx start'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => partOrder != null
        ? repo.updatePartAddress(id, partOrder, val)
        : repo.updateIntensityAddress(id, val),
  ),
  ColumnSpec(
    id: 'circuit',
    defaultLabel: 'CIRCUIT',
    dbField: 'circuit',
    defaultWidth: 80.0,
    section: ColumnSection.patch,
    getValue: (f) => f.circuit,
    isPartLevel: true,
    getPartValue: (f, p) => p.circuit,
    importAliases: ['circuit', 'circuit number', 'circuit no', 'ckt', 'ckt#', 'circuit name'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updatePartCircuit(id, partOrder ?? 0, val),
  ),
  ColumnSpec(
    id: 'position',
    defaultLabel: 'POSITION',
    dbField: 'position',
    defaultWidth: 140.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.position,
    importAliases: ['position', 'pos', 'electric', 'location', 'batten', 'pipe', 'lighting position'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updatePosition(id, val),
  ),
  ColumnSpec(
    id: 'unit',
    defaultLabel: 'Unit',
    dbField: 'unit_number',
    defaultWidth: 50.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.unitNumber,
    importAliases: ['unit', 'unit number', 'unit no', 'unit#', 'instrument number'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateUnitNumber(id, val),
  ),
  ColumnSpec(
    id: 'instrument',
    defaultLabel: 'Instrument',
    dbField: 'fixture_type',
    defaultWidth: 160.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.fixtureType,
    getPartValue: (f, p) {
      final name = p.partName ?? 'Part ${p.partOrder + 1}';
      return '${f.fixtureType ?? "Fixture"} - $name';
    },
    importAliases: ['instrument', 'instrument type', 'fixture type', 'type', 'luminaire', 'instrument name'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateFixtureType(id, val),
  ),
  ColumnSpec(
    id: 'wattage',
    defaultLabel: 'Wattage',
    dbField: 'wattage',
    defaultWidth: 60.0,
    section: ColumnSection.fixture,
    isPartLevel: true,
    getValue: (f) => f.parts
        .where((p) => p.wattage != null)
        .map((p) => p.wattage!)
        .join(' / '),
    getPartValue: (f, p) => p.wattage,
    importAliases: ['wattage', 'watts', 'watt', 'wattage (w)', 'load'],
    onEdit: (id, val, repo, {partOrder, customRepo}) =>
        repo.updatePartWattage(id, partOrder ?? 0, val),
  ),
  ColumnSpec(
    id: 'purpose',
    defaultLabel: 'Purpose',
    dbField: 'purpose',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.purpose,
    importAliases: ['purpose', 'use', 'function', 'system'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updatePurpose(id, val),
  ),
  ColumnSpec(
    id: 'area',
    defaultLabel: 'Area',
    dbField: 'area',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.area,
    importAliases: ['area', 'focus', 'focus area', 'focus point', 'target', 'zone', 'scene'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateArea(id, val),
  ),
  ColumnSpec(
    id: 'accessories',
    defaultLabel: 'ACCESSORIES',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.accessories,
    isPartLevel: true,
    getPartValue: (f, p) => p.accessories,
    isCollection: true,
    importAliases: ['accessories', 'accessory', 'acc', 'hardware', 'top hat', 'barndoor', 'add-ons'],
  ),
  ColumnSpec(
    id: 'color',
    defaultLabel: 'COLOR',
    defaultWidth: 100.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.color,
    isPartLevel: true,
    getPartValue: (f, p) => p.color,
    isCollection: true,
    importAliases: ['color', 'colour', 'gel', 'filter', 'gel color', 'gel colour', 'media', 'color filter'],
  ),
  ColumnSpec(
    id: 'gobo',
    defaultLabel: 'GOBO',
    defaultWidth: 100.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.gobo,
    isPartLevel: true,
    getPartValue: (f, p) => p.gobo,
    isCollection: true,
    importAliases: ['gobo', 'gobo 1', 'gobo1', 'pattern', 'template'],
  ),
  ColumnSpec(
    id: 'ip',
    defaultLabel: 'IP ADDRESS',
    dbField: 'ip_address',
    defaultWidth: 120.0,
    section: ColumnSection.network,
    getValue: (f) => f.ipAddress,
    isPartLevel: true,
    getPartValue: (f, p) => p.ipAddress,
    importAliases: ['ip', 'ip address', 'ip addr', 'ipv4', 'network address', 'ip4'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensityIp(id, val),
  ),
  ColumnSpec(
    id: 'subnet',
    defaultLabel: 'SUBNET',
    dbField: 'subnet',
    defaultWidth: 110.0,
    section: ColumnSection.network,
    getValue: (f) => f.subnet,
    isPartLevel: true,
    getPartValue: (f, p) => p.subnet,
    importAliases: ['subnet', 'subnet mask', 'mask', 'netmask', 'network mask'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensitySubnet(id, val),
  ),
  ColumnSpec(
    id: 'mac',
    defaultLabel: 'MAC ADDRESS',
    dbField: 'mac_address',
    defaultWidth: 130.0,
    section: ColumnSection.network,
    getValue: (f) => f.macAddress,
    isPartLevel: true,
    getPartValue: (f, p) => p.macAddress,
    importAliases: ['mac', 'mac address', 'mac addr', 'hardware address', 'physical address'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensityMac(id, val),
  ),
  ColumnSpec(
    id: 'ipv6',
    defaultLabel: 'IPV6',
    dbField: 'ipv6',
    defaultWidth: 150.0,
    section: ColumnSection.network,
    getValue: (f) => f.ipv6,
    isPartLevel: true,
    getPartValue: (f, p) => p.ipv6,
    importAliases: ['ipv6', 'ipv6 address', 'ip6', 'ipv6 addr'],
    onEdit: (id, val, repo, {partOrder, customRepo}) => repo.updateIntensityIpv6(id, val),
  ),
  ColumnSpec(
    id: 'hung',
    defaultLabel: 'HUNG',
    dbField: 'hung',
    defaultWidth: 55.0,
    section: ColumnSection.status,
    getValue: (f) => f.hung ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'patched',
    defaultLabel: 'Patched',
    dbField: 'patched',
    defaultWidth: 60.0,
    section: ColumnSection.status,
    getValue: (f) => f.patched ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'focused',
    defaultLabel: 'FOCUSED',
    dbField: 'focused',
    defaultWidth: 65.0,
    section: ColumnSection.status,
    getValue: (f) => f.focused ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'notes',
    defaultLabel: 'NOTES',
    dbField: null,
    defaultWidth: 120.0,
    section: ColumnSection.other,
    getValue: (f) => '',
    importAliases: ['notes', 'note', 'comment', 'comments', 'remarks', 'description'],
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
