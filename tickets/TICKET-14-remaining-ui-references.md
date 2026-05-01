# TICKET-14 — Remaining UI References and Preset Migration

**Phase:** 9 of 10  
**Executor:** Sonnet, with Haiku subagents for individual file cleanups  
**Delegation:** Sonnet runs the codebase search, categorizes findings, then delegates individual file cleanups to Haiku with precise scope. Sonnet handles preset serialization migration itself.  
**Depends on:** TICKETS 09–13  
**Blocks:** TICKET-15

---

## Goal

Find and fix every remaining reference to old field names in the UI layer (info panel, sidebar, toolbar, any other widget files). Also add a migration mapping for saved column presets that store old column IDs.

---

## Step 1: Codebase Search (Sonnet)

Run these searches across the `papertek/lib/` directory and catalog every file with hits:

```
grep -r "\.function" lib/ --include="*.dart" -l
grep -r "\.focus" lib/ --include="*.dart" -l    # careful: .focus is also a Flutter FocusNode method
grep -r "\.flagged" lib/ --include="*.dart" -l
grep -r "\.wattage" lib/ --include="*.dart" -l
grep -r "f\.wattage\|row\.wattage\|fixture\.wattage" lib/ --include="*.dart" -l
grep -r "'function'" lib/ --include="*.dart" -l
grep -r "'focus'" lib/ --include="*.dart" -l
grep -r "'type'" lib/ --include="*.dart" -l     # will have many false positives; filter carefully
grep -r "'patch'" lib/ --include="*.dart" -l
grep -r "toggleFlag\|flaggedFixtures" lib/ --include="*.dart" -l
grep -r "part\.address" lib/ --include="*.dart" -l
```

For each file found (excluding files already fixed in TICKETS 06–13), categorize:
- **Safe to delegate to Haiku**: The fix is a literal string substitution in a widget file
- **Needs Sonnet judgment**: Conditional logic, preset deserialization, or the fix is ambiguous

---

## Step 2: Delegate Individual File Cleanups (Haiku)

For each file identified in Step 1 that is safe to delegate, create a Haiku subagent with:
- The specific file path
- The exact substitutions to make (from the table below)
- Instruction to make NO other changes

Standard substitution table:
| Old | New |
|-----|-----|
| `fixture.function` | `fixture.purpose` |
| `fixture.focus` | `fixture.area` |
| `fixture.flagged` | *(remove reference)* |
| `fixture.wattage` | *(remove; display from parts instead)* |
| `part.address` (where used as dimmer) | `part.dimmer` |
| Column ID `'function'` | `'purpose'` |
| Column ID `'focus'` | `'area'` |
| Column ID `'type'` | `'instrument'` |
| Column ID `'patch'` | `'patched'` |
| `updateFunction` | `updatePurpose` |
| `updateFocus` | `updateArea` |
| `updateWattage` (fixture-level) | `updatePartWattage` |
| `toggleFlag` | *(remove call)* |

---

## Step 3: Preset Serialization Migration (Sonnet)

Find the code that loads and saves `SpreadsheetViewPresets`. Presets store column IDs as strings. An old preset might contain `'function'`, `'focus'`, `'type'`, `'patch'` — these will silently fail to resolve after the rename.

Add a migration map that is applied when loading any preset:

```dart
const _columnIdMigrations = {
  'function': 'purpose',
  'focus': 'area',
  'type': 'instrument',
  'patch': 'patched',
};

List<String> _migrateColumnIds(List<String> ids) {
  return ids.map((id) => _columnIdMigrations[id] ?? id).toList();
}
```

Apply `_migrateColumnIds` to any list of column IDs loaded from a preset before passing them to the spreadsheet. This is a one-time forward-only migration — no need to back-convert on save.

---

## Step 4: Info Panel / Sidebar

Check whether the info panel (fixture detail sidebar) renders field labels from `ColumnSpec.label` or hardcodes its own strings. If it hardcodes strings like "Function", "Focus", "Fixture Type", update them. If it reads from `ColumnSpec`, it will be correct automatically after TICKET-09.

---

## Verify

`grep -r "\.function\|\.flagged\|updateFunction\|updateFocus\|toggleFlag" lib/ --include="*.dart"` returns zero results (excluding legitimate Dart `.focus` Flutter API calls). App compiles cleanly with zero errors.
