# Report Template Engine — Full Specification

## Overview

Replace the hardcoded channel hookup report with a **data-driven template engine** and an **interactive template editor**. Users select columns, reorder them, resize widths, pick grouping/sorting, and see a live PDF preview update in real time. Templates are persisted to the database and can be saved, renamed, and deleted.

---

## Architecture

```
┌──────────────────────────┐     ┌────────────────────────┐
│  Template Editor Panel   │     │  PDF Preview Panel     │
│  (Flutter widgets)       │     │  (PdfPreview widget)   │
│                          │     │                        │
│  Column picker           │     │  ┌──────────────────┐  │
│  Drag-to-reorder         │ ──► │  │  CH  DIM  POS    │  │
│  Resize handles          │     │  │  1   101  FOH    │  │
│  Group-by dropdown       │     │  └──────────────────┘  │
│  Sort-by dropdown        │     │                        │
│  Template save/load      │     │  [Print] [Export PDF]  │
└──────────────────────────┘     └────────────────────────┘
         ▲                                 ▲
         │                                 │
         └───── ReportTemplate model ──────┘
              (Riverpod StateNotifier)
```

Both panels read from the same `ReportTemplate` state. The editor modifies it, the PDF renderer consumes it.

---

## Data Model

### ReportColumn

```dart
/// Represents one column (or stacked column) in a report template.
class ReportColumn {
  final String id;            // Unique within template (e.g. 'chan', 'stack_instrument')
  final String label;         // Header text shown in PDF
  final List<String> fieldKeys;  // 1 for simple, 2+ for stacked
  final double? fixedWidth;   // null = flex
  final int flex;             // Only used when fixedWidth is null
  final bool isBold;          // Bold text for this column
  
  bool get isStacked => fieldKeys.length > 1;
  
  // JSON round-trip
  Map<String, dynamic> toJson();
  factory ReportColumn.fromJson(Map<String, dynamic> json);
}
```

### ReportTemplate

```dart
/// Complete description of a report layout. JSON-serializable.
class ReportTemplate {
  final String name;                    // "Channel Hookup", "My Custom Report"
  final List<ReportColumn> columns;     // Ordered list of visible columns
  final String? groupByFieldKey;        // e.g. 'position', null = no grouping
  final String? sortByFieldKey;         // Primary sort field
  final bool sortAscending;
  final String orientation;             // 'portrait' or 'landscape'
  final double dataFontSize;            // Default: 9.0
  final double rowHeight;               // Default: 22.0 (single), 36.0 (if any stacked)

  // JSON round-trip
  Map<String, dynamic> toJson();
  factory ReportTemplate.fromJson(Map<String, dynamic> json);
}
```

### Field Registry

A `Map<String, ReportFieldDef>` that maps field keys to data accessors. This is derived from the existing `kColumns` list in `column_spec.dart` but extended with additional fields not currently in the spreadsheet (`wattage`, `gobo1`, `gobo2`).

```dart
/// All fields available for report columns.
/// Built from kColumns plus extras not exposed in the spreadsheet.
final Map<String, ReportFieldDef> kReportFields = { ... };

class ReportFieldDef {
  final String key;
  final String label;           // Human-readable name for the column picker
  final String? Function(FixtureRow) getValue;
  final double defaultWidth;    // Suggested width when first added
}
```

**Canonical field keys** (derived from `ColumnSpec.id` and `FixtureRow` properties):

| Key | Label | Source |
|---|---|---|
| `chan` | Channel | `ColumnSpec 'chan'` — `f.channel` |
| `dimmer` | Address | `ColumnSpec 'dimmer'` — `f.dimmer` |
| `circuit` | Circuit | `ColumnSpec 'circuit'` — `f.circuit` |
| `position` | Position | `ColumnSpec 'position'` — `f.position` |
| `unit` | U# | `ColumnSpec 'unit'` — `f.unitNumber?.toString()` |
| `type` | Fixture Type | `ColumnSpec 'type'` — `f.fixtureType` |
| `function` | Purpose | `ColumnSpec 'function'` — `f.function` |
| `focus` | Focus Area | `ColumnSpec 'focus'` — `f.focus` |
| `accessories` | Accessories | `ColumnSpec 'accessories'` — `f.accessories` |
| `color` | Color | NEW — `f.color` |
| `gobo1` | Gobo 1 | NEW — `f.gobo1` |
| `gobo2` | Gobo 2 | NEW — `f.gobo2` |
| `wattage` | Wattage | NEW — `f.wattage` |
| `notes` | Notes | `ColumnSpec 'notes'` — currently empty |

### Pre-Built Stacked Columns

These appear in the column picker alongside simple columns. Users select them as a unit — no sub-editing.

| Stack ID | Picker Label | Field Keys | Suggested Flex |
|---|---|---|---|
| `stack_instrument` | Full Definition | `['type', 'wattage']` | 2 |
| `stack_color_template` | Color / Template | `['color', 'gobo1']` | 1 |
| `stack_purpose_area` | Purpose and Area | `['function', 'focus']` | 2 |

### Built-In Default Templates

Three templates ship pre-installed (seeded on first open, `isSystem = 1`):

**1. Channel Hookup** (portrait)
- Columns: `chan` (30px), `dimmer` (40px), `position` (80px), `unit` (30px), `stack_purpose_area` (flex 1), `stack_instrument` (flex 2), `stack_color_template` (80px)
- Group by: `position`
- Sort by: `chan` ascending

**2. Instrument Schedule** (landscape)
- Columns: `position` (100px), `unit` (30px), `type` (flex 1), `wattage` (60px), `accessories` (flex 1), `color` (80px), `chan` (40px), `dimmer` (50px)
- Group by: `position`
- Sort by: `unit` ascending

**3. Channel Schedule** (portrait)
- Columns: `chan` (40px), `dimmer` (50px), `circuit` (50px), `position` (80px), `unit` (30px), `function` (flex 1), `type` (flex 1), `color` (60px)
- Group by: none
- Sort by: `chan` ascending

---

## Persistence

Templates are stored in the **existing `Reports` table** (already in schema since migration 5):

```sql
CREATE TABLE reports (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  template_json TEXT NOT NULL  -- JSON-encoded ReportTemplate
);
```

A `ReportTemplateRepository` handles CRUD following the same pattern as `SpreadsheetViewPresetRepository`:
- `watchTemplates()` → `Stream<List<Report>>`
- `createTemplate(String name, ReportTemplate template)` → `Future<int>`
- `updateTemplate(int id, ReportTemplate template)` → `Future<void>`
- `deleteTemplate(int id)` → `Future<void>`
- `seedDefaults()` → inserts the 3 built-in templates if table is empty

---

## PDF Renderer

### Function Signature

```dart
Future<Uint8List> buildFromTemplate(
  PdfPageFormat format,
  List<FixtureRow> fixtures,
  ReportTemplate template,
  ReportTheme theme,
) async { ... }
```

This replaces the current `buildChannelHookup` function. The existing `channel_hookup_report.dart` is deleted entirely.

### Layout Rules (Learned from Spike)

> [!CAUTION]
> These rules are **non-negotiable**. Violating any of them will cause assertion crashes in the `pdf` package.

1. **NO `pw.Table` + `pw.FittedBox` combination.** The `pdf` package's `Table` widget performs intrinsic sizing passes that feed zero-width constraints to `FittedBox`, crashing with `width > 0.0`. Use **`pw.Row`** with `pw.SizedBox` (fixed) and `pw.Expanded` (flex) instead.

2. **NO `pw.FittedBox` on empty strings.** Always check `value.isEmpty` before wrapping in `FittedBox`. Return `pw.SizedBox()` for empty values.

3. **Wrap `FittedBox` in `pw.OverflowBox`.** Use this pattern for every data cell:
   ```dart
   pw.OverflowBox(
     maxWidth: double.infinity,
     alignment: pw.Alignment.centerLeft,
     child: pw.ConstrainedBox(
       constraints: const pw.BoxConstraints(minWidth: 1),
       child: pw.FittedBox(fit: pw.BoxFit.scaleDown, child: textWidget),
     ),
   )
   ```

4. **`pw.MultiPage` build must return a flat `List<pw.Widget>`.** Do not nest a `pw.Column` containing all rows — it prevents page breaks. Each data row, group header, and spacer must be a top-level item in the list.

5. **Use `pw.PageTheme` exclusively.** Do NOT pass `pageFormat`, `margin`, `theme`, or `orientation` alongside `pageTheme` in `MultiPage`. The `pdf` package asserts that only one or the other is used.

6. **Font safety:** IBM Plex Mono TTFs from Google Fonts crash the `pdf` subsetter (`TtfParser._readSimpleGlyph` out-of-range). Use IBM Plex Sans as the monospace substitute. All fonts must be loaded from `assets/google_fonts/` (downloaded from `fonts.gstatic.com` CDN URLs matching the `printing` package's `gfonts.dart`).

7. **`Expanded.flex` must be `int`, not `double`.** The `pdf` package's `Expanded` widget requires integer flex values.

### Stacked Cell Rendering

For columns where `isStacked == true`:
- Row height increases to `template.rowHeight` (default 36.0 when stacks present, auto-detected)
- The cell builds a `pw.Column` with one `pw.Text` per field key
- Each sub-line uses `template.dataFontSize - 1` (e.g., 8pt instead of 9pt)
- Each sub-field gets its own line within the cell
- Apply the same `OverflowBox > ConstrainedBox > FittedBox` safety wrapper to each sub-line independently
- If ALL sub-fields for a stacked column are empty, render `pw.SizedBox()` (do NOT feed empty strings to FittedBox)

### Header / Footer

Keep the current masthead design from the spike:
- Header: "THEATRICAL LIGHTING DOCUMENTATION" subtitle + template name as title (Cormorant Garamond SemiBold, 24pt), page number, date
- Footer: Template name + print date
- The template name is injected dynamically from `ReportTemplate.name`

---

## Editor UI

### Layout

The `ReportsTab` becomes a split panel:
- **Left panel (300px fixed):** Template editor controls
- **Right panel (remaining):** Live `PdfPreview`

### Left Panel Sections

**1. Template Selector** (top)
- Dropdown listing all saved templates from `ReportTemplateRepository.watchTemplates()`
- Buttons: **New**, **Save**, **Save As**, **Delete**
- System templates (isSystem=1) cannot be deleted but can be "Save As" copied

**2. Column Picker** (scrollable body)
- Reuses the existing `ColumnCheckboxList` pattern from `column_checkbox_list.dart`
- Shows ALL available columns: the 14 simple fields + 3 pre-built stacks
- Stacked columns are visually distinguished with a subtitle listing sub-fields
- Checking/unchecking a column adds/removes it from `template.columns`
- **Order matters:** Use `ReorderableListView` so checked columns can be dragged to reorder

**3. Column Width Editor** (inline per checked column)
- Each checked column shows a row with: drag handle, label, width input
- Width input: a small `TextField` for fixed pixel width, or a toggle to "Flex" mode with a flex-weight dropdown (1, 2, 3)
- Default: new simple columns start at their `defaultWidth` from `kReportFields`; stacks start as flex

**4. Grouping & Sorting** (bottom section)
- Group by: Dropdown of available field keys + "None"
- Sort by: Dropdown of available field keys
- Sort direction: Ascending / Descending toggle

**5. Orientation** (bottom)
- Portrait / Landscape radio buttons

### State Management

```dart
/// Riverpod provider for the currently-edited template.
final activeReportTemplateProvider = StateNotifierProvider<ReportTemplateNotifier, ReportTemplate>((ref) {
  return ReportTemplateNotifier();
});
```

The `ReportTemplateNotifier` exposes methods like:
- `addColumn(String fieldKeyOrStackId)`
- `removeColumn(String columnId)`
- `reorderColumns(int oldIndex, int newIndex)`
- `setColumnWidth(String columnId, double? fixedWidth, int flex)`
- `setGroupBy(String? fieldKey)`
- `setSortBy(String? fieldKey, bool ascending)`
- `setOrientation(String orientation)`
- `loadTemplate(ReportTemplate template)`
- `reset()`

Every mutation triggers a Riverpod state update, which causes the `PdfPreview` to re-render.

---

## File Structure

```
lib/
  features/
    reports/
      report_field_registry.dart      // kReportFields map + ReportFieldDef + kStackedColumns
      report_template.dart            // ReportTemplate + ReportColumn models + JSON
      report_template_defaults.dart   // 3 built-in template definitions
      template_renderer.dart          // buildFromTemplate() — the generic PDF builder
      report_theme.dart               // (existing, unchanged)
  repositories/
    report_template_repository.dart   // CRUD for Reports table
  providers/
    show_provider.dart                // Add reportTemplateRepoProvider + reportTemplatesProvider
  ui/
    reports/
      reports_tab.dart                // Split panel: editor + preview
      template_editor_panel.dart      // Left panel with all editor controls
      template_column_list.dart       // ReorderableListView of checked columns with width editors
      template_selector.dart          // Dropdown + save/delete buttons
```

**Deleted files:**
- `lib/features/reports/channel_hookup_report.dart` — replaced by `template_renderer.dart`

---

## Edge Cases & Defensive Coding

1. **Empty fixture list:** If `fixtures.isEmpty`, render a single-page PDF with the header and a centered message: "No fixtures in current show." Do NOT pass an empty list to the grouping/sorting logic.

2. **All columns removed:** If `template.columns.isEmpty`, show an error state in the editor panel ("Add at least one column") and do not attempt PDF generation.

3. **Template with stale field keys:** If a saved template references a `fieldKey` that no longer exists in `kReportFields`, skip that column silently during rendering (log a warning, don't crash).

4. **Very long text:** The `OverflowBox > FittedBox` pattern handles this, but cap `FittedBox` scaling at a minimum font size of 5pt to prevent unreadable micro-text.

5. **Font loading failure:** Wrap `ReportTheme.load()` in try/catch. On failure, fall back to `pw.Font.helvetica()` / `pw.Font.times()` base14 fonts and log a warning.

6. **Zero-flex columns:** If a flex column has `flex: 0`, treat it as `flex: 1` to prevent division-by-zero in the layout engine.

7. **Group-by field not in columns:** Grouping works on the data regardless of whether the grouped field is a visible column. This is intentional — you might group by Position but not display Position as a column.

8. **Duplicate column IDs:** The editor must prevent adding the same column twice. If a simple field (`type`) is already added, and the user checks a stack containing `type` (`stack_instrument`), allow it — stacks and singles are independent column entries.
