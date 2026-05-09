-- ============================================================
-- Migration: Add rejected status and rejection_reason to surveys
-- ============================================================

-- 1. surveys tablosuna rejection_reason kolonu ekle
ALTER TABLE surveys 
ADD COLUMN IF NOT EXISTS rejection_reason TEXT DEFAULT NULL;

-- 2. status alanı text/varchar ise 'rejected' değerine izin ver
-- (Eğer enum ise aşağıdaki satırı kullanın)
-- ALTER TYPE survey_status ADD VALUE IF NOT EXISTS 'rejected';

-- 3. RLS: creators kendi rejection_reason'larını görebilir (zaten var)
-- 4. Index: rejected anketleri hızlı filtrelemek için
CREATE INDEX IF NOT EXISTS idx_surveys_status ON surveys(status);

-- 5. Supabase Webhook ayarı için not:
-- Supabase Dashboard > Database > Webhooks bölümünden:
-- Table: surveys, Event: INSERT
-- URL: https://<project-ref>.supabase.co/functions/v1/auto-moderate-survey
-- Headers: Authorization: Bearer <service_role_key>
-- Bu webhook, yeni anket eklendiğinde otomatik moderasyonu tetikler.
