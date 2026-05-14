-- Roundtable Seed Data

-- Clear existing data (Optional, be careful in production)
-- DELETE FROM public.roundtable_messages;
-- DELETE FROM public.roundtable_participants;
-- DELETE FROM public.roundtables;

-- 1. Active Roundtables
INSERT INTO public.roundtables (id, title, description, category, status, start_time, end_time, image_url)
VALUES 
(
    'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', 
    'Yapay Zeka Çağında Liderlik: Stratejilerimiz Nasıl Değişmeli?', 
    'AI dönüşümü, liderlik yetkinliklerini ve organizasyon kültürünü nasıl yeniden şekillendiriyor?', 
    'Teknoloji', 
    'active', 
    NOW() - INTERVAL '30 minutes', 
    NOW() + INTERVAL '1 hour', 
    'ai_meeting'
),
(
    'b2c3d4e5-f6a7-4b6c-9d8e-1f2a3b4c5d6e', 
    'Sürdürülebilirlik ve Net Sıfır Hedefleri', 
    'Şirketlerin karbon ayak izini azaltma stratejileri ve yeşil dönüşüm fırsatları.', 
    'Strateji', 
    'active', 
    NOW() - INTERVAL '15 minutes', 
    NOW() + INTERVAL '45 minutes', 
    'wind'
);

-- 2. Upcoming Roundtables
INSERT INTO public.roundtables (id, title, description, category, status, start_time, end_time, image_url)
VALUES 
(
    'c3d4e5f6-a7b8-4c7d-8e9f-2a3b4c5d6e7f', 
    'Global Ekonomide 2025 Beklentileri', 
    'Enflasyon, faiz kararları ve global pazarlardaki büyüme beklentilerinin analizi.', 
    'Ekonomi', 
    'upcoming', 
    NOW() + INTERVAL '2 days', 
    NOW() + INTERVAL '2 days' + INTERVAL '2 hours', 
    'economy'
),
(
    'd4e5f6a7-b8c9-4d8e-9f0a-3b4c5d6e7f8a', 
    'CEO''lar için Yetenek Stratejileri', 
    'Yeni nesil yetenekleri çekme ve elde tutma konusunda modern yaklaşımlar.', 
    'İK & Organizasyon', 
    'upcoming', 
    NOW() + INTERVAL '5 days', 
    NOW() + INTERVAL '5 days' + INTERVAL '90 minutes', 
    'talent'
);

-- 3. Completed Roundtables
INSERT INTO public.roundtables (id, title, description, category, status, start_time, end_time, image_url)
VALUES 
(
    'e5f6a7b8-c9d0-4e9f-0a1b-4c5d6e7f8a9b', 
    'Dijital Dönüşümde Başarı Hikayeleri', 
    'Geleneksel sektörlerde dijitalleşme sürecini başarıyla tamamlayan şirketlerden örnekler.', 
    'Teknoloji', 
    'completed', 
    NOW() - INTERVAL '7 days', 
    NOW() - INTERVAL '7 days' + INTERVAL '2 hours', 
    'digital'
);

-- 4. Sample Participants (Using existing users from profiles table)
-- We will add 3 participants to the first active roundtable
INSERT INTO public.roundtable_participants (roundtable_id, user_id, role, is_muted)
SELECT 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', id, 'speaker', true
FROM public.profiles
LIMIT 3;

-- Add a moderator to the second active roundtable
INSERT INTO public.roundtable_participants (roundtable_id, user_id, role, is_muted)
SELECT 'b2c3d4e5-f6a7-4b6c-9d8e-1f2a3b4c5d6e', id, 'moderator', false
FROM public.profiles
LIMIT 1;

-- 5. Sample Messages
-- Add some messages to the first active roundtable
INSERT INTO public.roundtable_messages (roundtable_id, user_id, content, type)
SELECT 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', id, 'Hoş geldiniz! Harika bir sohbet bizi bekliyor.', 'text'
FROM public.profiles
LIMIT 1;

INSERT INTO public.roundtable_messages (roundtable_id, user_id, content, type)
SELECT 'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d', id, 'Yapay zeka stratejileri hakkında sorularınızı bekliyoruz.', 'text'
FROM public.profiles
OFFSET 1 LIMIT 1;
