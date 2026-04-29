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

import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../../../repositories/fixture_repository.dart';

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
    this.section = ColumnSection.other,
    this.isReadOnly = false,
    this.isBoolean = false,
    this.isNumeric = false,
    this.isAlwaysVisible = false,
    this.isPartLevel = false,
    this.getPartValue,
    this.onEdit,
  });

  final String id;
  final String label;
  final double defaultWidth;
  final String? Function(FixtureRow) getValue;
  final ColumnSection section;
  final bool isReadOnly;
  final bool isBoolean;
  final bool isNumeric;
  final bool isAlwaysVisible;
  
  /// Whether this field is tied to an individual part (intensity) or the 
  /// fixture itself.
  final bool isPartLevel;
  
  /// Accessor for part-level data (for child rows).
  final String? Function(FixturePartRow)? getPartValue;

  /// Callback to update the database for this column.
  final Future<void> Function(int fixtureId, String? value, FixtureRepository repo)? onEdit;
}

/// The single, canonical list of all columns in the spreadsheet.
final List<ColumnSpec> kColumns = [
  ColumnSpec(
    id: '#',
    label: '#',
    defaultWidth: 40.0,
    section: ColumnSection.number,
    getValue: (f) => f.id.toString(),
    isReadOnly: true,
    isNumeric: true,
    isAlwaysVisible: true,
  ),
  ColumnSpec(
    id: 'chan',
    label: 'CHAN',
    defaultWidth: 60.0,
    section: ColumnSection.patch,
    getValue: (f) => f.channel,
    isNumeric: true,
    isPartLevel: true,
    getPartValue: (p) => p.channel,
    onEdit: (id, val, repo) => repo.updateIntensityChannel(id, val),
  ),
  ColumnSpec(
    id: 'dimmer',
    label: 'ADDRESS',
    defaultWidth: 80.0,
    section: ColumnSection.patch,
    getValue: (f) => f.dimmer,
    isPartLevel: true,
    getPartValue: (p) => p.address,
    onEdit: (id, val, repo) => repo.updatePartAddress(id, 0, val),
  ),
  ColumnSpec(
    id: 'circuit',
    label: 'CIRCUIT',
    defaultWidth: 80.0,
    section: ColumnSection.patch,
    getValue: (f) => f.circuit,
    isPartLevel: true,
    getPartValue: (p) => p.circuit,
    onEdit: (id, val, repo) => repo.updatePartCircuit(id, 0, val),
  ),
  ColumnSpec(
    id: 'position',
    label: 'POSITION',
    defaultWidth: 140.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.position,
    onEdit: (id, val, repo) => repo.updatePosition(id, val),
  ),
  ColumnSpec(
    id: 'unit',
    label: 'U#',
    defaultWidth: 50.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.unitNumber?.toString(),
    isNumeric: true,
    onEdit: (id, val, repo) => repo.updateUnitNumber(id, int.tryParse(val ?? '')),
  ),
  ColumnSpec(
    id: 'type',
    label: 'FIXTURE TYPE',
    defaultWidth: 160.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.fixtureType,
    onEdit: (id, val, repo) => repo.updateFixtureType(id, val),
  ),
  ColumnSpec(
    id: 'function',
    label: 'PURPOSE',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.function,
    onEdit: (id, val, repo) => repo.updateFunction(id, val),
  ),
  ColumnSpec(
    id: 'focus',
    label: 'FOCUS AREA',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.focus,
    onEdit: (id, val, repo) => repo.updateFocus(id, val),
  ),
  ColumnSpec(
    id: 'accessories',
    label: 'ACCESSORIES',
    defaultWidth: 120.0,
    section: ColumnSection.fixture,
    getValue: (f) => f.accessories,
    onEdit: (id, val, repo) => repo.updateAccessories(id, val),
  ),
  ColumnSpec(
    id: 'ip',
    label: 'IP ADDRESS',
    defaultWidth: 120.0,
    section: ColumnSection.network,
    getValue: (f) => f.ipAddress,
    isPartLevel: true,
    getPartValue: (p) => p.ipAddress,
    onEdit: (id, val, repo) => repo.updateIntensityIp(id, val),
  ),
  ColumnSpec(
    id: 'subnet',
    label: 'SUBNET',
    defaultWidth: 110.0,
    section: ColumnSection.network,
    getValue: (f) => f.subnet,
    isPartLevel: true,
    getPartValue: (p) => p.subnet,
    onEdit: (id, val, repo) => repo.updateIntensitySubnet(id, val),
  ),
  ColumnSpec(
    id: 'mac',
    label: 'MAC ADDRESS',
    defaultWidth: 130.0,
    section: ColumnSection.network,
    getValue: (f) => f.macAddress,
    isPartLevel: true,
    getPartValue: (p) => p.macAddress,
    onEdit: (id, val, repo) => repo.updateIntensityMac(id, val),
  ),
  ColumnSpec(
    id: 'ipv6',
    label: 'IPV6',
    defaultWidth: 150.0,
    section: ColumnSection.network,
    getValue: (f) => f.ipv6,
    isPartLevel: true,
    getPartValue: (p) => p.ipv6,
    onEdit: (id, val, repo) => repo.updateIntensityIpv6(id, val),
  ),
  ColumnSpec(
    id: 'hung',
    label: 'HUNG',
    defaultWidth: 55.0,
    section: ColumnSection.status,
    getValue: (f) => f.hung ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'patch',
    label: 'PATCHED',
    defaultWidth: 60.0,
    section: ColumnSection.status,
    getValue: (f) => f.patched ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'focused',
    label: 'FOCUSED',
    defaultWidth: 65.0,
    section: ColumnSection.status,
    getValue: (f) => f.focused ? '✓' : '—',
    isBoolean: true,
    isReadOnly: true,
  ),
  ColumnSpec(
    id: 'notes',
    label: 'NOTES',
    defaultWidth: 120.0,
    section: ColumnSection.other,
    getValue: (f) => '', // Notes are not currently backed by a field
  ),
];

/// Fast lookup by ID.
final Map<String, ColumnSpec> kColumnById = {
  for (final c in kColumns) c.id: c,
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
