import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/show_provider.dart';

class ShowFileActions extends ConsumerWidget {
  const ShowFileActions({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(currentShowPathProvider);
    if (path == null) return const SizedBox.shrink();
    Future<void> saveAs() async {
      final selected = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Show As',
        fileName: path.split(RegExp(r'[\\/]')).last,
        allowedExtensions: ['papertek'],
        type: FileType.custom,
        lockParentWindow: true,
      );
      if (selected == null || !context.mounted) return;
      final destination = selected.toLowerCase().endsWith('.papertek')
          ? selected
          : '$selected.papertek';
      try {
        await ref.read(showSessionProvider.notifier).saveAs(destination);
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Saved As $destination')));
      } catch (error) {
        if (context.mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Save As failed: $error')));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Tooltip(
              message: path,
              child: Text(path, overflow: TextOverflow.ellipsis),
            ),
          ),
          TextButton.icon(
            onPressed: saveAs,
            icon: const Icon(Icons.save_as),
            label: const Text('Save As...'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => ref.read(showSessionProvider.notifier).closeShow(),
            icon: const Icon(Icons.close),
            label: const Text('Close Show'),
          ),
        ],
      ),
    );
  }
}
