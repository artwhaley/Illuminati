import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notes_providers.dart';
import '../../repositories/notes_repository.dart';
import 'dart:async';

class LiveNotesTab extends ConsumerStatefulWidget {
  const LiveNotesTab({super.key});

  @override
  ConsumerState<LiveNotesTab> createState() => _LiveNotesTabState();
}

class _LiveNotesTabState extends ConsumerState<LiveNotesTab> {
  final _bodyCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  final _bodyFocusNode = FocusNode();
  
  String _noteType = 'work';
  Timer? _debounce;
  List<FixtureSearchResult> _searchResults = [];
  bool _isSearching = false;
  
  final List<FixtureSearchResult> _attachedFixtures = [];
  final List<String> _attachedPositions = [];
  
  // Local session feed
  final List<NoteWithDetails> _recentNotes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bodyFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    _bodyFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      final repo = ref.read(notesRepoProvider);
      if (repo == null) return;
      
      final results = await repo.searchFixtures(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _submitNote() async {
    final body = _bodyCtrl.text.trim();
    if (body.isEmpty) return;

    final repo = ref.read(notesRepoProvider);
    if (repo == null) return;

    final fixtureIds = _attachedFixtures.map((f) => f.fixtureId).toList();
    final positionNames = List<String>.from(_attachedPositions);
    
    // Also attach to position if search text directly matches a position, 
    // but the user didn't explicitly click it. For now we just use explicitly attached.

    try {
      final noteId = await repo.createNote(
        type: _noteType,
        body: body,
        userId: 'local-user', // TODO: auth
        fixtureIds: fixtureIds.isNotEmpty ? fixtureIds : null,
        positionNames: positionNames.isNotEmpty ? positionNames : null,
      );

      // Create a local fake object for the recent feed
      final fakeDetails = NoteWithDetails(
        id: noteId,
        type: _noteType,
        body: body,
        createdBy: 'local-user',
        createdAt: DateTime.now(),
        completed: false,
        elevated: false,
        linkedFixtureIds: fixtureIds,
        linkedPositionNames: positionNames,
        actionCount: 0,
      );

      setState(() {
        _recentNotes.insert(0, fakeDetails);
        if (_recentNotes.length > 20) _recentNotes.removeLast();
        
        _bodyCtrl.clear();
        _attachedFixtures.clear();
        _attachedPositions.clear();
        _searchCtrl.clear();
        _searchResults.clear();
      });

      _bodyFocusNode.requestFocus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note created.'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e, st) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: \$e'), 
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('ERROR SAVING NOTE: \$e');
      print('STACK TRACE: \$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        // Left Column: Input and Search
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top section: Note input
                _buildNoteInputSection(theme),
                const SizedBox(height: 24),
                
                // Middle section: Fixture search and attach
                _buildSearchSection(theme),
              ],
            ),
          ),
        ),
        
        const VerticalDivider(width: 1),
        
        // Right Column: Recent notes feed
        Expanded(
          flex: 1,
          child: Container(
            color: theme.colorScheme.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Recent Notes (Session)', style: theme.textTheme.titleMedium),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _recentNotes.length,
                    itemBuilder: (ctx, idx) {
                      final note = _recentNotes[idx];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Badge(
                                    label: Text(note.type == 'work' ? 'W' : 'B'),
                                    backgroundColor: note.type == 'work' ? Colors.blue : Colors.purple,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${note.createdAt.hour}:${note.createdAt.minute.toString().padLeft(2, '0')}', style: theme.textTheme.bodySmall),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(note.body),
                              if (note.linkedFixtureIds.isNotEmpty || note.linkedPositionNames.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Attached: ${note.linkedFixtureIds.length} fixtures, ${note.linkedPositionNames.length} positions',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteInputSection(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'work', label: Text('Work Note')),
                    ButtonSegment(value: 'board', label: Text('Board Note')),
                  ],
                  selected: {_noteType},
                  onSelectionChanged: (set) {
                    setState(() => _noteType = set.first);
                  },
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _submitNote,
                  icon: const Icon(Icons.send),
                  label: const Text('Submit Note'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            KeyboardListener(
              focusNode: FocusNode(), // Dummy focus node for listening
              onKeyEvent: (event) {
                if (event is KeyDownEvent && 
                    event.logicalKey == LogicalKeyboardKey.enter && 
                    HardwareKeyboard.instance.isControlPressed) {
                  _submitNote();
                }
              },
              child: TextField(
                controller: _bodyCtrl,
                focusNode: _bodyFocusNode,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type note here... (Ctrl+Enter to submit)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (_attachedFixtures.isNotEmpty || _attachedPositions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in _attachedFixtures)
                    Chip(
                      label: Text('Ch ${f.channel ?? "?"}'),
                      onDeleted: () {
                        setState(() => _attachedFixtures.remove(f));
                      },
                    ),
                  for (final p in _attachedPositions)
                    Chip(
                      label: Text('Pos: \$p'),
                      onDeleted: () {
                        setState(() => _attachedPositions.remove(p));
                      },
                    ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(ThemeData theme) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Search & Attach Fixtures', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search: channel, position, type, purpose...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (_searchResults.isEmpty && _searchCtrl.text.isNotEmpty)
                const Center(child: Text('No matching fixtures found.'))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final f = _searchResults[index];
                      final isAttached = _attachedFixtures.any((a) => a.fixtureId == f.fixtureId);
                      
                      return ListTile(
                        leading: isAttached 
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.circle_outlined),
                        title: Text('Ch ${f.channel ?? "-"} | ${f.position ?? "No Pos"} | ${f.fixtureType ?? "No Type"}'),
                        subtitle: Text('${f.function ?? ""} ${f.focus ?? ""}'),
                        onTap: () {
                          setState(() {
                            if (isAttached) {
                              _attachedFixtures.removeWhere((a) => a.fixtureId == f.fixtureId);
                            } else {
                              _attachedFixtures.add(f);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
