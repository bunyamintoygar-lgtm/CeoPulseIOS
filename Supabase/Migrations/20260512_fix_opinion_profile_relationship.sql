-- Fix relationship between ask_opinions and profiles for automatic joins
-- Created: 2026-05-12

ALTER TABLE public.ask_opinions 
DROP CONSTRAINT IF EXISTS ask_opinions_author_id_fkey;

ALTER TABLE public.ask_opinions
ADD CONSTRAINT ask_opinions_author_id_fkey 
FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Also fix for responses table
ALTER TABLE public.opinion_responses
DROP CONSTRAINT IF EXISTS opinion_responses_author_id_fkey;

ALTER TABLE public.opinion_responses
ADD CONSTRAINT opinion_responses_author_id_fkey 
FOREIGN KEY (author_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
