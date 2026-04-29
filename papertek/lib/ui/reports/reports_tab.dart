import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../providers/show_provider.dart';
import '../../features/reports/report_theme.dart';
import '../../features/reports/channel_hookup_report.dart';

class ReportsTab extends ConsumerStatefulWidget {
  const ReportsTab({super.key});

  @override
  ConsumerState<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<ReportsTab> {
  ReportTheme? _theme;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final theme = await ReportTheme.load();
    if (mounted) {
      setState(() {
        _theme = theme;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fixtures = ref.watch(fixtureRowsProvider).valueOrNull ?? [];
    
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: PdfPreview(
        build: (format) => buildChannelHookup(format, fixtures, _theme!),
        canChangeOrientation: false,
        canChangePageFormat: false,
        initialPageFormat: PdfPageFormat.letter,
      ),
    );
  }
}
