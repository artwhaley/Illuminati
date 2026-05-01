import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/show_provider.dart';
import '../../services/commit_service.dart';
import '../../repositories/fixture_repository.dart';
import '../../repositories/revision_repository.dart';
import 'widgets/maintenance_log_tab.dart';
import 'widgets/revision_card.dart';

class MaintenanceTab extends ConsumerStatefulWidget { const MaintenanceTab({super.key});
  @override ConsumerState<MaintenanceTab> createState() => _MaintenanceTabState(); }

class _MaintenanceTabState extends ConsumerState<MaintenanceTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override void initState() { super.initState(); _tabController = TabController(length: 2, vsync: this); }
  @override void dispose() { _tabController.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => Column(
    children: [
      Material(
        color: Theme.of(context).colorScheme.surface,
        child: TabBar(controller: _tabController, tabs: const [Tab(text: 'Edit Review'), Tab(text: 'Maintenance Log')]),
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: const [EditReviewTab(), MaintenanceLogTab()],
        ),
      ),
    ],
  );
}

class EditReviewTab extends ConsumerStatefulWidget { const EditReviewTab({super.key});
  @override ConsumerState<EditReviewTab> createState() => _EditReviewTabState(); }

class _EditReviewTabState extends ConsumerState<EditReviewTab> {
  final Map<int, ReviewDecision> _decisions = {}; bool _committing = false;
  void _setCardDecision(List<RevisionView> revisions, ReviewDecision decision) => setState(() {
    final allSame = revisions.every((r) => _decisions[r.id] == decision);
    if (allSame) { for (final r in revisions) _decisions.remove(r.id); }
    else { for (final r in revisions) _decisions[r.id] = decision; }
  });

  ReviewDecision? _cardDecision(List<RevisionView> revisions) {
    if (revisions.isEmpty) return null;
    final first = _decisions[revisions.first.id];
    return revisions.every((r) => _decisions[r.id] == first) ? first : null;
  }

  @override Widget build(BuildContext context) {
    final groupedAsync = ref.watch(pendingGroupedRevisionsProvider);
    final fixturesAsync = ref.watch(fixtureRowsProvider);
    return groupedAsync.when(
      data: (groups) {
        if (groups.isEmpty) return const Center(child: Text('No pending revisions to review.'));
        final fixtureMap = {for (final f in fixturesAsync.valueOrNull ?? []) f.id: f};
        final sortedKeys = groups.keys.toList()..sort((a, b) { if (a == null) return 1; if (b == null) return -1; return a.compareTo(b); });
        final allRevIds = groups.values.expand((list) => list).map((r) => r.id).toList();
        final decisionCount = _decisions.length;
        return Column(children: [
          _buildHeader(allRevIds, decisionCount),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: sortedKeys.length,
            itemBuilder: (ctx, idx) { final fixtureId = sortedKeys[idx]; final revisions = groups[fixtureId]!; final fixture = fixtureId != null ? fixtureMap[fixtureId] : null; return RevisionCard(
              key: ValueKey('card_$fixtureId'), fixture: fixture, fixtureId: fixtureId,
              revisions: revisions, cardDecision: _cardDecision(revisions),
              onApprove: () => _setCardDecision(revisions, ReviewDecision.approve),
              onReject: () => _setCardDecision(revisions, ReviewDecision.reject),
            );
          }),),
        ]);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading revisions: $e')),
    );
  }

  Widget _buildHeader(List<int> allRevIds, int decisionCount) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, border: Border(bottom: BorderSide(color: theme.dividerColor))),
      child: Row(children: [
        Text('${allRevIds.length} Pending Revisions', style: theme.textTheme.titleMedium), const Spacer(),
        if (decisionCount > 0) ...[
          Text('$decisionCount decided', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
        ],
        TextButton(onPressed: () => setState(() { for (final id in allRevIds) _decisions[id] = ReviewDecision.approve; }), child: const Text('Approve All')),
        const SizedBox(width: 4),
        TextButton(onPressed: () => setState(() { for (final id in allRevIds) _decisions[id] = ReviewDecision.reject; }), child: const Text('Reject All')),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: decisionCount == 0 || _committing ? null : _handleCommit,
          icon: _committing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle_outline, size: 18),
          label: const Text('Commit Changes'),
        ),
      ]),
    );
  }

  Future<void> _handleCommit() async {
    final service = ref.read(commitServiceProvider); if (service == null) return; setState(() => _committing = true);
    try { await service.commitBatch(decisions: _decisions); setState(() { _decisions.clear(); _committing = false; });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Changes committed.')));
    } catch (e) { setState(() => _committing = false); if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Commit failed: $e'))); }
  }
}
