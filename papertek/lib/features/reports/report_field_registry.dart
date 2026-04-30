import '../../ui/spreadsheet/column_spec.dart';
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

/// All fields available for reports, derived from the canonical ColumnSpec registry.
final Map<String, ReportFieldDef> kReportFields = {
  // 1. Derive from the canonical ColumnSpec registry.
  // Only includes non-boolean fields (status columns like 'hung' don't go in reports).
  for (final spec in kColumns)
    if (!spec.isBoolean)
      spec.id: ReportFieldDef(
        key: spec.id,
        label: spec.label,
        getValue: spec.getValue,
        defaultWidth: spec.defaultWidth,
      ),
};

/// Helper to read a field value from a FixtureRow by key.
/// Returns empty string if key is unknown or value is null.
String getFieldValue(FixtureRow fixture, String fieldKey) {
  // Legacy translation for gobos
  var effectiveKey = fieldKey;
  if (fieldKey == 'gobo1' || fieldKey == 'gobo2') {
    effectiveKey = 'gobo';
  }

  final def = kReportFields[effectiveKey];
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
    widthPercent: 20.0,
  ),
  'stack_color_template': const ReportColumn(
    id: 'stack_color_template',
    label: 'Color / Template',
    fieldKeys: ['color', 'gobo'],
    widthPercent: 10.0,
  ),
  'stack_purpose_area': const ReportColumn(
    id: 'stack_purpose_area',
    label: 'Purpose and Area',
    fieldKeys: ['function', 'focus'],
    widthPercent: 20.0,
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

/// Maps display name → Regular TTF asset path.
const Map<String, String> kFontFamilyPaths = {
  'Alegreya': 'assets/google_fonts/Alegreya-Regular.ttf',
  'Alegreya Sans': 'assets/google_fonts/AlegreyaSans-Regular.ttf',
  'Archivo Narrow': 'assets/google_fonts/ArchivoNarrow-Regular.ttf',
  'BioRhyme': 'assets/google_fonts/BioRhyme-Regular.ttf',
  'Cardo': 'assets/google_fonts/Cardo-Regular.ttf',
  'Chivo': 'assets/google_fonts/Chivo-Regular.ttf',
  'Cormorant': 'assets/google_fonts/Cormorant-Regular.ttf',
  'Cormorant Garamond': 'assets/google_fonts/CormorantGaramond-Regular.ttf',
  'DM Sans': 'assets/google_fonts/DMSans-Regular.ttf',
  'Eczar': 'assets/google_fonts/Eczar-Regular.ttf',
  'Fira Sans': 'assets/google_fonts/FiraSans-Regular.ttf',
  'Fraunces': 'assets/google_fonts/Fraunces-Regular.ttf',
  'IBM Plex Sans': 'assets/google_fonts/IBMPlexSans-Regular.ttf',
  'IBM Plex Sans Condensed': 'assets/google_fonts/IBMPlexSans_Condensed-Regular.ttf',
  'IBM Plex Sans SemiCondensed': 'assets/google_fonts/IBMPlexSans_SemiCondensed-Regular.ttf',
  'Inconsolata': 'assets/google_fonts/Inconsolata-Regular.ttf',
  'Inknut Antiqua': 'assets/google_fonts/InknutAntiqua-Regular.ttf',
  'Inter': 'assets/google_fonts/Inter-Regular.ttf',
  'Karla': 'assets/google_fonts/Karla-Regular.ttf',
  'Lato': 'assets/google_fonts/Lato-Regular.ttf',
  'Libre Baskerville': 'assets/google_fonts/LibreBaskerville-Regular.ttf',
  'Libre Franklin': 'assets/google_fonts/LibreFranklin-Regular.ttf',
  'Lora': 'assets/google_fonts/Lora-Regular.ttf',
  'Manrope': 'assets/google_fonts/Manrope-Regular.ttf',
  'Merriweather': 'assets/google_fonts/Merriweather-Regular.ttf',
  'Montserrat': 'assets/google_fonts/Montserrat-Regular.ttf',
  'Neuton': 'assets/google_fonts/Neuton-Regular.ttf',
  'Open Sans': 'assets/google_fonts/OpenSans-Regular.ttf',
  'PT Sans': 'assets/google_fonts/PTSans-Regular.ttf',
  'PT Serif': 'assets/google_fonts/PTSerif-Regular.ttf',
  'Playfair Display': 'assets/google_fonts/PlayfairDisplay-Regular.ttf',
  'Poppins': 'assets/google_fonts/Poppins-Regular.ttf',
  'Proza Libre': 'assets/google_fonts/ProzaLibre-Regular.ttf',
  'Raleway': 'assets/google_fonts/Raleway-Regular.ttf',
  'Roboto': 'assets/google_fonts/Roboto-Regular.ttf',
  'Rubik': 'assets/google_fonts/Rubik-Regular.ttf',
  'Source Sans 3': 'assets/google_fonts/SourceSans3-Regular.ttf',
  'Source Serif 4': 'assets/google_fonts/SourceSerif4-Regular.ttf',
  'Space Grotesk': 'assets/google_fonts/SpaceGrotesk-Regular.ttf',
  'Space Mono': 'assets/google_fonts/SpaceMono-Regular.ttf',
  'Spectral': 'assets/google_fonts/Spectral-Regular.ttf',
  'Syne': 'assets/google_fonts/Syne-Regular.ttf',
  'Work Sans': 'assets/google_fonts/WorkSans-Regular.ttf',
};

/// Maps display name → Bold TTF asset path.
const Map<String, String> kFontFamilyBoldPaths = {
  'Alegreya': 'assets/google_fonts/Alegreya-Bold.ttf',
  'Alegreya Sans': 'assets/google_fonts/AlegreyaSans-Bold.ttf',
  'Archivo Narrow': 'assets/google_fonts/ArchivoNarrow-Bold.ttf',
  'BioRhyme': 'assets/google_fonts/BioRhyme-Bold.ttf',
  'Cardo': 'assets/google_fonts/Cardo-Bold.ttf',
  'Chivo': 'assets/google_fonts/Chivo-Bold.ttf',
  'Cormorant': 'assets/google_fonts/Cormorant-Bold.ttf',
  'Cormorant Garamond': 'assets/google_fonts/CormorantGaramond-Bold.ttf',
  'DM Sans': 'assets/google_fonts/DMSans-Bold.ttf',
  'Eczar': 'assets/google_fonts/Eczar-Bold.ttf',
  'Fira Sans': 'assets/google_fonts/FiraSans-Bold.ttf',
  'Fraunces': 'assets/google_fonts/Fraunces-Bold.ttf',
  'IBM Plex Sans': 'assets/google_fonts/IBMPlexSans-Bold.ttf',
  'IBM Plex Sans Condensed': 'assets/google_fonts/IBMPlexSans_Condensed-Bold.ttf',
  'IBM Plex Sans SemiCondensed': 'assets/google_fonts/IBMPlexSans_SemiCondensed-Bold.ttf',
  'Inconsolata': 'assets/google_fonts/Inconsolata-Bold.ttf',
  'Inknut Antiqua': 'assets/google_fonts/InknutAntiqua-Bold.ttf',
  'Inter': 'assets/google_fonts/Inter-Bold.ttf',
  'Karla': 'assets/google_fonts/Karla-Bold.ttf',
  'Lato': 'assets/google_fonts/Lato-Bold.ttf',
  'Libre Baskerville': 'assets/google_fonts/LibreBaskerville-Bold.ttf',
  'Libre Franklin': 'assets/google_fonts/LibreFranklin-Bold.ttf',
  'Lora': 'assets/google_fonts/Lora-Bold.ttf',
  'Manrope': 'assets/google_fonts/Manrope-Bold.ttf',
  'Merriweather': 'assets/google_fonts/Merriweather-Bold.ttf',
  'Montserrat': 'assets/google_fonts/Montserrat-Bold.ttf',
  'Neuton': 'assets/google_fonts/Neuton-Bold.ttf',
  'Open Sans': 'assets/google_fonts/OpenSans-Bold.ttf',
  'PTSans': 'assets/google_fonts/PTSans-Bold.ttf',
  'PTSerif': 'assets/google_fonts/PTSerif-Bold.ttf',
  'Playfair Display': 'assets/google_fonts/PlayfairDisplay-Bold.ttf',
  'Poppins': 'assets/google_fonts/Poppins-Bold.ttf',
  'Proza Libre': 'assets/google_fonts/ProzaLibre-Bold.ttf',
  'Raleway': 'assets/google_fonts/Raleway-Bold.ttf',
  'Roboto': 'assets/google_fonts/Roboto-Bold.ttf',
  'Rubik': 'assets/google_fonts/Rubik-Bold.ttf',
  'Source Sans 3': 'assets/google_fonts/SourceSans3-Bold.ttf',
  'Source Serif 4': 'assets/google_fonts/SourceSerif4-Bold.ttf',
  'Space Grotesk': 'assets/google_fonts/SpaceGrotesk-Bold.ttf',
  'Space Mono': 'assets/google_fonts/SpaceMono-Bold.ttf',
  'Spectral': 'assets/google_fonts/Spectral-Bold.ttf',
  'Syne': 'assets/google_fonts/Syne-Bold.ttf',
  'Work Sans': 'assets/google_fonts/WorkSans-Bold.ttf',
};

/// Maps display name → Italic TTF asset path.
const Map<String, String> kFontFamilyItalicPaths = {
  'Alegreya': 'assets/google_fonts/Alegreya-Italic.ttf',
  'Alegreya Sans': 'assets/google_fonts/AlegreyaSans-Italic.ttf',
  'Archivo Narrow': 'assets/google_fonts/ArchivoNarrow-Italic.ttf',
  'Cardo': 'assets/google_fonts/Cardo-Italic.ttf',
  'Chivo': 'assets/google_fonts/Chivo-Italic.ttf',
  'Cormorant': 'assets/google_fonts/Cormorant-Italic.ttf',
  'Cormorant Garamond': 'assets/google_fonts/CormorantGaramond-Italic.ttf',
  'DM Sans': 'assets/google_fonts/DMSans-Italic.ttf',
  'Fira Sans': 'assets/google_fonts/FiraSans-Italic.ttf',
  'Fraunces': 'assets/google_fonts/Fraunces-Italic.ttf',
  'IBM Plex Sans': 'assets/google_fonts/IBMPlexSans-Italic.ttf',
  'IBM Plex Sans Condensed': 'assets/google_fonts/IBMPlexSans_Condensed-Italic.ttf',
  'IBM Plex Sans SemiCondensed': 'assets/google_fonts/IBMPlexSans_SemiCondensed-Italic.ttf',
  'Inter': 'assets/google_fonts/Inter-Italic.ttf',
  'Karla': 'assets/google_fonts/Karla-Italic.ttf',
  'Lato': 'assets/google_fonts/Lato-Italic.ttf',
  'Libre Baskerville': 'assets/google_fonts/LibreBaskerville-Italic.ttf',
  'Libre Franklin': 'assets/google_fonts/LibreFranklin-Italic.ttf',
  'Lora': 'assets/google_fonts/Lora-Italic.ttf',
  'Merriweather': 'assets/google_fonts/Merriweather-Italic.ttf',
  'Montserrat': 'assets/google_fonts/Montserrat-Italic.ttf',
  'Neuton': 'assets/google_fonts/Neuton-Italic.ttf',
  'Open Sans': 'assets/google_fonts/OpenSans-Italic.ttf',
  'PTSans': 'assets/google_fonts/PTSans-Italic.ttf',
  'PTSerif': 'assets/google_fonts/PTSerif-Italic.ttf',
  'Playfair Display': 'assets/google_fonts/PlayfairDisplay-Italic.ttf',
  'Poppins': 'assets/google_fonts/Poppins-Italic.ttf',
  'Proza Libre': 'assets/google_fonts/ProzaLibre-Italic.ttf',
  'Raleway': 'assets/google_fonts/Raleway-Italic.ttf',
  'Roboto': 'assets/google_fonts/Roboto-Italic.ttf',
  'Rubik': 'assets/google_fonts/Rubik-Italic.ttf',
  'Source Sans 3': 'assets/google_fonts/SourceSans3-Italic.ttf',
  'Source Serif 4': 'assets/google_fonts/SourceSerif4-Italic.ttf',
  'Space Mono': 'assets/google_fonts/SpaceMono-Italic.ttf',
  'Spectral': 'assets/google_fonts/Spectral-Italic.ttf',
  'Work Sans': 'assets/google_fonts/WorkSans-Italic.ttf',
};
