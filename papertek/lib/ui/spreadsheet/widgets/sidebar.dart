/// The property inspector sidebar for the spreadsheet. 
/// Contains CRUD actions (Add/Delete) and the [PropertiesPanel].
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../database/database.dart';
import '../../../repositories/fixture_repository.dart';
import '../column_spec.dart';
import '../fixture_draft.dart';

class SpreadsheetSidebar extends StatelessWidget {
  const SpreadsheetSidebar({
    super.key,
    required this.theme,
    required this.selected,       // FixtureRow? — the currently selected fixture (or donor)
    required this.isAddMode,      // bool — whether add mode is active
    required this.addDraft,       // FixtureDraft? — the draft being composed
    required this.continueAdding, // bool
    required this.copySelected,   // bool
    required this.lastEditedAddField, // String?
    required this.onEnterAddMode, // VoidCallback — toggle into add mode
    required this.onCancelAddMode,// VoidCallback
    required this.onSubmitAdd,    // VoidCallback — fires ADD FIXTURE
    required this.onContinueAddingChanged, // ValueChanged<bool>
    required this.onCopySelectedChanged,   // ValueChanged<bool>
    required this.onDraftEdit,    // void Function(String fieldId, String? value)
    required this.onDelete,       // VoidCallback
    required this.onEdit,         // Future<void> Function(String col, String? value)
  });

  final ThemeData theme;
  final FixtureRow? selected;
  final bool isAddMode;
  final FixtureDraft? addDraft;
  final bool continueAdding;
  final bool copySelected;
  final String? lastEditedAddField;
  final VoidCallback onEnterAddMode;
  final VoidCallback onCancelAddMode;
  final VoidCallback onSubmitAdd;
  final ValueChanged<bool> onContinueAddingChanged;
  final ValueChanged<bool> onCopySelectedChanged;
  final void Function(String fieldId, String? value) onDraftEdit;
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
              // Top toggle button
              if (!isAddMode) ...[
                FilledButton.icon(
                  onPressed: onEnterAddMode,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Fixture'),
                  style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: copySelected,
                        visualDensity: VisualDensity.compact,
                        onChanged: (v) => onCopySelectedChanged(v ?? false),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Copy selected', 
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
                      )),
                  ],
                ),
              ] else
                OutlinedButton.icon(
                  onPressed: onCancelAddMode,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancel Add'),
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              const SizedBox(height: 6),
              // Delete button — hidden in add mode
              if (!isAddMode)
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
                          : theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),

        // Add mode header banner
        if (isAddMode) _AddModeHeader(theme: theme),

        // Main content panel
        Expanded(
          child: isAddMode
              ? _DraftEditorPanel(
                  theme: theme,
                  draft: addDraft ?? FixtureDraft(),
                  lastEditedField: lastEditedAddField,
                  onEdit: onDraftEdit,
                  onSubmit: onSubmitAdd,
                )
              : PropertiesPanel(
                  theme: theme,
                  fixture: selected,
                  onEdit: onEdit,
                ),
        ),

        // Add mode footer
        if (isAddMode) _AddModeFooter(
          theme: theme,
          continueAdding: continueAdding,
          onSubmit: onSubmitAdd,
          onContinueChanged: onContinueAddingChanged,
        ),
      ],
    );
  }
}

class _AddModeHeader extends StatelessWidget {
  const _AddModeHeader({required this.theme});
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.edit_note, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'ADD FIXTURE MODE',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddModeFooter extends StatelessWidget {
  const _AddModeFooter({
    required this.theme,
    required this.continueAdding,
    required this.onSubmit,
    required this.onContinueChanged,
  });

  final ThemeData theme;
  final bool continueAdding;
  final VoidCallback onSubmit;
  final ValueChanged<bool> onContinueChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: onSubmit,
            child: const Text('ADD FIXTURE'),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Checkbox(
                value: continueAdding,
                visualDensity: VisualDensity.compact,
                onChanged: (v) => onContinueChanged(v ?? false),
              ),
              Text('Continue adding',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftEditorPanel extends StatefulWidget {
  const _DraftEditorPanel({
    required this.theme,
    required this.draft,
    required this.lastEditedField,
    required this.onEdit,
    required this.onSubmit,
  });

  final ThemeData theme;
  final FixtureDraft draft;
  final String? lastEditedField;
  final void Function(String fieldId, String? value) onEdit;
  final VoidCallback onSubmit;

  @override
  State<_DraftEditorPanel> createState() => _DraftEditorPanelState();
}

class _DraftEditorPanelState extends State<_DraftEditorPanel> {
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void dispose() {
    for (final node in _focusNodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  FocusNode _getNode(String id) {
    return _focusNodes.putIfAbsent(id, () => FocusNode());
  }

  String? _draftValue(String colId) {
    return switch (colId) {
      'chan'        => widget.draft.channel,
      'dimmer'      => widget.draft.dimmer,
      'circuit'     => widget.draft.circuit,
      'position'    => widget.draft.position,
      'unit'        => widget.draft.unitNumber?.toString(),
      'type'        => widget.draft.fixtureType,
      'function'    => widget.draft.function,
      'focus'       => widget.draft.focus,
      'accessories' => widget.draft.accessories,
      'ip'          => widget.draft.ipAddress,
      'subnet'      => widget.draft.subnet,
      'mac'         => widget.draft.macAddress,
      'ipv6'        => widget.draft.ipv6,
      _             => null,
    };
  }

  @override
  void didUpdateWidget(_DraftEditorPanel old) {
    super.didUpdateWidget(old);
    // If the draft was advanced (after insert), restore focus to the last edited field.
    if (old.draft != widget.draft && widget.lastEditedField != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[widget.lastEditedField]?.requestFocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <ColumnSection, List<ColumnSpec>>{};
    for (final spec in kColumns) {
      if (spec.isReadOnly || spec.isBoolean || spec.id == '#') continue;
      grouped.putIfAbsent(spec.section, () => []).add(spec);
    }

    final sectionOrder = [
      ColumnSection.patch, ColumnSection.fixture,
      ColumnSection.network, ColumnSection.other,
    ];

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        for (final section in sectionOrder)
          if (grouped.containsKey(section)) ...[
            _section(section.name.toUpperCase()),
            for (final spec in grouped[section]!)
              PropertyEditRow(
                key: ValueKey('draft-${spec.id}'),
                label: spec.label,
                value: _draftValue(spec.id),
                theme: widget.theme,
                focusNode: _getNode(spec.id),
                onSubmit: (v) => widget.onEdit(spec.id, v),
                onEnterPressed: widget.onSubmit,
                accent: spec.id == 'chan',
              ),
            Divider(height: 16, color: widget.theme.colorScheme.outlineVariant),
          ],
      ],
    );
  }

  Widget _section(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(label, style: widget.theme.textTheme.labelSmall?.copyWith(
        color: widget.theme.colorScheme.onSurfaceVariant, letterSpacing: 0.8)),
  );
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
    this.onEnterPressed,
    this.focusNode,
  });

  final String label;
  final String? value;
  final ThemeData theme;
  final void Function(String?) onSubmit;
  final VoidCallback? onEnterPressed;
  final FocusNode? focusNode;
  final bool accent;

  @override
  State<PropertyEditRow> createState() => _PropertyEditRowState();
}

class _PropertyEditRowState extends State<PropertyEditRow> {
  late TextEditingController _ctrl;
  late FocusNode _internalFocus;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value ?? '');
    _internalFocus = widget.focusNode ?? FocusNode();
    _internalFocus.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(PropertyEditRow old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !_internalFocus.hasFocus) {
      _ctrl.text = widget.value ?? '';
    }
    if (old.focusNode != widget.focusNode) {
       _internalFocus.removeListener(_onFocusChange);
       if (old.focusNode == null) _internalFocus.dispose();
       _internalFocus = widget.focusNode ?? FocusNode();
       _internalFocus.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _internalFocus.removeListener(_onFocusChange);
    if (widget.focusNode == null) _internalFocus.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_internalFocus.hasFocus) _submit();
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
                focusNode: _internalFocus,
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
                onSubmitted: (_) {
                   _submit();
                   widget.onEnterPressed?.call();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
