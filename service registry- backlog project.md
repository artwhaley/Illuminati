# Service Registry — Backlog Project

## Status

Deferred deliberately. Do not start this project during the current 0.1.x
feature iteration unless provider coupling begins blocking correctness work.

## Why this exists

`papertek/lib/providers/show_provider.dart` has become a mixed service locator,
session root, repository factory, stream registry, and UI-state container. It
works, but unrelated concerns now share one dependency surface. That makes it
easy for show-scoped state to survive a file switch, causes broad rebuilds, and
will make lifecycle, reports, collaboration, and testing progressively harder.

This is not a request for a framework rewrite. Riverpod remains the state and
dependency-injection mechanism. The project is a boundary cleanup.

## Current responsibility groups

The current file contains at least these distinct concerns:

1. active show/session and database handle;
2. tracked writes, revisions, conflicts, and commits;
3. show metadata and contacts;
4. positions, inventory, and venue infrastructure;
5. fixtures and spreadsheet presets;
6. report repositories plus active report-editor state;
7. operational notes and maintenance;
8. custom fields and field-name overrides.

## Target layout

Keep provider names stable where practical, but move definitions into bounded
registries:

```text
lib/providers/
  session_providers.dart
  revision_providers.dart
  show_domain_providers.dart
  fixture_providers.dart
  venue_providers.dart
  report_providers.dart
  operational_providers.dart
  field_providers.dart
  show_provider.dart        # temporary compatibility barrel only
```

`show_provider.dart` should end as a barrel exporting the bounded files, then be
removed only after imports have migrated naturally.

## Provider lifetime rules

- Application-scoped: theme, backup preferences, license/user identity.
- Session-scoped: active path/database, tracked-write coordinator, backup
  coordinator, current user role.
- Show-scoped UI state: designer mode, report selection/editor, spreadsheet
  selection/presets, work-note filters. It must reset when the session identity
  changes.
- View-scoped: dialogs, temporary selections, search text, and controllers;
  prefer `autoDispose`.

Do not use global `StateProvider`s for state whose meaning depends on the current
`.papertek` file unless the provider watches the session identity and resets.

## Dependency direction

```text
UI -> feature provider -> repository/service -> AppDatabase
session providers -> construct/dispose show-scoped services
```

Feature provider files may depend on session providers. Session providers must
not import feature/UI providers. Repositories must not import Riverpod or UI.

## Migration strategy

1. Add a provider-dependency map and tests proving which state resets on show
   switch.
2. Extract one responsibility group at a time without renaming public providers.
3. Leave compatibility exports in `show_provider.dart` during migration.
4. Run focused widget/provider tests after every extraction.
5. Only after all imports are stable, shrink or delete the barrel.

Avoid a big-bang move. File movement must not be mixed with behavior changes.

## Entry criteria

Start this backlog project when at least one is true:

- the `.papertek` format and local feature set are approaching freeze;
- show-switch leakage keeps recurring;
- cloud/collaboration work begins;
- provider tests require excessive global overrides;
- `show_provider.dart` exceeds roughly 500 meaningful lines.

## Acceptance criteria

- No show-scoped state survives switching between two test databases.
- Every provider has an explicit application/session/show/view lifetime.
- `show_provider.dart` contains exports only.
- No circular provider imports.
- No behavior or schema change is bundled with the extraction.
- Existing feature tests pass, plus a provider-lifetime test matrix.

