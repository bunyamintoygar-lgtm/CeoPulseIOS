-- Fix Multiple Choice Constraint
-- Date: 2026-05-10
-- Bu migration, bir kullanıcının bir soruya birden fazla seçenek işaretleyebilmesine olanak tanır.

-- 1. Eski kısıtlamayı (tekil cevap zorunluluğu) kaldır
ALTER TABLE public.survey_responses 
DROP CONSTRAINT IF EXISTS survey_responses_user_id_question_id_key;

-- 2. Yeni kısıtlamayı ekle (aynı şıkkın mükerrer kaydedilmesini önler ama farklı şıkların seçilmesine izin verir)
ALTER TABLE public.survey_responses 
ADD CONSTRAINT survey_responses_user_id_question_id_option_id_key 
UNIQUE (user_id, question_id, option_id);
