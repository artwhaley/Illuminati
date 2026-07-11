import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/show_provider.dart';
import '../../services/auto_backup_service.dart';
import '../../services/backup_settings.dart';

class BackupSettingsSection extends ConsumerWidget {
  const BackupSettingsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(backupSettingsProvider);
    final session = ref.watch(showSessionProvider);
    final path = session == null
        ? null
        : AutoBackupService(
            database: session.database,
            sourcePath: session.path,
            settings: settings,
          ).backupDirectory;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('DATA SAFETY', style: Theme.of(context).textTheme.labelLarge),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Automatic backups'),
          value: settings.enabled,
          onChanged: (value) =>
              ref.read(backupSettingsProvider.notifier).setEnabled(value),
        ),
        DropdownButtonFormField<int>(
          value: settings.intervalMinutes,
          decoration: const InputDecoration(labelText: 'Backup interval'),
          items: BackupSettings.intervals
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text('$value minutes'),
                ),
              )
              .toList(),
          onChanged: settings.enabled
              ? (value) {
                  if (value != null)
                    ref
                        .read(backupSettingsProvider.notifier)
                        .setInterval(value);
                }
              : null,
        ),
        const SizedBox(height: 8),
        const Text(
          'Two temporary copies are written only after changes are detected.',
        ),
        if (path != null)
          Row(
            children: [
              Expanded(
                child: Text(path, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                tooltip: 'Copy backup path',
                icon: const Icon(Icons.copy),
                onPressed: () => Clipboard.setData(ClipboardData(text: path)),
              ),
            ],
          ),
      ],
    );
  }
}
