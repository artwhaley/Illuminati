import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../providers/show_provider.dart';
import '../../features/reports/report_theme.dart';
import '../../features/reports/template_renderer.dart';
import '../../repositories/report_template_repository.dart';
import 'template_editor_panel.dart';
import 'column_resizer.dart';

class ReportsTab extends ConsumerStatefulWidget {
  const ReportsTab({super.key});
  @override
  ConsumerState<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends ConsumerState<ReportsTab> {
  ReportTheme? _theme;
  bool _loading = true;
  Timer? _saveDebounce;
  late final ValueNotifier<double> _pdfZoom;

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
        
        // Ensure first load is not marked dirty (though dirty is gone, we clear any pending saves)
        _saveDebounce?.cancel();
      }
    });

    // Phase 1: Auto-save on every edit (Debounced to avoid lag during drags)
    ref.listenManual(activeReportTemplateProvider, (previous, next) {
      if (previous != null && previous != next) {
        _saveDebounce?.cancel();
        _saveDebounce = Timer(const Duration(milliseconds: 500), () {
          final id = ref.read(activeReportTemplateIdProvider);
          final repo = ref.read(reportTemplateRepoProvider);
          if (id != null && repo != null) {
            repo.updateTemplate(id, next);
          }
        });
      }
    });
    _pdfZoom = ValueNotifier<double>(1.0);
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _pdfZoom.dispose();
    super.dispose();
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

    return Row(
      children: [
        // Left panel: template editor
        SizedBox(
          width: 320,
          child: TemplateEditorPanel(theme: _theme),
        ),
        const VerticalDivider(width: 1),

        // Right panel: live PDF preview
        Expanded(
          child: Column(
            children: [
              // Use a stable index for children to prevent unnecessary state resets
              if (template.columns.length > 1)
                const ColumnResizer()
              else
                const SizedBox.shrink(),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  child: template.columns.isEmpty
                    ? const Center(child: Text('Add at least one column to generate a report.'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          // Base dimensions for our rendered pages
                          const baseWidth = 800.0;
                          const baseHeight = 800.0 * (11.0 / 8.5); // Letter aspect ratio

                          // Available space, minus padding and action bar
                          final availableWidth = (constraints.maxWidth - 64).clamp(100.0, double.infinity);
                          final availableHeight = (constraints.maxHeight - 112).clamp(100.0, double.infinity);

                          // Calculate zoom factors
                          final fitWidthZoom = availableWidth / baseWidth;
                          final fitHeightZoom = availableHeight / baseHeight;

                          // min: fit one full page (smaller of the two)
                          // max: fill the container (fit width)
                          var minZoom = math.min(fitWidthZoom, fitHeightZoom);
                          var maxZoom = fitWidthZoom;

                          if (minZoom >= maxZoom) {
                            maxZoom = minZoom + 0.1;
                          }

                          return PdfPreview.builder(
                            key: _pdfPreviewKey,
                            build: (format) => buildFromTemplate(
                              format,
                              fixtures,
                              template,
                              _theme ?? ReportTheme.fallback(),
                            ),
                            canChangeOrientation: false,
                            canChangePageFormat: false,
                            initialPageFormat: PdfPageFormat.letter,
                            canDebug: false,
                            actions: [
                              ValueListenableBuilder<double>(
                                valueListenable: _pdfZoom,
                                builder: (context, zoom, _) {
                                  final renderZoom = zoom.clamp(minZoom, maxZoom);
                                  return Container(
                                    width: 450,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.zoom_out, size: 16),
                                        Expanded(
                                          child: Slider(
                                            value: renderZoom,
                                            min: minZoom,
                                            max: maxZoom,
                                            onChanged: (val) {
                                              _pdfZoom.value = val;
                                            },
                                          ),
                                        ),
                                        const Icon(Icons.zoom_in, size: 16),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: 45,
                                          child: Text(
                                            '${(renderZoom * 100).toInt()}%',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                            pagesBuilder: (context, pages) {
                              return ValueListenableBuilder<double>(
                                valueListenable: _pdfZoom,
                                builder: (context, zoom, _) {
                                  final renderZoom = zoom.clamp(minZoom, maxZoom);
                                  return LayoutBuilder(
                                    builder: (context, innerConstraints) {
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            constraints: BoxConstraints(
                                              minWidth: innerConstraints.maxWidth,
                                              minHeight: innerConstraints.maxHeight,
                                            ),
                                            alignment: Alignment.center,
                                            child: Padding(
                                              padding: const EdgeInsets.all(32.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: pages.map((page) => Container(
                                                  margin: const EdgeInsets.only(bottom: 24),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.white,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 8,
                                                        offset: Offset(0, 4),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Image(
                                                    image: page.image,
                                                    width: 800 * renderZoom,
                                                  ),
                                                )).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  );
                                },
                              );
                            },
                          );
                        }
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static final GlobalKey<PdfPreviewState> _pdfPreviewKey = GlobalKey<PdfPreviewState>();
}
