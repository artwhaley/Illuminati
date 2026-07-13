# EOS Phase 1 T06 — Windows Cue Stack UI

## Depends on

T01–T05 complete with focused tests passing.

## Objective

Replace the Cue Stack placeholder with the complete Windows cue-status and playback
surface. Keep it responsive enough for later mobile reuse, but do not generate or
build Android in this stack.

Implementation and widget tests use fake clients only. Live console testing is
reserved for the user-led session after T07 delivers the Windows build.

## Required UI

1. Display previous, current, and next cue prominently, including list, cue, part,
   label, and duration when available.
2. Show richer current/next details from cue-list bank or targeted cue responses:
   notes, scene, up/down/focus/color/beam times, follow/hang, and other already parsed
   fields when present. Missing fields render calmly rather than as errors.
3. Show determinate fade progress from 0–100% while current feedback is available.
   Show complete, stale, or unavailable states honestly; never infer completion from
   local button presses.
4. Display last-feedback time and listener status.
5. Provide large, separated GO, Back, and Stop buttons for main playback.
6. GO, Back, and Stop remain enabled when feedback is unavailable because sending is
   independent. Their local status says “sent,” never “executed” or “acknowledged.”
7. Never retry or double-send a playback command. Suppress accidental duplicate
   pointer activation while one local send call is in flight.
8. When the tab becomes active and feedback is already listening, configure/follow
   cue-list bank 1 once and request targeted details. Re-entering without relevant
   state change must not create a request storm.
9. When feedback is stopped, show setup instructions and last in-memory state marked
   stale. Do not auto-start feedback.
10. A receiver bind error must not disable GO/Back/Stop or Focus Remote.
11. Keep diagnostics on Setup rather than filling the Cue Stack page with raw OSC.

## Safety and testability

- No command is sent on app launch.
- Opening Setup or Focus Remote never sends a cue command.
- Opening Cue Stack sends only its documented bank/query setup and only when feedback
  is already listening.
- Widget tests inject fake sender/receiver implementations and never use real cached
  settings.
- Do not add Record/Update controls to Cue Stack; those remain in Focus Remote’s
  command surface.

## Widget tests first

- previous/current/next and detailed fields render from fake events;
- fade progress and stale/unavailable states render correctly;
- GO, Back, and Stop invoke three distinct fake-client operations once each;
- rapid repeated activation cannot interleave duplicate sends;
- feedback failure leaves all send controls enabled;
- first tab activation with listening feedback configures one bank and targeted
  query; repeated rebuilds do not resend;
- activation without feedback sends nothing;
- 320 logical pixel width has no overflow even though Android is deferred;
- navigation among all tabs preserves command and cue state;
- app startup sends zero datagrams.

## Acceptance gates

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build windows --release
```

The build here is a compilation gate, not the final handoff build.

## Completion report

Report UI state behavior, exact button-to-command mapping, request deduplication,
widget results, Windows compilation result, and confirmation that no live console
command was sent.
