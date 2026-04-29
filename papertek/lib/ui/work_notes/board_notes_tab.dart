import 'package:flutter/material.dart';
import 'shared_notes_list.dart';

class BoardNotesTab extends StatelessWidget {
  const BoardNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedNotesList(noteType: 'board');
  }
}
