# T04 — Show lifecycle, Save As, safe shutdown, and recoverable auto-backups

## Objective

Make a `.papertek` show safe to use for a real manual-entry production.

This ticket replaces ad-hoc database ownership with one session lifecycle, adds
Save As and Close Show controls to the Show page and File menu, guarantees an
orderly database close on every cooperative shutdown path, and maintains two
recoverable leapfrog snapshots in the operating-system temp directory.

This is a data-safety ticket. Do not combine it with importer, theme, report
layout, schema redesign, or general lint cleanup.

## Non-negotiable product decisions

These decisions are final; do not ask the user to choose alternatives.

1. **One owner for the active database.** A `ShowSessionNotifier` is the only
   code allowed to activate, replace, Save As, close, or shut down the current
   `AppDatabase`.
2. **Save As means duplicate and switch.** It creates a verified, standalone
   `.papertek` snapshot at the selected destination, closes the old connection,
   opens the destination, and makes the destination the active show. The source
   file is not modified or deleted.
3. **Never copy an open SQLite file with `File.copy`.** Use sqlite3's online
   backup API so committed WAL content is included and the result is consistent.
4. **Two backup slots per source path.** The files are `backup-a.papertek` and
   `backup-b.papertek`. Write the missing slot first; otherwise replace the
   older successful slot. Never retain more than these two completed slots for
   one source path.
5. **Default backup settings:** enabled, every 15 minutes. Allowed intervals are
   5, 10, 15, 30, and 60 minutes.
6. **Existing startup backups are protected for 30 minutes.** On opening or
   creating a show, completed slots already present for that source path must
   not be overwritten until `sessionOpenedAt + 30 minutes`. A missing slot may
   be filled during that window; an existing slot may not be replaced.
7. **No idle disk churn.** Drift table-update notifications mark the session
   dirty. A cheap source-file signature check is the fallback for custom/raw SQL.
   If neither indicates a change, a timer tick performs no snapshot and no hash.
   If a snapshot candidate is produced but its SHA-256 equals the newest
   completed backup, delete the candidate and do not rotate slots.
8. **Final backup on close.** When auto-backup is enabled and the show is dirty,
   explicit Close Show and application shutdown attempt a final snapshot. The
   30-minute protection rule still applies; it is valid to report
   `skippedProtected` when both old slots are protected.
9. **Explicit Close Show is cancelable on backup failure.** Offer Retry, Close
   Without Backup, and Cancel. Window close / Alt+F4 / File > Exit are best-effort
   for the final backup but always close the database in `finally` and then
   destroy the window.
10. **Backups are recoverable in-app.** The start screen gets `Recover Backup…`.
    Recovery never opens a temp backup in place. The user chooses a normal
    `.papertek` destination; the backup is copied through the verified snapshot
    path and that recovered destination is opened.
11. **No startup snapshot.** Merely opening a show does not create or rotate a
    backup. The first backup occurs on the next configured interval after a
    detected write, or during orderly close if dirty.
12. **No silent error swallowing.** Backup failures are surfaced to the user for
    explicit operations and retained as service status for Settings. Do not use
    empty `catch` blocks in new lifecycle code.

## Current problems being replaced

- `databaseProvider` is mutable from UI code and does not retain the active path.
- File > Exit calls `exit(0)`, bypassing the normal database-close path.
- Close Show closes the database directly from `MainShell`.
- Save As and recovery do not exist.
- The open SQLite database may have `-wal`/`-shm` companions, so copying only the
  main file is not a valid backup strategy.
- Report-template autosave is delayed by 500 ms and the timer is canceled during
  disposal; a quick close can lose the final edit.
- The app has no lifecycle-level barrier for pending debounced writes.

## Required architecture

### 1. Active session model and provider

Add `lib/services/show_session.dart`:

```dart
class ShowSession {
  const ShowSession({
    required this.database,
    required this.path,
    required this.openedAt,
  });

  final AppDatabase database;
  final String path;       // canonical absolute path
  final DateTime openedAt; // UTC
}
```

Replace the mutable `StateProvider<AppDatabase?> databaseProvider` with:

```dart
final showSessionProvider =
    NotifierProvider<ShowSessionNotifier, ShowSession?>(ShowSessionNotifier.new);

final databaseProvider = Provider<AppDatabase?>((ref) {
  return ref.watch(showSessionProvider)?.database;
});

final currentShowPathProvider = Provider<String?>((ref) {
  return ref.watch(showSessionProvider)?.path;
});
```

Existing read-only consumers may keep watching `databaseProvider`. Only replace
the two current mutation sites in `start_screen.dart` and `main_shell.dart` with
commands on `showSessionProvider.notifier`.

`ShowSessionNotifier` must serialize lifecycle operations with a single in-flight
future/lock. Double Close, Close during Save As, and two simultaneous Save As
requests must not race or close a database twice.

Required public operations:

```dart
Future<void> createShow(String path, {required String showName});
Future<String?> openShow(String path); // null success; message on gated failure
Future<void> saveAs(String destinationPath);
Future<CloseShowResult> closeShow({bool force = false});
Future<void> shutdown();
```

Activation must also reset show-scoped UI state, including designer mode and
active report-template selection, so state from the previous show cannot leak
into the next show.

### 2. Pending-write barrier

Add `lib/services/pending_write_coordinator.dart` with:

- `track<T>(Future<T> write)` to retain in-flight persistence futures.
- named `registerFlusher` / `unregisterFlusher` callbacks for debounced writers.
- `flushAndDrain()` that invokes every registered flusher, then awaits all
  tracked writes, including writes registered while draining. It must propagate
  the first error after waiting for all writes.
- a closed/disposed state that refuses new registrations.

There is one coordinator per active show session.

Move report-template debounce ownership out of the disposable widget timer or
register a real flusher that cancels the timer and **awaits** the latest
`ReportTemplateRepository.updateTemplate`. `ReportsTab.dispose()` must no longer
discard an unsaved template edit.

Before Save As, Close Show, or shutdown:

1. unfocus the current editor from the UI command;
2. call `flushAndDrain()`;
3. only then snapshot or close the database.

Do not use a fixed delay as a substitute for this barrier.

### 3. Verified SQLite snapshot service

Add `lib/services/sqlite_snapshot_service.dart`.

Use the already-declared direct `sqlite3` dependency:

1. Canonicalize source and destination paths.
2. Reject identical source/destination paths.
3. Create a unique `*.partial` file in the destination directory.
4. Open the source with raw sqlite3 read-only and the partial destination as a
   new database.
5. Set `PRAGMA busy_timeout = 5000` on both connections.
6. Run `await source.backup(destination, nPage: 64).drain<void>()`.
7. Dispose both raw connections in `finally`.
8. Reopen the partial read-only and require:
   - `PRAGMA quick_check` returns exactly `ok`;
   - `PRAGMA user_version` is not newer than
     `AppDatabase.currentSchemaVersion`;
   - `show_meta` exists and has one row.
9. Compute SHA-256 of the completed partial file.
10. Replace the target only after validation. Preserve an existing target until
    the partial is known-good. On Windows, use target -> `*.previous`, partial ->
    target, then delete `*.previous`; restore `*.previous` if promotion fails.
11. Clean partial/previous artifacts on all error paths without touching the
    valid source or last valid target.

Return a result containing path, byte length, SHA-256, and completion timestamp.
Add `crypto` as a direct dependency in `pubspec.yaml`; do not hand-roll SHA-256.

This same service is used by Save As, auto-backup, and recovery.

### 4. Backup paths and manifest

Add `lib/services/auto_backup_service.dart` and model classes as needed.

Root:

```text
${Directory.systemTemp.path}/papertek/backups/
```

Per-show directory name:

- canonicalize the absolute source path;
- lowercase it on Windows;
- SHA-256 the UTF-8 path;
- use the first 24 hex characters as the directory name.

Contents:

```text
backup-a.papertek
backup-b.papertek
manifest.json
```

Manifest schema version 1:

```json
{
  "version": 1,
  "sourcePath": "C:\\…\\show.papertek",
  "protectedUntilUtc": "2026-07-10T20:30:00.000Z",
  "slots": {
    "a": {"createdAtUtc": "…", "sha256": "…", "bytes": 123},
    "b": {"createdAtUtc": "…", "sha256": "…", "bytes": 123}
  }
}
```

Write the manifest through `manifest.json.partial` and promote it only after a
slot succeeds. Reconstruct a missing/corrupt manifest by validating any slot
files and using their filesystem timestamps. A bad manifest must never cause a
valid backup to be deleted.

On session start, set `protectedUntilUtc = openedAt + 30 minutes` whenever at
least one completed slot already exists. This may update only the manifest; it
must not touch the backup file bytes or timestamps.

### 5. Dirty detection and scheduling

The coordinator owns:

- one periodic `Timer` using the current setting;
- one subscription to `AppDatabase.tableUpdates()`;
- `_dirty`, `_backupInProgress`, `_lastSourceSignature`, and last result/error.

Rules:

- Any table update sets `_dirty = true`.
- The source signature contains main DB and `-wal` existence, byte length, and
  modified time. At a timer tick, compare it even when `_dirty` is false so raw
  SQL/external writes are detected without producing a backup.
- Never overlap backups. A tick during an active backup is coalesced into the
  next tick; do not queue multiple snapshots.
- Disabled settings cancel the timer but keep existing backup files untouched.
- Changing the interval restarts the timer from the settings-change time.
- A successful changed backup sets `_dirty = false` and refreshes the signature.
- An identical candidate is deleted, records `skippedUnchanged`, sets dirty
  false, and does not modify either slot or their timestamps.
- A failure leaves dirty true for retry on the next tick.
- Stop cancels timer and subscription and awaits any in-progress snapshot.

Inject `DateTime Function()` and a temp-root override for deterministic tests.

### 6. Backup settings

Add `lib/services/backup_settings.dart` and a Riverpod notifier following the
existing theme-settings persistence pattern.

Keys:

```text
papertek.backup.enabled.v1
papertek.backup.interval_minutes.v1
```

Defaults: `enabled = true`, `intervalMinutes = 15`.

Invalid/missing interval values resolve to 15. The UI only offers 5, 10, 15,
30, and 60. Initialize these settings before `runApp`, alongside theme settings.

Add a `DATA SAFETY` section to Settings with:

- `Automatic backups` switch;
- interval dropdown, disabled when backups are off;
- explanatory text: two temporary copies, written only after changes;
- current backup-directory path with a copy-path button;
- last backup time / last status / last error for the active show.

Settings are application-wide, not stored inside an individual show.

### 7. Save As and Close controls

Add a compact action strip above the show metadata card in the Show tab:

- left: filename and canonical path, ellipsized with full-path tooltip;
- right: `Save As…` and `Close Show` buttons.

Add the same commands to File menu in this order:

1. Save As…
2. Settings…
3. separator
4. Close Show
5. separator
6. Exit

Both UI surfaces must call shared command functions; do not duplicate lifecycle
logic.

Save As flow:

1. Unfocus current editor.
2. Pick a `.papertek` destination, defaulting to the current filename.
3. Normalize the extension.
4. If destination equals source, show a clear no-op error.
5. Flush pending writes.
6. Pause and await the backup coordinator.
7. Create and validate the snapshot at destination.
8. Close the source Drift database.
9. Open and validate the destination through `ShowFileService`.
10. Activate the new session and start its backup coordinator.
11. Show `Saved As <path>`.

If steps 7–9 fail, keep or reopen the source session and report the error. A
failed Save As must never leave the app with no open show if the source can still
be opened.

Close Show flow:

1. Confirm `Close <show name>?` with Cancel and Close.
2. Explain that database edits are already stored; mention pending review count
   if nonzero.
3. Unfocus, flush pending writes, and attempt final backup if required.
4. If final backup fails, offer Retry / Close Without Backup / Cancel.
5. Stop backup service, await it, close DB exactly once, clear show-scoped state,
   and return to StartScreen.

### 8. Unified application shutdown

Delete every `exit(0)` / `exit(...)` application path.

- File > Exit calls `windowManager.close()`.
- Title-bar X and Alt+F4 already arrive at `WindowListener.onWindowClose` because
  `setPreventClose(true)` is enabled.
- `onWindowClose` uses a reentrancy guard and calls exactly one shutdown method.
- `shutdown()` flushes pending writes, attempts the final backup, stops the
  backup coordinator, and closes the current DB in `finally`.
- Only after DB close completes: set prevent-close false, dispose the provider
  container, and destroy the window.
- When no show is open, the same shutdown path simply destroys the window.

Forced OS/process termination cannot run cleanup; do not claim otherwise in UI
or tests. Auto-backup is the recovery mechanism for non-cooperative termination.

### 9. Recovery UI

Add `Recover Backup…` below Open Show on StartScreen.

The recovery dialog scans `${temp}/papertek/backups/*/manifest.json`, validates
slots with `quick_check`, and shows only valid backups, newest first:

- show name (read from `show_meta`);
- snapshot time;
- original source path;
- slot A/B and file size.

Allow Refresh, Cancel, and Recover. On Recover:

1. prompt for a normal destination path;
2. refuse the temp backup path and the original source path as destination;
3. create a verified snapshot from backup to destination;
4. open the destination as the active show;
5. leave both temp slots unchanged.

If no valid backups exist, show a calm empty state. A corrupt slot should be
listed as invalid only if a sibling valid slot exists; never crash the dialog.

## Required files

Expected new files (names may be split further without changing behavior):

- `lib/services/show_session.dart`
- `lib/services/pending_write_coordinator.dart`
- `lib/services/sqlite_snapshot_service.dart`
- `lib/services/auto_backup_service.dart`
- `lib/services/backup_settings.dart`
- `lib/ui/settings/backup_settings_section.dart`
- `lib/ui/show/show_file_actions.dart`
- `lib/ui/recovery/recover_backup_dialog.dart`
- corresponding focused test files under `test/services`, `test/providers`, and
  `test/ui`

Expected modified files:

- `pubspec.yaml`
- `lib/main.dart`
- `lib/providers/show_provider.dart`
- `lib/services/show_file_service.dart`
- `lib/ui/start_screen.dart`
- `lib/ui/main_shell.dart`
- `lib/ui/show/show_tab_impl.dart`
- `lib/ui/settings/settings_dialog.dart`
- `lib/ui/reports/reports_tab.dart` or its extracted autosave controller

Do not edit generated `database.g.dart` for this ticket; there is no schema
change.

## Test requirements

### Snapshot service

1. Online backup includes committed rows while the Drift source remains open.
2. WAL-backed writes are present in the snapshot.
3. `quick_check` and `user_version` validation pass for a good snapshot.
4. Same source/destination is rejected.
5. A failed candidate preserves an existing destination.
6. Partial/previous files are cleaned after success and failure.

### Auto-backup

1. Defaults are enabled / 15 minutes.
2. Invalid preferences fall back to defaults.
3. First dirty interval creates slot A; second changed interval creates B;
   third changed interval replaces the older slot.
4. No table update + unchanged file signature produces no candidate file.
5. Candidate checksum equal to newest backup does not rotate or change mtimes.
6. Existing A and B survive every tick during the first 30 minutes after reopen.
7. A missing slot may be filled during the protection window.
8. At 30 minutes exactly, the oldest slot becomes replaceable.
9. Disabled setting writes nothing and preserves existing slots.
10. Interval change cancels the old timer and schedules the new interval.
11. Failure leaves dirty true and retries later.
12. Concurrent timer ticks never overlap snapshots.
13. Corrupt/missing manifest is reconstructed without deleting valid slots.

### Session lifecycle

1. Create and Open set both DB and canonical path.
2. Save As contains latest data and switches active path.
3. Save As failure leaves the source show active and usable.
4. Close Show drains pending writes, stops backup work, closes DB, and clears
   show-scoped providers.
5. Close called twice closes once and does not throw.
6. Shutdown during a backup awaits it, then closes DB.
7. A failed final backup cannot prevent shutdown DB close.
8. After close/shutdown, the former file can be renamed and opened exclusively,
   proving handles were released.
9. Designer/report selection state does not leak between two sequential shows.

### Widgets

1. StartScreen shows New, Open, and Recover Backup.
2. Show page and File menu expose Save As and Close Show.
3. Backup settings persist switch and every allowed interval.
4. Close failure dialog has Retry, Close Without Backup, and Cancel.
5. Recovery creates a user destination and does not alter temp backup mtimes.

## Acceptance gates

Run from `papertek/`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build windows --release
```

Because the repository currently has pre-existing analyzer/test debt, the patch
must meet both rules:

1. no new analyzer findings or test failures;
2. every new test listed above passes when run in isolation.

Also run these focused commands and include their full result in the completion
report:

```powershell
flutter test test/services/sqlite_snapshot_service_test.dart
flutter test test/services/auto_backup_service_test.dart
flutter test test/providers/show_session_provider_test.dart
flutter test test/ui/show_lifecycle_test.dart
rg -n "exit\(" lib
rg -n "databaseProvider\.notifier|\.close\(\)" lib/ui
```

The final two searches must find no application `exit()` and no UI ownership of
the database/provider lifecycle.

## Manual Windows rehearsal

Use a disposable show file, not a user show:

1. Create show, manually add fixture, wait configured interval, confirm A exists.
2. Edit fixture, wait, confirm B exists and both pass `PRAGMA quick_check`.
3. Make no edits for two intervals; confirm sizes/mtimes do not change.
4. Restart app and reopen show; edit repeatedly during first 30 minutes; confirm
   the two pre-start slots are not overwritten.
5. After 30 minutes, confirm only the older slot rotates.
6. Save As; confirm title/path switch and both source/destination open alone.
7. Exercise Close Show, File > Exit, title-bar X, and Alt+F4 separately; after
   each, confirm the file can be renamed immediately.
8. Kill the process after a backup, reopen the app, Recover Backup to a new
   destination, and verify the recovered fixture/report data.

## Completion report

Report:

- files added/modified;
- lifecycle ownership before/after;
- snapshot API and validation used;
- backup path, slot timestamps/hashes, and protection behavior observed;
- automated test counts and full gate results;
- manual rehearsal results for every shutdown path;
- any remaining limitation. Do not claim protection from forced termination
  beyond the most recent completed backup.

