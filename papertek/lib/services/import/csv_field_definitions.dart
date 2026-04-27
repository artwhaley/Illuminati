/// All PaperTek fields that can be populated from an external CSV import.
///
/// To add a new importable field:
///   1. Add an entry to this enum.
///   2. Fill in display metadata in the extension below.
///   3. Add column-name variants to the relevant [ColumnDetector] impl
///      (e.g. [LightwrightColumnDetector]).
///   4. Handle the new field in [ImportService._importRow].
enum PaperTekImportField {
  channel,
  dimmer,
  circuit,
  position,
  unitNumber,
  fixtureType,
  wattage,
  color, // creates a Gel row when present and non-empty
  gobo1, // creates a Gobo row
  gobo2, // creates a second Gobo row
  function,
  focus,
  notes,
  // When present, rows sharing the same position+unit+type are grouped into
  // one multi-part fixture (e.g. the three cells of a cyc unit).
  partNumber,
}

extension PaperTekImportFieldX on PaperTekImportField {
  String get displayName => switch (this) {
        PaperTekImportField.channel => 'Channel',
        PaperTekImportField.dimmer => 'Dimmer',
        PaperTekImportField.circuit => 'Circuit',
        PaperTekImportField.position => 'Position',
        PaperTekImportField.unitNumber => 'Unit #',
        PaperTekImportField.fixtureType => 'Fixture Type',
        PaperTekImportField.wattage => 'Wattage',
        PaperTekImportField.color => 'Color / Gel',
        PaperTekImportField.gobo1 => 'Gobo 1',
        PaperTekImportField.gobo2 => 'Gobo 2',
        PaperTekImportField.function => 'Function',
        PaperTekImportField.focus => 'Focus',
        PaperTekImportField.notes => 'Notes',
        PaperTekImportField.partNumber => 'Part #',
      };

  /// Shown in the mapping UI to explain what the field is used for.
  String get hint => switch (this) {
        PaperTekImportField.channel => 'Designer channel number',
        PaperTekImportField.dimmer => 'Dimmer or rack/slot',
        PaperTekImportField.circuit => 'Circuit name or number',
        PaperTekImportField.position => 'Hanging position (required)',
        PaperTekImportField.unitNumber => 'Unit # within position',
        PaperTekImportField.fixtureType => 'Instrument type / template',
        PaperTekImportField.wattage => 'Lamp wattage or type',
        PaperTekImportField.color => 'Gel color (creates a Gel record)',
        PaperTekImportField.gobo1 => 'First gobo (creates a Gobo record)',
        PaperTekImportField.gobo2 => 'Second gobo wheel',
        PaperTekImportField.function => 'Designer function label',
        PaperTekImportField.focus => 'Focus position or area',
        PaperTekImportField.notes => 'Instrument notes',
        PaperTekImportField.partNumber => 'Part number for multi-cell fixtures (e.g. 1, 2, 3 for a 3-cell cyc)',
      };

  /// Position is the only field without which a row cannot be created.
  bool get isRequired => this == PaperTekImportField.position;
}
