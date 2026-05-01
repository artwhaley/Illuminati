// -- type_info_panel.dart -----------------------------------------------------
//
// Right-side info panel for selected fixture type.

import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../../../repositories/fixture_type_repository.dart';
import 'inventory_shared_widgets.dart';

class TypeInfoPanel extends StatefulWidget {
  const TypeInfoPanel({
    required this.type,
    required this.repo,
    this.fetchCount,
  });

  final FixtureType? type;
  final FixtureTypeRepository? repo;
  final Future<int> Function()? fetchCount;

  @override
  State<TypeInfoPanel> createState() => _TypeInfoPanelState();
}

class _TypeInfoPanelState extends State<TypeInfoPanel> {
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
  void didUpdateWidget(TypeInfoPanel old) {
    super.didUpdateWidget(old);
    final t = widget.type;

    // Cases handled:
    // 1) Id changed -> selected fixture type changed: reset controllers + reload count
    // 2) Same id changed in DB -> update unfocused values
    // 3) Deselected -> controllers become irrelevant and panel switches to hint
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
    // Intentionally fire-and-forget; setState guarded by mounted check.
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
                InventoryInfoField(
                  label: 'WATTAGE',
                  controller: _wattCtrl,
                  onSave: _saveWattage,
                ),
                const SizedBox(height: 12),
                InventoryInfoField(
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
