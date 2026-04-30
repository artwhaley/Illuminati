import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../database/database.dart';

class PositionGroupCard extends StatefulWidget {
  const PositionGroupCard({
    super.key,
    required this.index,
    required this.group,
    required this.members,
    required this.selected,
    required this.selectedPositionKeys,
    required this.onGroupTap,
    required this.onGroupSecondaryTap,
    required this.onPositionTap,
    required this.onPositionSecondaryTap,
    this.onRename,
    this.onReorderMembers,
  });

  final int index;
  final PositionGroup group;
  final List<LightingPosition> members;
  final bool selected;
  final Set<String> selectedPositionKeys;
  final VoidCallback onGroupTap;
  final VoidCallback onGroupSecondaryTap;
  final void Function(LightingPosition) onPositionTap;
  final void Function(LightingPosition) onPositionSecondaryTap;
  final Future<void> Function(String)? onRename;
  final Future<void> Function(List<int>)? onReorderMembers;

  @override
  State<PositionGroupCard> createState() => _PositionGroupCardState();
}

class _PositionGroupCardState extends State<PositionGroupCard> {
  bool _expanded = true;
  bool _editingName = false;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.group.name);
  }

  @override
  void didUpdateWidget(PositionGroupCard old) {
    super.didUpdateWidget(old);
    if (widget.group.name != old.group.name) {
      _nameCtrl.text = widget.group.name;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _commitGroupRename() {
    final v = _nameCtrl.text.trim();
    if (v.isNotEmpty && v != widget.group.name) {
      widget.onRename?.call(v);
    }
    setState(() => _editingName = false);
  }

  static const double _tileHeight = 38.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amber = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: widget.selected
              ? amber.withValues(alpha: 0.08)
              : const Color(0xFF13161B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: widget.selected
                ? amber.withValues(alpha: 0.5)
                : const Color(0xFF23272E),
          ),
        ),
        child: Column(
          children: [
            InkWell(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              onTap: _editingName ? null : widget.onGroupTap,
              onSecondaryTap: _editingName ? null : widget.onGroupSecondaryTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.folder_outlined,
                      size: 16,
                      color: widget.selected ? amber : const Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _editingName
                          ? CallbackShortcuts(
                              bindings: {
                                const SingleActivator(
                                        LogicalKeyboardKey.escape):
                                    () => setState(() => _editingName = false),
                              },
                              child: Focus(
                                onFocusChange: (has) {
                                  if (!has) _commitGroupRename();
                                },
                                child: TextField(
                                  controller: _nameCtrl,
                                  autofocus: true,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: widget.selected ? amber : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (_) => _commitGroupRename(),
                                ),
                              ),
                            )
                          : GestureDetector(
                              onDoubleTap: widget.onRename == null
                                  ? null
                                  : () {
                                      _nameCtrl.text = widget.group.name;
                                      setState(() => _editingName = true);
                                    },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      widget.group.name,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: widget.selected ? amber : null,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${widget.members.length}',
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                            color: const Color(0xFF6B7280)),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    ReorderableDragStartListener(
                      index: widget.index,
                      child: const Icon(Icons.drag_indicator,
                          size: 18, color: Color(0xFF4B5263)),
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded && widget.members.isNotEmpty) ...[
              const Divider(height: 1, indent: 12, endIndent: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(36, 4, 4, 8),
                child: SizedBox(
                  height: widget.members.length * _tileHeight,
                  child: ReorderableListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    padding: EdgeInsets.zero,
                    itemCount: widget.members.length,
                    onReorder: (oldIdx, newIdx) {
                      if (newIdx > oldIdx) newIdx--;
                      final reordered = [...widget.members];
                      final moved = reordered.removeAt(oldIdx);
                      reordered.insert(newIdx, moved);
                      widget.onReorderMembers
                          ?.call(reordered.map((p) => p.id).toList());
                    },
                    itemBuilder: (_, i) =>
                        _buildMemberTile(i, widget.members[i], amber, theme),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemberTile(
      int index, LightingPosition pos, Color amber, ThemeData theme) {
    final posKey = 'pos_${pos.id}';
    final isSel = widget.selectedPositionKeys.contains(posKey);
    return Padding(
      key: ValueKey(pos.id),
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: isSel ? amber.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => widget.onPositionTap(pos),
          onSecondaryTap: () => widget.onPositionSecondaryTap(pos),
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10, right: 4, top: 8, bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    pos.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSel ? amber : null,
                      fontWeight:
                          isSel ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 36),
                    child: Icon(Icons.drag_indicator,
                        size: 14, color: Color(0xFF4B5263)),
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
