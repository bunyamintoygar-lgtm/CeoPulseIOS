-- 1. AI Insights Tablosunu Oluştur
CREATE TABLE IF NOT EXISTS public.ai_insights (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    subtitle TEXT,
    category TEXT NOT NULL,
    read_time INTEGER DEFAULT 5,
    content JSONB NOT NULL, -- Tüm tab içerikleri (Summary, Findings, Charts, Recs) burada tutulacak
    is_premium BOOLEAN DEFAULT FALSE,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. RLS (Row Level Security) Aktifleştir
ALTER TABLE public.ai_insights ENABLE ROW LEVEL SECURITY;

-- 3. Politikalar (Policies)
-- Herkes analizleri okuyabilir
CREATE POLICY "Analizler herkes tarafından okunabilir" 
ON public.ai_insights FOR SELECT 
USING (true);

-- Sadece Service Role (Edge Function) ekleme/güncelleme yapabilir
CREATE POLICY "Sadece sistem analiz ekleyebilir" 
ON public.ai_insights FOR ALL 
TO service_role 
USING (true) 
WITH CHECK (true);

-- 4. Otomatik updated_at tetikleyicisi (Opsiyonel ama iyi bir pratik)
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_ai_insights_updated_at
BEFORE UPDATE ON public.ai_insights
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
