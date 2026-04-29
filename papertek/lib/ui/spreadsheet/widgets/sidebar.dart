/// The property inspector sidebar for the spreadsheet. 
/// Contains CRUD actions (Add/Clone/Delete) and the [PropertiesPanel].
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../database/database.dart';
import '../../../repositories/fixture_repository.dart';

class SpreadsheetSidebar extends StatelessWidget {
  const SpreadsheetSidebar({
    super.key,
    required this.theme,
    required this.selected,
    required this.canClone,
    required this.onAdd,
    required this.onClone,
    required this.onDelete,
    required this.onEdit,
  });

  final ThemeData theme;
  final FixtureRow? selected;
  final bool canClone;
  final VoidCallback onAdd;
  final VoidCallback onClone;
  final VoidCallback onDelete;
  final Future<void> Function(String col, String? value) onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Fixture'),
                style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: canClone ? onClone : null,
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('Clone Fixture'),
                style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
              ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                onPressed: selected != null ? onDelete : null,
                icon: Icon(Icons.delete_outline, size: 16,
                    color: selected != null ? theme.colorScheme.error : null),
                label: const Text('Delete Fixture'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(
                      color: selected != null
                          ? theme.colorScheme.error.withValues(alpha: 0.5)
                          : theme.colorScheme.outlineVariant),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        Expanded(
          child: PropertiesPanel(
            theme: theme,
            fixture: selected,
            onEdit: onEdit,
          ),
        ),
      ],
    );
  }
}

class PropertiesPanel extends StatelessWidget {
  const PropertiesPanel({
    super.key,
    required this.theme,
    required this.fixture,
    required this.onEdit,
  });

  final ThemeData theme;
  final FixtureRow? fixture;
  final Future<void> Function(String col, String? value) onEdit;

  @override
  Widget build(BuildContext context) {
    final f = fixture;
    if (f == null) {
      return Center(
        child: Text('No fixture\nselected',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        _section('PATCH'),
        PropertyEditRow(
          key: ValueKey('chan-${f.id}'),
          label: 'Channel',
          value: f.channel,
          accent: true,
          theme: theme,
          onSubmit: (v) => onEdit('chan', v),
        ),
        PropertyReadRow(label: 'Address', value: f.dimmer, theme: theme),
        PropertyReadRow(label: 'Circuit', value: f.circuit, theme: theme),
        _divider(),
        _section('FIXTURE'),
        PropertyEditRow(
          key: ValueKey('pos-${f.id}'),
          label: 'Position',
          value: f.position,
          theme: theme,
          onSubmit: (v) => onEdit('position', v),
        ),
        PropertyEditRow(
          key: ValueKey('unit-${f.id}'),
          label: 'Unit #',
          value: f.unitNumber?.toString(),
          theme: theme,
          onSubmit: (v) => onEdit('unit', v),
        ),
        PropertyEditRow(
          key: ValueKey('type-${f.id}'),
          label: 'Type',
          value: f.fixtureType,
          theme: theme,
          onSubmit: (v) => onEdit('type', v),
        ),
        PropertyEditRow(
          key: ValueKey('func-${f.id}'),
          label: 'Purpose',
          value: f.function,
          theme: theme,
          onSubmit: (v) => onEdit('function', v),
        ),
        PropertyEditRow(
          key: ValueKey('focus-${f.id}'),
          label: 'Focus Area',
          value: f.focus,
          theme: theme,
          onSubmit: (v) => onEdit('focus', v),
        ),
        PropertyEditRow(
          key: ValueKey('acc-${f.id}'),
          label: 'Accessories',
          value: f.accessories,
          theme: theme,
          onSubmit: (v) => onEdit('accessories', v),
        ),
        _divider(),
        _section('NETWORK'),
        PropertyEditRow(
          key: ValueKey('ip-${f.id}'),
          label: 'IP',
          value: f.ipAddress,
          theme: theme,
          onSubmit: (v) => onEdit('ip', v),
        ),
        PropertyEditRow(
          key: ValueKey('sub-${f.id}'),
          label: 'Subnet',
          value: f.subnet,
          theme: theme,
          onSubmit: (v) => onEdit('subnet', v),
        ),
        PropertyEditRow(
          key: ValueKey('mac-${f.id}'),
          label: 'MAC',
          value: f.macAddress,
          theme: theme,
          onSubmit: (v) => onEdit('mac', v),
        ),
        PropertyEditRow(
          key: ValueKey('ipv6-${f.id}'),
          label: 'IPv6',
          value: f.ipv6,
          theme: theme,
          onSubmit: (v) => onEdit('ipv6', v),
        ),
        _divider(),
        _section('STATUS'),
        PropertyReadRow(
          label: 'Patched',
          value: f.patched ? 'Yes' : 'No',
          valueColor: f.patched ? Colors.green : null,
          theme: theme,
        ),
        PropertyReadRow(
          label: 'Hung',
          value: f.hung ? 'Yes' : 'No',
          valueColor: f.hung ? Colors.green : null,
          theme: theme,
        ),
        PropertyReadRow(
          label: 'Focused',
          value: f.focused ? 'Yes' : 'No',
          valueColor: f.focused ? Colors.green : null,
          theme: theme,
        ),
        PropertyReadRow(
          label: 'Flagged',
          value: f.flagged ? 'Yes' : 'No',
          valueColor: f.flagged ? theme.colorScheme.primary : null,
          theme: theme,
        ),
      ],
    );
  }

  Widget _divider() =>
      Divider(height: 16, color: theme.colorScheme.outlineVariant);

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant, letterSpacing: 0.8)),
      );
}

class PropertyReadRow extends StatelessWidget {
  const PropertyReadRow({
    super.key,
    required this.label,
    required this.value,
    required this.theme,
    this.accent = false,
    this.valueColor,
  });

  final String label;
  final String? value;
  final ThemeData theme;
  final bool accent;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final vc = valueColor ??
        (accent ? theme.colorScheme.primary : theme.colorScheme.onSurface);
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value ?? '—',
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.jetBrainsMono(fontSize: 12, color: vc)),
          ),
        ],
      ),
    );
  }
}

class PropertyEditRow extends StatefulWidget {
  const PropertyEditRow({
    super.key,
    required this.label,
    required this.value,
    required this.theme,
    required this.onSubmit,
    this.accent = false,
  });

  final String label;
  final String? value;
  final ThemeData theme;
  final void Function(String?) onSubmit;
  final bool accent;

  @override
  State<PropertyEditRow> createState() => _PropertyEditRowState();
}

class _PropertyEditRowState extends State<PropertyEditRow> {
  late TextEditingController _ctrl;
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
    _focus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(PropertyEditRow old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_focus.hasFocus) {
      _ctrl.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focus.hasFocus) _submit();
  }

  void _submit() {
    final val = _ctrl.text.trim();
    widget.onSubmit(val.isEmpty ? null : val);
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent
        ? widget.theme.colorScheme.primary
        : widget.theme.colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(widget.label,
                style: widget.theme.textTheme.labelSmall?.copyWith(
                    color: widget.theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            child: SizedBox(
              height: 24,
              child: TextField(
                controller: _ctrl,
                focusNode: _focus,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 12, color: accent),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  filled: true,
                  fillColor:
                      widget.theme.colorScheme.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                        color: widget.theme.colorScheme.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide: BorderSide(
                        color: widget.theme.colorScheme.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(3),
                    borderSide:
                        BorderSide(color: widget.theme.colorScheme.primary),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
