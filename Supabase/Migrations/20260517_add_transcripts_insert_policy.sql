-- Add INSERT policy for roundtable_transcripts table
-- This allows authenticated users to save the transcripts they receive via Agora stream messages

DROP POLICY IF EXISTS "Allow authenticated insert on transcripts" ON public.roundtable_transcripts;
CREATE POLICY "Allow authenticated insert on transcripts" ON public.roundtable_transcripts
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');
