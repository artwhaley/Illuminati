# TICKET-10 — FieldNameNotifier

**Phase:** 5 of 10  
**Executor:** Sonnet  
**Delegation:** None — requires judgment about the Riverpod provider graph and initialization lifecycle.  
**Depends on:** TICKET-08 (`FieldNameRepository`), TICKET-09 (`ColumnSpec.label` is now mutable)  
**Blocks:** TICKET-14 (UI uses this for reactive column name display)

---

## Goal

Create a Riverpod notifier that loads field display names from the DB on startup, applies them to the `kColumns` list (mutating `ColumnSpec.label`), and notifies watchers when names change so column headers rebuild. This is the runtime half of the user-editable names system.

---

## Files to Read First

1. `papertek/lib/ui/spreadsheet/column_spec.dart` — understand `kColumns`, `kColumnById`, the `defaultLabel`/`label` structure from TICKET-09
2. `papertek/lib/repositories/field_name_repository.dart` — the data source
3. Find the main providers file (likely `papertek/lib/providers/show_provider.dart` or similar) — understand the Riverpod provider graph pattern used in this codebase

---

## Step 1: Create FieldNameNotifier

Create `papertek/lib/ui/spreadsheet/field_name_notifier.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'column_spec.dart';
import '../../repositories/field_name_repository.dart';

/// Holds the current display name overrides and applies them to kColumns.
/// Widgets that render column headers should watch this provider so they
/// rebuild when a user renames a field.
///
/// State is a Map<fieldId, currentLabel> — widgets can use this or just
/// read col.label directly after a rebuild.
class FieldNameNotifier extends AsyncNotifier<Map<String, String>> {
  @override
  Future<Map<String, String>> build() async {
    final repo = ref.watch(fieldNameRepositoryProvider);
    final names = await repo.getAllDisplayNames();
    _applyToColumns(names);
    return names;
  }

  void _applyToColumns(Map<String, String> names) {
    for (final entry in names.entries) {
      final col = kColumnById[entry.key];
      if (col != null) col.label = entry.value;
    }
  }

  Future<void> setLabel(String fieldId, String displayName) async {
    final repo = ref.read(fieldNameRepositoryProvider);
    await repo.setDisplayName(fieldId, displayName);
    // Update the in-memory label immediately
    final col = kColumnById[fieldId];
    if (col != null) col.label = displayName;
    // Update state to trigger rebuilds
    state = AsyncData({...state.valueOrNull ?? {}, fieldId: displayName});
  }

  Future<void> resetToDefault(String fieldId) async {
    final col = kColumnById[fieldId];
    if (col == null) return;
    await setLabel(fieldId, col.defaultLabel);
  }
}

final fieldNameNotifierProvider =
    AsyncNotifierProvider<FieldNameNotifier, Map<String, String>>(
  FieldNameNotifier.new,
);
```

---

## Step 2: Initialize on App/Show Load

Find where the app loads a show file and initializes the provider graph. Ensure `fieldNameNotifierProvider` is watched or read during startup so `_applyToColumns` runs before the spreadsheet renders. The simplest place: wherever the spreadsheet widget tree is built, add:

```dart
// In the relevant ConsumerWidget or ConsumerStatefulWidget build method:
ref.watch(fieldNameNotifierProvider);
```

This forces initialization. The `kColumns` labels will be correct by the time any column header renders.

---

## Step 3: Column Header Rebuild

In the spreadsheet's column header builder (wherever column labels are displayed), ensure the widget watches `fieldNameNotifierProvider`. This is the only call site that needs to change for reactivity — everything else just reads `col.label`.

---

## Note on Thread Safety

`kColumns` is a module-level `final List<ColumnSpec>`. Mutating `col.label` is safe because Flutter's widget tree runs on the main isolate and there are no concurrent writers. If this assumption ever changes, the label mutation should move to a copy-on-write pattern.

---

## Verify

1. App launches and column headers show 'Instrument', 'Unit', 'Purpose', 'Area' (the new defaults from `field_names` table)
2. Calling `fieldNameNotifier.setLabel('instrument', 'Fixture Type')` causes column header to update without restart
3. After restart, the custom name persists (loaded from DB)
