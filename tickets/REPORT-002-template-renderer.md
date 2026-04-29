# REPORT-002: Template Renderer (PDF Generation Engine)

## Summary
Create the generic PDF renderer that accepts a `ReportTemplate` and `List<FixtureRow>` and produces a PDF document. This replaces the hardcoded `channel_hookup_report.dart`.

## Depends On
- REPORT-001 (data models and field registry)

## Files to Create
1. `lib/features/reports/template_renderer.dart`

## Files to Delete
1. `lib/features/reports/channel_hookup_report.dart` — replaced by `template_renderer.dart`

## Files to Modify
1. `lib/ui/reports/reports_tab.dart` — update import from `channel_hookup_report.dart` to `template_renderer.dart`

## Critical Layout Rules

> **READ THESE BEFORE WRITING ANY CODE. Violating any rule causes runtime assertion crashes.**

1. **NO `pw.Table` with `pw.FittedBox`.** Use `pw.Row` with `pw.SizedBox` (fixed columns) and `pw.Expanded` (flex columns).

2. **NO `pw.FittedBox` on empty strings.** Check `value.isEmpty` first; return `pw.SizedBox()` for empty values.

3. **Wrap `FittedBox` in safety layers.** Every data cell with text must use:
   ```dart
   pw.OverflowBox(
     maxWidth: double.infinity,
     alignment: pw.Alignment.centerLeft,
     child: pw.ConstrainedBox(
       constraints: const pw.BoxConstraints(minWidth: 1),
       child: pw.FittedBox(
         fit: pw.BoxFit.scaleDown,
         child: textWidget,
       ),
     ),
   )
   ```

4. **`MultiPage.build` must return a flat list.** Each row is a top-level widget. Do NOT wrap all rows in a `pw.Column`.

5. **Use `pw.PageTheme` exclusively in `MultiPage`.** Do NOT also pass `pageFormat`, `margin`, `theme`, `orientation`, or `clip`. The pdf package asserts only one approach is used.

6. **`Expanded.flex` must be `int`.** Never pass a `double` to the `flex` parameter.

7. **Clamp flex to minimum 1.** If `column.flex` is 0 or negative, use 1.

## Detailed Instructions

### Function Signature

```dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../repositories/fixture_repository.dart';
import 'report_field_registry.dart';
import 'report_template.dart';
import 'report_theme.dart';

Future<Uint8List> buildFromTemplate(
  PdfPageFormat format,
  List<FixtureRow> fixtures,
  ReportTemplate template,
  ReportTheme theme,
) async { ... }
```

### Implementation Structure

The function must:

1. **Create the document** with `pw.Document(theme: theme.themeData)`.

2. **Determine page format and orientation:**
   ```dart
   final pageFormat = template.orientation == 'landscape'
       ? format.landscape
       : format.portrait;
   ```

3. **Sort fixtures** using `template.sortByFieldKey`:
   - Look up the field's accessor from `kReportFields`
   - Sort ascending or descending per `template.sortAscending`
   - Use natural string comparison (null values sort last)

4. **Group fixtures** using `template.groupByFieldKey`:
   - If null, treat all fixtures as one group with key `''` (no group headers rendered)
   - If set, group into a `LinkedHashMap<String, List<FixtureRow>>` preserving insertion order

5. **Build the widget list:**
   ```dart
   final widgets = <pw.Widget>[];
   widgets.add(_buildHeaderRow(template, theme));
   widgets.add(pw.SizedBox(height: 8));
   
   for (final entry in groups.entries) {
     if (template.groupByFieldKey != null) {
       widgets.add(_buildGroupHeader(entry.key, theme));
     }
     for (int i = 0; i < entry.value.length; i++) {
       widgets.add(_buildDataRow(entry.value[i], i % 2 == 0, template, theme));
     }
     if (template.groupByFieldKey != null) {
       widgets.add(pw.SizedBox(height: 12));
     }
   }
   ```

6. **Handle empty fixtures:** If `fixtures.isEmpty`, add a single centered text widget: "No fixtures in current show."

7. **Add page with spread:**
   ```dart
   pdf.addPage(
     pw.MultiPage(
       pageTheme: pw.PageTheme(
         pageFormat: pageFormat,
         margin: const pw.EdgeInsets.only(left: 52, right: 52, top: 24, bottom: 28),
         buildBackground: (context) => pw.FullPage(
           ignoreMargins: true,
           child: pw.Container(color: ReportTheme.pageBackground),
         ),
       ),
       header: (context) => _buildPageHeader(context, template, theme),
       footer: (context) => _buildPageFooter(context, template, theme),
       build: (context) => [...widgets],
     ),
   );
   ```

### Helper Functions

#### `_buildColumnWidget` — the core cell builder

This is the most important function. It handles both simple and stacked columns.

```dart
pw.Widget _buildColumnWidget(
  FixtureRow fixture,
  ReportColumn column,
  ReportTemplate template,
  ReportTheme theme, {
  bool isHeader = false,
}) {
  pw.Widget content;
  
  if (isHeader) {
    content = _buildHeaderCellContent(column, theme);
  } else if (column.isStacked) {
    content = _buildStackedCellContent(fixture, column, template, theme);
  } else {
    content = _buildSimpleCellContent(fixture, column, template, theme);
  }

  // Wrap in sizing container
  if (column.fixedWidth != null) {
    return pw.SizedBox(width: column.fixedWidth!, child: content);
  }
  return pw.Expanded(flex: column.flex.clamp(1, 100), child: content);
}
```

#### `_buildSimpleCellContent` — single-field cell

```dart
pw.Widget _buildSimpleCellContent(FixtureRow f, ReportColumn col, ReportTemplate tmpl, ReportTheme theme) {
  final value = getFieldValue(f, col.fieldKeys.first);
  
  return pw.Container(
    height: tmpl.effectiveRowHeight,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4),
    child: pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: value.isEmpty
        ? pw.SizedBox()
        : pw.OverflowBox(
            maxWidth: double.infinity,
            alignment: pw.Alignment.centerLeft,
            child: pw.ConstrainedBox(
              constraints: const pw.BoxConstraints(minWidth: 1),
              child: pw.FittedBox(
                fit: pw.BoxFit.scaleDown,
                child: pw.Text(
                  value,
                  style: pw.TextStyle(
                    font: col.isBold ? theme.plexSansMedium : theme.plexSansRegular,
                    fontSize: tmpl.dataFontSize,
                    color: ReportTheme.textMain,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ),
    ),
  );
}
```

#### `_buildStackedCellContent` — multi-field cell

```dart
pw.Widget _buildStackedCellContent(FixtureRow f, ReportColumn col, ReportTemplate tmpl, ReportTheme theme) {
  final subFontSize = tmpl.dataFontSize - 1;
  final values = col.fieldKeys.map((k) => getFieldValue(f, k)).toList();
  
  // If ALL sub-values are empty, return empty container
  if (values.every((v) => v.isEmpty)) {
    return pw.Container(height: tmpl.effectiveRowHeight);
  }

  return pw.Container(
    height: tmpl.effectiveRowHeight,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        for (final value in values)
          value.isEmpty
            ? pw.SizedBox(height: subFontSize + 2)
            : pw.OverflowBox(
                maxWidth: double.infinity,
                alignment: pw.Alignment.centerLeft,
                child: pw.ConstrainedBox(
                  constraints: const pw.BoxConstraints(minWidth: 1),
                  child: pw.FittedBox(
                    fit: pw.BoxFit.scaleDown,
                    child: pw.Text(
                      value,
                      style: pw.TextStyle(
                        font: theme.plexSansRegular,
                        fontSize: subFontSize,
                        color: ReportTheme.textMain,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
      ],
    ),
  );
}
```

#### `_buildHeaderRow`, `_buildDataRow`, `_buildGroupHeader`, `_buildPageHeader`, `_buildPageFooter`

Port these from the existing `channel_hookup_report.dart`, but make them template-driven:

- `_buildHeaderRow`: Iterate `template.columns`, call `_buildColumnWidget` with `isHeader: true`
- `_buildDataRow`: Iterate `template.columns`, call `_buildColumnWidget` for each
- `_buildGroupHeader`: Same design as current (rule lines + position name in Cormorant Garamond)
- `_buildPageHeader`: Same design, but use `template.name` as the title instead of hardcoded "CHANNEL HOOKUP"
- `_buildPageFooter`: Same design, but use `template.name`

### Updating `reports_tab.dart`

Temporarily update `reports_tab.dart` to use `buildFromTemplate` with a hardcoded Channel Hookup template for testing. Import the default templates from REPORT-003 once that ticket is complete.

```dart
// Temporary — will be replaced by the editor UI in REPORT-005
import '../../features/reports/template_renderer.dart';
import '../../features/reports/report_template.dart';

// In build():
build: (format) => buildFromTemplate(
  format,
  fixtures,
  ReportTemplate(
    name: 'Channel Hookup',
    columns: [
      const ReportColumn(id: 'chan', label: 'CH', fieldKeys: ['chan'], fixedWidth: 30, isBold: true),
      const ReportColumn(id: 'dimmer', label: 'DIM', fieldKeys: ['dimmer'], fixedWidth: 40),
      const ReportColumn(id: 'position', label: 'POSITION', fieldKeys: ['position'], fixedWidth: 80),
      const ReportColumn(id: 'unit', label: 'U#', fieldKeys: ['unit'], fixedWidth: 30),
      const ReportColumn(id: 'stack_purpose_area', label: 'PURPOSE / AREA', fieldKeys: ['function', 'focus'], flex: 1),
      const ReportColumn(id: 'stack_instrument', label: 'INSTRUMENT', fieldKeys: ['type', 'wattage'], flex: 2),
      const ReportColumn(id: 'stack_color_template', label: 'COLOR / GOBO', fieldKeys: ['color', 'gobo1'], fixedWidth: 80),
    ],
    groupByFieldKey: 'position',
    sortByFieldKey: 'chan',
  ),
  _theme!,
),
```

## Testing
- Hot restart the app after making changes
- Verify the PDF preview renders without assertion errors
- Verify grouping by position works
- Verify stacked columns show two lines per cell
- Verify empty cells don't crash
- Verify the page header shows the template name
