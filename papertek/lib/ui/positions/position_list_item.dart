import '../../database/database.dart';

// ── Data model for the unified top-level list ──────────────────────────────

sealed class PositionListItem {
  int get sortOrder;
  String get listKey;
}

class SinglePositionItem extends PositionListItem {
  SinglePositionItem(this.pos);
  final LightingPosition pos;
  @override int get sortOrder => pos.sortOrder;
  @override String get listKey => 'pos_${pos.id}';
}

class PositionGroupItem extends PositionListItem {
  PositionGroupItem(this.group, this.members);
  final PositionGroup group;
  final List<LightingPosition> members;
  @override int get sortOrder => group.sortOrder;
  @override String get listKey => 'group_${group.id}';
}

// ── Conflict resolution choices for rename collision ──────────────────────

sealed class PositionConflictResolution {}

class MergeKeepExisting extends PositionConflictResolution {}

class MergeKeepNew extends PositionConflictResolution {}

class UseAlternateName extends PositionConflictResolution {
  UseAlternateName(this.name);
  final String name;
}
