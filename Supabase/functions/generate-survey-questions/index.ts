import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { title, description = "", language = 'tr' } = await req.json()

    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OPENAI_API_KEY is not set in Secrets')
    }

    const langName = language === 'tr' ? 'Turkish' : 'English'

    const prompt = `You are a professional survey consultant for elite CEOs. 
    Create a comprehensive and high-quality survey based on the following:
    Title: ${title}
    Description: ${description}
    
    Instructions:
    - Generate 5-8 insightful questions.
    - For each question, decide if it should be 'single_choice' or 'multiple_choice'.
    - Provide 4-6 high-quality options for each question.
    - Return ONLY a valid JSON array of objects.
    - Each object must have: 
      "text" (string), 
      "type" (either "single_choice" or "multiple_choice"), 
      "options" (array of strings),
      "isRequired": true,
      "allowMultiple": (true if type is multiple_choice, else false)
    - Language: ${langName}.`

    const openAiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are a professional survey generator that outputs only JSON." },
          { role: "user", content: prompt }
        ],
        response_format: { type: "json_object" }
      }),
    })

    const openAiData = await openAiResponse.json()
    
    if (openAiData.error) {
      return new Response(
        JSON.stringify({ error: `OpenAI Error: ${openAiData.error.message}` }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    if (!openAiData.choices || openAiData.choices.length === 0) {
      return new Response(
        JSON.stringify({ error: "OpenAI returned no results. Please check your quota/balance." }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
      )
    }

    const content = openAiData.choices[0].message.content
    let rawData = JSON.parse(content)
    let questionsArray = Array.isArray(rawData) ? rawData : (rawData.questions || [])

    // Ensure each question has the exact expected structure and types
    const cleanedQuestions = questionsArray.map((q: any) => ({
      text: typeof q.text === 'string' ? q.text : (q.text?.tr || q.text?.en || JSON.stringify(q.text)),
      type: typeof q.type === 'string' ? q.type : (q.type?.value || "single_choice"),
      options: Array.isArray(q.options) ? q.options.map((opt: any) => typeof opt === 'string' ? opt : JSON.stringify(opt)) : [],
      isRequired: true,
      allowMultiple: q.type === 'multiple_choice' || q.allowMultiple === true
    }))

    return new Response(
      JSON.stringify(cleanedQuestions),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
