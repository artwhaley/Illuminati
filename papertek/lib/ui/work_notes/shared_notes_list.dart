import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notes_providers.dart';
import '../../repositories/notes_repository.dart';

class SharedNotesList extends ConsumerWidget {
  const SharedNotesList({
    super.key,
    required this.noteType,
  });

  final String noteType; // 'work' or 'board'

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = noteType == 'work' ? workNotesProvider : boardNotesProvider;
    final notesAsync = ref.watch(provider);

    return Column(
      children: [
        _buildToolbar(context, ref),
        const Divider(height: 1),
        Expanded(
          child: notesAsync.when(
            data: (notes) {
              if (notes.isEmpty) {
                return const Center(child: Text('No notes found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return _NoteCard(note: notes[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading notes: $e')),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(BuildContext context, WidgetRef ref) {
    final filterProvider = noteType == 'work' ? workNotesFilterProvider : boardNotesFilterProvider;
    final filter = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Active'),
            selected: filter.completed == false,
            onSelected: (val) {
              notifier.state = filter.copyWith(completed: val ? false : null, clearCompleted: !val);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Completed'),
            selected: filter.completed == true,
            onSelected: (val) {
              notifier.state = filter.copyWith(completed: val ? true : null, clearCompleted: !val);
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Elevated'),
            selected: filter.elevated == true,
            onSelected: (val) {
              notifier.state = filter.copyWith(elevated: val ? true : null, clearElevated: !val);
            },
          ),
          const Spacer(),
          // Basic search input
          SizedBox(
            width: 200,
            height: 36,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search, size: 16),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                notifier.state = filter.copyWith(search: val, clearSearch: val.isEmpty);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends ConsumerStatefulWidget {
  const _NoteCard({required this.note});
  final NoteWithDetails note;

  @override
  ConsumerState<_NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends ConsumerState<_NoteCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = widget.note;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: note.completed ? Colors.green.withValues(alpha: 0.5) : theme.dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Checkbox(
              value: note.completed,
              onChanged: (val) {
                // we'll pass a dummy user id for now
                ref.read(notesRepoProvider)?.toggleCompleted(note.id, 'local-user');
              },
            ),
            title: Text(
              note.body,
              style: TextStyle(
                decoration: note.completed ? TextDecoration.lineThrough : null,
                color: note.completed ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : null,
              ),
            ),
            subtitle: _buildSubtitle(theme, note),
            trailing: IconButton(
              icon: Icon(
                note.elevated ? Icons.star : Icons.star_border,
                color: note.elevated ? Colors.amber : null,
              ),
              onPressed: () {
                ref.read(notesRepoProvider)?.toggleElevated(note.id);
              },
            ),
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
          ),
          if (_expanded) _NoteActionsPanel(noteId: note.id),
        ],
      ),
    );
  }

  Widget _buildSubtitle(ThemeData theme, NoteWithDetails note) {
    final dt = note.createdAt;
    final dateStr = '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    
    List<Widget> chips = [];
    for (final fid in note.linkedFixtureIds) {
      chips.add(_Chip(label: 'Fixture #$fid'));
    }
    for (final pos in note.linkedPositionNames) {
      if (pos.isNotEmpty) {
        chips.add(_Chip(label: pos));
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text('By ${note.createdBy} at $dateStr', style: theme.textTheme.bodySmall),
        if (chips.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(spacing: 4, runSpacing: 4, children: chips),
        ]
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 10)),
    );
  }
}

class _NoteActionsPanel extends ConsumerWidget {
  const _NoteActionsPanel({required this.noteId});
  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(noteActionsProvider(noteId));
    final theme = Theme.of(context);
    
    return Container(
      color: theme.colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Activity History', style: theme.textTheme.labelMedium),
          const SizedBox(height: 8),
          actionsAsync.when(
            data: (actions) {
              if (actions.isEmpty) return const Text('No activity yet.', style: TextStyle(fontSize: 12));
              return Column(
                children: actions.map((a) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${a.timestamp.month}/${a.timestamp.day} ${a.timestamp.hour}:${a.timestamp.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: theme.colorScheme.primary)),
                        const SizedBox(width: 8),
                        Expanded(child: Text('${a.userId}: ${a.body}', style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            error: (e, st) => Text('Error: $e'),
          ),
          const SizedBox(height: 8),
          _AddActionInput(noteId: noteId),
        ],
      ),
    );
  }
}

class _AddActionInput extends ConsumerStatefulWidget {
  const _AddActionInput({required this.noteId});
  final int noteId;

  @override
  ConsumerState<_AddActionInput> createState() => _AddActionInputState();
}

class _AddActionInputState extends ConsumerState<_AddActionInput> {
  final _ctrl = TextEditingController();

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    
    final repo = ref.read(notesRepoProvider);
    if (repo != null) {
      await repo.addAction(noteId: widget.noteId, body: text, userId: 'local-user');
      _ctrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 32,
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(fontSize: 12),
              decoration: const InputDecoration(
                hintText: 'Add an update...',
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send, size: 16),
          onPressed: _submit,
        )
      ],
    );
  }
}
