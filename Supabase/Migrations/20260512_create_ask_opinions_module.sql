-- Ask Opinions Module Migration
-- Created: 2026-05-12

-- 1. Create the main table
CREATE TABLE IF NOT EXISTS public.ask_opinions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT,
    type INTEGER DEFAULT 0, -- 0: General, 1: Compare, 2: Solution
    target_audience INTEGER DEFAULT 0,
    privacy_level INTEGER DEFAULT 0,
    attachments JSONB DEFAULT '[]'::jsonb, -- Store list of {name, type, url}
    view_count INTEGER DEFAULT 0,
    response_count INTEGER DEFAULT 0,
    like_count INTEGER DEFAULT 0,
    status TEXT DEFAULT 'open', -- open, answered, closed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create the responses table
CREATE TABLE IF NOT EXISTS public.opinion_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    opinion_id UUID REFERENCES public.ask_opinions(id) ON DELETE CASCADE,
    author_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_best_response BOOLEAN DEFAULT false,
    is_anonymous BOOLEAN DEFAULT false,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Enable RLS
ALTER TABLE public.ask_opinions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.opinion_responses ENABLE ROW LEVEL SECURITY;

-- 4. Policies for ask_opinions
CREATE POLICY "Anyone can view public opinions" ON public.ask_opinions
    FOR SELECT USING (privacy_level = 0 OR auth.uid() IS NOT NULL);

CREATE POLICY "Users can create opinions" ON public.ask_opinions
    FOR INSERT WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can update their own opinions" ON public.ask_opinions
    FOR UPDATE USING (auth.uid() = author_id);

-- 5. Policies for opinion_responses
CREATE POLICY "Anyone can view responses to visible opinions" ON public.opinion_responses
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.ask_opinions 
            WHERE id = opinion_id AND (privacy_level = 0 OR auth.uid() IS NOT NULL)
        )
    );

CREATE POLICY "Authenticated users can post responses" ON public.opinion_responses
    FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- 6. Trigger for response_count
CREATE OR REPLACE FUNCTION public.update_opinion_response_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.ask_opinions 
        SET response_count = response_count + 1 
        WHERE id = NEW.opinion_id;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.ask_opinions 
        SET response_count = response_count - 1 
        WHERE id = OLD.opinion_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_update_opinion_response_count
AFTER INSERT OR DELETE ON public.opinion_responses
FOR EACH ROW EXECUTE FUNCTION public.update_opinion_response_count();
