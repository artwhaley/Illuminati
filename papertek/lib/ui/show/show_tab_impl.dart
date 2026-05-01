// -- show_tab_impl.dart -----------------------------------------------------
//
// Show tab orchestrator and body layout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/database.dart';
import '../../providers/show_provider.dart';
import '../../repositories/show_meta_repository.dart';
import 'show_info_panel.dart';
import 'sub_tab_panel.dart';

class ShowTab extends ConsumerWidget {
  const ShowTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(currentShowMetaProvider);
    final repo = ref.watch(showMetaRepoProvider);
    return meta.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (row) {
        if (row == null || repo == null) {
          return const Center(child: Text('No show data found.'));
        }
        return _ShowTabBody(row: row, repo: repo);
      },
    );
  }
}

// -- Body --------------------------------------------------------------------
//
// Layout approach: LayoutBuilder ? SingleChildScrollView ? Column.
//   * Info card  - natural height inside the scrollable Column.
//   * Venue card - SizedBox(height: constraints.maxHeight): the LayoutBuilder
//     captures the available viewport height and forces the venue card to that
//     exact height. This gives SubTabPanel a BOUNDED constraint so Column+Expanded
//     propagates correctly to nested LightingPositionsTab -> ReorderableListView.
//
// Total column height = infoCard.height + viewportHeight, so the page scrolls
// exactly far enough to hide the info card and let the venue card fill the window.
//
// SliverFillRemaining was tried and abandoned: it queries the child's intrinsic
// height first (Column+Expanded ? 0), causing a NEEDS-LAYOUT dead-lock when
// actual list items exist inside the venue card.
class _ShowTabBody extends StatelessWidget {
  const _ShowTabBody({required this.row, required this.repo});

  final ShowMetaData row;
  final ShowMetaRepository repo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = theme.colorScheme.surfaceContainerLow;
    final borderColor = theme.colorScheme.outlineVariant;

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                child: ShowInfoPanel(row: row, repo: repo),
              ),
            ),
            SizedBox(
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const SubTabPanel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


