-- Migrations: Add Comprehensive Survey Categories
-- Date: 2026-05-08

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Ekonomi', 'Economy', 'chart.line.uptrend.xyaxis' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Ekonomi');

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Yapay Zeka', 'Artificial Intelligence', 'cpu' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Yapay Zeka');

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Liderlik', 'Leadership', 'person.2' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Liderlik');

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Teknoloji', 'Technology', 'laptopcomputer' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Teknoloji');

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'İnsan Kaynakları', 'Human Resources', 'person.3.sequence' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'İnsan Kaynakları');

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Sürdürülebilirlik', 'Sustainability', 'leaf' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Sürdürülebilirlik');

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Yatırım', 'Investment', 'dollarsign.circle' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Yatırım');

INSERT INTO public.survey_categories (name_tr, name_en, icon) 
SELECT 'Şirket Kültürü', 'Company Culture', 'building.2' WHERE NOT EXISTS (SELECT 1 FROM public.survey_categories WHERE name_tr = 'Şirket Kültürü');
