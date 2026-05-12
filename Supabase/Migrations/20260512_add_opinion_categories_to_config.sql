-- Migration: Add Opinion Categories to app_config
-- Date: 2026-05-12

DO $$
DECLARE
    opinion_categories_json JSONB;
BEGIN
    -- 1. Fikir Al (Ask Opinion) Kategorilerini Tanımla
    opinion_categories_json := '[
        {"id": "leadership-strategy", "tr": "Liderlik & Strateji", "en": "Leadership & Strategy", "icon": "person.2.fill"},
        {"id": "tech-innovation", "tr": "Teknoloji & İnovasyon", "en": "Tech & Innovation", "icon": "cpu.fill"},
        {"id": "finance-investment", "tr": "Finans & Yatırım", "en": "Finance & Investment", "icon": "chart.line.uptrend.xyaxis"},
        {"id": "marketing-growth", "tr": "Pazarlama & Büyüme", "en": "Marketing & Growth", "icon": "megaphone.fill"},
        {"id": "hr-culture", "tr": "İK & Kurum Kültürü", "en": "HR & Culture", "icon": "person.3.fill"},
        {"id": "operations-efficiency", "tr": "Operasyon & Verimlilik", "en": "Operations", "icon": "gearshape.2.fill"}
    ]'::JSONB;

    -- 2. app_config tablosuna ekle veya güncelle
    -- Eğer tablo yoksa önce oluştur (Garanti olsun)
    CREATE TABLE IF NOT EXISTS public.app_config (
        key TEXT PRIMARY KEY,
        value JSONB NOT NULL,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
    );

    INSERT INTO public.app_config (key, value)
    VALUES ('opinion_categories', opinion_categories_json)
    ON CONFLICT (key) DO UPDATE SET 
        value = EXCLUDED.value,
        updated_at = NOW();

    RAISE NOTICE 'Fikir Al kategorileri başarıyla app_config tablosuna eklendi.';
END $$;
