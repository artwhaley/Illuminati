// -- revision_card.dart --------------------------------------------------------
//
// Per-fixture revision card for the Edit Review tab.
//
// _RevisionCard renders the card chrome (fixture label + approve/reject buttons)
// and selects the appropriate body widget: _TabularCardBody for fixture revisions,
// _GenericCardBody for non-fixture revisions (show_meta, etc.).
//
// _ActionButton is the approve/reject toggle � an animated bordered button that
// highlights in green or red when active.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../repositories/fixture_repository.dart';
import '../../../repositories/revision_repository.dart';
import '../../../services/commit_service.dart';
import '../../../ui/spreadsheet/column_spec.dart';
import '../maintenance_helpers.dart';
import 'generic_card_body.dart';
import 'tabular_card_body.dart';

class RevisionCard extends ConsumerWidget {
  RevisionCard({
    super.key,
    required this.fixture,
    required this.fixtureId,
    required this.revisions,
    required this.cardDecision,
    required this.onApprove,
    required this.onReject,
    List<ColumnSpec>? columns,
  }) : columns = columns ?? kMaintenanceFixtureCols;

  final FixtureRow? fixture;
  final int? fixtureId;
  final List<RevisionView> revisions;
  final ReviewDecision? cardDecision;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final List<ColumnSpec> columns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isApproved = cardDecision == ReviewDecision.approve;
    final isRejected = cardDecision == ReviewDecision.reject;
    final f = fixture;

    final label = f != null
        ? 'Ch ${f.channel ?? "�"}  �  ${f.position ?? "No Position"}  �  U#${f.unitNumber ?? "?"}  �  ${f.fixtureType ?? "No Type"}'
        : fixtureId == null
            ? 'Global / Other'
            : 'Fixture #$fixtureId (Deleted)';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isApproved
              ? Colors.green.withValues(alpha: 0.5)
              : isRejected
                  ? Colors.red.withValues(alpha: 0.5)
                  : theme.dividerColor.withValues(alpha: 0.15),
          width: isApproved || isRejected ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // -- header ------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Row(
              children: [
                Text(label,
                    style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary)),
                const Spacer(),
                _ActionButton(
                  label: 'REJECT',
                  color: Colors.red,
                  isActive: isRejected,
                  onPressed: onReject,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: 'APPROVE',
                  color: Colors.green,
                  isActive: isApproved,
                  icon: Icons.chevron_right,
                  onPressed: onApprove,
                ),
              ],
            ),
          ),

          // -- body: tabular (fixture) or generic (other) -------------------
          if (f != null)
            TabularCardBody(
              fixture: f,
              revisions: revisions,
              columns: columns,
              cardDecision: cardDecision,
            )
          else
            GenericCardBody(revisions: revisions),
        ],
      ),
    );
  }
}

// -- APPROVE / REJECT toggle button --------------------------------------------

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.2) : Colors.transparent,
          border: Border.all(
              color: isActive ? color : color.withValues(alpha: 0.35), width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : color.withValues(alpha: 0.6),
                    letterSpacing: 0.5)),
            if (icon != null) ...[
              const SizedBox(width: 2),
              Icon(icon, size: 14,
                  color: isActive ? color : color.withValues(alpha: 0.6)),
            ],
          ],
        ),
      ),
    );
  }
}
