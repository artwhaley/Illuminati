# Ticket 01: ColumnSpec — importAliases and isImportable

## Goal
Add `importAliases: List<String>?` and `bool isImportable` to `ColumnSpec`, then populate aliases for all 18 importable columns.

## Depends on
Nothing. This is the foundation for all subsequent tickets.

## Delegate to
**Haiku** — purely mechanical additions to an existing file.

---

## Context to load
Read the full file: `papertek/lib/ui/spreadsheet/column_spec.dart`

Key sections you will modify:
- The `ColumnSpec` constructor (around line 31) — add `this.importAliases`
- The field declarations (around line 70–105) — add the field
- After `bool get isCustomField` — add the getter
- The `ColumnSpec.custom` factory — leave `importAliases` absent (defaults to null)
- Each of the 18 importable `ColumnSpec(...)` entries in `kColumns` — add `importAliases:`

---

## Changes

### 1. Add to constructor parameter list (after `this.customFieldId,`)
```dart
this.importAliases,
```

### 2. Add field declaration (after `final int? customFieldId;`)
```dart
final List<String>? importAliases;
```

### 3. Add getter (after `bool get isCustomField => customFieldId != null;`)
```dart
bool get isImportable => !isReadOnly && !isBoolean;
```

### 4. ColumnSpec.custom factory
No change needed — `importAliases` will be null by default.

### 5. Add importAliases to each column in kColumns

The three status columns (`hung`, `patched`, `focused`) have `isBoolean: true` or `isReadOnly: true` and therefore return `isImportable == false` automatically. Do NOT add importAliases to them.

Add the following `importAliases:` line to each of the 18 importable columns. Match each column by its `id:` field:

| id | importAliases value |
|----|---------------------|
| `'chan'` | `['channel', 'chan', 'ch', 'ch#']` |
| `'dimmer'` | `['dimmer', 'dim', 'dim#', 'dimmer number', 'dimmer no', 'dimmer #']` |
| `'address'` | `['address', 'addr', 'dmx address', 'dmx addr', 'dmx#', 'u address', 'start address', 'dmx start']` |
| `'circuit'` | `['circuit', 'circuit number', 'circuit no', 'ckt', 'ckt#', 'circuit name']` |
| `'position'` | `['position', 'pos', 'electric', 'location', 'batten', 'pipe', 'lighting position']` |
| `'unit'` | `['unit', 'unit number', 'unit no', 'unit#', 'instrument number']` |
| `'instrument'` | `['instrument', 'instrument type', 'fixture type', 'type', 'luminaire', 'instrument name']` |
| `'wattage'` | `['wattage', 'watts', 'watt', 'wattage (w)', 'load']` |
| `'purpose'` | `['purpose', 'use', 'function', 'system']` |
| `'area'` | `['area', 'focus', 'focus area', 'focus point', 'target', 'zone', 'scene']` |
| `'accessories'` | `['accessories', 'accessory', 'acc', 'hardware', 'top hat', 'barndoor', 'add-ons']` |
| `'color'` | `['color', 'colour', 'gel', 'filter', 'gel color', 'gel colour', 'media', 'color filter']` |
| `'gobo'` | `['gobo', 'gobo 1', 'gobo1', 'pattern', 'template']` |
| `'ip'` | `['ip', 'ip address', 'ip addr', 'ipv4', 'network address', 'ip4']` |
| `'subnet'` | `['subnet', 'subnet mask', 'mask', 'netmask', 'network mask']` |
| `'mac'` | `['mac', 'mac address', 'mac addr', 'hardware address', 'physical address']` |
| `'ipv6'` | `['ipv6', 'ipv6 address', 'ip6', 'ipv6 addr']` |
| `'notes'` | `['notes', 'note', 'comment', 'comments', 'remarks', 'description']` |

---

## Acceptance criteria

Run from `papertek/` directory. All must pass before proceeding to Ticket 02.

```bash
# 1. No new analysis errors
flutter analyze

# 2. Field, getter, and 18 column entries all present
grep -c "importAliases" lib/ui/spreadsheet/column_spec.dart
# Expected: 21 or more (1 constructor param + 1 field decl + 1 getter context + 18 columns)

# 3. isImportable getter present
grep "isImportable" lib/ui/spreadsheet/column_spec.dart
# Expected: matches at least one line

# 4. Status columns have no aliases (they should NOT appear as importAliases lines near 'hung'/'patched'/'focused')
grep -A5 "id: 'hung'" lib/ui/spreadsheet/column_spec.dart | grep "importAliases"
# Expected: empty (no output)
```

---

## Subagent prompt

```
You are making a targeted addition to a single file in a Flutter/Dart project.

Working directory: c:\Users\artwh\Downloads\Illuminati
File to modify: papertek/lib/ui/spreadsheet/column_spec.dart

Read the full file before making any changes.

Make exactly these changes:

1. In the ColumnSpec constructor parameter list, after `this.customFieldId,` add:
   this.importAliases,

2. In the field declarations, after `final int? customFieldId;` add:
   final List<String>? importAliases;

3. After `bool get isCustomField => customFieldId != null;` add:
   bool get isImportable => !isReadOnly && !isBoolean;

4. In the kColumns list, add `importAliases:` to each of these 18 columns (identified by their id: field).
   Do NOT add importAliases to the 'hung', 'patched', or 'focused' columns.
   Do NOT change anything else in each column definition — just insert the importAliases line.

   id 'chan':        importAliases: ['channel', 'chan', 'ch', 'ch#'],
   id 'dimmer':      importAliases: ['dimmer', 'dim', 'dim#', 'dimmer number', 'dimmer no', 'dimmer #'],
   id 'address':     importAliases: ['address', 'addr', 'dmx address', 'dmx addr', 'dmx#', 'u address', 'start address', 'dmx start'],
   id 'circuit':     importAliases: ['circuit', 'circuit number', 'circuit no', 'ckt', 'ckt#', 'circuit name'],
   id 'position':    importAliases: ['position', 'pos', 'electric', 'location', 'batten', 'pipe', 'lighting position'],
   id 'unit':        importAliases: ['unit', 'unit number', 'unit no', 'unit#', 'instrument number'],
   id 'instrument':  importAliases: ['instrument', 'instrument type', 'fixture type', 'type', 'luminaire', 'instrument name'],
   id 'wattage':     importAliases: ['wattage', 'watts', 'watt', 'wattage (w)', 'load'],
   id 'purpose':     importAliases: ['purpose', 'use', 'function', 'system'],
   id 'area':        importAliases: ['area', 'focus', 'focus area', 'focus point', 'target', 'zone', 'scene'],
   id 'accessories': importAliases: ['accessories', 'accessory', 'acc', 'hardware', 'top hat', 'barndoor', 'add-ons'],
   id 'color':       importAliases: ['color', 'colour', 'gel', 'filter', 'gel color', 'gel colour', 'media', 'color filter'],
   id 'gobo':        importAliases: ['gobo', 'gobo 1', 'gobo1', 'pattern', 'template'],
   id 'ip':          importAliases: ['ip', 'ip address', 'ip addr', 'ipv4', 'network address', 'ip4'],
   id 'subnet':      importAliases: ['subnet', 'subnet mask', 'mask', 'netmask', 'network mask'],
   id 'mac':         importAliases: ['mac', 'mac address', 'mac addr', 'hardware address', 'physical address'],
   id 'ipv6':        importAliases: ['ipv6', 'ipv6 address', 'ip6', 'ipv6 addr'],
   id 'notes':       importAliases: ['notes', 'note', 'comment', 'comments', 'remarks', 'description'],

After making changes, run `flutter analyze` from the `papertek/` directory and report the full output.
Only touch column_spec.dart. Do not modify any other file.
```
