-- Insert roundtable categories into app_config with icons
INSERT INTO public.app_config (key, value)
VALUES ('roundtable_categories', '[
  {"id": "leadership_strategy", "tr": "Liderlik ve Strateji", "en": "Leadership & Strategy", "icon": "person.fill.checkmark"},
  {"id": "technology_innovation", "tr": "Teknoloji ve İnovasyon", "en": "Technology & Innovation", "icon": "cpu.fill"},
  {"id": "finance_investment", "tr": "Finans ve Yatırım", "en": "Finance & Investment", "icon": "chart.line.uptrend.xyaxis"},
  {"id": "marketing_growth", "tr": "Pazarlama ve Büyüme", "en": "Marketing & Growth", "icon": "arrow.up.right.circle.fill"},
  {"id": "human_resources", "tr": "İnsan Kaynakları", "en": "Human Resources", "icon": "person.2.fill"},
  {"id": "operations_efficiency", "tr": "Operasyon ve Verimlilik", "en": "Operations & Efficiency", "icon": "gearshape.2.fill"},
  {"id": "digital_transformation", "tr": "Dijital Dönüşüm", "en": "Digital Transformation", "icon": "laptopcomputer.and.iphone"},
  {"id": "entrepreneurship", "tr": "Girişimcilik", "en": "Entrepreneurship", "icon": "lightbulb.fill"}
]')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
