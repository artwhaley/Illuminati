# T07 — Remove direct database mutation from Maintenance UI

## Problem

`lib/ui/maintenance/widgets/tabular_card_body.dart` directly updates a revision
row. This violates the documented persistence boundary and can desynchronize a
revision proposal from live fixture data.

## Required investigation

Before changing behavior, write tests describing the intended supervisor edit:

1. editing a pending revision proposal updates the displayed/live proposed value;
2. old value and author/history remain correct;
3. approve commits the edited value;
4. reject restores the original value;
5. conflicting proposals remain internally consistent.

Use current product semantics from `SPEC.md`; if current UI behavior contradicts
the spec, follow the spec and describe the corrected behavior.

## Implementation

- Add a named repository/service method for supervisor editing of a pending
  revision, with one transaction covering revision and live-row changes.
- Validate target table/field through the existing SQL guard.
- UI calls the repository/provider only; it imports no Drift companions and
  performs no `db.update`, `db.into`, `db.delete`, or custom SQL.
- Surface failures without discarding the editor value.

## Gate

```powershell
rg -n "db\.(into|update|delete)|customStatement" lib/ui
```

There must be no UI persistence write. Add focused approve/reject/conflict tests.

