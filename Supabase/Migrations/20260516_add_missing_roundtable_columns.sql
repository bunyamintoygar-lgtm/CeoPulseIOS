-- Add missing columns to roundtable tables

-- Add current_speaker_id to roundtables
ALTER TABLE public.roundtables 
ADD COLUMN IF NOT EXISTS current_speaker_id UUID REFERENCES auth.users(id) ON DELETE SET NULL;

-- Add is_requesting_floor to roundtable_participants
ALTER TABLE public.roundtable_participants 
ADD COLUMN IF NOT EXISTS is_requesting_floor BOOLEAN DEFAULT false;
