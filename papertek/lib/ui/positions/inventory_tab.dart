import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';
import '../../providers/show_provider.dart';
import '../../repositories/fixture_type_repository.dart';

// ── Tab widget ─────────────────────────────────────────────────────────────────

class InventoryTab extends ConsumerStatefulWidget {
  const InventoryTab({super.key});

  @override
  ConsumerState<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends ConsumerState<InventoryTab> {
  final _selected = <int>{};
  final _scrollCtrl = ScrollController();
  double _toolbarPad = 8.0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_updateToolbarPad);
  }

  void _updateToolbarPad() {
    if (!mounted || !_scrollCtrl.hasClients) return;
    final t = (_scrollCtrl.offset / 280.0).clamp(0.0, 1.0);
    final newPad = 8.0 + t * 120.0;
    if ((newPad - _toolbarPad).abs() > 1.0) {
      setState(() => _toolbarPad = newPad);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Selection ────────────────────────────────────────────────────────────

  void _primaryTap(int id) {
    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    setState(() {
      if (isCtrl) {
        _toggle(id);
      } else {
        _selected
          ..clear()
          ..add(id);
      }
    });
  }

  void _secondaryTap(int id) => setState(() => _toggle(id));

  void _toggle(int id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
  }

  FixtureType? _singleSelected(List<FixtureType> types) {
    if (_selected.length == 1) {
      final id = _selected.first;
      for (final t in types) {
        if (t.id == id) return t;
      }
    }
    return null;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _addType(FixtureTypeRepository repo) async {
    final name = await _nameDialog(context,
        title: 'New Fixture Type', hint: 'Type name');
    if (name == null) return;
    final id = await repo.addType(name);
    setState(() {
      _selected.clear();
      _selected.add(id);
    });
  }

  Future<void> _deleteSelected(FixtureTypeRepository repo) async {
    if (_selected.isEmpty) return;
    final ok = await _confirmDialog(
      context,
      title: 'Delete',
      message: 'Delete ${_selected.length} fixture type(s)?\n'
          'Fixtures of these types will lose their type assignment.',
    );
    if (!ok) return;
    for (final id in _selected) {
      await repo.deleteType(id);
    }
    setState(() => _selected.clear());
  }

  Future<void> _mergeSelected(
      FixtureTypeRepository repo, List<FixtureType> types) async {
    if (_selected.length != 2) return;
    final ids = _selected.toList();
    final a = types.firstWhere((t) => t.id == ids[0]);
    final b = types.firstWhere((t) => t.id == ids[1]);

    final result = await showDialog<({int keepId, String? newName})>(
      context: context,
      builder: (_) => _MergeTypeDialog(typeA: a, typeB: b),
    );
    if (result == null) return;

    final deleteId = result.keepId == a.id ? b.id : a.id;
    await repo.mergeTypes(
      keepId: result.keepId,
      deleteId: deleteId,
      newName: result.newName,
    );
    setState(() {
      _selected.clear();
      _selected.add(result.keepId);
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(fixtureTypesProvider);
    final repo = ref.watch(fixtureTypeRepoProvider);
    final types = typesAsync.valueOrNull ?? [];
    final single = _singleSelected(types);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Tool sidebar (LEFT) ───────────────────────────────────────
        Container(
          width: 52,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: Color(0xFF23272E))),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: _toolbarPad),
                _ToolButton(
                  icon: Icons.add,
                  tooltip: 'Add Fixture Type',
                  onPressed: repo != null ? () => _addType(repo) : null,
                ),
                _ToolButton(
                  icon: Icons.delete_outline,
                  tooltip: 'Delete Selected',
                  onPressed: (repo != null && _selected.isNotEmpty)
                      ? () => _deleteSelected(repo)
                      : null,
                ),
                const Divider(indent: 8, endIndent: 8),
                _ToolButton(
                  icon: Icons.merge,
                  tooltip: 'Merge 2 Types',
                  onPressed: (repo != null && _selected.length == 2)
                      ? () => _mergeSelected(repo, types)
                      : null,
                ),
              ],
            ),
          ),
        ),

        // ── Type info panel (LEFT) ────────────────────────────────────
        _TypeInfoPanel(
          type: single,
          repo: repo,
          fetchCount: single != null && repo != null
              ? () => repo.getFixtureCount(single.id)
              : null,
        ),

        // ── Type list ─────────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: typesAsync.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : types.isEmpty
                        ? Center(
                            child: Text(
                              'No fixture types yet.\nUse + to add one.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: const Color(0xFF6B7280)),
                            ),
                          )
                        : Scrollbar(
                            controller: _scrollCtrl,
                            child: ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              itemCount: types.length,
                              itemBuilder: (_, i) => _TypeCard(
                                key: ValueKey(types[i].id),
                                type: types[i],
                                selected: _selected.contains(types[i].id),
                                onTap: () => _primaryTap(types[i].id),
                                onSecondaryTap: () =>
                                    _secondaryTap(types[i].id),
                                onRename: repo != null
                                    ? (name) =>
                                        repo.updateName(types[i].id, name)
                                    : null,
                              ),
                            ),
                          ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
                child: Text(
                  'Ctrl+click or right-click to multi-select · Double-click name to rename',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF4B5263),
                        fontSize: 10,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Type info panel ────────────────────────────────────────────────────────────

class _TypeInfoPanel extends StatefulWidget {
  const _TypeInfoPanel({
    required this.type,
    required this.repo,
    this.fetchCount,
  });

  final FixtureType? type;
  final FixtureTypeRepository? repo;
  final Future<int> Function()? fetchCount;

  @override
  State<_TypeInfoPanel> createState() => _TypeInfoPanelState();
}

class _TypeInfoPanelState extends State<_TypeInfoPanel> {
  late final TextEditingController _wattCtrl;
  late final TextEditingController _partsCtrl;
  int? _lastId;
  int? _count;

  @override
  void initState() {
    super.initState();
    _wattCtrl = TextEditingController(text: widget.type?.wattage ?? '');
    _partsCtrl = TextEditingController(
        text: widget.type != null ? '${widget.type!.partCount}' : '');
    _lastId = widget.type?.id;
    _loadCount();
  }

  @override
  void didUpdateWidget(_TypeInfoPanel old) {
    super.didUpdateWidget(old);
    final t = widget.type;
    if (t?.id != _lastId) {
      _lastId = t?.id;
      _count = null;
      _wattCtrl.text = t?.wattage ?? '';
      _partsCtrl.text = t != null ? '${t.partCount}' : '';
      _loadCount();
    } else if (t != null) {
      if (!_wattCtrl.selection.isValid) _wattCtrl.text = t.wattage ?? '';
      if (!_partsCtrl.selection.isValid) _partsCtrl.text = '${t.partCount}';
    }
  }

  void _loadCount() {
    if (widget.fetchCount == null) return;
    widget.fetchCount!().then((n) {
      if (mounted) setState(() => _count = n);
    });
  }

  @override
  void dispose() {
    _wattCtrl.dispose();
    _partsCtrl.dispose();
    super.dispose();
  }

  void _saveWattage() {
    if (widget.type == null || widget.repo == null) return;
    final v = _wattCtrl.text.trim();
    widget.repo!.updateWattage(widget.type!.id, v.isEmpty ? null : v);
  }

  void _savePartCount() {
    if (widget.type == null || widget.repo == null) return;
    final v = int.tryParse(_partsCtrl.text.trim());
    if (v != null && v > 0) {
      widget.repo!.updatePartCount(widget.type!.id, v);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasType = widget.type != null;

    return Container(
      width: 180,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF23272E))),
      ),
      padding: const EdgeInsets.all(12),
      child: hasType
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.type!.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'QTY IN SHOW',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        letterSpacing: 0.6,
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _count != null ? '$_count' : '—',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoField(
                  label: 'WATTAGE',
                  controller: _wattCtrl,
                  onSave: _saveWattage,
                ),
                const SizedBox(height: 12),
                _InfoField(
                  label: 'PART COUNT',
                  controller: _partsCtrl,
                  onSave: _savePartCount,
                  keyboardType: TextInputType.number,
                ),
              ],
            )
          : Center(
              child: Text(
                'Select a\nfixture type',
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFF4B5263),
                ),
              ),
            ),
    );
  }
}

class _InfoField extends StatelessWidget {
  const _InfoField({
    required this.label,
    required this.controller,
    required this.onSave,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      onFocusChange: (has) {
        if (!has) onSave();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF6B7280),
              letterSpacing: 0.6,
              fontSize: 9,
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: theme.textTheme.bodySmall,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF23272E), width: 1),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
            onSubmitted: (_) => onSave(),
          ),
        ],
      ),
    );
  }
}

// ── Type card ─────────────────────────────────────────────────────────────────

class _TypeCard extends StatefulWidget {
  const _TypeCard({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
    required this.onSecondaryTap,
    this.onRename,
  });

  final FixtureType type;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onSecondaryTap;
  final Future<void> Function(String)? onRename;

  @override
  State<_TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<_TypeCard> {
  bool _editing = false;
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.type.name);
  }

  @override
  void didUpdateWidget(_TypeCard old) {
    super.didUpdateWidget(old);
    if (widget.type.name != old.type.name && !_ctrl.selection.isValid) {
      _ctrl.text = widget.type.name;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _commitRename() {
    final v = _ctrl.text.trim();
    if (v.isNotEmpty && v != widget.type.name) {
      widget.onRename?.call(v);
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: widget.selected
            ? amber.withValues(alpha: 0.15)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _editing ? null : widget.onTap,
          onSecondaryTap: _editing ? null : widget.onSecondaryTap,
          onDoubleTap: widget.onRename == null
              ? null
              : () {
                  _ctrl.text = widget.type.name;
                  setState(() => _editing = true);
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _editing
                      ? CallbackShortcuts(
                          bindings: {
                            const SingleActivator(LogicalKeyboardKey.escape):
                                () => setState(() => _editing = false),
                          },
                          child: Focus(
                            onFocusChange: (has) {
                              if (!has) _commitRename();
                            },
                            child: TextField(
                              controller: _ctrl,
                              autofocus: true,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.selected ? amber : null,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _commitRename(),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.type.name,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: widget.selected ? amber : null,
                                fontWeight: widget.selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                            if (widget.type.wattage != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.type.wattage!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                if (!_editing)
                  Text(
                    '${widget.type.partCount}p',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF4B5263),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Tool button ────────────────────────────────────────────────────────────────

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: onPressed != null
          ? Theme.of(context).colorScheme.primary
          : const Color(0xFF3A3F4A),
    );
  }
}

// ── Dialogs ────────────────────────────────────────────────────────────────────

Future<String?> _nameDialog(
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

Future<bool> _confirmDialog(
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

class _MergeTypeDialog extends StatefulWidget {
  const _MergeTypeDialog({required this.typeA, required this.typeB});

  final FixtureType typeA;
  final FixtureType typeB;

  @override
  State<_MergeTypeDialog> createState() => _MergeTypeDialogState();
}

class _MergeTypeDialogState extends State<_MergeTypeDialog> {
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
