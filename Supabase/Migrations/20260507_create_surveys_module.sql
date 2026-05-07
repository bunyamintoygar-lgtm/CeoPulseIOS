-- Migrations: Create Surveys Module
-- Date: 2026-05-07

-- 1. Kategoriler Tablosu
CREATE TABLE IF NOT EXISTS public.survey_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_tr TEXT NOT NULL,
    name_en TEXT NOT NULL,
    icon TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Anketler Tablosu
CREATE TABLE IF NOT EXISTS public.surveys (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    creator_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category_id UUID REFERENCES public.survey_categories(id),
    cover_image_url TEXT,
    target_audience TEXT DEFAULT 'public',
    status TEXT DEFAULT 'active',
    start_date TIMESTAMPTZ DEFAULT now(),
    end_date TIMESTAMPTZ,
    is_anonymous BOOLEAN DEFAULT true,
    result_visibility TEXT DEFAULT 'immediate',
    allow_edit_responses BOOLEAN DEFAULT false,
    participation_limit INTEGER,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. Sorular Tablosu
CREATE TABLE IF NOT EXISTS public.survey_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    survey_id UUID REFERENCES public.surveys(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type TEXT DEFAULT 'single_choice',
    is_required BOOLEAN DEFAULT true,
    max_selections INTEGER DEFAULT 1,
    "order" INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. Seçenekler Tablosu
CREATE TABLE IF NOT EXISTS public.survey_options (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID REFERENCES public.survey_questions(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Yanıtlar Tablosu
CREATE TABLE IF NOT EXISTS public.survey_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    survey_id UUID REFERENCES public.surveys(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    question_id UUID REFERENCES public.survey_questions(id) ON DELETE CASCADE,
    option_id UUID REFERENCES public.survey_options(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, question_id)
);

-- Örnek Kategoriler
INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Ekonomi', 'Economy', 'chart.line.uptrend.xyaxis' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Ekonomi');
INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Yapay Zeka', 'Artificial Intelligence', 'cpu' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Yapay Zeka');
INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Liderlik', 'Leadership', 'person.2' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Liderlik');
INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Teknoloji', 'Technology', 'laptopcomputer' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Teknoloji');

-- RLS
ALTER TABLE public.surveys ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.survey_responses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Surveys Access" ON public.surveys FOR SELECT USING (status != 'draft');
CREATE POLICY "Public Questions Access" ON public.survey_questions FOR SELECT USING (true);
CREATE POLICY "Public Options Access" ON public.survey_options FOR SELECT USING (true);
CREATE POLICY "Creators Manage Own Surveys" ON public.surveys FOR ALL USING (auth.uid() = creator_id);
CREATE POLICY "Authenticated Users Response" ON public.survey_responses FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users View Own Responses" ON public.survey_responses FOR SELECT USING (auth.uid() = user_id);
