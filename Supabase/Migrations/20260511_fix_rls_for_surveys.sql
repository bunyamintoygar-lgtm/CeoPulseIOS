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

-- 3. survey_questions için SELECT yetkisini de 'authenticated' ile kısıtlayalım (Opsiyonel ama daha güvenli)
-- Mevcut Public Questions Access politikasını güncelliyoruz
DROP POLICY IF EXISTS "Public Questions Access" ON public.survey_questions;
CREATE POLICY "Authenticated View Questions" ON public.survey_questions 
FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS "Public Options Access" ON public.survey_options;
CREATE POLICY "Authenticated View Options" ON public.survey_options 
FOR SELECT TO authenticated USING (true);
