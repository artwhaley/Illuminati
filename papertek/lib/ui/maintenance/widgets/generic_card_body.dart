// -- generic_card_body.dart ----------------------------------------------------
//
// Card body used for non-fixture revisions in the Edit Review tab.
// Renders a plain field-name ? old-value ? new-value diff list.
// Used by _RevisionCard when no FixtureRow is available.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../repositories/revision_repository.dart';
import '../maintenance_helpers.dart';

class GenericCardBody extends StatelessWidget {
  const GenericCardBody({required this.revisions});
  final List<RevisionView> revisions;

  @override
  Widget build(BuildContext context) {
    final sorted = List<RevisionView>.from(revisions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rev in sorted) _RevisionDiffRow(revision: rev),
        ],
      ),
    );
  }
}

class _RevisionDiffRow extends StatelessWidget {
  const _RevisionDiffRow({required this.revision});
  final RevisionView revision;

  @override
  Widget build(BuildContext context) {
    final fieldLabel = revision.fieldName ?? revision.operation;
    final oldVal = revision.oldValue?.toString();
    final newVal = revision.newValue?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fieldLabel,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF78909C))),
          const SizedBox(height: 2),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              _ValueChip(label: oldVal ?? '�', fg: kFgPurple, bg: kBgPurple),
              const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
              _ValueChip(label: newVal ?? '�', fg: kFgCyan, bg: kBgCyan),
              const SizedBox(width: 4),
              Text('${formatMaintenanceTs(revision.timestamp)}  ${revision.userId}',
                  style: GoogleFonts.jetBrainsMono(
                      fontSize: 10, color: const Color(0xFF546E7A))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({required this.label, required this.fg, required this.bg});
  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3)),
        child: Text(label,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 11, color: fg, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
