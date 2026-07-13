# EOS Phase 1 T02 — Cached Setup and adaptive tab shell

## Depends on

T01 stateless UDP send boundary.

## Objective

Replace the single long screen with an adaptive three-destination shell and a Setup
page that describes UDP honestly. Focus Remote may be a placeholder until T04 and
Cue Stack may be a placeholder until T06. Neither placeholder may send on entry.

Do not send anything to the live console while implementing or testing this ticket.

## Concrete anchors

- `papertek_eos_probe/lib/focus_remote_screen.dart` currently owns endpoint fields,
  JSON persistence, transport state, focus controls, cue/query state, and the log.
- `_settingsFile`, `_loadCachedEndpoint()`, and `_cacheEndpoint()` persist the current
  host/source/console-RX fields.
- `_buildConnectionCard()` exposes misleading Start UDP/Stop UDP controls.
- `papertek_eos_probe/lib/main.dart` directly installs `FocusRemoteScreen`.

## Required behavior

1. Introduce an adaptive app shell:
   - bottom `NavigationBar` on narrow/portrait layouts;
   - `NavigationRail` on sufficiently wide layouts;
   - Setup, Focus Remote, and Cue Stack destinations;
   - safe areas and independent scrolling;
   - preserved in-memory state across tab changes.
2. Open Focus Remote initially when cached send settings are valid. Open Setup when
   required send settings are missing or invalid.
3. Setup fields:
   - Console IP/host;
   - “Console OSC UDP RX (app sends here)” with default 8000;
   - optional local/source IPv4;
   - “App UDP RX (console sends here)” with default 8001.
4. `Save settings` validates and atomically caches settings but sends nothing.
   Invalid edits must not overwrite the last valid cache.
5. Remove Connect/Disconnect and Start UDP/Stop UDP as sender controls. Display
   `Send configured` independently from receiver status.
6. Expose `Start feedback` and `Stop feedback` only for the optional receiver. A
   receiver failure is visible but never disables Focus Remote.
7. Move the bounded TX/RX/error diagnostics to Setup.
8. Include the console feedback checklist from the parent specification.
9. Until T06, Cue Stack displays a neutral “Not implemented yet” placeholder. It
   must contain no active GO, Back, Stop, cue-fire, or query-on-entry behavior.
10. Do not add an automatic test-send on startup, tab change, save, or feedback
    start.

Extract settings persistence from the widget into a testable service/model. Preserve
the existing `%APPDATA%/PaperTekEosProbe/settings.json` data by migrating missing new
fields to defaults in memory. This is app-local preference compatibility, not a
PaperTek show/database change.

## Tests first

Add widget/unit tests proving:

- valid legacy cached settings load and gain feedback port 8001;
- invalid edits do not replace last valid settings;
- Save settings sends zero datagrams;
- Focus opens first with valid settings and Setup opens first without them;
- sender controls remain available while feedback is stopped/faulted;
- narrow and wide shells expose all three destinations without overflow;
- the temporary Cue Stack placeholder has no enabled show-control actions;
- changing tabs sends zero datagrams.

## Acceptance gates

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

No live-console packet is permitted.

## Completion report

Report settings migration behavior, adaptive breakpoints, tests, and explicit
confirmation that the temporary Cue Stack placeholder is inert and sending no longer
requires Start.
