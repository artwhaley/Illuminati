# EOS Focus Remote Windows Phase — Orchestrator

## Role

Execute the UDP-only Windows build stack in dependency order. Deliver a complete
Windows release containing Setup, Focus Remote, and Cue Stack, then pause for a
deliberate user-led console test session.

Do not install Android Studio, generate Android, configure Codemagic, build an APK,
or begin mobile work. That becomes a separate stack only after Windows acceptance.

## Required reading before any edit

Read completely:

1. `AGENTS.md`
2. `papertek_eos_probe/README.md`
3. `tickets/EOS_FOCUS_REMOTE_TABBED_MOBILE.md`
4. every `tickets/EOS-P1-T*.md` file listed below
5. current `papertek_eos_probe` source and tests relevant to the active ticket

Product decisions are final:

- Position maps to Eos Focus Palette;
- Cue Only is the Eos CueOnly modifier, never Record_Only;
- Previous/Next remains in Focus Remote;
- UDP is the only application transport;
- send controls require no Connect/Start/feedback state.

## Stack order

1. `EOS-P1-T01_udp_send_boundary.md`
2. `EOS-P1-T02_settings_and_adaptive_shell.md`
3. `EOS-P1-T03_focus_command_model.md`
4. `EOS-P1-T04_focus_remote_ui.md`
5. `EOS-P1-T05_cue_stack_protocol_and_feedback.md`
6. `EOS-P1-T06_cue_stack_windows_ui.md`
7. `EOS-P1-T07_windows_release_and_test_handoff.md`

T03 may proceed alongside T02 only if files do not overlap. All earlier gates must
pass before T04, T05, or T06 changes their dependent surfaces. T07 is always last.

## Console safety and final pause

The live performance has ended, so Cue Stack implementation is no longer deferred.
That is permission to build and test against fakes/loopback—not permission for an
executor to send commands to the real console autonomously.

Throughout T01–T07:

- use in-memory messages, fake clients, and loopback UDP sockets;
- never address the cached console endpoint;
- never launch the build in a way that might send on startup;
- never click GO, Back, Stop, Record, Update, palette, level, or release controls
  against the console;
- never run exploratory network probes.

T07 delivers the Windows build and manual checklist, reports “Paused for Windows
testing,” and stops. The user will perform or explicitly direct live console tests
after reviewing the handoff.

## Explicit deferrals

- Android Studio and local Android SDK/JDK installation.
- Android runner generation and Android permissions.
- Codemagic configuration or cloud builds.
- APK/AAB, signing, distribution, and mobile-device testing.
- TCP connection, probing, fallback, discovery, or modality selection.
- Integration into the main PaperTek application.
- Any PaperTek database/show-file/schema change.

## Worktree protocol

1. Start with `git status --short`, `git diff --stat`, and an untracked-file
   inventory.
2. The worktree is dirty and `papertek_eos_probe` may be untracked. Preserve every
   pre-existing user/agent change. Never reset, checkout, clean, or overwrite files
   wholesale.
3. Do not modify unrelated `papertek/` files, its generated plugin files, or its
   lockfile.
4. Use `apply_patch` for source edits. Formatting tools may perform mechanical Dart
   formatting.
5. Capture a pre-stack package-test, `flutter analyze`, and `flutter test` baseline.
   Existing failures are comparison data, not permission for unrelated cleanup.
6. No database compatibility approval is granted by this stack.

## Ticket protocol

For each ticket:

1. announce the ticket and restate its boundary;
2. re-inspect current code—the ticket anchors do not authorize overwriting;
3. add focused contract tests first;
4. implement the smallest coherent change;
5. format touched Dart files;
6. run the focused gates;
7. report files and pass/fail delta;
8. proceed only when focused tests pass and no new analyzer errors exist.

If behavior already exists with adequate tests, preserve it and add only the missing
contract. Do not rewrite proven packet encoding.

## Blocked protocol

Stop and ask only when:

- user-owned changes conflict with a required edit and cannot be preserved;
- a product choice is not settled by these tickets;
- a focused gate cannot pass without entering an explicit deferral;
- separate GO/Back/Stop cannot be represented from documented Eos key names without
  a live test. In that case, implement the documented candidates and defer proof to
  T07's user checklist rather than transmitting autonomously.

## Final gates and terminal condition

Run T07’s complete automated gate list and produce the Windows Release directory.
The stack may not add test failures or analyzer errors.

The terminal condition is not “cue controls proven on the live console.” It is:

- complete Windows build produced;
- fake/loopback contracts passing;
- manual test checklist delivered;
- executor paused without sending to the console.

## Final report

Provide:

- result for T01–T07;
- exact files added/modified;
- focused/full test results and baseline delta;
- Windows Release directory path;
- proof sending works without Start/Connect or feedback;
- Focus command grammar and Previous/Next results;
- Cue Stack mappings, feedback parsing, and progress behavior;
- explicit confirmation that no real-console packet was sent;
- explicit confirmation that no Android/Codemagic/mobile work occurred;
- manual rehearsal checklist;
- final status: **Paused for Windows testing**.
