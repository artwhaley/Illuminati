# T06 — Isolate and reset show-scoped state

## Objective

Prevent UI/controller state from one `.papertek` show from appearing in the next
show without performing the deferred service-registry breakup.

## Scope

Keep existing provider files and public names. Fix lifetimes/reset behavior only.

Audit and cover at least:

- `designerModeProvider` and the internal mode of `TrackedWriteRepository`;
- active report template, active template ID, dirty/autosave state;
- work-note and board-note filters;
- spreadsheet selection/view controller state;
- position selection/controller state;
- any global notifier whose state contains show row IDs.

## Required behavior

1. Define a stable session identity from the active canonical show path/session
   instance.
2. Show-scoped providers either watch that identity and rebuild/reset, or are
   invalidated centrally during session activation/closure.
3. New show activation begins in Tracked Changes mode in both UI and repository.
4. No report template from show A may be written into show B.
5. Closing with no replacement resets state before StartScreen is displayed.
6. Do not move providers into new registry files; that refactor is documented in
   `service registry- backlog project.md` and remains deferred.

## Tests

Create two temporary databases with different fixtures/templates. Open A, set
every audited state, close/open B, and assert B has defaults and no IDs/data from
A. Repeat B -> A to catch cached autoDispose providers.

No schema or visual redesign.

