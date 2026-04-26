import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/show_provider.dart';

class StartScreen extends ConsumerWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PaperTek',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Theatrical Lighting Data Manager',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              FilledButton(
                onPressed: () => _newShow(context, ref),
                child: const Text('New Show'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _openShow(context, ref),
                child: const Text('Open Show'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _newShow(BuildContext context, WidgetRef ref) async {
    final showName = await showDialog<String>(
      context: context,
      builder: (_) => const _NewShowDialog(),
    );
    if (showName == null || !context.mounted) return;

    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Show File',
      fileName: '$showName.papertek',
      allowedExtensions: ['papertek'],
      type: FileType.custom,
      lockParentWindow: true,
    );
    if (savePath == null || !context.mounted) return;

    final path =
        savePath.endsWith('.papertek') ? savePath : '$savePath.papertek';

    try {
      final db = await ref
          .read(showFileServiceProvider)
          .createShow(path, showName: showName);
      ref.read(databaseProvider.notifier).state = db;
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Could not create show:\n$e');
    }
  }

  Future<void> _openShow(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Open Show File',
      allowedExtensions: ['papertek'],
      type: FileType.custom,
      lockParentWindow: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;

    final path = result.files.single.path!;
    try {
      final (db, error) =
          await ref.read(showFileServiceProvider).openShow(path);
      if (!context.mounted) return;
      if (error != null) {
        _showError(context, error);
      } else if (db != null) {
        ref.read(databaseProvider.notifier).state = db;
      }
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Could not open show:\n$e');
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _NewShowDialog extends StatefulWidget {
  const _NewShowDialog();

  @override
  State<_NewShowDialog> createState() => _NewShowDialogState();
}

class _NewShowDialogState extends State<_NewShowDialog> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Show'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 320,
          child: TextFormField(
            controller: _ctrl,
            decoration: const InputDecoration(labelText: 'Show Name'),
            autofocus: true,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Next'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_ctrl.text.trim());
  }
}
