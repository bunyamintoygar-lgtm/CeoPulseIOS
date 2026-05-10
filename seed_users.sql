-- 20 adet test kullanıcısı ve profili oluşturma
DO $$
DECLARE
    new_user_id UUID;
    user_names TEXT[] := ARRAY['Bünyamin Toygar', 'Selin Yılmaz', 'Mehmet Kaya', 'Ayşe Demir', 'Can Özkan', 'Derya Arslan', 'Emre Yıldız', 'Fatma Şahin', 'Gökhan Aydın', 'Hülya Koç', 'İbrahim Çelik', 'Jale Doğan', 'Kaan Polat', 'Leyla Aksoy', 'Murat Güneş', 'Nalan Bulut', 'Okan Yalçın', 'Pelin Şen', 'Rıza Öztürk', 'Sibel Kara'];
    titles TEXT[] := ARRAY['CEO @ TechSolutions', 'Marketing Director @ GlobalCorp', 'Founder @ StartupHub', 'CFO @ FinanceFlow', 'CTO @ InnovateSoft', 'Product Manager @ DesignPro', 'VP of Sales @ MarketMaster', 'HR Director @ TalentPool', 'Chief Architect @ BuildIt', 'Operations Manager @ SmoothOps', 'Senior Dev @ CodeCraft', 'UI/UX Designer @ PixelPerfect', 'Business Analyst @ DataDriven', 'Creative Lead @ ArtStudio', 'PR Manager @ MediaMind', 'Project Coordinator @ TaskForce', 'Solutions Architect @ CloudBase', 'Brand Manager @ IdentityPlus', 'Security Expert @ SafeNet', 'Investor @ GrowthCap'];
    i INTEGER;
BEGIN
    FOR i IN 1..20 LOOP
        new_user_id := gen_random_uuid();
        
        -- auth.users tablosuna ekle (Supabase Auth için gerekli simülasyon)
        INSERT INTO auth.users (id, email, raw_user_meta_data)
        VALUES (
            new_user_id, 
            'test_user_' || i || '@ceopulse.com', 
            jsonb_build_object('full_name', user_names[i])
        ) ON CONFLICT (id) DO NOTHING;

        -- profiles tablosuna ekle
        INSERT INTO public.profiles (id, full_name, avatar_url, title, updated_at)
        VALUES (
            new_user_id,
            user_names[i],
            'https://i.pravatar.cc/150?u=' || new_user_id,
            titles[i],
            NOW()
        ) ON CONFLICT (id) DO UPDATE SET
            full_name = EXCLUDED.full_name,
            avatar_url = EXCLUDED.avatar_url,
            title = EXCLUDED.title;
    END LOOP;
END $$;
