-- Enable RLS and add policies for roundtables table
ALTER TABLE public.roundtables ENABLE ROW LEVEL SECURITY;

-- 1. Policy for viewing (Everyone can view)
DROP POLICY IF EXISTS "Allow public read access" ON public.roundtables;
CREATE POLICY "Allow public read access" ON public.roundtables
FOR SELECT USING (true);

-- 2. Policy for inserting (Only authenticated users can create)
DROP POLICY IF EXISTS "Allow authenticated insert" ON public.roundtables;
CREATE POLICY "Allow authenticated insert" ON public.roundtables
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 3. Policy for updating (Only moderator can update their own roundtable)
DROP POLICY IF EXISTS "Allow moderator update" ON public.roundtables;
CREATE POLICY "Allow moderator update" ON public.roundtables
FOR UPDATE USING (auth.uid() = moderator_id);

-- 4. Policy for deleting (Only moderator can delete)
DROP POLICY IF EXISTS "Allow moderator delete" ON public.roundtables;
CREATE POLICY "Allow moderator delete" ON public.roundtables
FOR DELETE USING (auth.uid() = moderator_id);
