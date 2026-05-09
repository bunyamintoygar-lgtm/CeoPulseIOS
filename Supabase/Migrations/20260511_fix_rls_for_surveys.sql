-- Fix RLS for Survey Questions and Options
-- Date: 2026-05-11
-- This migration ensures that survey creators can manage (Insert/Update/Delete) 
-- the questions and options belonging to their surveys.

-- 1. survey_questions için politikalar
DROP POLICY IF EXISTS "Creators Manage Own Questions" ON public.survey_questions;

CREATE POLICY "Creators Manage Own Questions" ON public.survey_questions 
FOR ALL 
TO authenticated 
USING (
    EXISTS (
        SELECT 1 FROM public.surveys 
        WHERE public.surveys.id = survey_id 
        AND public.surveys.creator_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.surveys 
        WHERE public.surveys.id = survey_id 
        AND public.surveys.creator_id = auth.uid()
    )
);

-- 2. survey_options için politikalar
DROP POLICY IF EXISTS "Creators Manage Own Options" ON public.survey_options;

CREATE POLICY "Creators Manage Own Options" ON public.survey_options 
FOR ALL 
TO authenticated 
USING (
    EXISTS (
        SELECT 1 FROM public.survey_questions q
        JOIN public.surveys s ON q.survey_id = s.id
        WHERE q.id = question_id 
        AND s.creator_id = auth.uid()
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.survey_questions q
        JOIN public.surveys s ON q.survey_id = s.id
        WHERE q.id = question_id 
        AND s.creator_id = auth.uid()
    )
);

-- 3. surveys tablosu için yetkileri güçlendirelim
-- Önce eski geniş kapsamlı politikayı kaldıralım
DROP POLICY IF EXISTS "Creators Manage Own Surveys" ON public.surveys;

-- Sahibi için SELECT ve INSERT yetkisi
CREATE POLICY "Creators Select Own Surveys" ON public.surveys 
FOR SELECT TO authenticated 
USING (auth.uid() = creator_id OR status IN ('active', 'completed'));

CREATE POLICY "Creators Insert Own Surveys" ON public.surveys 
FOR INSERT TO authenticated 
WITH CHECK (auth.uid() = creator_id);

-- Sahibi için UPDATE ve DELETE yetkisi (SADECE HİÇ OY YOKSA)
CREATE POLICY "Creators Update/Delete If No Votes" ON public.surveys 
FOR ALL TO authenticated 
USING (
    auth.uid() = creator_id 
    AND NOT EXISTS (
        SELECT 1 FROM public.survey_responses 
        WHERE public.survey_responses.survey_id = public.surveys.id
    )
)
WITH CHECK (
    auth.uid() = creator_id 
    AND NOT EXISTS (
        SELECT 1 FROM public.survey_responses 
        WHERE public.survey_responses.survey_id = public.surveys.id
    )
);

-- 4. survey_questions ve survey_options için SELECT yetkisi (authenticated için genel)
DROP POLICY IF EXISTS "Authenticated View Questions" ON public.survey_questions;
CREATE POLICY "Authenticated View Questions" ON public.survey_questions 
FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Authenticated View Options" ON public.survey_options;
CREATE POLICY "Authenticated View Options" ON public.survey_options 
FOR SELECT TO authenticated USING (true);
