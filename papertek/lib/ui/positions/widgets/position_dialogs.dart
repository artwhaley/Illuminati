import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../position_list_item.dart';

sealed class DeleteWithFixturesResult {
  const DeleteWithFixturesResult();
}

class MergeFixturesInto extends DeleteWithFixturesResult {
  const MergeFixturesInto(this.target);
  final LightingPosition target;
}

class OrphanFixtures extends DeleteWithFixturesResult {
  const OrphanFixtures();
}

class DeleteFixturesToo extends DeleteWithFixturesResult {
  const DeleteFixturesToo();
}

Future<String?> showPositionNameDialog(
  BuildContext context, {
  required String title,
  required String hint,
  String? initial,
}) =>
    showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: title, hint: hint, initial: initial),
    );

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.hint,
    this.initial,
  });

  final String title;
  final String hint;
  final String? initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
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
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('OK'),
        ),
      ],
    );
  }
}

Future<bool> showPositionConfirmDialog(
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

class PositionRenameConflictDialog extends StatefulWidget {
  const PositionRenameConflictDialog({
    super.key,
    required this.beingRenamed,
    required this.existing,
    required this.targetName,
    required this.suggested,
  });

  final LightingPosition beingRenamed;
  final LightingPosition existing;
  final String targetName;
  final String suggested;

  @override
  State<PositionRenameConflictDialog> createState() =>
      _PositionRenameConflictDialogState();
}

class _PositionRenameConflictDialogState
    extends State<PositionRenameConflictDialog> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.suggested);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submitRename() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty) Navigator.of(context).pop(UseAlternateName(v));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final existing = widget.existing.name;
    final renaming = widget.beingRenamed.name;

    return AlertDialog(
      title: const Text('Name Already In Use'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '"${widget.targetName}" is already used by another position. '
              'Choose how to resolve this:',
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(MergeKeepExisting()),
              child: Text('Merge — keep "$existing" location data'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(MergeKeepNew()),
              child: Text('Merge — keep "$renaming" location data'),
            ),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 4),
            Text(
              'Or use a different name:',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: const Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(isDense: true),
                    onSubmitted: (_) => _submitRename(),
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton(
                    onPressed: _submitRename,
                    child: const Text('Rename'),
                  ),
                ),
              ],
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

class PositionCombineDialog extends StatefulWidget {
  const PositionCombineDialog({super.key, required this.posA, required this.posB});

  final LightingPosition posA;
  final LightingPosition posB;

  @override
  State<PositionCombineDialog> createState() => _PositionCombineDialogState();
}

class _PositionCombineDialogState extends State<PositionCombineDialog> {
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
          .pop((keepId: widget.posA.id, newName: _ctrl.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Combine Positions'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Fixtures from the discarded position will be reassigned. '
              'Which name should the combined position carry?',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pop((keepId: widget.posA.id, newName: null)),
                    child: Text(widget.posA.name),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context)
                        .pop((keepId: widget.posB.id, newName: null)),
                    child: Text(widget.posB.name),
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
                        hintText: 'New position name',
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

class PositionDeleteWithFixturesDialog extends StatefulWidget {
  const PositionDeleteWithFixturesDialog({
    super.key,
    required this.positionsWithFixtures,
    required this.availableTargets,
  });

  final List<({LightingPosition pos, int count})> positionsWithFixtures;
  final List<LightingPosition> availableTargets;

  @override
  State<PositionDeleteWithFixturesDialog> createState() =>
      _PositionDeleteWithFixturesDialogState();
}

class _PositionDeleteWithFixturesDialogState
    extends State<PositionDeleteWithFixturesDialog> {
  LightingPosition? _selectedTarget;

  @override
  void initState() {
    super.initState();
    if (widget.availableTargets.isNotEmpty) {
      _selectedTarget = _bestMatch(
        widget.availableTargets,
        widget.positionsWithFixtures.first.pos.name,
      );
    }
  }

  LightingPosition? _bestMatch(
      List<LightingPosition> targets, String referenceName) {
    if (targets.isEmpty) return null;
    return targets.reduce((best, t) {
      int sharedLength(String a, String b) {
        int i = 0;
        while (i < a.length && i < b.length && a[i] == b[i]) {
          i++;
        }
        return i;
      }

      return sharedLength(t.name, referenceName) >=
              sharedLength(best.name, referenceName)
          ? t
          : best;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall
        ?.copyWith(color: const Color(0xFF6B7280));

    return AlertDialog(
      title: const Text('Positions Have Fixtures'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('The following positions have fixtures assigned:'),
            const SizedBox(height: 8),
            ...widget.positionsWithFixtures.map(
              (e) => Text(
                '• ${e.pos.name} — ${e.count} fixture${e.count == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: const Color(0xFF6B7280)),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            if (widget.availableTargets.isNotEmpty) ...[
              Text('Move all fixtures to:', style: labelStyle),
              const SizedBox(height: 8),
              DropdownButton<LightingPosition>(
                value: _selectedTarget,
                isExpanded: true,
                items: widget.availableTargets
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedTarget = v),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: _selectedTarget == null
                    ? null
                    : () => Navigator.of(context)
                        .pop(MergeFixturesInto(_selectedTarget!)),
                child: const Text('Move Fixtures'),
              ),
              const SizedBox(height: 12),
              const Divider(),
            ],
            Text('Or leave fixtures unassigned:', style: labelStyle),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(const OrphanFixtures()),
              child: const Text('Leave as Unassigned'),
            ),
            Text(
              '(fixtures remain in the show but have no position)',
              style: labelStyle?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Divider(),
            Text('Or remove them entirely:', style: labelStyle),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop(const DeleteFixturesToo()),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
              child: const Text('Delete Fixtures Too'),
            ),
            Text(
              '(permanently deletes the fixture records)',
              style: labelStyle?.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
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
