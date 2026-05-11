import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

serve(async (req) => {
  try {
    const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!)

    // 1. OpenAI ile Güncel Konu Belirleme ve Araştırma
    const prompt = `
      Sen dünyanın en prestijli strateji danışmanlık firmalarında (McKinsey, BCG gibi) çalışan bir "Senior Strategy Consultant" ve Yapay Zeka uzmanısın. 
      Görevin CEO'lar için "Deep Research" yaparak benzersiz, niş ve yüksek stratejik değere sahip bir analiz raporu hazırlamak.
      
      ADIMLAR:
      1. Web araması yaparak bugün iş dünyasını sarsan, henüz herkesin tam analiz edemediği çok taze ve kritik bir konu seç.
      2. Bu konu hakkında "Deep Dive" araştırma yap. Genel geçer bilgilerden kaçın, gizli trendleri ve sayısal verileri bul.
      3. Çıktıyı MUTLAKA aşağıdaki JSON formatında ver.
      
      ULTRA DETAY KURALLARI:
      - "summary_tab.description": En az 150 kelimelik, derinlemesine bir yönetici özeti olmalı.
      - "findings_tab": En az 5 adet, her biri şaşırtıcı bir veri içeren bulgu olmalı.
      - "analysis_tab.trends": En az 4 farklı veri serisi ve her seride en az 6 veri noktası (zaman serisi) olmalı.
      - "analysis_tab.regional_data": En az 6-7 farklı bölge/pazar detayı içermeli.
      - "recommendations_tab": En az 5 adet, "Radikal" ve "Pratik" dengesinde stratejik öneri içermeli.
      - "icon" SEÇİMİ: Sadece geçerli SF Symbols kullan (Örn: 'chart.line.uptrend.xyaxis', 'dollarsign.circle', 'rocket.fill', 'flask', 'person.2.fill', 'banknote', 'lightbulb.fill', 'target', 'bolt.fill').
      
      JSON FORMATI:
      {
        "title": "Vurucu, Provokatif ve Profesyonel Başlık",
        "subtitle": "Analizin stratejik değerini anlatan alt başlık",
        "category": "Teknoloji|Ekonomi|İK & Yetenek",
        "read_time": 7,
        "content": {
          "summary_tab": {
            "description": "Stratejik derinliği olan, neden-sonuç ilişkisi kuran uzun özet...",
            "stats": [
              { "label": "Stratejik Metrik 1", "value": "...", "icon": "..." },
              { "label": "Finansal Etki", "value": "...", "icon": "..." },
              { "label": "Güven Aralığı", "value": "%98", "icon": "checkmark.seal" }
            ]
          },
          "findings_tab": [
            { "title": "Kritik Bulgu", "desc": "Detaylı analiz ve sayısal veri içeren açıklama...", "percentage": 75, "icon": "..." }
          ],
          "analysis_tab": {
            "trends": [
              { "label": "Metrik A", "points": [10, 15, 25, 40, 60, 85], "color": "#6366F1" }
            ],
            "regional_data": [
              { "region": "Gelişmekte Olan Pazarlar", "percentage": 42, "flag": "..." }
            ]
          },
          "recommendations_tab": [
            { "title": "Stratejik Hamle", "desc": "Bu hamlenin neden yapılması gerektiği ve 12 aylık projeksiyonu...", "impact": "High", "icon": "..." }
          ]
        }
      }
    `;

    const response = await fetch('https://api.openai.com/v1/responses', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-5.4-mini',
        tools: [
          { type: "web_search" }
        ],
        input: `
          Sen profesyonel bir iş analisti ve stratejistsin. Görevin CEO'lar için internette derinlemesine araştırma yaparak taze ve stratejik içgörüler üretmektir.
          
          TALİMAT: Aşağıdaki çerçevede bir analiz hazırla. Çıktıyı MUTLAKA SADECE JSON formatında ver. Hiçbir açıklama veya ekstra metin ekleme.
          
          ${prompt}
        `
      }),
    })

    const aiResult = await response.json()
    
    if (aiResult.error) {
      console.error("OpenAI API Error:", JSON.stringify(aiResult.error))
      throw new Error(`OpenAI API Error: ${aiResult.error.message}`)
    }

    // v1/responses yapısında içerik genellikle output.text içinde gelir
    let rawContent = aiResult.output?.text || aiResult.choices?.[0]?.message?.content
    if (!rawContent) {
      console.error("AI Result Structure:", JSON.stringify(aiResult))
      throw new Error("AI response structure unexpected or empty.")
    }

    // Markdown bloklarını temizle (```json ... ``` gibi)
    rawContent = rawContent.replace(/```json\n?/, "").replace(/```\n?$/, "").trim()

    const insightData = JSON.parse(rawContent)

    // 2. Veritabanına Kaydet
    const { data, error } = await supabase
      .from('ai_insights')
      .insert([
        {
          title: insightData.title,
          subtitle: insightData.subtitle,
          category: insightData.category,
          read_time: insightData.read_time,
          content: insightData.content,
          is_premium: true
        }
      ])
      .select()

    if (error) throw error

    return new Response(JSON.stringify({ success: true, data }), {
      headers: { "Content-Type": "application/json" },
    })

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    })
  }
})
