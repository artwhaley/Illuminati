// -- inventory_dialogs.dart ----------------------------------------------------
//
// Dialogs used by the Inventory tab.

import 'package:flutter/material.dart';
import '../../../database/database.dart';

Future<String?> inventoryNameDialog(
  BuildContext context, {
  required String title,
  required String hint,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: title, hint: hint),
    );

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_ctrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _ctrl,
          decoration: InputDecoration(labelText: widget.hint),
          autofocus: true,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('OK')),
      ],
    );
  }
}

Future<bool> inventoryConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class MergeTypeDialog extends StatefulWidget {
  const MergeTypeDialog({required this.typeA, required this.typeB});

  final FixtureType typeA;
  final FixtureType typeB;

  @override
  State<MergeTypeDialog> createState() => _MergeTypeDialogState();
}

class _MergeTypeDialogState extends State<MergeTypeDialog> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _useCustomName() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context)
          .pop((keepId: widget.typeA.id, newName: _ctrl.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Merge Fixture Types'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Fixtures of the removed type will be reassigned. '
              'Which name should the merged type carry?',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pop((keepId: widget.typeA.id, newName: null)),
                    child: Text(widget.typeA.name),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pop((keepId: widget.typeB.id, newName: null)),
                    child: Text(widget.typeB.name),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 4),
            Text(
              'Or enter a new name:',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'New type name',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                      onFieldSubmitted: (_) => _useCustomName(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: FilledButton(
                      onPressed: _useCustomName,
                      child: const Text('Use'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
