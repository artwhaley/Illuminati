import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../database/database.dart';
import '../../../repositories/fixture_repository.dart';

enum CollectionKind { gel, gobo, accessory }

class CollectionEditorDialog extends StatefulWidget {
  final int fixtureId;
  final CollectionKind kind;
  final int? partId; // If null, aggregate mode
  final FixtureRepository repo;

  const CollectionEditorDialog({
    super.key,
    required this.fixtureId,
    required this.kind,
    this.partId,
    required this.repo,
  });

  @override
  State<CollectionEditorDialog> createState() => _CollectionEditorDialogState();
}

class _CollectionEditorDialogState extends State<CollectionEditorDialog> {
  bool _loading = true;
  List<FixturePart> _parts = [];
  
  // Data for each part
  final Map<int, List<dynamic>> _itemsByPart = {};
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    _parts = await widget.repo.getPartsForFixture(widget.fixtureId);
    
    // Filter parts if part-scoped
    if (widget.partId != null) {
      _parts = _parts.where((p) => p.id == widget.partId).toList();
    }

    for (final part in _parts) {
      switch (widget.kind) {
        case CollectionKind.gel:
          _itemsByPart[part.id] = await widget.repo.listGelsByPart(part.id);
        case CollectionKind.gobo:
          _itemsByPart[part.id] = await widget.repo.listGobosByPart(part.id);
        case CollectionKind.accessory:
          _itemsByPart[part.id] = await widget.repo.listAccessoriesByPart(part.id);
      }
    }

    if (mounted) setState(() => _loading = false);
  }

  String get _title {
    final type = widget.kind.name.toUpperCase();
    return widget.partId != null ? 'Edit $type' : 'Edit $type (All Parts)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(_title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        height: 500,
        child: _loading 
          ? const Center(child: CircularProgressIndicator())
          : _buildList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context), // Changes are applied immediately via repo calls in this simple v1
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: _parts.length,
      itemBuilder: (context, index) {
        final part = _parts[index];
        final items = _itemsByPart[part.id] ?? [];
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.partId == null) // Show part header only in aggregate mode
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'PART ${part.partOrder} (${part.partName})',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                ),
              ),
            ...items.asMap().entries.map((entry) => _buildItemRow(part, entry.key, entry.value, items)),
            _buildAddRow(part),
            const Divider(),
          ],
        );
      },
    );
  }

  Widget _buildItemRow(FixturePart part, int index, dynamic item, List<dynamic> items) {
    final String label;
    final int id;
    
    if (item is Gel) {
      label = item.color;
      id = item.id;
    } else if (item is Gobo) {
      label = item.goboNumber;
      id = item.id;
    } else {
      label = (item as Accessory).name;
      id = item.id;
    }

    return ListTile(
      dense: true,
      title: Text(label, style: GoogleFonts.jetBrainsMono()),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward, size: 16),
            onPressed: index > 0 ? () => _reorderItem(part, index, index - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, size: 16),
            onPressed: index < items.length - 1 ? () => _reorderItem(part, index, index + 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 16),
            onPressed: () => _editItem(part, id, label),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16),
            onPressed: () => _deleteItem(part, id),
          ),
        ],
      ),
    );
  }

  void _reorderItem(FixturePart part, int oldIndex, int newIndex) async {
    final items = _itemsByPart[part.id] ?? [];
    if (newIndex < 0 || newIndex >= items.length) return;

    final double newSortOrder;
    if (newIndex == 0) {
      newSortOrder = items[0].sortOrder - 1.0;
    } else if (newIndex == items.length - 1) {
      newSortOrder = items.last.sortOrder + 1.0;
    } else {
      // Use midpoint logic
      final prev = items[newIndex > oldIndex ? newIndex : newIndex - 1].sortOrder;
      final next = items[newIndex > oldIndex ? newIndex + 1 : newIndex].sortOrder;
      newSortOrder = (prev + next) / 2.0;
    }

    final dynamic item = items[oldIndex];
    final int id = item.id;

    switch (widget.kind) {
      case CollectionKind.gel:
        await widget.repo.reorderGel(id, newSortOrder);
      case CollectionKind.gobo:
        await widget.repo.reorderGobo(id, newSortOrder);
      case CollectionKind.accessory:
        await widget.repo.reorderAccessory(id, newSortOrder);
    }
    _loadData();
  }

  Widget _buildAddRow(FixturePart part) {
    return ListTile(
      dense: true,
      leading: const Icon(Icons.add, size: 18),
      title: const Text('Add item...'),
      onTap: () => _addItem(part),
    );
  }

  void _addItem(FixturePart part) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${widget.kind.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: 'Value'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      switch (widget.kind) {
        case CollectionKind.gel:
          await widget.repo.addGel(fixtureId: widget.fixtureId, partId: part.id, color: result);
        case CollectionKind.gobo:
          await widget.repo.addGobo(fixtureId: widget.fixtureId, partId: part.id, goboNumber: result);
        case CollectionKind.accessory:
          await widget.repo.addAccessory(fixtureId: widget.fixtureId, partId: part.id, name: result);
      }
      _loadData();
    }
  }

  void _editItem(FixturePart part, int id, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${widget.kind.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && result != current) {
      switch (widget.kind) {
        case CollectionKind.gel:
          await widget.repo.updateGel(id, color: result);
        case CollectionKind.gobo:
          await widget.repo.updateGobo(id, goboNumber: result);
        case CollectionKind.accessory:
          await widget.repo.updateAccessory(id, name: result);
      }
      _loadData();
    }
  }

  void _deleteItem(FixturePart part, int id) async {
    switch (widget.kind) {
      case CollectionKind.gel:
        await widget.repo.deleteGel(id);
      case CollectionKind.gobo:
        await widget.repo.deleteGobo(id);
      case CollectionKind.accessory:
        await widget.repo.deleteAccessory(id);
    }
    _loadData();
  }
}
