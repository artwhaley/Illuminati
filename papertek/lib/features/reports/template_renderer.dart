import 'dart:collection';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
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
  // ignore: avoid_print
  print('Building PDF for template: ${template.name} (${template.columns.length} columns)');
  try {
    final pdf = await _buildPdf(format, fixtures, template, theme);
    return await pdf.save();
  } catch (e, st) {
    // ignore: avoid_print
    print('CRITICAL: PDF Generation Failed with theme fonts. Falling back to Helvetica. Error: $e');
    final pdf = await _buildPdf(format, fixtures, template, ReportTheme.fallback());
    return await pdf.save();
  }
}

final Map<String, pw.Font> _fontCache = {};

Future<pw.Font> _loadFont(String family, Map<String, String> paths, pw.Font fallback) async {
  final path = paths[family];
  if (path == null) return fallback;
  
  final cacheKey = '$family-${path.split('-').last}';
  if (_fontCache.containsKey(cacheKey)) return _fontCache[cacheKey]!;

  try {
    final bytes = await rootBundle.load(path);
    final font = pw.Font.ttf(bytes.buffer.asByteData());
    _fontCache[cacheKey] = font;
    return font;
  } catch (e) {
    // ignore: avoid_print
    print('Error loading font $path: $e');
    return fallback;
  }
}

Future<pw.Document> _buildPdf(
  PdfPageFormat format,
  List<FixtureRow> fixtures,
  ReportTemplate template,
  ReportTheme theme,
) async {
  final pdf = pw.Document(theme: theme.themeData);

  // Load font variants
  final dataFont = await _loadFont(template.fontFamily, kFontFamilyPaths, theme.plexSansRegular);
  final dataFontBold = await _loadFont(template.fontFamily, kFontFamilyBoldPaths, theme.plexSansMedium);
  final dataFontItalic = await _loadFont(template.fontFamily, kFontFamilyItalicPaths, theme.plexSansRegular);

  final pageFormat = template.orientation == 'landscape'
      ? format.landscape
      : format.portrait;

  // 1. Sort fixtures (multi-level)
  final sortedFixtures = List<FixtureRow>.from(fixtures);
  if (template.sortLevels.isNotEmpty) {
    sortedFixtures.sort((a, b) {
      for (final level in template.sortLevels) {
        if (level.fieldKey.isEmpty) continue;
        
        final valA = getFieldValue(a, level.fieldKey);
        final valB = getFieldValue(b, level.fieldKey);

        if (valA == valB) continue;
        
        // Empty values sort last
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

        if (cmp != 0) return level.ascending ? cmp : -cmp;
      }
      return 0;
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
              fontFallback: theme.fallbackFonts,
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
        widgets.add(_buildDataRow(entry.value[i], i % 2 == 0, template, theme, dataFont, dataFontBold, dataFontItalic));
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
      build: (context) => [
        pw.DefaultTextStyle(
          style: pw.TextStyle(
            font: dataFont,
            fontFallback: theme.fallbackFonts,
            fontSize: template.dataFontSize,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: widgets,
          ),
        ),
      ],
    ),
  );

  return pdf;
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
                fontFallback: theme.fallbackFonts,
                fontSize: 8,
                color: ReportTheme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            pw.Text(
              template.name.toUpperCase(),
              style: pw.TextStyle(
                font: theme.cormorantSemiBold,
                fontFallback: theme.fallbackFonts,
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
                fontFallback: theme.fallbackFonts,
                fontSize: 10,
                color: ReportTheme.textMain,
              ),
            ),
            pw.Text(
              DateTime.now().toIso8601String().split('T').first,
              style: pw.TextStyle(
                font: theme.plexMonoLight,
                fontFallback: theme.fallbackFonts,
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
            fontFallback: theme.fallbackFonts,
            fontSize: 7,
            color: ReportTheme.textMuted,
          ),
        ),
        pw.Text(
          'Printed ${DateTime.now().toIso8601String().split('T').first}',
          style: pw.TextStyle(
            font: theme.plexMonoRegular,
            fontFallback: theme.fallbackFonts,
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

pw.Widget _buildDataRow(
  FixtureRow f, 
  bool isEven, 
  ReportTemplate template, 
  ReportTheme theme,
  pw.Font dataFont,
  pw.Font dataFontBold,
  pw.Font dataFontItalic,
) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: isEven ? ReportTheme.zebraStripe : null,
    ),
    child: pw.Row(
      children: [
        for (final col in template.columns)
          _buildColumnWidget(f, col, template, theme, 
            isHeader: false,
            dataFont: dataFont,
            dataFontBold: dataFontBold,
            dataFontItalic: dataFontItalic,
          ),
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
              fontFallback: theme.fallbackFonts,
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
  pw.Font? dataFont,
  pw.Font? dataFontBold,
  pw.Font? dataFontItalic,
}) {
  pw.Widget content;

  if (isHeader) {
    content = _buildHeaderCellContent(column, theme);
  } else if (column.isStacked) {
    content = _buildStackedCellContent(fixture!, column, template, theme, dataFont!, dataFontBold!, dataFontItalic!);
  } else {
    content = _buildSimpleCellContent(fixture!, column, template, theme, dataFont!, dataFontBold!, dataFontItalic!);
  }

  // Draw an inset border box around non-header cells when isBoxed is enabled.
  // Vertical inset of 2pt keeps the box clear of the row above/below.
  if (!isHeader && column.isBoxed) {
    content = pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2, horizontal: 1),
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(
            color: ReportTheme.ruleColor,
            width: 0.5,
          ),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(1)),
        ),
        child: content,
      ),
    );
  }

  return pw.Expanded(
    flex: (column.widthPercent * 100).toInt(),
    child: content,
  );
}

pw.Widget _buildHeaderCellContent(ReportColumn col, ReportTheme theme) {
  final pw.Alignment cellAlign;
  final pw.TextAlign textAlign;
  switch (col.textAlign) {
    case 'center':
      cellAlign = pw.Alignment.bottomCenter;
      textAlign = pw.TextAlign.center;
      break;
    case 'right':
      cellAlign = pw.Alignment.bottomRight;
      textAlign = pw.TextAlign.right;
      break;
    default: // 'left'
      cellAlign = pw.Alignment.bottomLeft;
      textAlign = pw.TextAlign.left;
  }

  return pw.Align(
    alignment: cellAlign,
    child: pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8, left: 4, right: 4),
      child: pw.Text(
        col.label,
        textAlign: textAlign,
        style: pw.TextStyle(
          font: theme.plexMonoRegular,
          fontFallback: theme.fallbackFonts,
          fontSize: 7,
          color: ReportTheme.textMuted,
        ),
      ),
    ),
  );
}

pw.Widget _buildSimpleCellContent(
  FixtureRow f, 
  ReportColumn col, 
  ReportTemplate tmpl, 
  ReportTheme theme,
  pw.Font dataFont,
  pw.Font dataFontBold,
  pw.Font dataFontItalic,
) {
  final value = getFieldValue(f, col.fieldKeys.first);
  final font = col.isBold ? dataFontBold : (col.isItalic ? dataFontItalic : dataFont);

  // Map textAlign string to pdf alignment objects
  final pw.Alignment cellAlign;
  final pw.TextAlign textAlign;
  switch (col.textAlign) {
    case 'center':
      cellAlign = pw.Alignment.center;
      textAlign = pw.TextAlign.center;
      break;
    case 'right':
      cellAlign = pw.Alignment.centerRight;
      textAlign = pw.TextAlign.right;
      break;
    default: // 'left'
      cellAlign = pw.Alignment.centerLeft;
      textAlign = pw.TextAlign.left;
  }

  return pw.Container(
    height: tmpl.effectiveRowHeight,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4),
    child: pw.Align(
      alignment: cellAlign,
      child: value.isEmpty
        ? pw.SizedBox()
        : pw.Text(
            value,
            style: pw.TextStyle(
              font: font,
              fontFallback: theme.fallbackFonts,
              fontSize: col.fontSize,
              color: ReportTheme.textMain,
            ),
            textAlign: textAlign,
            maxLines: 1,
          ),
    ),
  );
}

pw.Widget _buildStackedCellContent(
  FixtureRow f, 
  ReportColumn col, 
  ReportTemplate tmpl, 
  ReportTheme theme,
  pw.Font dataFont,
  pw.Font dataFontBold,
  pw.Font dataFontItalic,
) {
  final subFontSize = col.fontSize - 2;
  final values = col.fieldKeys.map((k) => getFieldValue(f, k)).toList();
  final font = col.isBold ? dataFontBold : (col.isItalic ? dataFontItalic : dataFont);

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
          pw.Text(
            value,
            maxLines: 1,
            overflow: pw.TextOverflow.clip,
            style: pw.TextStyle(
              font: font,
              fontFallback: theme.fallbackFonts,
              fontSize: subFontSize,
              color: value.isEmpty ? PdfColors.white : ReportTheme.textMain,
            ),
          ),
      ],
    ),
  );
}
