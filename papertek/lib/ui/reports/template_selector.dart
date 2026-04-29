import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/show_provider.dart';
import '../../repositories/report_template_repository.dart';

class TemplateSelector extends ConsumerStatefulWidget {
  const TemplateSelector({super.key});
  @override
  ConsumerState<TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends ConsumerState<TemplateSelector> {
  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(reportTemplatesProvider).valueOrNull ?? [];
    final repo = ref.read(reportTemplateRepoProvider);
    final notifier = ref.read(activeReportTemplateProvider.notifier);
    final currentTemplate = ref.watch(activeReportTemplateProvider);
    final selectedId = ref.watch(activeReportTemplateIdProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<int>(
            value: selectedId,
            decoration: InputDecoration(
              labelText: 'Template',
              isDense: true,
              border: const OutlineInputBorder(),
              labelStyle: GoogleFonts.jetBrainsMono(fontSize: 12),
            ),
            items: templates.map((t) =>
              DropdownMenuItem(
                value: t.id, 
                child: Text(t.name, style: GoogleFonts.jetBrainsMono(fontSize: 12)),
              ),
            ).toList(),
            onChanged: (id) {
              if (id == null) return;
              ref.read(activeReportTemplateIdProvider.notifier).state = id;
              final row = templates.firstWhere((t) => t.id == id);
              final template = ReportTemplateRepository.parseTemplate(row);
              notifier.loadTemplate(template);
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save, size: 14),
                  label: const Text('Save'),
                  onPressed: selectedId == null ? null : () {
                    repo?.updateTemplate(selectedId, currentTemplate);
                  },
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.save_as, size: 14),
                  label: const Text('Save As'),
                  onPressed: () async {
                    final name = await _showNameDialog(context, currentTemplate.name);
                    if (name != null && name.isNotEmpty) {
                      final newTemplate = currentTemplate.copyWith(name: name);
                      notifier.setName(name);
                      final id = await repo?.createTemplate(name, newTemplate);
                      if (id != null) ref.read(activeReportTemplateIdProvider.notifier).state = id;
                    }
                  },
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: selectedId == null ? null : () async {
                  final selected = templates.firstWhere((t) => t.id == selectedId);
                  if (selected.isSystem == 1) return;
                  
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Template?'),
                      content: Text('Are you sure you want to delete "${selected.name}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  
                  if (confirm == true) {
                    await repo?.deleteTemplate(selectedId);
                    ref.read(activeReportTemplateIdProvider.notifier).state = null;
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> _showNameDialog(BuildContext context, String defaultName) {
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Template As'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Template Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text('Save')),
        ],
      ),
    );
  }
}
