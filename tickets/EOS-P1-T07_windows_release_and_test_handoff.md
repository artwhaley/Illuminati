# EOS Phase 1 T07 — Windows release and deliberate test handoff

## Depends on

T01–T06 complete with all focused tests passing.

## Objective

Produce the complete Windows release build, perform non-live automated verification,
write a concise manual rehearsal checklist, and pause. Do not autonomously execute
that checklist against the console.

This ticket is the end of the current stack. Android Studio, Android runner
generation, Codemagic, APK/AAB builds, signing, and mobile testing are all deferred
until the user accepts the Windows behavior and starts a separate mobile stack.

## Final automated gates

From `papertek_eos_probe/`:

```powershell
Push-Location packages/eos_osc_client
dart format --output=none --set-exit-if-changed lib test
dart test
Pop-Location
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build windows --release
```

Also classify these searches:

```powershell
rg -n "EosTcpTransport|Socket\.connect|3032|requireHandshake" lib
rg -n "Go_Main_CueList|Back_CueList|Stop_CueList|Stop_Back_Main_CueList" lib packages
rg -n "Record_Only" lib packages
```

The application must not instantiate/select/probe TCP. The reusable package may
retain dormant TCP classes. No Focus Remote path may generate `Record_Only`.

## Windows deliverable

Provide the complete runnable Release directory, not only the `.exe`, and report its
absolute path. Confirm the app can launch without sending and that all three tabs are
reachable. Do not open it against the live console if launch would load real cached
settings into an unverified control path; use widget tests or a safe local endpoint
for launch smoke testing.

## Manual test checklist to deliver

Prepare a short ordered checklist for the user-led session:

1. **Setup/send independence**
   - verify cached endpoint;
   - leave feedback stopped;
   - set one known-safe channel to an agreed level and Release it;
   - confirm no Start/Connect action was needed.
2. **Focus keypad**
   - `1 @ 55 Enter`-style numeric entry on a designated safe channel;
   - Full, Out, Release;
   - Previous/Next only after adjacent channels are confirmed safe;
   - Position/Color/Beam only on a suitable fixture and agreed palette;
   - Record/Update/Cue Only only in a disposable test cue context.
3. **Feedback**
   - configure console OSC TX IP and port for this computer;
   - Start feedback;
   - confirm current/next cue and last-feedback time update.
4. **Cue Stack**
   - choose a disposable/safe cue list or rehearsal context;
   - test GO once and verify exactly one advance;
   - test Stop during a timed fade;
   - test Back once;
   - verify current/next labels and progress behavior;
   - if separate Back/Stop key names fail, capture the TX log and console behavior
     before trying the clearly labeled Stop/Back fallback.
5. **Failure behavior**
   - Stop feedback and confirm focus/playback sending remains enabled;
   - restore feedback and confirm no stale command is replayed.

The checklist is documentation, not executor authorization. The executor must stop
after delivering it and wait for the user to conduct or explicitly direct each live
test.

## Completion report

Provide:

- result for every T01–T07 ticket;
- exact files added/modified;
- focused/full test results and analyzer delta from baseline;
- Windows Release directory path;
- proof no sender connection prerequisite remains;
- exact Focus grammar and cue-button OSC mappings;
- explicit confirmation that no live-console command was sent by the executor;
- explicit confirmation that Android/Codemagic/mobile work was not started;
- the manual checklist and a clear “Paused for Windows testing” final status.
