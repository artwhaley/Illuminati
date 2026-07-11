# T09 — Enforce actionable error handling and fix Live Notes literals

## Objective

Replace silent/incorrect error handling with one small, consistent policy. This
is not a service-registry refactor.

## Required work

1. Fix escaped interpolation in Live Notes so `$e`, `$st`, and `$p` are actual
   values, not literal text.
2. Remove production `print` calls. Add a small injectable `AppLogger` service
   backed by `dart:developer.log`, carrying operation, error, and stack trace.
3. Audit every explicit `catch` in `lib/`:
   - user-triggered failure: log full context and show a concise actionable UI
     message;
   - background/best-effort failure: log it and retain status for inspection;
   - expected parse/fallback: document the expected exception and return a
     typed fallback/result;
   - no empty or comment-only catch blocks.
4. Do not show raw stack traces, SQL, or enormous exception strings in normal
   dialogs/snackbars.
5. Preference load failures may fall back to defaults, but must be logged.
6. Database, backup, migration, report generation, note persistence, and commit
   failures must never be silently swallowed.

## Tests and enforcement

- Test Live Notes error and position-label rendering.
- Test logger invocation for representative preference, report, and persistence
  failures.
- `rg -n "print\(|catch \(_\).*\{\s*\}" lib` must find no production violations.
- Do not convert recoverable UI failures into crashes merely to satisfy logging.

