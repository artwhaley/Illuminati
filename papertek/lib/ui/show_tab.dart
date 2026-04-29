import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../providers/show_provider.dart';
import '../repositories/show_meta_repository.dart';
import '../repositories/role_contact_repository.dart';
import 'contact_card_dialog.dart';
import 'positions/lighting_positions_tab.dart';
import 'positions/inventory_tab.dart';
import 'positions/venue_tabs.dart';

// ── Default labels for the six named roles ─────────────────────────────────────
// These are the strings shown when no custom override is stored.
const _defaultLabels = {
  RoleKey.designer: 'Lighting Designer',
  RoleKey.asstDesigner: 'Asst. Lighting Designer',
  RoleKey.masterElectrician: 'Master Electrician',
  RoleKey.producer: 'Producer',
  RoleKey.asstMasterElectrician: 'Asst. Master Electrician',
  RoleKey.stageManager: 'Stage Manager',
};

// ── Root widget ────────────────────────────────────────────────────────────────

class ShowTab extends ConsumerWidget {
  const ShowTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(currentShowMetaProvider);
    final repo = ref.watch(showMetaRepoProvider);
    return meta.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (row) {
        if (row == null || repo == null) {
          return const Center(child: Text('No show data found.'));
        }
        return _ShowTabBody(row: row, repo: repo);
      },
    );
  }
}

// ── Body ───────────────────────────────────────────────────────────────────────
//
// Layout approach: LayoutBuilder → SingleChildScrollView → Column.
//   • Info card  — natural height inside the scrollable Column.
//   • Venue card — SizedBox(height: constraints.maxHeight): the LayoutBuilder
//     captures the available viewport height and forces the venue card to that
//     exact height. This gives _VenuePanel a BOUNDED constraint so Column+Expanded
//     propagates correctly through _VenuePanel → IndexedStack → LightingPositionsTab
//     → ReorderableListView.
//
// Total column height = infoCard.height + viewportHeight, so the page scrolls
// exactly far enough to hide the info card and let the venue card fill the window.
//
// SliverFillRemaining was tried and abandoned: it queries the child's intrinsic
// height first (Column+Expanded → 0), causing a NEEDS-LAYOUT dead-lock when
// actual list items exist inside the venue card.

class _ShowTabBody extends StatelessWidget {
  const _ShowTabBody({required this.row, required this.repo});

  final ShowMetaData row;
  final ShowMetaRepository repo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceContainerLow;
    final borderColor = theme.colorScheme.outlineVariant;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                child: _ShowInfoPanel(row: row, repo: repo),
              ),
            ),
            SizedBox(
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const _VenuePanel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Show Info panel ────────────────────────────────────────────────────────────

class _ShowInfoPanel extends StatelessWidget {
  const _ShowInfoPanel({required this.row, required this.repo});

  final ShowMetaData row;
  final ShowMetaRepository repo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Playbill heading — constrained & centered ────────────────────
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _PlaybillField(
                  value: row.showName,
                  style: theme.textTheme.headlineLarge!.copyWith(
                    color: amber,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  hint: 'Show Title',
                  autoSize: true,
                  onSave: (v) => repo.updateShowName(row.id, v),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: _PlaybillField(
                    value: row.company,
                    style: theme.textTheme.titleMedium!,
                    hint: 'Production Company',
                    onSave: (v) =>
                        repo.updateCompany(row.id, v.isEmpty ? null : v),
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 390),
                  child: _PlaybillField(
                    value: row.designBusiness,
                    style: theme.textTheme.bodyMedium!
                        .copyWith(color: const Color(0xFF6B7280)),
                    hint: 'Design Business',
                    onSave: (v) =>
                        repo.updateDesignBusiness(row.id, v.isEmpty ? null : v),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),
        const Divider(height: 1),
        const SizedBox(height: 24),

        // ── Two-column role fields ────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column
            Expanded(
              child: Column(
                children: [
                  _RolePanel(
                    roleKey: RoleKey.designer,
                    customLabel: row.labelDesigner,
                    value: row.designer,
                    onSaveValue: (v) =>
                        repo.updateDesigner(row.id, v.isEmpty ? null : v),
                    onSaveLabel: (v) => repo.updateLabelDesigner(row.id, v),
                  ),
                  const SizedBox(height: 20),
                  _RolePanel(
                    roleKey: RoleKey.asstDesigner,
                    customLabel: row.labelAsstDesigner,
                    value: row.asstDesigner,
                    onSaveValue: (v) =>
                        repo.updateAsstDesigner(row.id, v.isEmpty ? null : v),
                    onSaveLabel: (v) =>
                        repo.updateLabelAsstDesigner(row.id, v),
                  ),
                  const SizedBox(height: 20),
                  _RolePanel(
                    roleKey: RoleKey.masterElectrician,
                    customLabel: row.labelMasterElectrician,
                    value: row.masterElectrician,
                    onSaveValue: (v) => repo.updateMasterElectrician(
                        row.id, v.isEmpty ? null : v),
                    onSaveLabel: (v) =>
                        repo.updateLabelMasterElectrician(row.id, v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
            // Right column
            Expanded(
              child: Column(
                children: [
                  _RolePanel(
                    roleKey: RoleKey.producer,
                    customLabel: row.labelProducer,
                    value: row.producer.isEmpty ? null : row.producer,
                    onSaveValue: (v) => repo.updateProducer(row.id, v),
                    onSaveLabel: (v) => repo.updateLabelProducer(row.id, v),
                  ),
                  const SizedBox(height: 20),
                  _RolePanel(
                    roleKey: RoleKey.asstMasterElectrician,
                    customLabel: row.labelAsstMasterElectrician,
                    value: row.asstMasterElectrician,
                    onSaveValue: (v) => repo.updateAsstMasterElectrician(
                        row.id, v.isEmpty ? null : v),
                    onSaveLabel: (v) =>
                        repo.updateLabelAsstMasterElectrician(row.id, v),
                  ),
                  const SizedBox(height: 20),
                  _RolePanel(
                    roleKey: RoleKey.stageManager,
                    customLabel: row.labelStageManager,
                    value: row.stageManager,
                    onSaveValue: (v) =>
                        repo.updateStageManager(row.id, v.isEmpty ? null : v),
                    onSaveLabel: (v) =>
                        repo.updateLabelStageManager(row.id, v),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(height: 1),
        const SizedBox(height: 16),

        // ── Venue / dates strip ───────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _SimpleField(
                label: 'VENUE',
                value: row.venue,
                onSave: (v) =>
                    repo.updateVenue(row.id, v.isEmpty ? null : v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _SimpleField(
                label: 'TECH DATE',
                value: row.techDate,
                onSave: (v) =>
                    repo.updateTechDate(row.id, v.isEmpty ? null : v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _SimpleField(
                label: 'OPENING',
                value: row.openingDate,
                onSave: (v) =>
                    repo.updateOpeningDate(row.id, v.isEmpty ? null : v),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _SimpleField(
                label: 'CLOSING',
                value: row.closingDate,
                onSave: (v) =>
                    repo.updateClosingDate(row.id, v.isEmpty ? null : v),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Venue / Positions panel ────────────────────────────────────────────────────

class _VenuePanel extends StatefulWidget {
  const _VenuePanel();

  @override
  State<_VenuePanel> createState() => _VenuePanelState();
}

class _VenuePanelState extends State<_VenuePanel>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tab,
      builder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tab,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Positions'),
              Tab(text: 'Inventory'),
              Tab(text: 'Channels'),
              Tab(text: 'Addresses'),
              Tab(text: 'Dimmers'),
              Tab(text: 'Circuits'),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: IndexedStack(
              index: _tab.index,
              children: const [
                LightingPositionsTab(),
                InventoryTab(),
                ChannelsTab(),
                AddressesTab(),
                DimmersTab(),
                CircuitsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Role panel — editable label + name field + contact card ───────────────────

class _RolePanel extends ConsumerStatefulWidget {
  const _RolePanel({
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
  ConsumerState<_RolePanel> createState() => _RolePanelState();
}

class _RolePanelState extends ConsumerState<_RolePanel> {
  bool _editingLabel = false;
  late final TextEditingController _labelCtrl;
  late final TextEditingController _valueCtrl;
  late String _lastSavedValue;

  String get _displayLabel =>
      widget.customLabel ?? _defaultLabels[widget.roleKey]!;

  @override
  void initState() {
    super.initState();
    _lastSavedValue = widget.value ?? '';
    _valueCtrl = TextEditingController(text: _lastSavedValue);
    _labelCtrl = TextEditingController();
  }

  @override
  void didUpdateWidget(_RolePanel old) {
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
        // ── Label row ────────────────────────────────────────────────────
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
                          borderSide: BorderSide(
                              color: theme.colorScheme.primary, width: 1),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        suffixText: '  (Enter to save · Esc to cancel)',
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

        // ── Value row (name field + contact button) ───────────────────────
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
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 4),
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

// ── Playbill field (centered, no box border) ───────────────────────────────────

class _PlaybillField extends StatefulWidget {
  const _PlaybillField({
    required this.value,
    required this.style,
    required this.hint,
    required this.onSave,
    this.autoSize = false,
  });

  final String? value;
  final TextStyle style;
  final String hint;
  final Future<void> Function(String) onSave;

  /// When true, displays as a FittedBox (scales down long text) and switches to
  /// a TextField only when tapped.
  final bool autoSize;

  @override
  State<_PlaybillField> createState() => _PlaybillFieldState();
}

class _PlaybillFieldState extends State<_PlaybillField> {
  late final TextEditingController _ctrl;
  late String _lastSaved;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _lastSaved = widget.value ?? '';
    _ctrl = TextEditingController(text: _lastSaved);
  }

  @override
  void didUpdateWidget(_PlaybillField old) {
    super.didUpdateWidget(old);
    final incoming = widget.value ?? '';
    if (incoming != _lastSaved && !_ctrl.selection.isValid) {
      _lastSaved = incoming;
      _ctrl.text = incoming;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final v = _ctrl.text.trim();
    if (v != _lastSaved) {
      _lastSaved = v;
      widget.onSave(v);
    }
  }

  void _commitAndClose() {
    _save();
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final amber = Theme.of(context).colorScheme.primary;

    // Display-only mode: FittedBox scales long text down to fit in one line.
    if (widget.autoSize && !_editing) {
      final displayText = _lastSaved.isEmpty ? widget.hint : _lastSaved;
      final displayStyle = _lastSaved.isEmpty
          ? widget.style.copyWith(color: const Color(0xFF2E3340))
          : widget.style;
      return GestureDetector(
        onTap: () => setState(() => _editing = true),
        child: SizedBox(
          width: double.infinity,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              displayText,
              style: displayStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Focus(
      onFocusChange: (has) {
        if (!has) _commitAndClose();
      },
      child: TextField(
        controller: _ctrl,
        autofocus: widget.autoSize && _editing,
        style: widget.style,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: widget.style.copyWith(color: const Color(0xFF2E3340)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: UnderlineInputBorder(
            borderSide:
                BorderSide(color: amber.withValues(alpha: 0.4), width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          isDense: true,
        ),
        onSubmitted: (_) => _commitAndClose(),
      ),
    );
  }
}

// ── Simple underline field for venue/dates ────────────────────────────────────

class _SimpleField extends StatefulWidget {
  const _SimpleField({
    required this.label,
    required this.value,
    required this.onSave,
  });

  final String label;
  final String? value;
  final Future<void> Function(String) onSave;

  @override
  State<_SimpleField> createState() => _SimpleFieldState();
}

class _SimpleFieldState extends State<_SimpleField> {
  late final TextEditingController _ctrl;
  late String _lastSaved;

  @override
  void initState() {
    super.initState();
    _lastSaved = widget.value ?? '';
    _ctrl = TextEditingController(text: _lastSaved);
  }

  @override
  void didUpdateWidget(_SimpleField old) {
    super.didUpdateWidget(old);
    final incoming = widget.value ?? '';
    if (incoming != _lastSaved && !_ctrl.selection.isValid) {
      _lastSaved = incoming;
      _ctrl.text = incoming;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final v = _ctrl.text.trim();
    if (v == _lastSaved) return;
    _lastSaved = v;
    widget.onSave(v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Focus(
      onFocusChange: (has) {
        if (!has) _save();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: _ctrl,
            style: theme.textTheme.bodyMedium,
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
            onSubmitted: (_) => _save(),
          ),
        ],
      ),
    );
  }
}
