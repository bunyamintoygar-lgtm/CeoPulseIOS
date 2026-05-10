import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
      }
    })
  }

  try {
    const { record, survey_id: body_id } = await req.json()
    const survey_id = body_id || record?.id

    if (!survey_id) {
      return new Response(JSON.stringify({ error: 'survey_id is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Webhook'tan geliyorsa soruların tam yazılması için 2 saniye bekle
    await new Promise(resolve => setTimeout(resolve, 2000))

    // Service role ile Supabase bağlantısı (tüm verilere erişebilir)
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // 1. Anketi çek
    const { data: survey, error: surveyError } = await supabase
      .from('surveys')
      .select('title, description, status, language')
      .eq('id', survey_id)
      .single()

    if (surveyError || !survey) {
      return new Response(JSON.stringify({ error: 'Survey not found' }), {
        status: 404,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const systemPrompt = survey.language === 'en' 
      ? `You are a content moderator. Review the provided survey content for obscenity, insults, profanity, hate speech, and community guidelines. 
         If the content is inappropriate, set 'flagged' to true and add a short 'reason' in English. 
         If it is appropriate, 'flagged' should be false. 
         Return ONLY JSON: {"flagged": boolean, "reason": string|null}`
      : `Sen bir içerik moderatörüsün. Verilen anket içeriğini müstehcenlik, hakaret, küfür, nefret söylemi ve topluluk kuralları açısından incele. 
         Eğer içerik uygunsuzsa 'flagged' değerini true yap ve kısa bir 'reason' (Türkçe) ekle. 
         Uygunsa 'flagged' false olsun. 
         Sadece JSON döndür: {"flagged": boolean, "reason": string|null}`;

    // 2. Soruları ve seçenekleri çek
    const { data: questions } = await supabase
      .from('survey_questions')
      .select('question_text, survey_options(option_text)')
      .eq('survey_id', survey_id)

    // 3. Tüm metni birleştir
    let textToModerate = `Başlık: ${survey.title}\n`
    if (survey.description) {
      textToModerate += `Açıklama: ${survey.description}\n`
    }
    for (const q of (questions || [])) {
      textToModerate += `Soru: ${q.question_text}\n`
      for (const opt of (q.survey_options || [])) {
        textToModerate += `Seçenek: ${opt.option_text}\n`
      }
    }

    // 4. OpenAI ile içerik denetimi
    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          {
            role: "system",
            content: systemPrompt
          },
          {
            role: "user",
            content: textToModerate
          }
        ],
        response_format: { type: "json_object" }
      }),
    })

    const aiResult = await aiResponse.json()
    const moderation = JSON.parse(aiResult.choices[0].message.content)

    // 5. Uygunsuzsa status'u rejected yap
    if (moderation.flagged) {
      const defaultReason = survey.language === 'en' ? 'Content violated community guidelines.' : 'İçerik topluluk kurallarına aykırı bulundu.'
      
      await supabase
        .from('surveys')
        .update({
          status: 'rejected',
          rejection_reason: moderation.reason ?? defaultReason
        })
        .eq('id', survey_id)

      console.log(`Survey ${survey_id} rejected (${survey.language}): ${moderation.reason}`)
    }

    return new Response(
      JSON.stringify({ 
        flagged: moderation.flagged, 
        reason: moderation.reason 
      }),
      { headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' } }
    )

  } catch (error) {
    console.error('auto-moderate-survey error:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    })
  }
})
