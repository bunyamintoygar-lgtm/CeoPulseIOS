-- 1. Roundtable Transcripts Table
CREATE TABLE IF NOT EXISTS public.roundtable_transcripts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    roundtable_id UUID REFERENCES public.roundtables(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. RLS Enable
ALTER TABLE public.roundtable_transcripts ENABLE ROW LEVEL SECURITY;

-- 3. Policies
CREATE POLICY "Allow public read access on transcripts" ON public.roundtable_transcripts
    FOR SELECT USING (true);

-- 4. Enable Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE roundtable_transcripts;

-- 5. Indexes
CREATE INDEX IF NOT EXISTS idx_roundtable_transcripts_roundtable_id ON public.roundtable_transcripts(roundtable_id);
