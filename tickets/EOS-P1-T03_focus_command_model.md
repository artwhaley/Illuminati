# EOS Phase 1 T03 — Focus command parser and OSC compiler

## Depends on

T01 stateless UDP sender. May proceed alongside T02 if files do not overlap.

## Objective

Implement the pure-Dart token buffer, validation, and Eos command compiler used by
the touch/keyboard Focus Remote. This ticket has no live-console test.

## Product decisions

- UI `Position` means Eos `Focus Palette`.
- `Cue Only` means the Eos `CueOnly` modifier, never `Record_Only`.
- Previous/Next is retained but remains outside the command grammar.
- One channel and one action/record target per command in Phase 1.

## Required grammar

Compile these normalized commands:

| Input tokens | `/eos/newcmd` string |
| --- | --- |
| `1 @ 55 Enter` | `Chan 1 At 55 Enter` |
| `1 Full` | `Chan 1 Full Enter` |
| `1 Out` | `Chan 1 Out Enter` |
| `1 Release` | `Chan 1 Sneak Time 0 Enter` |
| `45 Color 5 Enter` | `Chan 45 Color Palette 5 Enter` |
| `45 Position 5 Enter` | `Chan 45 Focus Palette 5 Enter` |
| `45 Beam 5 Enter` | `Chan 45 Beam Palette 5 Enter` |
| `Record 4 Enter` | `Record Cue 4 Enter` |
| `Update Enter` | `Update Enter` |
| `Update Cue Only Enter` | `Update CueOnly Enter` |
| `Record 4 Cue Only Enter` | `Record Cue 4 CueOnly Enter` |

Full, Out, and Release are terminal actions. Numeric level, palette, Record, and
Update commands require Enter. Record/Update controls only append tokens until Enter.

## Required behavior

1. Use typed tokens/parser state, not arbitrary string concatenation.
2. Support channel and cue/palette decimal values where Eos allows them; channel
   itself remains a positive whole number.
3. Validate intensity 0–100 and positive target numbers.
4. Support Clear and Backspace deterministically.
5. Reject incomplete, ambiguous, duplicate-action, range, group, `Thru`, `+`, and
   `-` commands without sending.
6. Emit one complete `/eos/newcmd` message only at a valid terminal action.
7. Retain invalid input and return a user-readable validation error.
8. Do not implement arbitrary OSC or arbitrary Eos command text.
9. Do not alter the proven direct level/release methods used by Previous/Next.

Place the parser in the pure Dart client package if it is genuinely reusable and
Flutter-free; otherwise place it under `lib/focus/` with no widget dependencies.

## Tests first

- exact success case for every row above;
- Full/Out/Release terminate without Enter;
- Record/Update never terminate before Enter;
- Position compiles to Focus Palette;
- no path emits `Record_Only`;
- invalid level/channel/target and incomplete commands emit no OSC;
- Clear resets all state;
- Backspace removes the last numeric digit or semantic token correctly;
- one terminal action yields exactly one datagram-worthy `OscMessage`.

Tests must inspect messages in memory or use loopback. Never use the console IP.

## Acceptance gates

```powershell
Push-Location packages/eos_osc_client
dart format --output=none --set-exit-if-changed lib test
dart test
Pop-Location
flutter analyze
```

## Completion report

Report grammar coverage, rejected syntax, exact Release compilation, and confirmation
that no live packets or Record_Only commands were produced.
