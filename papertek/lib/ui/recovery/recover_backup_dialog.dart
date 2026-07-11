import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../providers/show_provider.dart';
import '../../services/sqlite_snapshot_service.dart';

class RecoverBackupDialog extends ConsumerStatefulWidget {
  const RecoverBackupDialog({super.key});
  @override
  ConsumerState<RecoverBackupDialog> createState() =>
      _RecoverBackupDialogState();
}

class _RecoverBackupDialogState extends ConsumerState<RecoverBackupDialog> {
  List<_BackupChoice> choices = [];
  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final root = Directory(
      p.join(Directory.systemTemp.path, 'papertek', 'backups'),
    );
    final found = <_BackupChoice>[];
    if (root.existsSync())
      for (final dir in root.listSync().whereType<Directory>()) {
        final manifest = File(p.join(dir.path, 'manifest.json'));
        if (!manifest.existsSync()) continue;
        try {
          final json = jsonDecode(manifest.readAsStringSync()) as Map;
          final source = json['sourcePath']?.toString() ?? '';
          for (final slot in ['a', 'b']) {
            final file = File(p.join(dir.path, 'backup-$slot.papertek'));
            if (file.existsSync())
              found.add(
                _BackupChoice(file.path, slot, source, file.lengthSync()),
              );
          }
        } catch (_) {}
      }
    setState(() => choices = found);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Recover Backup'),
    content: SizedBox(
      width: 560,
      child: choices.isEmpty
          ? const Text('No valid backups are available.')
          : ListView(
              shrinkWrap: true,
              children: choices
                  .map(
                    (choice) => ListTile(
                      title: Text(
                        '${choice.slot.toUpperCase()}  ${choice.bytes} bytes',
                      ),
                      subtitle: Text(choice.source),
                      trailing: FilledButton(
                        onPressed: () => _recover(choice),
                        child: const Text('Recover'),
                      ),
                    ),
                  )
                  .toList(),
            ),
    ),
    actions: [
      TextButton(onPressed: _refresh, child: const Text('Refresh')),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ],
  );
  Future<void> _recover(_BackupChoice choice) async {
    final selected = await FilePicker.platform.saveFile(
      dialogTitle: 'Recover To',
      fileName: 'recovered.papertek',
      allowedExtensions: ['papertek'],
      type: FileType.custom,
      lockParentWindow: true,
    );
    if (selected == null || !mounted) return;
    final destination = selected.toLowerCase().endsWith('.papertek')
        ? selected
        : '$selected.papertek';
    try {
      await const SqliteSnapshotService().snapshot(choice.path, destination);
      await ref.read(showSessionProvider.notifier).openShow(destination);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Recovery failed: $error')));
    }
  }
}

class _BackupChoice {
  const _BackupChoice(this.path, this.slot, this.source, this.bytes);
  final String path, slot, source;
  final int bytes;
}
