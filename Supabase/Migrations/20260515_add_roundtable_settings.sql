-- Add participant counts and durations to app_config
INSERT INTO public.app_config (key, value)
VALUES 
('roundtable_participant_counts', '[
  {"id": "small", "tr": "3 - 6 kişi", "en": "3 - 6 people"},
  {"id": "medium", "tr": "6 - 12 kişi", "en": "6 - 12 people"},
  {"id": "large", "tr": "12 - 20 kişi", "en": "12 - 20 people"},
  {"id": "unlimited", "tr": "20+ kişi", "en": "20+ people"}
]'),
('roundtable_durations', '[
  {"id": "short", "tr": "45 dakika", "en": "45 minutes"},
  {"id": "medium", "tr": "60 dakika", "en": "60 minutes"},
  {"id": "long", "tr": "90 dakika", "en": "90 minutes"},
  {"id": "extra_long", "tr": "120 dakika", "en": "120 minutes"}
]')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;
