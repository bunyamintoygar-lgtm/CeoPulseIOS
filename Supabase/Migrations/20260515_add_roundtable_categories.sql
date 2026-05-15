-- Insert roundtable categories into app_config
INSERT INTO public.app_config (key, value)
VALUES ('roundtable_categories', '[
  {"id": "leadership_strategy", "tr": "Liderlik ve Strateji", "en": "Leadership & Strategy"},
  {"name": "teknoloji_inovasyon", "tr": "Teknoloji ve İnovasyon", "en": "Technology & Innovation"},
  {"id": "finans_yatirim", "tr": "Finans ve Yatırım", "en": "Finance & Investment"},
  {"id": "pazarlama_buyume", "tr": "Pazarlama ve Büyüme", "en": "Marketing & Growth"},
  {"id": "insan_kaynaklari", "tr": "İnsan Kaynakları", "en": "Human Resources"},
  {"id": "operasyon_verimlilik", "tr": "Operasyon ve Verimlilik", "en": "Operations & Efficiency"},
  {"id": "dijital_donusum", "tr": "Dijital Dönüşüm", "en": "Digital Transformation"},
  {"id": "girisimcilik", "tr": "Girişimcilik", "en": "Entrepreneurship"}
]')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
