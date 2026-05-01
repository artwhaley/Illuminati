// ── venue_dialogs.dart ────────────────────────────────────────────────────────
//
// Shared dialogs for adding and deleting venue items (channels, addresses,
// dimmers, circuits).
//
// Public surface:
//   _nameDialog()     — prompts for a name, returns it or null
//   _confirmDelete()  — asks the user to confirm a delete action
//
// All items in this file are private (underscore prefix), used only within
// the venue/ sub-package.

import 'package:flutter/material.dart';

Future<String?> venueNameDialog(BuildContext context,
        {required String title, required String hint}) =>
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
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Required' : null,
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

Future<bool> venueConfirmDelete(BuildContext context, String itemType) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete'),
      content: Text('Delete this $itemType?'),
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
