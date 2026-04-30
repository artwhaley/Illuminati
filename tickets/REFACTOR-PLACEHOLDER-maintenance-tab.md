# REFACTOR-PLACEHOLDER: Refactor `maintenance_tab.dart`

> **STATUS: NOT PLANNED YET**  
> This is a placeholder to ensure this refactor is not forgotten.  
> Do not execute this ticket until the user has reviewed and expanded it into full tickets.

---

## Why this refactor is needed

`maintenance_tab.dart` is approximately 971 lines after the recent rewrite. The card-based
review UI is well-structured internally, but all card types, row renderers, staging logic,
and the tab shell are inlined in one file. As the feature grows (more revision types,
more card layouts), this will become unwieldy.

Additionally, `_ColDef` and `_kFixtureCols` will be replaced by `ColumnSpec` references
as part of the REFACTOR-COL batch — that change should be complete before a structural
refactor of this file, or the structural refactor plan should account for the already-removed
`_ColDef`.

## What a full plan should include

When this placeholder is converted to a real plan:

1. **Extract `_RevisionCard` and its body types**: `_TabularCardBody`, `_GenericCardBody`,
   `_HeaderRow`, `_ReadOnlyRow`, `_StagingRow`, `_HistoryRow` model class — each to its own
   file in `papertek/lib/ui/maintenance/widgets/`.
2. **Extract `_ActionButton`**: to `widgets/action_button.dart`.
3. **Extract `EditReviewTab`**: this is currently the inner tab body. Consider whether it
   should become the main content of the file or a separate widget.
4. **Extract decision state**: The `Map<int, ReviewDecision> _decisions` state in
   `EditReviewTab` is a candidate for a `StateNotifier` provider, which would allow the
   `_StagingRow` to read and update decisions without needing callbacks threaded through.
5. **Target line count**: Main file under 250 lines.

## Prerequisites

- REFACTOR-COL-001, 003, 004 should be complete first (replaces `_ColDef` with `ColumnSpec`,
  removes per-column switch in `_StagingRow._save`).
- After COL refactor, the file will be somewhat simpler — re-count lines before planning.

## Files to read before planning

- `papertek/lib/ui/maintenance/maintenance_tab.dart` (the target, read in full)
- `papertek/lib/services/commit_service.dart` (the service it calls)
- `papertek/lib/repositories/revision_repository.dart` (the data model it displays)
