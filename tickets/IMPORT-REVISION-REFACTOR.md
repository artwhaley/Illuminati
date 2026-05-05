# Ticket: Import Revision Refactoring

## Objective
Refactor the import pipeline to bypass individual fixture revisions and instead create a single, human-readable summary commit. This mimics "Designer Mode" behavior to prevent database bloat while maintaining a clear audit trail.

## Success Criteria
- [ ] Individual `insert` revisions are NOT created for fixtures, parts, gels, gobos, or accessories during import.
- [ ] A single `import_batch` revision is created at the end of the operation.
- [ ] The `import_batch` revision contains a descriptive summary like: *"Imported 50 fixtures. 20 on 1st Electric, 30 on 2nd Electric."*
- [ ] The system correctly restores the previous "Designer Mode" state after the import completes (state-aware).

## Implementation Plan

### Step 1: Update `TrackedWriteRepository`
- **File**: `lib/repositories/tracked_write_repository.dart`
- **Change**: Ensure `insertRow` and `endImportBatch` are fully coordinated for import operations.
- **Refinement**: Add an optional `summaryOverride` to `endImportBatch` or `exitDesignerMode` to allow the caller to provide the human-readable text.

### Step 2: Update `ImportService` (Summary Tracking)
- **File**: `lib/services/import/import_service.dart`
- **Change**: 
    - Initialize a `Map<String, int> positionTally = {}` at the start of `importRows`.
    - Increment the tally for the relevant position every time a fixture is successfully imported.
    - Build a summary string from this map (e.g., sort by count descending, list top positions).

### Step 3: Update `ImportService` (Mode Handling)
- **File**: `lib/services/import/import_service.dart`
- **Change**: 
    - Cache the initial state: `final wasDesigner = _tracked.designerMode;`.
    - If `!wasDesigner`, call `_tracked.enterDesignerMode()`.
    - Perform the import.
    - If `!wasDesigner`, call `_tracked.exitDesignerMode()`, passing the custom summary string.
    - Ensure this happens in a `finally` block to protect the mode state if the import crashes.

### Step 4: Verification
- [ ] Run a test import of 10+ fixtures.
- [ ] Check the `revisions` table: there should be exactly 1 new row for the batch, and 0 new rows for individual inserts.
- [ ] Verify the `newValue` field in the batch revision contains the detailed text description.

## Safety & Constraints
- Do NOT modify the database schema.
- Do NOT change the core logic of `RowMatcher` or `DelimitedRowReader`.
- Maintain standard `isImport: true` behavior (skipping Undo stack) to avoid memory pressure on large imports.
