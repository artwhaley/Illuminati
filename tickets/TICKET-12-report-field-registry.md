# TICKET-12 — Report Field Registry Updates

**Phase:** 7 of 10  
**Executor:** Haiku (delegate from Sonnet)  
**Delegation scope:** Entire ticket. Changes are small and precisely specified.  
**Depends on:** TICKET-09 (ColumnSpec IDs updated)  
**Blocks:** Nothing — reports should work after this

---

## Goal

Update `report_field_registry.dart` to use new column IDs in `kStackedColumns` and fix the `getPartFieldValue` switch cases for the renamed part-level fields.

---

## File to Read First

`papertek/lib/features/reports/report_field_registry.dart` — full file (269 lines, but most is font maps — focus on lines 1–135).

---

## Changes

### 1. `kStackedColumns` — update fieldKeys arrays

```dart
// OLD:
'stack_instrument': const ReportColumn(
  fieldKeys: ['type', 'wattage'],
  ...
),
'stack_purpose_area': const ReportColumn(
  fieldKeys: ['function', 'focus'],
  ...
),

// NEW:
'stack_instrument': const ReportColumn(
  fieldKeys: ['instrument', 'wattage'],
  ...
),
'stack_purpose_area': const ReportColumn(
  fieldKeys: ['purpose', 'area'],
  ...
),
```

The `label` and `id` on these `ReportColumn` objects are unchanged.

### 2. `getPartFieldValue` — update switch cases

In the `switch (fieldKey)` block (lines 58–81):

```dart
// OLD:
case 'dimmer':
  return part.address ?? '';

// NEW — split into two cases:
case 'dimmer':
  return part.dimmer ?? '';
case 'address':
  return part.address ?? '';
```

### 3. `kReportFields` — no changes needed

It derives from `kColumns` automatically. After TICKET-09, it will pick up the new IDs and labels without any edits here.

### 4. Legacy translation in `getFieldValue`

The existing gobo1/gobo2 → gobo translation stays. No new legacy translations needed.

---

## Verify

No compile errors in `report_field_registry.dart`. `kStackedColumns['stack_purpose_area']!.fieldKeys` == `['purpose', 'area']`. A report using the "Purpose and Area" stacked column renders correctly.
