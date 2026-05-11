-- 1. Eklentileri Kontrol Et ve Aktifleştir
CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

-- 2. Eğer varsa eski görevi sil (Hata almamak için)
DO $$
BEGIN
    PERFORM cron.unschedule('daily-ai-insight-generation');
EXCEPTION
    WHEN others THEN
        -- Görev yoksa hata vermez
END $$;

-- 3. Yeni Günlük Görevi Tanımla
-- Her sabah 07:00 UTC'de (Türkiye saatiyle 10:00) çalışır
SELECT cron.schedule(
  'daily-ai-insight-generation', -- Görev adı
  '0 7 * * *',                   -- Cron ifadesi
  $$
  SELECT net.http_post(
    url := 'https://wvsbpsahpshgmrgcxpmq.supabase.co/functions/v1/generate-ai-insight',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer [SERVICE_ROLE_KEY]"}'::jsonb
  )
  $$
);
