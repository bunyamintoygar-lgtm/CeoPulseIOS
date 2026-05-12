-- Migration: Add Opinion Categories to app_config
-- Date: 2026-05-12

DO $$
DECLARE
    opinion_categories_json JSONB;
BEGIN
    -- 1. Fikir Al (Ask Opinion) Kategorilerini Tanımla
    opinion_categories_json := '[
        {"id": "strategy", "tr": "Strateji", "en": "Strategy", "icon": "target"},
        {"id": "growth", "tr": "Büyüme", "en": "Growth", "icon": "chart.line.uptrend.xyaxis"},
        {"id": "product-service", "tr": "Ürün & Hizmet", "en": "Product & Service", "icon": "cube.fill"},
        {"id": "sustainability", "tr": "Sürdürülebilirlik", "en": "Sustainability", "icon": "leaf.fill"},
        {"id": "marketing", "tr": "Pazarlama", "en": "Marketing", "icon": "megaphone.fill"},
        {"id": "sales", "tr": "Satış", "en": "Sales", "icon": "cart.fill"},
        {"id": "operations", "tr": "Operasyon", "en": "Operations", "icon": "gearshape.2.fill"},
        {"id": "finance", "tr": "Finans", "en": "Finance", "icon": "dollarsign.circle.fill"},
        {"id": "technology", "tr": "Teknoloji", "en": "Technology", "icon": "cpu.fill"},
        {"id": "human-resources", "tr": "İnsan Kaynakları", "en": "Human Resources", "icon": "person.2.fill"},
        {"id": "management", "tr": "Yönetim", "en": "Management", "icon": "briefcase.fill"},
        {"id": "leadership", "tr": "Liderlik", "en": "Leadership", "icon": "crown.fill"},
        {"id": "innovation", "tr": "İnovasyon", "en": "Innovation", "icon": "lightbulb.fill"},
        {"id": "investment", "tr": "Yatırım", "en": "Investment", "icon": "chart.pie.fill"},
        {"id": "legal", "tr": "Hukuk & Mevzuat", "en": "Legal & Regulation", "icon": "scale.3d"}
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
