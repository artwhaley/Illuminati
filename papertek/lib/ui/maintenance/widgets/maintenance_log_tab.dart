// -- maintenance_log_tab.dart --------------------------------------------------
//
// The "Maintenance Log" sub-tab of the Maintenance tab.
// Shows unresolved maintenance flag items grouped by fixture, with per-card
// and per-item resolve actions.
//
// Public: MaintenanceLogTab

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../providers/show_provider.dart';
import '../../../repositories/fixture_repository.dart';
import '../../../repositories/revision_repository.dart';
import '../../../database/database.dart';
import '../maintenance_helpers.dart';

class MaintenanceLogTab extends ConsumerWidget {
  const MaintenanceLogTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(unresolvedMaintenanceProvider);
    final fixturesAsync = ref.watch(fixtureRowsProvider);

    return logsAsync.when(
      data: (logs) {
        if (logs.isEmpty) {
          return const Center(
            child: Text('No unresolved maintenance items.\nEverything is looking good!',
                textAlign: TextAlign.center),
          );
        }

        // Group logs by fixture
        final logsByFixture = <int, List<MaintenanceLogData>>{};
        for (final log in logs) {
          logsByFixture.putIfAbsent(log.fixtureId, () => []).add(log);
        }

        final fixtureIds = logsByFixture.keys.toList()..sort();
        final fixtureMap = {
          for (final f in fixturesAsync.valueOrNull ?? <FixtureRow>[]) f.id: f
        };

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fixtureIds.length,
          itemBuilder: (context, index) {
            final fid = fixtureIds[index];
            final fixture = fixtureMap[fid];
            final fixtureLogs = logsByFixture[fid] ?? [];

            return _MaintenanceItemCard(
              fixtureId: fid,
              fixture: fixture,
              logs: fixtureLogs,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading maintenance log: $e')),
    );
  }
}

class _MaintenanceItemCard extends ConsumerWidget {
  const _MaintenanceItemCard({
    required this.fixtureId,
    this.fixture,
    required this.logs,
  });

  final int fixtureId;
  final FixtureRow? fixture;
  final List<MaintenanceLogData> logs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final f = fixture;

    final title = f != null
        ? 'Ch ${f.channel ?? "�"}  �  ${f.position ?? "No Position"}  �  U#${f.unitNumber ?? "?"}'
        : 'Fixture #$fixtureId';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              children: [
                const Icon(Icons.build_outlined, size: 16),
                const SizedBox(width: 8),
                Text(title,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
                const Spacer(),
                if (f != null && f.fixtureType != null)
                  Text(f.fixtureType!,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          if (logs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text('No log entries.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
            )
          else
            ...logs.map((log) => _MaintenanceLogRow(log: log)),

          if (logs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => _resolveAll(ref),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Resolve All'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _resolveAll(WidgetRef ref) async {
    final repo = ref.read(operationalRepoProvider);
    if (repo == null) return;
    for (final log in logs) {
      await repo.resolveMaintenance(log.id);
    }
  }
}

class _MaintenanceLogRow extends ConsumerWidget {
  const _MaintenanceLogRow({required this.log});
  final MaintenanceLogData log;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text('${formatMaintenanceTs(log.timestamp)}  �  ${log.userId}',
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, size: 20),
            tooltip: 'Resolve',
            onPressed: () =>
                ref.read(operationalRepoProvider)?.resolveMaintenance(log.id),
          ),
        ],
      ),
    );
  }
}
