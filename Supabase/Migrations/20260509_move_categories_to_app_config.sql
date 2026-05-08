-- Migration: Fix Category IDs in app_config (Post-table drop)
-- Date: 2026-05-09

DO $$
DECLARE
    new_categories_json JSONB;
BEGIN
    -- 1. Kategorileri hardcoded olarak (slug ID'lerle) yeniden tanımlıyoruz
    -- Bu yöntem en güvenlisidir çünkü tablo zaten silindi.
    new_categories_json := '[
        {"id": "economy", "tr": "Ekonomi", "en": "Economy", "icon": "chart.line.uptrend.xyaxis"},
        {"id": "artificial-intelligence", "tr": "Yapay Zeka", "en": "Artificial Intelligence", "icon": "cpu"},
        {"id": "leadership", "tr": "Liderlik", "en": "Leadership", "icon": "person.2"},
        {"id": "technology", "tr": "Teknoloji", "en": "Technology", "icon": "laptopcomputer"},
        {"id": "human-resources", "tr": "İnsan Kaynakları", "en": "Human Resources", "icon": "person.3.sequence"},
        {"id": "sustainability", "tr": "Sürdürülebilirlik", "en": "Sustainability", "icon": "leaf"},
        {"id": "investment", "tr": "Yatırım", "en": "Investment", "icon": "dollarsign.circle"},
        {"id": "company-culture", "tr": "Şirket Kültürü", "en": "Company Culture", "icon": "building.2"}
    ]'::JSONB;

    -- 2. app_config tablosuna 'survey_categories' anahtarıyla güncelle
    INSERT INTO public.app_config (key, value)
    VALUES ('survey_categories', new_categories_json)
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

    -- 3. surveys tablosundaki category_id tipini UUID'den TEXT'e çevir (Eğer henüz yapılmadıysa)
    -- Önce kısıtlamayı kaldırıyoruz
    ALTER TABLE public.surveys DROP CONSTRAINT IF EXISTS surveys_category_id_fkey;
    
    -- Tipi değiştiriyoruz (Eğer zaten TEXT ise bu komut bir şeyi değiştirmez)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'surveys' AND column_name = 'category_id' AND data_type = 'uuid') THEN
        ALTER TABLE public.surveys ALTER COLUMN category_id TYPE TEXT USING NULL;
    END IF;

    RAISE NOTICE 'Kategoriler slug ID’lerle başarıyla güncellendi.';
END $$;
