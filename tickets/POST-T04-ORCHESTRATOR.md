# Post-T04 hardening stack — Orchestrator

## Role

Execute the post-T04 hardening tickets in order. The worktree contains another
executor's lifecycle implementation. Treat it as user-owned work: inspect and
extend it, never reset, replace wholesale, or revert it.

## Precondition

The user must have confirmed the T04 executor is finished before this stack
starts. If files are still changing underneath you, stop and report that the
handoff is not stable. Do not race the other executor.

## Required reading

Read completely before editing:

1. `tickets/T04_show_lifecycle_save_as_autobackup.md`
2. every `tickets/POST-T04-T*.md` file listed below
3. `papertek/docs/ARCHITECTURE.md`
4. `SPEC.md` sections on revisions, undo/review, file versioning, and reports
5. `service registry- backlog project.md` for the boundary of the deferred work

## Stack order

1. `POST-T04-T05_lifecycle_completion_audit.md`
2. `POST-T04-T06_show_scoped_state_isolation.md`
3. `POST-T04-T07_maintenance_write_boundary.md`
4. `POST-T04-T08_importer_safety_cleanup.md`
5. `POST-T04-T09_error_handling_live_notes.md`
6. `POST-T04-T10_version_and_dependency_alignment.md`
7. `POST-T04-T11_spreadsheet_sort_contract_tests.md`

Do not reorder: lifecycle stability and state isolation must precede persistence
and UI contract work.

## Explicit deferrals

Do not work on these, even if analyzer/spec comments mention them:

- old `.papertek` migration/version-floor policy;
- making the full pre-existing test/analyzer suite clean;
- service-registry breakup;
- cloud/authentication;
- Syncfusion upgrade;
- importer feature expansion beyond T08.

## Worktree rules

- Start with `git status --short`, `git diff --stat`, and a list of untracked
  files. Preserve all pre-existing changes.
- Never run reset/checkout/clean or delete another executor's files.
- Do not edit `T04_show_lifecycle_save_as_autobackup.md`.
- Planning/backlog files are instructions, not production code.
- Use `apply_patch` for edits.
- Do not modify generated Drift code unless a ticket truly changes schema; none
  currently should.
- Keep each ticket behaviorally focused. Do not opportunistically lint unrelated
  files.

## Ticket protocol

For each ticket:

1. announce the ticket and restate its boundary;
2. inspect current code and tests—T04 may have changed since these tickets were
   authored;
3. write failing/contract tests first where required;
4. implement the smallest coherent fix;
5. format touched Dart files;
6. run the focused tests named by the ticket;
7. run `flutter analyze` and compare with the captured pre-stack baseline;
8. report changed files, focused results, and remaining pre-existing findings;
9. proceed only when the ticket's focused tests pass.

If a ticket's requested behavior already exists and is proven by adequate tests,
do not rewrite it; add only missing coverage or mark the ticket satisfied with
evidence.

## Baseline policy

The user deliberately deferred full test-suite cleanup. At stack start, capture:

```powershell
flutter analyze
flutter test
```

These establish a comparison baseline, not a demand to fix unrelated failures.
The completed stack may not add analyzer findings or failures. Every new/focused
test must pass.

## Blocked protocol

Stop and report before proceeding only when:

- the T04 executor is still changing the same files;
- user-owned changes conflict with a required edit and cannot be preserved;
- current behavior contradicts `SPEC.md` in a way that requires a product choice
  not already settled by the ticket;
- a focused ticket test cannot pass without entering an explicit deferral.

Report the exact file/behavior, evidence, and smallest choices. Do not guess or
silently broaden scope.

## Final gates

After all focused gates pass:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build windows --release
rg -n "exit\(" lib
rg -n "db\.(into|update|delete)|customStatement" lib/ui
rg -n "print\(" lib
```

Classify any remaining output as pre-existing, introduced, or intentionally
deferred. No introduced failure is acceptable.

## Final report

Provide:

- result for each T05–T11;
- exact files changed;
- focused tests and counts;
- analyzer/full-suite delta from baseline;
- Windows release-build result;
- T04 gaps found and closed;
- explicit confirmation that migration policy and service-registry breakup were
  not performed;
- any genuine blocker still requiring user input.

