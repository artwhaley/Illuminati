import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:printing/printing.dart';

void main() {
  test('download clean fonts from PdfGoogleFonts', () async {
    final fonts = {
      'CormorantGaramond-Regular.ttf': PdfGoogleFonts.cormorantGaramondRegular,
      'CormorantGaramond-Medium.ttf': PdfGoogleFonts.cormorantGaramondMedium,
      'CormorantGaramond-SemiBold.ttf': PdfGoogleFonts.cormorantGaramondSemiBold,
      
      'IBMPlexMono-Light.ttf': PdfGoogleFonts.ibmPlexMonoLight,
      'IBMPlexMono-Regular.ttf': PdfGoogleFonts.ibmPlexMonoRegular,
      'IBMPlexMono-Medium.ttf': PdfGoogleFonts.ibmPlexMonoMedium,
      
      'IBMPlexSans-Light.ttf': PdfGoogleFonts.ibmPlexSansLight,
      'IBMPlexSans-Regular.ttf': PdfGoogleFonts.ibmPlexSansRegular,
      'IBMPlexSans-Medium.ttf': PdfGoogleFonts.ibmPlexSansMedium,
    };

    final dir = Directory('assets/fonts/pdf');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    for (final entry in fonts.entries) {
      print('Downloading ${entry.key}...');
      final font = await entry.value();
      final bytes = font.data.buffer.asUint8List();
      File('assets/fonts/pdf/${entry.key}').writeAsBytesSync(bytes);
      print('Saved ${entry.key} (${bytes.length} bytes)');
    }
  });
}
