-- Update roundtables table schema to match the new Create Roundtable flow
-- 1. Remove end_time and add estimated_duration
ALTER TABLE public.roundtables 
DROP COLUMN IF EXISTS end_time;

ALTER TABLE public.roundtables 
ADD COLUMN IF NOT EXISTS estimated_duration TEXT;

-- 2. Add participant_limit
ALTER TABLE public.roundtables 
ADD COLUMN IF NOT EXISTS participant_limit TEXT;

-- 3. Add join_policy (everyone, premium, invitedOnly)
ALTER TABLE public.roundtables 
ADD COLUMN IF NOT EXISTS join_policy TEXT DEFAULT 'everyone';

-- 4. Add questions (as JSONB for flexibility)
ALTER TABLE public.roundtables 
ADD COLUMN IF NOT EXISTS questions JSONB DEFAULT '[]'::jsonb;

-- 5. Add table_type (open, invited)
ALTER TABLE public.roundtables 
ADD COLUMN IF NOT EXISTS table_type TEXT DEFAULT 'open';

-- Comments for documentation
COMMENT ON COLUMN public.roundtables.estimated_duration IS 'Estimated duration of the session (e.g., 60 minutes)';
COMMENT ON COLUMN public.roundtables.participant_limit IS 'Limit of participants (e.g., 6 - 12 people)';
COMMENT ON COLUMN public.roundtables.join_policy IS 'Who can join the session';
COMMENT ON COLUMN public.roundtables.questions IS 'List of discussion questions for the session';
