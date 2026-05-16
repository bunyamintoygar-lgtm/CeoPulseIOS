-- Allow users to update their own participant record (e.g. to request floor or update role)
DROP POLICY IF EXISTS "Allow users to update their own participant state" ON public.roundtable_participants;
CREATE POLICY "Allow users to update their own participant state" ON public.roundtable_participants
    FOR UPDATE USING (auth.uid() = user_id);
