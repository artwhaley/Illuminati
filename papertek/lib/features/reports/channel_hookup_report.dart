import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../database/database.dart';
import '../../repositories/fixture_repository.dart';
import 'report_theme.dart';

Future<Uint8List> buildChannelHookup(
  PdfPageFormat format,
  List<FixtureRow> fixtures,
  ReportTheme theme,
) async {
  final pdf = pw.Document(theme: theme.themeData);

  pdf.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: format,
        margin: const pw.EdgeInsets.only(left: 52, right: 52, top: 24, bottom: 28),
        buildBackground: (context) => pw.FullPage(
          ignoreMargins: true,
          child: pw.Container(color: ReportTheme.pageBackground),
        ),
      ),
      header: (context) => _buildHeader(context, theme),
      footer: (context) => _buildFooter(context, theme),
      build: (context) => [
        ..._buildTable(fixtures, theme),
      ],
    ),
  );

  return pdf.save();
}

pw.Widget _buildHeader(pw.Context context, ReportTheme theme) {
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
              'CHANNEL HOOKUP',
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

pw.Widget _buildFooter(pw.Context context, ReportTheme theme) {
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
          'CHANNEL HOOKUP',
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

pw.Widget _buildHeaderRow(ReportTheme theme) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      _headerCell('CH', 30, theme),
      _headerCell('DIM', 40, theme),
      _headerCell('POSITION', 80, theme),
      _headerCell('U#', 30, theme),
      _headerCell('PURPOSE / FOCUS AREA', null, theme, flex: 1),
      _headerCell('TYPE & ACC & LOAD', null, theme, flex: 2),
      _headerCell('COLOR / GOBO', 80, theme),
    ],
  );
}

List<pw.Widget> _buildTable(List<FixtureRow> fixtures, ReportTheme theme) {
  // 1. Sort Data (Position, then Channel)
  final sortedFixtures = List<FixtureRow>.from(fixtures)
    ..sort((a, b) {
      final posComp = (a.position ?? '').compareTo(b.position ?? '');
      if (posComp != 0) return posComp;
      return (a.channel ?? '').compareTo(b.channel ?? '');
    });

  // 2. Group by Position
  final groups = <String, List<FixtureRow>>{};
  for (final f in sortedFixtures) {
    final pos = f.position ?? 'UNPOSITIONED';
    groups.putIfAbsent(pos, () => []).add(f);
  }

  final widgets = <pw.Widget>[];
  widgets.add(_buildHeaderRow(theme));
  widgets.add(pw.SizedBox(height: 8));

  for (final entry in groups.entries) {
    widgets.add(_buildGroupHeader(entry.key, theme));
    for (int i = 0; i < entry.value.length; i++) {
      widgets.add(_buildDataRow(entry.value[i], i % 2 == 0, theme));
    }
    widgets.add(pw.SizedBox(height: 12));
  }

  return widgets;
}

pw.Widget _buildGroupHeader(String posName, ReportTheme theme) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 8, bottom: 8),
    child: pw.Row(
      children: [
        pw.Container(width: 20, height: 0.5, color: ReportTheme.ruleColor),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Text(
            posName.toUpperCase(),
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

pw.Widget _buildDataRow(FixtureRow f, bool isEven, ReportTheme theme) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: isEven ? ReportTheme.zebraStripe : null,
    ),
    child: pw.Row(
      children: [
        _dataCell(f.channel ?? '', 30, theme, isBold: true),
        _dataCell(f.dimmer ?? '', 40, theme),
        _dataCell(f.position ?? '', 80, theme),
        _dataCell(f.unitNumber?.toString() ?? '', 30, theme),
        _dataCell(f.function ?? '', null, theme, flex: 1),
        _dataCell(f.fixtureType ?? '', null, theme, flex: 2),
        _dataCell(f.color ?? '', 80, theme),
      ],
    ),
  );
}

pw.Widget _headerCell(String label, double? width, ReportTheme theme, {int flex = 0}) {
  final content = pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8, left: 4, right: 4),
    child: pw.Text(
      label,
      style: pw.TextStyle(
        font: theme.plexMonoRegular,
        fontSize: 7,
        color: ReportTheme.textMuted,
      ),
    ),
  );

  if (width != null) {
    return pw.SizedBox(width: width, child: content);
  }
  return pw.Expanded(flex: flex, child: content);
}

pw.Widget _dataCell(
  String value,
  double? width,
  ReportTheme theme, {
  bool isBold = false,
  int flex = 0,
}) {
  final textWidget = pw.Text(
    value,
    style: pw.TextStyle(
      font: isBold ? theme.plexSansMedium : theme.plexSansRegular,
      fontSize: 10,
      color: ReportTheme.textMain,
    ),
    maxLines: 1,
  );

  final content = pw.Container(
    height: 24,
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
                child: textWidget,
              ),
            ),
          ),
    ),
  );

  if (width != null) {
    return pw.SizedBox(width: width, child: content);
  }
  return pw.Expanded(flex: flex, child: content);
}
