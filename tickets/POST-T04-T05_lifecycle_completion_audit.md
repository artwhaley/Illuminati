# T05 — Complete and verify T04 lifecycle work

## Purpose

T04 was implemented by another executor in the shared worktree. Audit the final
implementation against `T04_show_lifecycle_save_as_autobackup.md`; do not redo
working code and do not assume the in-progress snapshot described below is
still current.

## Precondition

Do not begin until the T04 executor has finished and the user has handed off the
worktree. Preserve all T04 changes. Never reset or overwrite them wholesale.

## Mandatory audit points

Confirm each behavior with code plus a focused test. Fix only gaps that remain:

1. Pending-write coordinator is actually exposed, used by report-template
   debounce, and drained before Save As/Close/Exit. Merely constructing it is
   not implementation.
2. Changing backup enabled/interval settings updates the active backup service
   immediately.
3. Dirty detection uses Drift updates **and** main/WAL file signatures so custom
   SQL is not missed.
4. Windows replacement of an existing backup slot and `manifest.json` works.
   `File.rename` must not be asked to overwrite an existing Windows target.
5. Save As failure restarts/retains the source session and its backups. Opening
   a bad replacement must not close a valid current show first.
6. Explicit Close Show has confirmation and, on final-backup failure, Retry / 
   Close Without Backup / Cancel. Both Show-page and File-menu controls use the
   same flow.
7. Existing backup slots survive the first 30 minutes after reopen; missing
   slots may be filled; exact boundary behavior is tested with an injected clock.
8. Identical backup candidates do not rotate slots or alter completed-slot
   mtimes.
9. Settings shows live last backup time/status/error, not just the directory.
10. Recovery validates `quick_check`, reads show name/time, sorts newest first,
    rejects source/temp destinations, and never mutates backup mtimes.
11. Show-scoped UI state reset required by T04 is present or explicitly handed
    to T06 without leaving a misleading designer-mode state.
12. All cooperative exits close the DB exactly once. `rg -n "exit\(" lib` is
    empty and UI code never owns `database.close()`.

## Known risks observed during the in-progress implementation

Re-check rather than blindly patch:

- backup rotation renamed a candidate onto an existing slot;
- manifest partial was renamed onto an existing manifest;
- settings updates had no listener into `AutoBackupService`;
- no file-signature fallback existed;
- pending-write coordinator had no consumers;
- Save As stopped backups before work that could fail;
- Open Show closed the current show before validating the replacement;
- recovery scanned manifests without SQLite validation;
- Show-page Close called the notifier directly without confirmation.

## Tests and gates

Implement every test required by T04. At minimum run:

```powershell
flutter test test/services/sqlite_snapshot_service_test.dart
flutter test test/services/auto_backup_service_test.dart
flutter test test/providers/show_session_provider_test.dart
flutter test test/ui/show_lifecycle_test.dart
flutter build windows --release
```

Report pre-existing failures separately; introduce none.

