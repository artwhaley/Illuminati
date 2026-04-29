import 'dart:collection';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../repositories/fixture_repository.dart';
import 'report_field_registry.dart';
import 'report_template.dart';
import 'report_theme.dart';

/// Generic PDF renderer that produces a document from a ReportTemplate.
Future<Uint8List> buildFromTemplate(
  PdfPageFormat format,
  List<FixtureRow> fixtures,
  ReportTemplate template,
  ReportTheme theme,
) async {
  final pdf = pw.Document(theme: theme.themeData);

  final pageFormat = template.orientation == 'landscape'
      ? format.landscape
      : format.portrait;

  // 1. Sort fixtures
  final sortedFixtures = List<FixtureRow>.from(fixtures);
  if (template.sortByFieldKey != null) {
    sortedFixtures.sort((a, b) {
      final valA = getFieldValue(a, template.sortByFieldKey!);
      final valB = getFieldValue(b, template.sortByFieldKey!);

      // Empty values sort last
      if (valA.isEmpty && valB.isEmpty) return 0;
      if (valA.isEmpty) return 1;
      if (valB.isEmpty) return -1;

      int cmp;
      final numA = int.tryParse(valA);
      final numB = int.tryParse(valB);

      if (numA != null && numB != null) {
        cmp = numA.compareTo(numB);
      } else {
        cmp = valA.toLowerCase().compareTo(valB.toLowerCase());
      }

      return template.sortAscending ? cmp : -cmp;
    });
  }

  // 2. Group fixtures
  final groups = LinkedHashMap<String, List<FixtureRow>>();
  if (template.groupByFieldKey == null) {
    groups[''] = sortedFixtures;
  } else {
    for (final f in sortedFixtures) {
      final groupValue = getFieldValue(f, template.groupByFieldKey!) ?? 'NONE';
      groups.putIfAbsent(groupValue, () => []).add(f);
    }
  }

  // 3. Build widget list
  final widgets = <pw.Widget>[];
  
  if (fixtures.isEmpty) {
    widgets.add(
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 40),
        child: pw.Center(
          child: pw.Text(
            'No fixtures in current show.',
            style: pw.TextStyle(
              font: theme.plexSansRegular,
              fontSize: 12,
              color: ReportTheme.textMuted,
            ),
          ),
        ),
      ),
    );
  } else {
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
  }

  // 4. Create multi-page document
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
      build: (context) => widgets,
    ),
  );

  return pdf.save();
}

pw.Widget _buildPageHeader(pw.Context context, ReportTemplate template, ReportTheme theme) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(width: 2, color: ReportTheme.textMain),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'THEATRICAL LIGHTING DOCUMENTATION',
              style: pw.TextStyle(
                font: theme.plexMonoRegular,
                fontSize: 8,
                color: ReportTheme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            pw.Text(
              template.name.toUpperCase(),
              style: pw.TextStyle(
                font: theme.cormorantSemiBold,
                fontSize: 24,
                color: ReportTheme.textMain,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              '${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(
                font: theme.plexMonoRegular,
                fontSize: 10,
                color: ReportTheme.textMain,
              ),
            ),
            pw.Text(
              DateTime.now().toIso8601String().split('T').first,
              style: pw.TextStyle(
                font: theme.plexMonoLight,
                fontSize: 8,
                color: ReportTheme.textMuted,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

pw.Widget _buildPageFooter(pw.Context context, ReportTemplate template, ReportTheme theme) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 8),
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        top: pw.BorderSide(width: 0.5, color: ReportTheme.ruleColor),
      ),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          template.name.toUpperCase(),
          style: pw.TextStyle(
            font: theme.plexMonoRegular,
            fontSize: 7,
            color: ReportTheme.textMuted,
          ),
        ),
        pw.Text(
          'Printed ${DateTime.now().toIso8601String().split('T').first}',
          style: pw.TextStyle(
            font: theme.plexMonoRegular,
            fontSize: 7,
            color: ReportTheme.textMuted,
          ),
        ),
      ],
    ),
  );
}

pw.Widget _buildHeaderRow(ReportTemplate template, ReportTheme theme) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      for (final col in template.columns)
        _buildColumnWidget(null, col, template, theme, isHeader: true),
    ],
  );
}

pw.Widget _buildDataRow(FixtureRow f, bool isEven, ReportTemplate template, ReportTheme theme) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: isEven ? ReportTheme.zebraStripe : null,
    ),
    child: pw.Row(
      children: [
        for (final col in template.columns)
          _buildColumnWidget(f, col, template, theme, isHeader: false),
      ],
    ),
  );
}

pw.Widget _buildGroupHeader(String groupName, ReportTheme theme) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 8, bottom: 8),
    child: pw.Row(
      children: [
        pw.Container(width: 20, height: 0.5, color: ReportTheme.ruleColor),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Text(
            groupName.toUpperCase(),
            style: pw.TextStyle(
              font: theme.cormorantMedium,
              fontSize: 10,
              color: ReportTheme.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        pw.Expanded(child: pw.Container(height: 0.5, color: ReportTheme.ruleColor)),
      ],
    ),
  );
}

pw.Widget _buildColumnWidget(
  FixtureRow? fixture,
  ReportColumn column,
  ReportTemplate template,
  ReportTheme theme, {
  bool isHeader = false,
}) {
  pw.Widget content;
  
  if (isHeader) {
    content = _buildHeaderCellContent(column, theme);
  } else if (column.isStacked) {
    content = _buildStackedCellContent(fixture!, column, template, theme);
  } else {
    content = _buildSimpleCellContent(fixture!, column, template, theme);
  }

  if (column.fixedWidth != null) {
    return pw.SizedBox(width: column.fixedWidth!, child: content);
  }
  return pw.Expanded(flex: column.flex.clamp(1, 100), child: content);
}

pw.Widget _buildHeaderCellContent(ReportColumn col, ReportTheme theme) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8, left: 4, right: 4),
    child: pw.Text(
      col.label,
      style: pw.TextStyle(
        font: theme.plexMonoRegular,
        fontSize: 7,
        color: ReportTheme.textMuted,
      ),
    ),
  );
}

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

pw.Widget _buildStackedCellContent(FixtureRow f, ReportColumn col, ReportTemplate tmpl, ReportTheme theme) {
  final subFontSize = tmpl.dataFontSize - 1;
  final values = col.fieldKeys.map((k) => getFieldValue(f, k)).toList();
  
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
            ? pw.SizedBox(height: subFontSize + 1) // Minimal height for empty sub-line
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
