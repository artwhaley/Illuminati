import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../providers/show_provider.dart';
import '../../features/reports/report_theme.dart';
import '../../features/reports/template_renderer.dart';
import '../../repositories/report_template_repository.dart';
import 'template_editor_panel.dart';
import 'font_specimen_tab.dart';

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
    
    // Seed default templates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportTemplateRepoProvider)?.seedDefaults();
    });

    // Listen for the first load of templates to set initial active template
    ref.listenManual(reportTemplatesProvider, (previous, next) {
      final rows = next.valueOrNull ?? [];
      final selectedId = ref.read(activeReportTemplateIdProvider);
      
      if (rows.isNotEmpty && selectedId == null) {
        final first = rows.first;
        ref.read(activeReportTemplateIdProvider.notifier).state = first.id;
        ref.read(activeReportTemplateProvider.notifier)
            .loadTemplate(ReportTemplateRepository.parseTemplate(first));
      }
    });
  }

  Future<void> _loadTheme() async {
    try {
      final theme = await ReportTheme.load();
      if (mounted) {
        setState(() {
          _theme = theme;
          _loading = false;
        });
      }
    } catch (e) {
      // Font loading failed — use null theme, renderer will use fallbacks
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fixtures = ref.watch(fixtureRowsProvider).valueOrNull ?? [];
    final template = ref.watch(activeReportTemplateProvider);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Report Editor'),
              Tab(text: 'Font Specimen'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Row(
              children: [
                // Left panel: editor
                SizedBox(
                  width: 320,
                  child: TemplateEditorPanel(theme: _theme),
                ),
                const VerticalDivider(width: 1),
                // Right panel: PDF preview
                Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    child: template.columns.isEmpty
                      ? const Center(child: Text('Add at least one column to generate a report.'))
                      : PdfPreview(
                          build: (format) => buildFromTemplate(
                            format, 
                            fixtures, 
                            template, 
                            _theme ?? ReportTheme.fallback(),
                          ),
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          initialPageFormat: PdfPageFormat.letter,
                          // Hide some UI elements for a cleaner look
                          canDebug: false,
                          actions: const [],
                        ),
                  ),
                ),
              ],
            ),
            const FontSpecimenTab(),
          ],
        ),
      ),
    );
  }
}
