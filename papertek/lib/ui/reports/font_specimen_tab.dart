import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FontValidationResult {
  final String fontName;
  final String assetPath;
  final bool isSuccess;
  final String? errorMessage;
  final pw.Font? loadedFont;

  FontValidationResult({
    required this.fontName, 
    required this.assetPath, 
    required this.isSuccess, 
    this.errorMessage,
    this.loadedFont,
  });
}

class FontSpecimenTab extends StatefulWidget {
  const FontSpecimenTab({super.key});

  @override
  State<FontSpecimenTab> createState() => _FontSpecimenTabState();
}

class _FontSpecimenTabState extends State<FontSpecimenTab> {
  bool _isValidating = true;
  List<FontValidationResult> _results = [];
  double _progress = 0.0;
  String _currentFont = '';
  pw.Font? _interFallback;

  // Comprehensive test string covering alphanumerics and standard WinAnsi symbols
  static const String _testString = '''
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
0123456789
 !"#\$%&'()*+,-./:;<=>?@[\\]^_`{|}~
°µ©®£¢¥§±×÷=
''';

  @override
  void initState() {
    super.initState();
    _validateFonts();
  }

  Future<void> _validateFonts() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      final fontPaths = manifestMap.keys
          .where((key) => key.startsWith('assets/google_fonts/') && key.endsWith('.ttf'))
          .toList()
          ..sort();

      List<FontValidationResult> results = [];
      List<String> corruptedGlyphs = [];
      List<String> corruptedMetadata = [];

      // Load safe fallback fonts for the tolerant test
      pw.Font? fallbackSans;
      pw.Font? fallbackSerif;
      try {
        fallbackSans = pw.Font.ttf(await rootBundle.load('assets/google_fonts/Inter-Regular.ttf'));
        fallbackSerif = pw.Font.ttf(await rootBundle.load('assets/google_fonts/Merriweather-Regular.ttf'));
      } catch (_) {}

      // Store Inter as the global fallback for specimen PDF generation
      _interFallback = fallbackSans;

      final fallbacks = [
        if (fallbackSans != null) fallbackSans,
        if (fallbackSerif != null) fallbackSerif,
      ];

      for (int i = 0; i < fontPaths.length; i++) {
        final path = fontPaths[i];
        final name = path.split('/').last.replaceAll('.ttf', '');
        
        if (mounted) {
          setState(() {
            _currentFont = name;
            _progress = i / fontPaths.length;
          });
        }
        
        await Future.delayed(const Duration(milliseconds: 1)); // Yield for UI

        try {
          final bytes = await rootBundle.load(path);
          final font = pw.Font.ttf(bytes);
          bool isFailed = false;
          String failureReason = '';

          // 1. Bulk test the entire string at once for speed
          try {
            final doc = pw.Document();
            doc.addPage(pw.Page(
              build: (context) => pw.Text(_testString, style: pw.TextStyle(
                font: font,
                fontFallback: [if (fallbackSans != null) fallbackSans, if (fallbackSerif != null) fallbackSerif],
                fontSize: 12,
              )),
            ));
            await doc.save();
          } catch (e) {
            isFailed = true;
            final errorStr = e.toString();
            if (errorStr.contains('RangeError') || errorStr.contains('byteOffset') || errorStr.contains('Index out of range')) {
              failureReason = 'RangeError';
            } else if (errorStr.contains('FormatException')) {
              failureReason = 'FormatException';
              corruptedMetadata.add('METADATA CRASH -> $name : $errorStr');
            } else {
              failureReason = 'Unknown Error';
            }
          }

          // 2. If the bulk test crashed with a RangeError, find the exact character
          if (isFailed && failureReason == 'RangeError') {
            for (final rune in _testString.runes) {
              final char = String.fromCharCode(rune);
              if (char.trim().isEmpty) continue; 
              
              try {
                final doc = pw.Document();
                doc.addPage(pw.Page(
                  build: (context) => pw.Text(char, style: pw.TextStyle(
                    font: font,
                    fontFallback: [if (fallbackSans != null) fallbackSans, if (fallbackSerif != null) fallbackSerif],
                    fontSize: 12,
                  )),
                ));
                await doc.save();
              } catch (e) {
                final errorStr = e.toString();
                if (errorStr.contains('RangeError') || errorStr.contains('byteOffset') || errorStr.contains('Index out of range')) {
                  corruptedGlyphs.add('FATAL GLYPH -> $name : Code $rune : $char');
                }
              }
            }
          }
          
          if (isFailed) {
            results.add(FontValidationResult(
              fontName: name, 
              assetPath: path, 
              isSuccess: false, 
              errorMessage: 'Failed ($failureReason)',
            ));
          } else {
            results.add(FontValidationResult(
              fontName: name, 
              assetPath: path, 
              isSuccess: true,
              loadedFont: font,
            ));
          }
        } catch (e, st) {
          results.add(FontValidationResult(
            fontName: name, 
            assetPath: path, 
            isSuccess: false, 
            errorMessage: 'Font Load Crash: $e',
          ));
        }
      }

      print('\n======================================================');
      print('=== FATAL: CORRUPTED GLYPH TABLES (Subsetter Crash) ===');
      print('======================================================');
      if (corruptedGlyphs.isEmpty) {
        print('None! All fonts have structurally safe glyph tables.');
      } else {
        for (final fail in corruptedGlyphs) {
          print(fail);
        }
      }
      
      print('\n======================================================');
      print('=== FATAL: CORRUPTED FONT METADATA (TtfParser Crash) ===');
      print('======================================================');
      if (corruptedMetadata.isEmpty) {
        print('None! All fonts have safe internal metadata.');
      } else {
        for (final fail in corruptedMetadata) {
          print(fail);
        }
      }
      print('======================================================\n');

      if (mounted) {
        setState(() {
          _results = results;
          _isValidating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isValidating = false;
          _results = [
            FontValidationResult(
              fontName: 'Error Loading Manifest',
              assetPath: '',
              isSuccess: false,
              errorMessage: e.toString(),
            )
          ];
        });
      }
    }
  }

  Future<Uint8List> _generateSpecimenPdf(PdfPageFormat format) async {
    final successfulFonts = _results.where((r) => r.isSuccess).toList();
    final baseFont = successfulFonts.isNotEmpty 
        ? successfulFonts.first.loadedFont! 
        : pw.Font.helvetica();

    final fallbacks = <pw.Font>[
      if (_interFallback != null) _interFallback!,
    ];

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: baseFont,
        fontFallback: fallbacks,
      ),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(width: 1))),
          child: pw.Text('Robust Font Specimen', style: pw.TextStyle(
            font: baseFont,
            fontFallback: fallbacks,
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          )),
        ),
        build: (context) {
          return successfulFonts.map((r) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 150,
                    child: pw.Text(r.fontName, style: pw.TextStyle(
                      font: baseFont,
                      fontFallback: fallbacks,
                      fontSize: 10,
                      color: PdfColors.grey700,
                    )),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      _testString,
                      style: pw.TextStyle(
                        font: r.loadedFont,
                        fontFallback: fallbacks,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Running Subsetter Stress Test...', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_currentFont, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 16),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(value: _progress),
            ),
          ],
        ),
      );
    }

    final failures = _results.where((r) => !r.isSuccess).toList();
    final theme = Theme.of(context);

    return Row(
      children: [
        // Left Panel: Status List
        SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Text(
                  'Stress Test Results\n${_results.length} tested • ${failures.length} failed subsetting',
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final r = _results[index];
                    return ExpansionTile(
                      leading: Icon(
                        r.isSuccess ? Icons.check_circle : Icons.error,
                        color: r.isSuccess ? Colors.green : Colors.red,
                        size: 20,
                      ),
                      title: Text(r.fontName, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: r.isSuccess ? FontWeight.normal : FontWeight.bold)),
                      children: r.isSuccess ? [] : [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: theme.colorScheme.errorContainer,
                          child: SelectableText(
                            r.errorMessage ?? 'Unknown error',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: theme.colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        // Right Panel: Specimen PDF
        Expanded(
          child: Container(
            color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            child: PdfPreview(
              build: _generateSpecimenPdf,
              canChangeOrientation: false,
              canChangePageFormat: false,
              initialPageFormat: PdfPageFormat.letter,
              canDebug: false,
            ),
          ),
        ),
      ],
    );
  }
}
