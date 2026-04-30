# REFACTOR-PLACEHOLDER: Refactor `venue_tabs.dart`

> **STATUS: NOT PLANNED YET**  
> This is a placeholder to ensure this refactor is not forgotten.  
> Do not execute this ticket until the user has reviewed and expanded it into full tickets.

---

## Why this refactor is needed

`venue_tabs.dart` is approximately 1074 lines. It is a monolithic file containing the UI for
managing venue infrastructure: dimmers, circuits, channels, and addresses. The same problems
apply as with `lighting_positions_tab.dart` — all widget classes, dialogs, business logic,
and data helpers are inlined together, making it hard to maintain or extend.

## What a full plan should include

When this placeholder is converted to a real plan, it should cover:

1. **Extract data models**: Any sealed classes or enums used only within this file.
2. **Extract widget classes**: Per-tab sub-widgets (each venue sub-tab likely has its own
   list widget, card widget, and inline editor). Extract to `papertek/lib/ui/venue/widgets/`.
3. **Extract dialogs**: Add/edit/delete confirmation dialogs to a `venue_dialogs.dart`.
4. **Extract controller**: Selection state, action methods (add dimmer, delete circuit, etc.)
   into a `VenueController` Riverpod StateNotifier.
5. **Target line count**: Main file under 300 lines.

## Files to read before planning

- `papertek/lib/ui/venue/venue_tabs.dart` (the target)
- `papertek/lib/repositories/venue_repository.dart` (the data layer it interacts with)
- `papertek/lib/providers/show_provider.dart` (the relevant providers: `venueRepoProvider`,
  `channelsProvider`, `addressesProvider`, `dimmersProvider`, `circuitsProvider`)

## Risks to investigate

- Venue sub-tabs may share state (e.g. a selected circuit row driving an address sub-panel).
  The controller extraction must handle shared-state cases carefully.
- Channel/address/dimmer/circuit are all linked relationally; edits to one affect the others.
  The controller must not duplicate the relationship logic from `VenueRepository`.
