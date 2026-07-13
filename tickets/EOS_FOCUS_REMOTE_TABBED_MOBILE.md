# Eos Focus Remote: UDP-only tabbed desktop/mobile UI

## Status

Specification only. This ticket does not authorize a transport change. The app
remains UDP-only until a separate discussion explicitly reopens TCP work.

Product decisions confirmed:

- the Position button maps to Eos Focus Palette;
- Cue Only means the Eos CueOnly modifier, never Record_Only;
- Previous and Next remain in the Focus Remote.

Phase 1 now ends at a complete Windows release build containing Setup, Focus Remote,
and Cue Stack. The live show has ended, so cue-stack functions may be implemented
and prepared for deliberate testing. The executor still must not autonomously send
live-console commands: after producing the Windows build and manual test checklist,
it pauses for the user-led test session. Android, Codemagic, and all mobile work are
deferred to a later stack after the Windows behavior is accepted. See
`EOS-P1-ORCHESTRATOR.md` for the executable ticket stack.

This work does not touch the PaperTek database, show-file schema, import/export
formats, or persistence lifecycle. Endpoint settings remain app-local preferences.

## Outcome

Rework the existing Eos probe into a three-tab remote that is comfortable on a
Windows desktop and an Android phone:

1. **Setup** — UDP endpoint, optional source-interface binding, optional feedback
   listener, and diagnostics.
2. **Focus Remote** — a self-contained Eos-style command line and touch keypad.
3. **Cue Stack** — current/next cue status, fade progress, and main-playback
   controls.

The app must open directly into usable controls. Sending a command must not require
the user to press Connect, Start, or any equivalent first.

## Non-negotiable transport boundary

- Use one unframed OSC UDP datagram per command.
- Do not use TCP, probe TCP, fall back to TCP, or expose a TCP selector.
- Keep the proven channel-level representation: OSC `int32` in the range 0–100.
- Treat send and receive as independent capabilities.
- Never disable send controls merely because feedback is stopped or unavailable.
- Never automatically retry show-control commands. A successful socket send means
  only that the operating system accepted the datagram, not that Eos executed it.

UDP does not have a connection session. The sender does still need a local datagram
socket and a destination, but the app can create the sender lazily on the first
command and retain it until settings change or the app closes. The existing global
`EosConnectionState.ready` gate is therefore the wrong abstraction for normal UDP
transmission and must be removed from operational controls.

## Architecture change

Split the current combined client lifecycle into two explicit services.

### UDP command sender

- Loads and validates the cached console host, console UDP RX port, and optional
  local source address at startup.
- Lazily binds an ephemeral source port and sends immediately.
- Recreates its socket only when an endpoint setting changes, the socket faults, or
  the app resumes after the platform has invalidated it.
- Has states such as `configured`, `sending`, and `error`; it does not claim to be
  connected to Eos.
- Exposes the last local send time and last local socket error for diagnostics.

### Optional feedback receiver

- Binds the configured local feedback port only when **Start feedback** is pressed
  (or when a later opt-in auto-start preference is enabled).
- Receives Eos OSC output and query responses.
- Has independent `stopped`, `listening`, and `faulted` states.
- A bind failure is shown on Setup and Cue Stack but does not close or disable the
  sender.
- **Stop feedback** closes only the receive socket and cancels pending queries. It
  sends no cleanup command to Eos.

The current `EosUdpTransport` already owns separate send and receive sockets, but
`EosOscClient` and the screen currently wrap both in a TCP-shaped
connect/ready/disconnect lifecycle. Refactor that boundary rather than layering a
second fake connection state over it.

## Navigation and adaptive layout

Use Material 3 tab navigation with stable per-tab state:

- phones/narrow portrait: bottom `NavigationBar`;
- desktop/tablet landscape: `NavigationRail` when width allows;
- each tab owns a scroll view and respects safe areas;
- command state survives tab changes but not app restarts;
- cached setup survives app restarts;
- no control requires hover, right-click, or a hardware keyboard.

The initial tab should be **Focus Remote** when cached send settings are valid. If
settings are missing or invalid, open **Setup** and explain what is required.

## Setup tab

### Fields

- Console IP/host (required).
- Console OSC UDP RX port (required; default 8000).
- Local/source IPv4 (optional; blank means let the OS choose the route).
- App feedback-listen port (optional; default 8001).

Label ports by direction, not merely `Port`:

- “Console OSC UDP RX (app sends here)”
- “App UDP RX (console sends here)”

Show a short console checklist: OSC RX enabled for commands; OSC TX enabled for
feedback; console OSC TX IP set to this device; console OSC TX port equal to the
app feedback-listen port.

### Actions and status

- **Save settings** validates and caches values; it sends nothing.
- **Start feedback** / **Stop feedback** controls only the receive socket. These
  replace misleading Connect/Disconnect wording.
- **Test send** sends a harmless `/eos/get/version` only if feedback is listening;
  otherwise it explains that a round trip cannot be verified. It must not gate
  ordinary sending.
- Display “Send configured” separately from “Feedback listening.” Never display
  “Connected” for UDP.
- Keep a compact recent error/TX/RX diagnostic area on Setup, not permanently on the
  Focus Remote tab.

When settings change, save them atomically to the existing app-local JSON settings
file. Do not erase the last valid cache when edited values fail validation.

## Focus Remote tab

### Command-line model

Build commands in an app-owned token buffer. Do not mirror individual keypad presses
to the Eos command line. Only a terminal action sends a single `/eos/newcmd` OSC
message with a complete command string. This avoids half-entered console state and
packet-order dependence.

The visible command line is always present at the top. It must:

- show normalized Eos wording as tokens are entered;
- keep keyboard focus without requiring the user to tap between controls;
- support physical digits, decimal point, `@`, Enter, Backspace, and Escape/Clear;
- allow touch buttons to append tokens without summoning the software keyboard;
- include **Backspace** and **Clear** controls;
- retain invalid commands and show a validation message;
- clear after a datagram is successfully handed to the local socket;
- show the last transmitted command below the input as confirmation.

Use an internal parser/AST rather than concatenating arbitrary strings. For this
release, accept one channel and one action/record target per command. Ranges, groups,
`Thru`, `+`, and `-` are explicitly out of scope.

### Keypad

Provide large touch targets (minimum 48 logical pixels, preferably 56) for:

- digits 0–9;
- decimal point;
- `@`;
- Full;
- Out;
- Release;
- Enter;
- Backspace;
- Clear.

Full, Out, and Release are terminal actions and send immediately when the current
buffer contains a valid channel. Enter is required for numeric level, palette,
Record, and Update commands.

### Required command behavior

| User input | App-normalized Eos command | Send timing |
| --- | --- | --- |
| `1 @ 55 Enter` | `Chan 1 At 55 Enter` | Enter |
| `1 Full` | `Chan 1 Full Enter` | Full |
| `1 Out` | `Chan 1 Out Enter` | Out |
| `1 Release` | `Chan 1 Sneak Time 0 Enter` | Release |
| `45 Color 5 Enter` | `Chan 45 Color Palette 5 Enter` | Enter |
| `45 Position 5 Enter` | `Chan 45 Focus Palette 5 Enter` | Enter |
| `45 Beam 5 Enter` | `Chan 45 Beam Palette 5 Enter` | Enter |
| `Record 4 Enter` | `Record Cue 4 Enter` | Enter |
| `Update Enter` | `Update Enter` | Enter |
| `Update Cue Only Enter` | `Update CueOnly Enter` | Enter |
| `Record 4 Cue Only Enter` | `Record Cue 4 CueOnly Enter` | Enter |

The UI label **Position** maps to Eos **Focus Palette** terminology. Palette
selection buttons append a target token and do not send until a palette number and
Enter are supplied.

Do not replace Release with intensity zero. Preserve the current immediate Sneak
release behavior unless a separate live-console test proves a more direct Eos method
returns manual data to its background value correctly.

### Record/update safety

- Record and Update buttons only append tokens; they never auto-enter.
- Cue Only only appends the modifier.
- Record/update commands are never retried.
- Show a distinct destructive-action color for Record and Update.
- Do not add a generic free-form OSC sender in this release.

### Existing focus workflow

Retain Previous and Next as convenience actions. Each performs the existing atomic
sequence: release the old channel, adjust by one, and set the new channel to the
last explicit numeric level. Put these controls below the keypad as optional focus
navigation, not inside the command grammar. Disable Previous only when it would
select a channel below 1.

Remove the level slider and the old separate channel/level fields.

## Cue Stack tab

### Controls

Expose large, separated **GO**, **Back**, and **Stop** buttons for the main playback.
Use official Eos key names and verify each against the live Ion XE before release.
The first implementation candidates are:

- `/eos/key/Go_Main_CueList`
- `/eos/key/Back_CueList`
- `/eos/key/Stop_CueList`

If the console version does not accept those independently, do not silently collapse
Back and Stop into one action. Report the protocol limitation and retain a clearly
labeled **Stop/Back** fallback using `/eos/key/Stop_Back_Main_CueList` until separate
commands are proven.

Playback commands are send-only and remain enabled without feedback.

### Live feedback

When feedback is listening, parse and render:

- `/eos/out/previous/cue/...` and `/text`;
- `/eos/out/active/cue/<list>/<cue>` and `/text`;
- `/eos/out/pending/cue/...` and `/text`;
- `/eos/out/event/cue/<list>/<cue>/<fire|stop|resume>`;
- the active-cue float as a 0.0–1.0 progress value.

Eos documents active-cue progress as updating once per second. Show a determinate
progress bar while a fade is in progress, 100% when complete, and an indeterminate
or unavailable state when no progress packet has been received. Display a “last
feedback” timestamp so stale data is obvious.

On entry to the tab, start/follow OSC cue-list bank 1 with
`/eos/cuelist/1/config/0/1/1` when feedback is listening. List 0 follows the current
cue list. Parse `/eos/out/cuelist/1` and `/eos/out/cuelist/1/<row>` to obtain labels,
notes, scene, duration, and remaining time for the previous/current/next rows. This
provides richer information than the active/pending text alone.

Also request detailed cue records with `/eos/get/cue/<list>/<cue>` after active or
pending identity changes, then reuse the existing typed cue parser to display all
available fields. Debounce duplicate identities and do not enumerate every cue list
or every cue just to render this tab.

After GO, Back, or Stop:

- send exactly one playback datagram;
- do not retry;
- if feedback is listening, await normal output and issue a targeted refresh only
  if no update arrives within about 1.25 seconds;
- if feedback is stopped, leave the controls enabled and label status “Feedback
  unavailable”; do not pretend the action was acknowledged.

### Initial and fallback behavior

There is no meaningful pull response without a receive listener. Therefore:

- entering Cue Stack with feedback stopped shows instructions and the last cached
  in-memory state, marked stale;
- entering with feedback listening configures the cue-list bank and requests only
  the current detailed records;
- normal implicit active/pending output is preferred over polling;
- OSC Subscribe is reserved for show-data edits. Playback status does not require a
  general `/eos/subscribe=1` subscription.

## Android work

- Generate the Android runner and add Internet/network-state permissions required
  for UDP.
- Validate lifecycle behavior when the app backgrounds and resumes; recreate invalid
  sockets without replaying commands.
- Do not keep the screen awake by default; this can be a later explicit setting.
- Verify navigation with gesture insets, small portrait screens, landscape, and a
  hardware keyboard.
- Document that the phone must be reachable from the console's lighting network and
  that the console OSC TX destination must be changed when the phone IP changes.

## Code organization

Break up `focus_remote_screen.dart`; do not expand the current single 1,200-line
screen. Suggested boundaries:

```text
lib/
  remote_shell.dart
  settings/udp_settings.dart
  settings/udp_settings_store.dart
  setup/setup_tab.dart
  focus/command_buffer.dart
  focus/command_parser.dart
  focus/focus_remote_tab.dart
  cue_stack/cue_stack_tab.dart

packages/eos_osc_client/lib/src/
  eos_udp_sender.dart
  eos_udp_receiver.dart
  eos_protocol.dart
  eos_client.dart
```

Keep the pure Dart package independent of Flutter and third-party runtime packages.

## Tests and acceptance criteria

### Pure Dart

- Token parser accepts every command table example and rejects incomplete or
  out-of-range commands.
- Each terminal action emits exactly one OSC datagram.
- Channel level remains OSC `int32`, not normalized float.
- Sender works without a receiver and without calling `connect()`.
- Receiver bind failure leaves sender usable.
- Endpoint edits recreate the sender without replay.
- Playback parser handles identity, text, event, and progress packets.
- Cue-list bank packets parse labels, notes, duration, and remaining time.

### Flutter

- App opens on Focus Remote when cached endpoint settings are valid.
- All send controls are enabled while feedback is stopped.
- Touch keypad and physical keyboard produce the same token buffer.
- Clear and Backspace work without focus changes.
- Record/Update never send before Enter.
- Tab state survives navigation.
- Narrow-phone layout has no overflow at 320 logical pixels wide.
- Setup clearly separates send configuration from feedback state.

### Live Ion XE

Use a safe test show and verify one packet/action at a time:

1. launch and set `Chan 1 At 45` without pressing Start feedback;
2. Full, Out, and Release restore expected console behavior;
3. apply one known Focus, Color, and Beam Palette;
4. record and update disposable cues, including Cue Only behavior;
5. verify GO, Back, and Stop independently or document the Stop/Back limitation;
6. configure console TX to the app and confirm previous/current/next updates;
7. run a timed cue and compare the progress bar to Eos once-per-second output;
8. stop feedback and confirm focus/playback sending still works;
9. repeat the core send workflow on Android.

## Documentation sources

- [ETC: Eos OSC Setup](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/Using_OSC_with_Eos/Eos_OSC_Setup.htm)
- [ETC: OSC Eos Control](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/Using_OSC_with_Eos/OSC_Eos_Control.htm)
- [ETC: OSC Dictionary](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/OSC_Dictionary.htm)
- [ETC: OSC Get and Subscribe](https://www.etcconnect.com/WebDocs/Controls/EosFamilyOnlineHelp/en/Content/23_Show_Control/08_OSC/Using_OSC_with_Eos/OSC_Third-Party_Integration/OSC_Get.htm)

## Confirmed command-surface decisions

1. Treat the requested **Position** button as the user-facing label for Eos **Focus
   Palette**.
2. Treat **Record Cue Only** as `Record Cue <number> CueOnly Enter`, not the distinct
   Eos `Record_Only` command.
3. Keep Previous/Next convenience buttons below the new keypad even though they are
   not part of the requested command grammar.

These choices were confirmed before the Phase 1 build-ticket stack was created.
