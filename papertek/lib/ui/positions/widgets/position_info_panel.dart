import 'package:flutter/material.dart';
import '../../../database/database.dart';
import '../../../repositories/position_repository.dart';

class PositionInfoPanel extends StatefulWidget {
  const PositionInfoPanel({super.key, required this.position, required this.repo});

  final LightingPosition? position;
  final PositionRepository? repo;

  @override
  State<PositionInfoPanel> createState() => _PositionInfoPanelState();
}

class _PositionInfoPanelState extends State<PositionInfoPanel> {
  late final TextEditingController _trimCtrl;
  late final TextEditingController _plasterCtrl;
  late final TextEditingController _centerCtrl;
  int? _lastId;

  @override
  void initState() {
    super.initState();
    _trimCtrl = TextEditingController(text: widget.position?.trim ?? '');
    _plasterCtrl =
        TextEditingController(text: widget.position?.fromPlasterLine ?? '');
    _centerCtrl =
        TextEditingController(text: widget.position?.fromCenterLine ?? '');
    _lastId = widget.position?.id;
  }

  @override
  void didUpdateWidget(PositionInfoPanel old) {
    super.didUpdateWidget(old);
    final pos = widget.position;
    if (pos?.id != _lastId) {
      // Different position selected — always sync all fields.
      _lastId = pos?.id;
      _trimCtrl.text = pos?.trim ?? '';
      _plasterCtrl.text = pos?.fromPlasterLine ?? '';
      _centerCtrl.text = pos?.fromCenterLine ?? '';
    } else if (pos != null) {
      // Same position updated in DB — sync only unfocused fields.
      if (!_trimCtrl.selection.isValid) _trimCtrl.text = pos.trim ?? '';
      if (!_plasterCtrl.selection.isValid) {
        _plasterCtrl.text = pos.fromPlasterLine ?? '';
      }
      if (!_centerCtrl.selection.isValid) {
        _centerCtrl.text = pos.fromCenterLine ?? '';
      }
    }
  }

  @override
  void dispose() {
    _trimCtrl.dispose();
    _plasterCtrl.dispose();
    _centerCtrl.dispose();
    super.dispose();
  }

  void _saveTrim() {
    if (widget.position == null || widget.repo == null) return;
    final v = _trimCtrl.text.trim();
    widget.repo!.updateTrim(widget.position!.id, v.isEmpty ? null : v);
  }

  void _savePlaster() {
    if (widget.position == null || widget.repo == null) return;
    final v = _plasterCtrl.text.trim();
    widget.repo!
        .updateFromPlasterLine(widget.position!.id, v.isEmpty ? null : v);
  }

  void _saveCenter() {
    if (widget.position == null || widget.repo == null) return;
    final v = _centerCtrl.text.trim();
    widget.repo!
        .updateFromCenterLine(widget.position!.id, v.isEmpty ? null : v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPosition = widget.position != null;

    return Container(
      width: 180,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFF23272E))),
      ),
      padding: const EdgeInsets.all(12),
      child: hasPosition
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.position!.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _InfoField(
                  label: 'TRIM',
                  controller: _trimCtrl,
                  onSave: _saveTrim,
                ),
                const SizedBox(height: 12),
                _InfoField(
                  label: 'FROM PLASTER',
                  controller: _plasterCtrl,
                  onSave: _savePlaster,
                ),
                const SizedBox(height: 12),
                _InfoField(
                  label: 'FROM CENTER',
                  controller: _centerCtrl,
                  onSave: _saveCenter,
                ),
              ],
            )
          : Center(
              child: Text(
                'Select a\nposition',
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
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onSave;

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
