-- Add Likes and Views Persistence for Ask Opinions
-- Created: 2026-05-14

-- 1. Create response likes table
CREATE TABLE IF NOT EXISTS public.opinion_response_likes (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    response_id UUID REFERENCES public.opinion_responses(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, response_id)
);

-- 2. Enable RLS
ALTER TABLE public.opinion_response_likes ENABLE ROW LEVEL SECURITY;

-- 3. Policies
CREATE POLICY "Anyone can view likes" ON public.opinion_response_likes
    FOR SELECT USING (true);

CREATE POLICY "Users can toggle their own likes" ON public.opinion_response_likes
    FOR ALL USING (auth.uid() = user_id);

-- 4. Trigger to update like_count in opinion_responses
CREATE OR REPLACE FUNCTION public.update_response_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE public.opinion_responses 
        SET like_count = like_count + 1 
        WHERE id = NEW.response_id;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE public.opinion_responses 
        SET like_count = like_count - 1 
        WHERE id = OLD.response_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_update_response_like_count
AFTER INSERT OR DELETE ON public.opinion_response_likes
FOR EACH ROW EXECUTE FUNCTION public.update_response_like_count();

-- 5. Function to increment opinion view count
CREATE OR REPLACE FUNCTION public.increment_opinion_view_count(op_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.ask_opinions
    SET view_count = view_count + 1
    WHERE id = op_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
