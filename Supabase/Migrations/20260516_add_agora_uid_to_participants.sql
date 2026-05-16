-- 1. Add agora_uid column to participants
ALTER TABLE public.roundtable_participants 
ADD COLUMN IF NOT EXISTS agora_uid BIGINT;

-- 2. Index for faster lookup
CREATE INDEX IF NOT EXISTS idx_roundtable_participants_agora_uid ON public.roundtable_participants(agora_uid);
