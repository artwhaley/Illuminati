-- Migration: Initial Cloud Schema for PaperTek
-- Phased implementation including Profiles, Orgs, Shows, Sync, and Social Stubs.

-- ─────────────────────────────────────────────────────────────────────────────
-- PHASE 9.1: Profiles & Personal Workspaces
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    last_seen TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.personal_workspaces (
    user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    storage_quota_bytes BIGINT DEFAULT 104857600, -- 100MB default
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- PHASE 9.2: Organizations & Memberships
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    billing_email TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.organization_members (
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'member', -- 'owner', 'admin', 'member'
    invited_at TIMESTAMPTZ DEFAULT now(),
    accepted_at TIMESTAMPTZ,
    PRIMARY KEY (org_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.organization_subscriptions (
    org_id UUID PRIMARY KEY REFERENCES public.organizations(id) ON DELETE CASCADE,
    plan TEXT NOT NULL DEFAULT 'trialing',
    status TEXT NOT NULL DEFAULT 'active',
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ
);

-- ─────────────────────────────────────────────────────────────────────────────
-- PHASE 9.3: Cloud Shows & Permissions
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.cloud_shows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    org_id UUID REFERENCES public.organizations(id) ON DELETE CASCADE,
    personal_workspace_id UUID REFERENCES public.personal_workspaces(user_id) ON DELETE CASCADE,
    show_id_local TEXT NOT NULL, -- The local UUID in show_meta
    name TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    latest_snapshot_path TEXT,
    revision_cursor BIGINT DEFAULT 0,
    snapshot_cursor BIGINT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    -- Ensure show belongs to exactly one owner type
    CONSTRAINT owner_check CHECK (
        (org_id IS NOT NULL AND personal_workspace_id IS NULL) OR
        (org_id IS NULL AND personal_workspace_id IS NOT NULL)
    )
);

CREATE TABLE IF NOT EXISTS public.show_permissions (
    show_id UUID REFERENCES public.cloud_shows(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    can_read BOOLEAN DEFAULT true,
    can_edit BOOLEAN DEFAULT false,
    can_approve BOOLEAN DEFAULT false,
    can_manage BOOLEAN DEFAULT false,
    PRIMARY KEY (show_id, user_id)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- PHASE 9.3: Cloud Sync (Revisions & Commits)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.cloud_revisions (
    id BIGSERIAL PRIMARY KEY,
    show_id UUID REFERENCES public.cloud_shows(id) ON DELETE CASCADE,
    operation TEXT NOT NULL, -- update, insert, delete, import_batch
    target_table TEXT NOT NULL,
    target_id INTEGER NOT NULL,
    field_name TEXT,
    old_value TEXT, -- JSON
    new_value TEXT, -- JSON
    batch_id TEXT,
    user_id UUID REFERENCES public.profiles(id),
    timestamp TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'pending', -- pending, committed, rejected
    commit_id BIGINT -- references cloud_commits(id)
);

CREATE TABLE IF NOT EXISTS public.cloud_commits (
    id BIGSERIAL PRIMARY KEY,
    show_id UUID REFERENCES public.cloud_shows(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id),
    timestamp TIMESTAMPTZ NOT NULL,
    notes TEXT
);

CREATE TABLE IF NOT EXISTS public.snapshots (
    id BIGSERIAL PRIMARY KEY,
    show_id UUID REFERENCES public.cloud_shows(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    created_by UUID REFERENCES public.profiles(id),
    revision_cursor BIGINT NOT NULL
);

-- ─────────────────────────────────────────────────────────────────────────────
-- PHASE 10: Social Stubs
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.conversation_participants (
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.messages (
    id BIGSERIAL PRIMARY KEY,
    conversation_id UUID REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id),
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ─────────────────────────────────────────────────────────────────────────────
-- PHASE 9.4: RLS Policies
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.personal_workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.organization_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cloud_shows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.show_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cloud_revisions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cloud_commits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- Profiles: Anyone can read, only owner can update.
CREATE POLICY "Profiles are viewable by everyone" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Orgs: Members can see their orgs.
CREATE POLICY "Members can view their organizations" ON public.organizations
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.organization_members
        WHERE org_id = organizations.id AND user_id = auth.uid()
    )
);

-- Shows: Based on show_permissions.
CREATE POLICY "Users can view shows they have permission for" ON public.cloud_shows
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.show_permissions
        WHERE show_id = cloud_shows.id AND user_id = auth.uid() AND can_read = true
    )
    OR personal_workspace_id = auth.uid()
);

-- Sync: Gated by show access.
CREATE POLICY "Users can read revisions for their shows" ON public.cloud_revisions
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.show_permissions
        WHERE show_id = cloud_revisions.show_id AND user_id = auth.uid() AND can_read = true
    )
);

CREATE POLICY "Users can push revisions to their shows" ON public.cloud_revisions
FOR INSERT WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.show_permissions
        WHERE show_id = cloud_revisions.show_id AND user_id = auth.uid() AND can_edit = true
    )
);

-- Messages: Gated by conversation participation.
CREATE POLICY "Participants can view messages" ON public.messages
FOR SELECT USING (
    EXISTS (
        SELECT 1 FROM public.conversation_participants
        WHERE conversation_id = messages.conversation_id AND user_id = auth.uid()
    )
);
