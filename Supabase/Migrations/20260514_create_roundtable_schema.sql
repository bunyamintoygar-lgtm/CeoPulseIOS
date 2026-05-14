-- Roundtable Tables Migration

-- 1. Roundtables Table
CREATE TABLE IF NOT EXISTS public.roundtables (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'upcoming', -- upcoming, active, completed, archived
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    image_url TEXT,
    moderator_id UUID REFERENCES auth.users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Roundtable Participants Table
CREATE TABLE IF NOT EXISTS public.roundtable_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    roundtable_id UUID REFERENCES public.roundtables(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL DEFAULT 'listener', -- moderator, speaker, listener
    is_muted BOOLEAN DEFAULT true,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(roundtable_id, user_id)
);

-- 3. Roundtable Messages Table
CREATE TABLE IF NOT EXISTS public.roundtable_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    roundtable_id UUID REFERENCES public.roundtables(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'text', -- text, system, insight
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS Policies
ALTER TABLE public.roundtables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roundtable_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roundtable_messages ENABLE ROW LEVEL SECURITY;

-- Roundtables: Everyone can view
CREATE POLICY "Allow public read access on roundtables" ON public.roundtables
    FOR SELECT USING (true);

-- Participants: Everyone can view, authenticated users can join
CREATE POLICY "Allow public read access on participants" ON public.roundtable_participants
    FOR SELECT USING (true);

CREATE POLICY "Allow users to join roundtables" ON public.roundtable_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Allow users to leave roundtables" ON public.roundtable_participants
    FOR DELETE USING (auth.uid() = user_id);

-- Messages: Everyone in a roundtable can view and send messages
CREATE POLICY "Allow public read access on messages" ON public.roundtable_messages
    FOR SELECT USING (true);

CREATE POLICY "Allow authenticated users to send messages" ON public.roundtable_messages
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_roundtables_status ON public.roundtables(status);
CREATE INDEX IF NOT EXISTS idx_roundtable_participants_roundtable_id ON public.roundtable_participants(roundtable_id);
CREATE INDEX IF NOT EXISTS idx_roundtable_messages_roundtable_id ON public.roundtable_messages(roundtable_id);
