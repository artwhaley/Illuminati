import 'package:flutter/material.dart';
import 'shared_notes_list.dart';

class WorkNotesTab extends StatelessWidget {
  const WorkNotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SharedNotesList(noteType: 'work');
  }
}
