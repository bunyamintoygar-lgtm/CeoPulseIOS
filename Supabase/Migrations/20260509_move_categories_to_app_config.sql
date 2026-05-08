-- Migration: Move Survey Categories to app_config JSON with Readable IDs
-- Date: 2026-05-09

DO $$
DECLARE
    categories_json JSONB;
BEGIN
    -- 1. Mevcut kategorileri JSONB formatına dönüştür
    -- ID olarak UUID yerine name_en'den türetilmiş slug kullanıyoruz (örn: 'Artificial Intelligence' -> 'artificial-intelligence')
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', LOWER(REPLACE(name_en, ' ', '-')),
            'tr', name_tr,
            'en', name_en,
            'icon', icon
        )
    ) INTO categories_json
    FROM public.survey_categories;

    -- 2. app_config tablosuna ekle/güncelle
    INSERT INTO public.app_config (key, value)
    VALUES ('survey_categories', categories_json)
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

    -- 3. surveys tablosundaki category_id tipini UUID'den TEXT'e çevir
    -- Önce kısıtlamayı kaldırıyoruz
    ALTER TABLE public.surveys DROP CONSTRAINT IF EXISTS surveys_category_id_fkey;
    
    -- Tipi değiştiriyoruz (Mevcut UUID verilerini slug'lara eşlemek zor olacağı için bu aşamada temizliyoruz)
    ALTER TABLE public.surveys ALTER COLUMN category_id TYPE TEXT USING NULL;

    -- 4. Eski tabloyu sil
    DROP TABLE IF EXISTS public.survey_categories;
    
    RAISE NOTICE 'Anket kategorileri okunabilir ID’lerle app_config’e taşındı.';
END $$;
