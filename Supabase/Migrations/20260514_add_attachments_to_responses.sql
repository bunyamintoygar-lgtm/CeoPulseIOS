-- Add attachments support to opinion responses
-- Created: 2026-05-14

-- 1. Add attachments column to opinion_responses
ALTER TABLE public.opinion_responses 
ADD COLUMN IF NOT EXISTS attachments JSONB DEFAULT '[]'::jsonb;

-- 2. Update RLS policies if necessary (usually JSONB columns don't need special policies if the table is covered)
