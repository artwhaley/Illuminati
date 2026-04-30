# REFACTOR-PLACEHOLDER: Refactor `inventory_tab.dart`

> **STATUS: NOT PLANNED YET**  
> This is a placeholder to ensure this refactor is not forgotten.  
> Do not execute this ticket until the user has reviewed and expanded it into full tickets.

---

## Why this refactor is needed

`inventory_tab.dart` is approximately 833 lines. It likely manages the fixture type
inventory (the list of all fixture types used in the show: ETC S4 26°, Mac Aura, etc.)
with inline editing, add/remove, and count tracking. All widget classes and business logic
are likely inlined together.

## What a full plan should include

When this placeholder is converted to a real plan:

1. **Extract data models**: Any sealed classes or display structs used only in this file.
2. **Extract widgets**: List item, edit card, count display — to `papertek/lib/ui/inventory/widgets/`.
3. **Extract dialogs**: Add/edit/delete dialogs.
4. **Extract controller**: Selection and action logic into a `StateNotifier`.
5. **Target line count**: Main file under 300 lines.

## Files to read before planning

- `papertek/lib/ui/inventory/inventory_tab.dart` (the target — verify actual path first)
- `papertek/lib/repositories/fixture_type_repository.dart` (the data layer)
- `papertek/lib/providers/show_provider.dart` (relevant providers: `fixtureTypeRepoProvider`,
  `fixtureTypesProvider`)

## Risks to investigate

- Fixture type names are referenced by fixtures as plain strings (not foreign keys), so
  renaming a type requires updating all matching fixture rows. Verify the current rename
  path in `FixtureTypeRepository` handles this correctly before splitting the tab logic.
