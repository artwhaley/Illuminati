# PaperTek — Implementation Plan
 

## Phase 9: Cloud — Supabase (separate from local app)

### Step 9.1 — Supabase project + auth tables

- Create Supabase project.
- Migration 1: `profiles` table (extends auth.users with display_name, avatar_url).
- Migration 2: `personal_workspaces` (user_id, storage_quota, created_at).
- Wire up Supabase Auth in the Flutter app: sign up, sign in, sign out. Store session.
- **No RLS yet.** Auth only.

**Verify:** Sign up in the app. Check Supabase dashboard — user exists. Sign out, sign in again. Profile row created.

### Step 9.2 — Org tables (no RLS yet)

- Migration 3: `organizations` (name, slug, billing refs).
- Migration 4: `organization_members` (user_id, org_id, role, invited_at, accepted_at).
- Migration 5: `organization_subscriptions` (org_id, plan, status, dates).
- Basic Flutter UI: create org, invite member (by email), accept invite.

**Verify:** Create an org. Invite a second account. Second account sees invite, accepts. Both are members in the dashboard. Subscription row exists (status: trialing or similar).

### Step 9.3 — Cloud show tables (no RLS yet)

- Migration 6: `cloud_shows` (org_id or personal_workspace_id, show_id UUID — sourced from `show_meta.cloud_id`, metadata JSON, latest_snapshot_path, revision_cursor, snapshot_cursor).
- Migration 7: `show_permissions` (org_id, show_id, user_id, can_read, can_edit, can_approve, can_manage).
- Migration 8: `cloud_revisions` (show_id, mirrored structure of local revisions + sync metadata).
- Migration 9: `cloud_commits` (show_id, mirrored structure of local commits).
- Migration 10: `snapshots` (show_id, storage_path, created_at, created_by, revision_cursor).

**Verify:** Manually insert a cloud_show row via Supabase dashboard (using a `cloud_id` UUID from a local show). Insert a show_permission row. Query — returns correctly. No RLS blocking anything yet (that's intentional — we test the schema in the open before locking it down).

### Step 9.4 — RLS policies (applied incrementally)

Apply RLS in small batches, testing after each:

- **Batch A:** `profiles` — users can read any profile, update only their own.
- **Batch B:** `personal_workspaces` — user can only see/edit their own.
- **Batch C:** `organizations` + `organization_members` — members can read their org, only owners/admins can update. Members can read member list.
- **Batch D:** `organization_subscriptions` — read by org members, write by org owners.
- **Batch E:** `cloud_shows` + `show_permissions` — gated by org membership + show permission rows.
- **Batch F:** `cloud_revisions` + `cloud_commits` + `snapshots` — gated by show access (can_read for viewing, can_edit for pushing revisions, can_approve for committing).

**Verify (after each batch):** Test with two users. User A should see their data. User B should NOT see User A's data. Try an unauthorized update — should fail. Use Supabase's SQL editor to run queries as each user role and confirm policies hold.

### Step 9.5 — Sync engine

- Background sync when the show is linked to cloud and the app is online (use a **configurable** interval; tune for reliability—exact timing is not a product guarantee in v1).
- Push: unsynced local revisions → `cloud_revisions`.
- Pull: remote revisions since last cursor → local SQLite. Apply to data tables, apply highlights.
- Committed state: remote commits apply locally, clear highlights.
- **Snapshot upload (with optimistic locking):** Before uploading, send the local `revision_cursor` to the server. Server accepts the snapshot only if `cloud_shows.revision_cursor` matches — meaning no other client uploaded a newer snapshot in the interim. On mismatch, client re-syncs (pulls latest revisions) and retries.
- Snapshot download for new user joining a show: download latest snapshot, then pull incremental revisions from `snapshots.revision_cursor` to present.
- Optional: lightweight nudge to sync (Realtime or periodic poll) — not required for correctness. **No** presence cursors or "who is editing which cell" in v1.

**Verify:** Open the same show on two devices (or two instances with different user accounts). Edit a fixture on device A; after sync runs, device B shows the change with the expected **pending** highlight. Commit on device A; device B eventually reflects **committed** and highlights clear. Test snapshot conflict: two clients race — second upload rejected per optimistic locking rules.

---

## Phase 10: Social stubs

### Step 10.1 — Social table migrations (no UI)

- `conversations`, `messages`, `user_connections` tables in Supabase.
- RLS: messages visible to conversation participants, connections visible to involved users.

**Verify:** Tables exist. RLS blocks cross-user reads. No UI — this is just schema prep.

---

## Phase 11: Mobile

Deferred — separate planning phase once desktop is solid.
