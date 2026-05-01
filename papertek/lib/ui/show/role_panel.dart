// -- role_panel.dart ----------------------------------------------------------
//
// Editable contact-role row used by the show info panel.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../repositories/role_contact_repository.dart';
import '../contact_card_dialog.dart';

// Built-in role labels that can be overridden by per-show custom labels.
const _defaultLabels = {
  RoleKey.designer: 'Lighting Designer',
  RoleKey.asstDesigner: 'Asst. Lighting Designer',
  RoleKey.masterElectrician: 'Master Electrician',
  RoleKey.producer: 'Producer',
  RoleKey.asstMasterElectrician: 'Asst. Master Electrician',
  RoleKey.stageManager: 'Stage Manager',
};

class RolePanel extends ConsumerStatefulWidget {
  const RolePanel({
    required this.roleKey,
    required this.customLabel,
    required this.value,
    required this.onSaveValue,
    required this.onSaveLabel,
  });

  final String roleKey;

  /// Stored custom label override, or null if using the built-in default.
  final String? customLabel;

  /// Current person name value from show_meta.
  final String? value;
  final Future<void> Function(String) onSaveValue;

  /// Called with null to reset to default, or a non-empty string to override.
  final Future<void> Function(String?) onSaveLabel;

  @override
  ConsumerState<RolePanel> createState() => _RolePanelState();
}

class _RolePanelState extends ConsumerState<RolePanel> {
  bool _editingLabel = false;
  late final TextEditingController _labelCtrl;
  late final TextEditingController _valueCtrl;
  late String _lastSavedValue;

  // Built-in labels live in _defaultLabels and are overridden by customLabel when set.
  String get _displayLabel => widget.customLabel ?? _defaultLabels[widget.roleKey]!;

  @override
  void initState() {
    super.initState();
    _lastSavedValue = widget.value ?? '';
    _valueCtrl = TextEditingController(text: _lastSavedValue);
    _labelCtrl = TextEditingController();
  }

  @override
  void didUpdateWidget(RolePanel old) {
    super.didUpdateWidget(old);
    // Keep value in sync when the stream updates (without clobbering focused input).
    final incoming = widget.value ?? '';
    if (incoming != _lastSavedValue && !_valueCtrl.selection.isValid) {
      _lastSavedValue = incoming;
      _valueCtrl.text = incoming;
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  void _startEditingLabel() {
    // Pre-fill with the current custom value (empty = using default).
    _labelCtrl.text = widget.customLabel ?? '';
    setState(() => _editingLabel = true);
  }

  void _saveLabel() {
    final v = _labelCtrl.text.trim();
    // Empty string means "reset to default".
    widget.onSaveLabel(v.isEmpty ? null : v);
    setState(() => _editingLabel = false);
  }

  void _cancelLabelEdit() {
    setState(() => _editingLabel = false);
  }

  void _saveValue() {
    final v = _valueCtrl.text.trim();
    if (v == _lastSavedValue) return;
    _lastSavedValue = v;
    widget.onSaveValue(v);
  }

  void _openContactCard() {
    showDialog<void>(
      context: context,
      builder: (_) => ContactCardDialog(
        roleKey: widget.roleKey,
        roleLabel: _displayLabel,
        personName: widget.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = theme.colorScheme.onSurfaceVariant;
    final isCustom = widget.customLabel != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Label row ----------------------------------------------------
        if (_editingLabel)
          Row(
            children: [
              Expanded(
                child: CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape):
                        _cancelLabelEdit,
                  },
                  child: Focus(
                    onFocusChange: (has) {
                      if (!has) _saveLabel();
                    },
                    child: TextField(
                      controller: _labelCtrl,
                      autofocus: true,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 0.6,
                      ),
                      decoration: InputDecoration(
                        hintText: _defaultLabels[widget.roleKey],
                        hintStyle: theme.textTheme.labelSmall?.copyWith(
                          color: labelColor.withValues(alpha: 0.5),
                          letterSpacing: 0.6,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: theme.colorScheme.primary, width: 1),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        suffixText: '  (Enter to save . Esc to cancel)',
                        suffixStyle: theme.textTheme.labelSmall?.copyWith(
                          color: labelColor.withValues(alpha: 0.8),
                          fontSize: 9,
                        ),
                      ),
                      onSubmitted: (_) => _saveLabel(),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          GestureDetector(
            onDoubleTap: _startEditingLabel,
            child: MouseRegion(
              cursor: SystemMouseCursors.text,
              child: Row(
                children: [
                  Text(
                    _displayLabel.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCustom
                          ? theme.colorScheme.primary.withValues(alpha: 0.8)
                          : labelColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: 'Double-click to customise label',
                    child: Icon(
                      Icons.edit,
                      size: 9,
                      color: labelColor.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 3),

        // -- Value row (name field + contact button) -----------------------
        Focus(
          onFocusChange: (has) {
            if (!has) _saveValue();
          },
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _valueCtrl,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          const BorderSide(color: Color(0xFF23272E), width: 1),
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
                  onSubmitted: (_) => _saveValue(),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Contact info',
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: _openContactCard,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.badge_outlined,
                      size: 16,
                      color: labelColor.withValues(alpha: 0.6),
                    ),
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


