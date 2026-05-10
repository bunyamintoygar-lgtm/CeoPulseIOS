-- Uzak DB Şemasına Uygun Seed Data (Profiles: first_name, last_name, position, company)
DO $$
DECLARE
    u_id UUID;
    user_names TEXT[] := ARRAY['Elon Musk', 'Tim Cook', 'Satya Nadella', 'Jensen Huang', 'Mark Zuckerberg', 'Sunder Pichai', 'Jeff Bezos', 'Reed Hastings', 'Sam Altman', 'Vitalik Buterin', 'Sheryl Sandberg', 'Gwynne Shotwell', 'Cathie Wood', 'Mary Barra', 'Safra Catz', 'Susan Wojcicki', 'Leena Nair', 'Whitney Wolfe', 'Melanie Perkins', 'Anne Wojcicki'];
    u_positions TEXT[] := ARRAY['CEO', 'CEO', 'CEO', 'CEO', 'CEO', 'CEO', 'Founder', 'Chairman', 'CEO', 'Co-founder', 'Board Member', 'COO', 'CEO', 'CEO', 'CEO', 'Former CEO', 'CEO', 'Founder', 'CEO', 'CEO'];
    u_companies TEXT[] := ARRAY['Tesla/SpaceX', 'Apple', 'Microsoft', 'NVIDIA', 'Meta', 'Google', 'Amazon', 'Netflix', 'OpenAI', 'Ethereum', 'Independent', 'SpaceX', 'ARK Invest', 'GM', 'Oracle', 'YouTube', 'Chanel', 'Bumble', 'Canva', '23andMe'];
    i INTEGER;
    s_id UUID;
    q_id UUID;
    cat_id UUID := '68686868-6868-6868-6868-686868686868'; -- Teknoloji
BEGIN
    FOR i IN 1..20 LOOP
        u_id := gen_random_uuid();
        
        -- Profile ekle (Uzak DB şemasına göre)
        INSERT INTO public.profiles (id, first_name, last_name, position, company, avatar_url, updated_at)
        VALUES (
            u_id,
            split_part(user_names[i], ' ', 1),
            split_part(user_names[i], ' ', 2),
            u_positions[i],
            u_companies[i],
            'https://i.pravatar.cc/150?u=' || user_names[i],
            NOW()
        );

        -- Anket Oluştur (Her 4 kullanıcıda bir)
        IF i % 4 = 0 THEN
            s_id := gen_random_uuid();
            INSERT INTO public.surveys (id, creator_id, category_id, title, description, status, language, created_at)
            VALUES (
                s_id,
                u_id,
                cat_id,
                '2026 ' || user_names[i] || ' Vision Survey',
                'Exploring industry trends and future expectations.',
                'active',
                'en',
                NOW() - (i || ' days')::interval
            );

            -- Soru 1
            q_id := gen_random_uuid();
            INSERT INTO public.survey_questions (id, survey_id, question_text, question_type, is_required)
            VALUES (q_id, s_id, 'How will AI affect employment in your sector?', 'single_choice', true);
            
            INSERT INTO public.survey_options (id, question_id, option_text, order_index)
            VALUES 
                (gen_random_uuid(), q_id, 'Create new opportunities', 0),
                (gen_random_uuid(), q_id, 'Reduce total headcount', 1),
                (gen_random_uuid(), q_id, 'Shift focus to higher-value tasks', 2);
        END IF;
    END LOOP;
END $$;
