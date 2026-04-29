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
      italic: plexSansLight, // Fallback for light if needed
    );
  }

  static Future<ReportTheme> load() async {
    // Fonts are downloaded from Google Fonts CDN (fonts.gstatic.com) via the
    // exact URLs used by PdfGoogleFonts in the printing package. This ensures
    // the TTF files are in the simplified format the pdf package can subset.
    // They are bundled as assets — no internet connection required at runtime.

    final cormorantRegular = pw.Font.ttf(await rootBundle.load('assets/google_fonts/CormorantGaramond-Regular.ttf'));
    final cormorantMedium = pw.Font.ttf(await rootBundle.load('assets/google_fonts/CormorantGaramond-Medium.ttf'));
    final cormorantSemiBold = pw.Font.ttf(await rootBundle.load('assets/google_fonts/CormorantGaramond-SemiBold.ttf'));

    final plexSansLight = pw.Font.ttf(await rootBundle.load('assets/google_fonts/IBMPlexSans-Light.ttf'));
    final plexSansRegular = pw.Font.ttf(await rootBundle.load('assets/google_fonts/IBMPlexSans-Regular.ttf'));
    final plexSansMedium = pw.Font.ttf(await rootBundle.load('assets/google_fonts/IBMPlexSans-Medium.ttf'));

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
    );
  }
}
