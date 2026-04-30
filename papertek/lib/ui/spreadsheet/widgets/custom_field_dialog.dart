import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/custom_field_repository.dart';
import '../../../providers/show_provider.dart';

class CustomFieldManagerDialog extends ConsumerStatefulWidget {
  const CustomFieldManagerDialog({super.key});

  @override
  ConsumerState<CustomFieldManagerDialog> createState() => _CustomFieldManagerDialogState();
}

class _CustomFieldManagerDialogState extends ConsumerState<CustomFieldManagerDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addField() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final repo = ref.read(customFieldRepoProvider);
    if (repo == null) return;

    await repo.createField(name: name);
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(customFieldsProvider).valueOrNull ?? [];
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Manage Custom Fields'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Field Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'New Field Name (e.g. Weight)',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addField(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addField,
                  icon: const Icon(Icons.add_circle),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            // List of existing fields
            if (fields.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('No custom fields yet.', style: TextStyle(fontStyle: FontStyle.italic)),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: fields.length,
                  itemBuilder: (context, index) {
                    final f = fields[index];
                    return ListTile(
                      title: Text(f.name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => ref.read(customFieldRepoProvider)?.deleteField(f.id),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
