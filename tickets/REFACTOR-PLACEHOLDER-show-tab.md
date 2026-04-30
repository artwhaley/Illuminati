# REFACTOR-PLACEHOLDER: Refactor `show_tab.dart`

> **STATUS: NOT PLANNED YET**  
> This is a placeholder to ensure this refactor is not forgotten.  
> Do not execute this ticket until the user has reviewed and expanded it into full tickets.

---

## Why this refactor is needed

`show_tab.dart` is approximately 822 lines. It manages the show metadata panel (show name,
designer, dates, venue info) and possibly the contact list (ME, ALD, stage manager, etc.).
Inline mixing of form widgets, save logic, and layout is the expected problem.

## What a full plan should include

When this placeholder is converted to a real plan:

1. **Extract sub-panels**: Show info panel, contact list panel, dates panel — each likely
   a natural extraction target. Move to `papertek/lib/ui/show/widgets/`.
2. **Extract dialogs**: Any add/edit contact dialogs.
3. **Extract form save logic**: The save-on-change or save-on-blur pattern for text fields
   updating show metadata should be in a helper, not inline in the build method.
4. **Target line count**: Main file under 250 lines.

## Files to read before planning

- `papertek/lib/ui/show/show_tab.dart` (the target — verify actual path first)
- `papertek/lib/repositories/show_meta_repository.dart`
- `papertek/lib/repositories/role_contact_repository.dart`
- `papertek/lib/providers/show_provider.dart` (relevant providers: `showMetaRepoProvider`,
  `currentShowMetaProvider`, `roleContactRepoProvider`)

## Risks to investigate

- If the show tab contains the "designer mode" toggle (`designerModeProvider`), extracting
  that widget must preserve the provider binding correctly.
- Show meta fields are a flat struct; a generic form framework is tempting but probably
  over-engineered. Keep field-by-field save handlers unless there's a compelling reason
  to consolidate.
