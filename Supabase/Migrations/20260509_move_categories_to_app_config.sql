-- Migration: Move Survey Categories to app_config JSON
-- Date: 2026-05-09

DO $$
DECLARE
    categories_json JSONB;
BEGIN
    -- 1. Mevcut kategorileri JSONB formatına dönüştür ve bir değişkene ata
    -- Not: ConfigManager'daki LocalizedValue yapısıyla (id, tr, en) uyumlu olması için 
    -- name_tr -> tr, name_en -> en olarak eşliyoruz.
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', id,
            'tr', name_tr,
            'en', name_en,
            'icon', icon
        )
    ) INTO categories_json
    FROM public.survey_categories;

    -- 2. app_config tablosuna 'survey_categories' anahtarıyla ekle veya güncelle
    -- Eğer app_config tablosunda 'key' alanı UNIQUE ise ON CONFLICT çalışacaktır.
    INSERT INTO public.app_config (key, value)
    VALUES ('survey_categories', categories_json)
    ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

    -- 3. surveys tablosundaki Foreign Key kısıtlamasını kaldır
    -- Bu sayede kategori tablosu silindiğinde hata almayız, UUID'ler referans olarak kalır.
    ALTER TABLE public.surveys DROP CONSTRAINT IF EXISTS surveys_category_id_fkey;

    -- 4. Artık ihtiyaç duyulmayan survey_categories tablosunu sil
    DROP TABLE IF EXISTS public.survey_categories;
    
    RAISE NOTICE 'Anket kategorileri başarıyla app_config tablosuna taşındı.';
END $$;
