# EOS Phase 1 T04 — Desktop/mobile Focus Remote UI

## Depends on

T01, T02, and T03.

## Objective

Build the adaptive Focus Remote tab around the tested command model and stateless UDP
sender. Remove the level slider and old channel/level form. Preserve Previous/Next.

Implementation and widget testing use fake clients only. Live testing belongs to T05.

## Required UI

1. A persistent visible command line at the top with:
   - normalized token display;
   - validation/error text;
   - last locally transmitted command;
   - Clear and Backspace.
2. Large touch targets, minimum 48 logical pixels and preferably 56, for:
   - 0–9 and decimal point;
   - `@`, Full, Out, Release, Enter;
   - Position, Color, Beam;
   - Record, Update, Cue Only;
   - Clear and Backspace.
3. Physical keyboard handling for digits, decimal point, `@`, Enter, Backspace, and
   Escape/Clear without requiring focus changes.
4. Touch buttons must not require shifting focus into separate fields or summon the
   mobile software keyboard unnecessarily.
5. Remove the slider and separate channel/level text fields.
6. Keep Previous and Next below the keypad. They use the last successfully sent
   channel and numeric level:
   - release old channel;
   - change channel by exactly one;
   - set new channel to the remembered level;
   - one click performs the complete sequence;
   - prevent overlap/double-tap;
   - Previous cannot select below channel 1.
7. Show send configuration errors without navigating silently or disabling the
   entire tab. Provide a clear route to Setup.
8. Sending remains enabled with feedback stopped or faulted.
9. Do not add Cue Stack controls in this ticket; T06 owns that tab.

Record/Update buttons are present because they are part of the requested command
surface, but widget tests must prove they send nothing before Enter. Do not execute
their resulting commands against a live console in Phase 1.

## Responsive behavior

- No horizontal overflow at 320 logical pixels wide.
- Portrait phone prioritizes command line and numeric/action keypad; secondary
  palette/record rows may scroll vertically.
- Desktop may use additional width but must preserve the same token order and
  behavior.
- Controls must remain usable with touch only.

## Tests first

Use a fake sender/event recorder to verify:

- touch and keyboard build `1 @ 55 Enter` identically;
- Full, Out, Release auto-send exactly once;
- palettes map to correct Eos strings but only send on Enter;
- Record/Update/Cue Only token behavior and Enter requirement;
- Clear and Backspace do not change focus;
- no send-state gate depends on feedback;
- Previous/Next exact release/change/set order;
- duplicate Previous/Next taps cannot interleave;
- 320px portrait and desktop layouts have no overflow;
- visiting the temporary Cue Stack placeholder cannot cause a send.

## Acceptance gates

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build windows --release
```

Do not generate or build Android. Mobile work is outside this Windows-first stack.

## Completion report

Report UI files, keyboard/touch parity, responsive tests, Previous/Next sequence,
build results, and confirmation that no live-console testing occurred.
