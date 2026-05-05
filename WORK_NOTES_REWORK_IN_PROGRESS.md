# WORK NOTES REWORK IN PROGRESS

## PROJECT CONTEXT
We are in the middle of a comprehensive rework of the **Create Notes** (formerly Live Notes) interface and its underlying data structure. The goal is to separate the entry logic into two distinct modes: **Board Notes** (cue-focused) and **Work Notes** (fixture/position-focused).

## COMPLETED SO FAR
- Initial UI renaming: Main navigation tab renamed to "Notes".
- Sub-tabs renamed and reordered: [Work Notes] [Create Notes] [Board Notes].
- "Create Notes" set as the default starting tab.
- Detailed implementation plan drafted and discussed.

## PENDING UI REWORK
### 1. General Layout
- **Header**: "Create Note" title on left; "Work / Board" text toggle on right (Active: Bright Yellow, Inactive: Grey).
- **Main Area**: Flexible panel switching between Board/Work layouts.
- **Footer**: Recent notes list moved from the side to the bottom, full width.

### 2. Board Mode (Full Width)
- **Top Row**: "Cue Number" optional text field.
- **Body**: 3-line scrollable text area.
- **Distribution**: 10 Checkboxes.
    - 6 Static: Stage Management, Follow Spots, ALD, ME, Personal, Patch.
    - 4 Dynamic: User-assignable labels (to be tracked in DB).
- **Recent Feed Format**: `Board : Cue {cue number} : Body : [Chips for Flags]`

### 3. Work Mode (70/30 Split)
- **Left Panel (70%)**:
    - 5-line scrollable body text area.
    - 5 Individual Search Boxes: Channel, Address, Color, Purpose, Focus Area.
    - Search Results: Multi-selectable list (Ctrl/Shift support) displaying full fixture details.
    - Lighting Positions Search: Dedicated search/attach box for positions.
- **Right Panel (30%)**:
    - Live list of all Fixtures and Positions currently attached to the pending note.

## PENDING DATABASE CHANGES (Migration 23)
- **`notes` table**:
    - Add `cue_number` (text).
    - Add `distribution_flags` (int bitmask or individual bools).
    - Add storage for the 4 custom checkbox labels (per-project settings or per-note).

## NEXT STEPS
1. Perform database migration to version 23.
2. Update `NotesRepository` with advanced search capability for the 5 specific fields.
3. Scaffold the new vertical layout in `live_notes_tab.dart`.
4. Implement the Work/Board toggle state logic.
5. Build out the specific forms for each mode.
