import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportTheme {
  ReportTheme({
    required this.cormorantRegular,
    required this.cormorantMedium,
    required this.cormorantSemiBold,
    required this.plexMonoLight,
    required this.plexMonoRegular,
    required this.plexMonoMedium,
    required this.plexSansLight,
    required this.plexSansRegular,
    required this.plexSansMedium,
    required this.interRegular,
  });

  final pw.Font cormorantRegular;
  final pw.Font cormorantMedium;
  final pw.Font cormorantSemiBold;
  
  final pw.Font plexMonoLight;
  final pw.Font plexMonoRegular;
  final pw.Font plexMonoMedium;

  final pw.Font plexSansLight;
  final pw.Font plexSansRegular;
  final pw.Font plexSansMedium;

  final pw.Font interRegular;

  // v3 HTML Colors
  static const PdfColor pageBackground = PdfColor.fromInt(0xFFFAF9F6);
  static const PdfColor textMain = PdfColor.fromInt(0xFF111111);
  static const PdfColor textMuted = PdfColor.fromInt(0xFF888888);
  static const PdfColor ruleColor = PdfColor.fromInt(0xFFCCCCCC);
  static const PdfColor zebraStripe = PdfColor.fromInt(0xFFF0EFEB);

  pw.ThemeData get themeData {
    return pw.ThemeData.withFont(
      base: plexSansRegular,
      bold: plexSansMedium,
      italic: plexSansLight,
      fontFallback: fallbackFonts,
    );
  }

  List<pw.Font> get fallbackFonts => [interRegular, plexSansRegular];

  static Future<ReportTheme> load() async {
    Future<pw.Font> loadFont(String path) async {
      try {
        final data = await rootBundle.load(path);
        return pw.Font.ttf(data);
      } catch (e) {
        // ignore: avoid_print
        print('CRITICAL: Failed to load font at $path: $e');
        rethrow;
      }
    }

    final cormorantRegular = await loadFont('assets/google_fonts/CormorantGaramond-Regular.ttf');
    final cormorantMedium = await loadFont('assets/google_fonts/CormorantGaramond-Medium.ttf');
    final cormorantSemiBold = await loadFont('assets/google_fonts/CormorantGaramond-SemiBold.ttf');

    final plexSansLight = await loadFont('assets/google_fonts/IBMPlexSans-Light.ttf');
    final plexSansRegular = await loadFont('assets/google_fonts/IBMPlexSans-Regular.ttf');
    final plexSansMedium = await loadFont('assets/google_fonts/IBMPlexSans-Medium.ttf');

    final interRegular = await loadFont('assets/google_fonts/Inter-Regular.ttf');

    // Temporary substitution: Use Sans for Mono to bypass subsetter crash
    final plexMonoLight = plexSansLight;
    final plexMonoRegular = plexSansRegular;
    final plexMonoMedium = plexSansMedium;

    return ReportTheme(
      cormorantRegular: cormorantRegular,
      cormorantMedium: cormorantMedium,
      cormorantSemiBold: cormorantSemiBold,
      plexMonoLight: plexMonoLight,
      plexMonoRegular: plexMonoRegular,
      plexMonoMedium: plexMonoMedium,
      plexSansLight: plexSansLight,
      plexSansRegular: plexSansRegular,
      plexSansMedium: plexSansMedium,
      interRegular: interRegular,
    );
  }

  /// Provides a theme using standard PDF fonts (Helvetica, Times, Courier) 
  /// if custom TTF loading fails.
  factory ReportTheme.fallback() {
    return ReportTheme(
      cormorantRegular: pw.Font.times(),
      cormorantMedium: pw.Font.timesBold(),
      cormorantSemiBold: pw.Font.timesBold(),
      plexMonoLight: pw.Font.courier(),
      plexMonoRegular: pw.Font.courier(),
      plexMonoMedium: pw.Font.courierBold(),
      plexSansLight: pw.Font.helvetica(),
      plexSansRegular: pw.Font.helvetica(),
      plexSansMedium: pw.Font.helveticaBold(),
      interRegular: pw.Font.helvetica(),
    );
  }
}
