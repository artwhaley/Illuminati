import 'package:flutter/material.dart';
import 'work_notes_tab.dart';
import 'board_notes_tab.dart';
import 'live_notes_tab.dart';

class WorkNotesShell extends StatefulWidget {
  const WorkNotesShell({super.key});

  @override
  State<WorkNotesShell> createState() => _WorkNotesShellState();
}

class _WorkNotesShellState extends State<WorkNotesShell> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            tabs: const [
              Tab(text: 'Work Notes'),
              Tab(text: 'Board Notes'),
              Tab(text: 'Live Notes'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              WorkNotesTab(),
              BoardNotesTab(),
              LiveNotesTab(),
            ],
          ),
        ),
      ],
    );
  }
}
