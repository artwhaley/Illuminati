# Fixture deletion reliability

## Status

Diagnosis and specification only. Any change to delete semantics requires explicit approval under the project's database-compatibility rule.

## Current diagnosis

The intended persistence path is a soft delete:

1. the spreadsheet's `onCellSecondaryTap` opens a fixture context menu;
2. `Delete Fixture` calls `SpreadsheetViewController.deleteFixture`;
3. `FixtureRepository.deleteFixture` runs a tracked transaction and sets `fixtures.deleted = 1`;
4. `FixtureRepository.watchRows` watches the `fixtures` table and queries only `deleted = 0` rows.

Therefore, a successful database update should automatically remove the fixture from the UI. There is no separate refresh call missing in this path.

The present UI starts the asynchronous delete from `PopupMenuItem.onTap` without awaiting it, confirmation, progress state, success feedback, or error handling. If the menu callback does not fire, snapshot creation fails, the tracked transaction rolls back, or the database update fails, the user sees the same symptom: nothing happens. Static inspection cannot distinguish those runtime cases, but it rules out "successful delete followed by forgotten refresh" as the designed behavior.

### CAA 2026b evidence (2026-07-11)

- The reported fixture is fixture `id = 22`, first intensity part `id = 78`, position `1st Electric`, channel/dimmer `345`, purpose `Work Light`.
- After repeated deletion attempts, the persisted fixture still has `deleted = 0`.
- There are no delete revisions for fixture 22 and no fixture-delete revisions anywhere in this show file.
- `PRAGMA quick_check` reports `ok`; the file is schema/user version 22 and is not marked read-only.
- On a disposable copy, both the raw soft-delete update and the complete update-plus-delete-revision transaction succeed. The fixture FTS update trigger also completes correctly.

This rules out a successful delete with stale spreadsheet data, a corrupt fixture row, a read-only show file, a failing FTS trigger, and an invalid revision payload. The failure is in the unobserved Dart/UI execution path before transaction completion. Because both the right-click menu and sidebar button fire-and-forget the same future, any asynchronous exception is discarded and never reaches the user or persistent logs.

## Required diagnostic work

- Reproduce against a disposable copy of the current imported show, never the production test-show file.
- Record fixture ID and pre-delete `deleted` value.
- Trigger deletion from the right-click menu and observe whether the controller/repository method is entered.
- Await the operation and capture any exception through the app logger.
- Query the row after the action and observe the fixture stream emission.
- Repeat in tracked and designer modes, with and without pending revisions.
- Verify deletion from the sidebar action to separate context-menu problems from repository problems.

Classification:

- method not entered: context-menu/gesture wiring bug;
- method entered, transaction throws, `deleted` remains `0`: persistence/tracking bug;
- method completes, `deleted` becomes `1`, stream does not emit: Drift watch/invalidation bug;
- method completes, stream emits without the row, grid still displays it: `FixtureDataSource` refresh bug.

## Required behavior

- Right-clicking any fixture or multipart child opens the menu for the owning fixture.
- Choosing delete asks for confirmation identifying channel/unit/type where available.
- Confirmed deletion is awaited exactly once and disables duplicate submission.
- Success clears stale grid/sidebar selection and the watched row disappears.
- Failure leaves the fixture present and shows a visible error with a logged technical cause.
- Cancel performs no write and creates no revision.
- Undo/redo and commit behavior remain consistent with the existing soft-delete lifecycle.

## Compatibility constraint

Keep `fixtures.deleted = 1` soft-delete semantics unless a separate compatibility discussion explicitly approves a change. Do not hard-delete fixture rows or alter cascade behavior as part of a UI fix.

## Tests

- Repository test: deleting an active fixture changes `deleted` from `0` to `1`, creates the correct tracked revision, and removes it from `watchRows`.
- Repository rollback test: injected revision/snapshot failure leaves `deleted = 0`.
- Widget test: secondary-click menu invokes deletion once and awaits completion.
- Widget test: success removes the row and clears selection; failure retains the row and displays an error.
- Multipart test: deleting from a child row targets the owning fixture once.
- Undo/redo test: delete, undo, and redo restore the expected visibility and related data.
