# EOS Phase 1 T05 — Cue-stack protocol and feedback model

## Depends on

T01 stateless UDP sender and independent feedback receiver. T02–T04 should be stable
before this ticket begins so protocol work does not race the UI refactor.

## Objective

Implement and test the pure-Dart commands and feedback state needed by the Windows
Cue Stack tab. Use fake/loopback UDP only in this ticket. The live show has ended,
but protocol implementation is not permission for an executor to advance the real
console autonomously.

## Concrete anchors

- `papertek_eos_probe/packages/eos_osc_client/lib/src/eos_protocol.dart` currently
  contains `goMainPlayback()`, `stopBackMainPlayback()`, cue-fire commands, and cue
  response parsing.
- `papertek_eos_probe/packages/eos_osc_client/lib/src/eos_client.dart` already parses
  previous, active, and pending cue messages plus fade progress.
- `EosCuePlaybackState` already carries previous/active/pending identity/text and
  `fadeProgress`.
- The former screen contained cue enumeration and playback UI, but it was not
  reachable in the current two-card build and remained tied to `_isReady`.

## Playback command contract

Add distinct main-playback operations using official Eos key names:

- GO: `/eos/key/Go_Main_CueList`
- Back: `/eos/key/Back_CueList`
- Stop: `/eos/key/Stop_CueList`

Keep `/eos/key/Stop_Back_Main_CueList` available only as an explicitly labeled
fallback if the separate Back/Stop commands fail during later user-led testing. Do
not silently map two UI buttons to the same command.

Each press emits exactly one UDP datagram and is never retried. Sending remains
available without feedback listening. Remove or deprecate undocumented playback
addresses from the application-facing API when an official key command replaces
them, while preserving source compatibility where practical.

## Feedback contract

Parse and model:

- `/eos/out/previous/cue/<list>/<cue>[/<part>]` and `/text`;
- `/eos/out/active/cue/<list>/<cue>[/<part>]` and `/text`;
- `/eos/out/pending/cue/<list>/<cue>[/<part>]` and `/text`;
- `/eos/out/active/cue` progress with a numeric 0.0–1.0 argument;
- `/eos/out/event/cue/<list>/<cue>/<fire|stop|resume>`;
- `/eos/out/cuelist/1` bank summary;
- `/eos/out/cuelist/1/<row>` details: label, cue number/part, cue label, notes,
  scene, scene-end flag, duration, and remaining time.

Support `/eos/cuelist/1/config/0/1/1` to create a bank that follows the current cue
list with one previous and one pending cue. This configuration command may be sent
only when the user opens Cue Stack while feedback is already listening; never send
it at application startup or merely when settings are loaded.

After active/pending identity changes, support targeted
`/eos/get/cue/<list>/<cue>` requests and reuse the existing detailed cue parser.
Debounce duplicate identities. Do not enumerate all cue lists or all cues.

## State and staleness

The model must expose:

- previous/current/next identity and descriptive text;
- detailed current/next cue records when available;
- fade progress and last progress timestamp;
- latest event action;
- last feedback timestamp;
- whether feedback is listening, stale, or unavailable.

Treat feedback as stale after a documented threshold (recommended three seconds for
once-per-second active-cue output) without deleting the last known values.

## Tests first

Using in-memory messages and loopback UDP only, prove:

- GO, Back, and Stop compile to three distinct official key addresses;
- each playback operation emits one packet and never retries;
- playback sending does not require feedback;
- every feedback address above parses, including optional cue parts;
- progress clamps or rejects malformed out-of-range values consistently;
- cue-list bank row fields and remaining time parse correctly;
- duplicate identities do not cause duplicate targeted queries;
- stale state is deterministic with an injected clock;
- entering Cue Stack with feedback stopped sends no bank configuration/query;
- no test addresses the cached console endpoint.

## Acceptance gates

```powershell
Push-Location packages/eos_osc_client
dart format --output=none --set-exit-if-changed lib test
dart test
Pop-Location
flutter analyze
```

## Completion report

Report exact playback addresses, parsed feedback coverage, stale-state rule, test
results, and confirmation that no packet was sent to the live console.
