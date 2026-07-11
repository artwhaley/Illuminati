# T08 — Make the existing importer honest, atomic, and minimally safe

## Objective

Do not expand importer scope. Repair the known paths so the existing UI never
lies and a failed import never leaves partial positions/types/fixtures.

## Required work

1. Fix fixture-level/part-level routing. `wattage` is part-level and must not be
   passed through the fixture-level `firstNonNull` assertion. Preserve per-part
   wattage and define fixture-type wattage from a deliberate source only if the
   data model still requires it.
2. Replace `List<dynamic>? multipartDecisions` with the real typed decision
   model in a non-UI domain file.
3. Implement all three choices:
   - merge candidate rows as multipart;
   - import rows as separate fixtures;
   - skip candidate rows and count/report each skipped source row.
4. Make the import atomic. Any unexpected persistence failure rolls back
   positions, types, fixtures, parts, attachables, revisions, and batch summary.
   Validation skips are allowed only when identified before the write transaction.
5. Do not catch per-group persistence exceptions inside the outer transaction
   and then commit partial lookup data.
6. Import summary distinguishes validation skips from fatal rollback.
7. If import remains experimental, label it `Import Fixtures (Experimental)`
   until all focused tests pass; remove the label only when this ticket passes.

## Tests

Use all bundled CSV/TXT fixtures. Include the exact Lightwright sample that
previously produced 0 fixtures, 20 positions, and 163 skips. Assert counts,
multipart actions, per-part wattage, revision batch, and full rollback after an
injected mid-import failure.

Do not redesign column mapping or add formats.

