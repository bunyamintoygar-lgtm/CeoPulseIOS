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
    const { title, description, language = 'tr' } = await req.json()

    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OPENAI_API_KEY is not set')
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
        model: "gpt-4o",
        messages: [
          { role: "system", content: "You are a professional survey generator that outputs only JSON." },
          { role: "user", content: prompt }
        ],
        response_format: { type: "json_object" }
      }),
    })

    const openAiData = await openAiResponse.json()
    
    if (openAiData.error) {
      console.error('OpenAI API Error:', openAiData.error)
      throw new Error(`OpenAI Error: ${openAiData.error.message || 'Unknown error'}`)
    }

    if (!openAiData.choices || openAiData.choices.length === 0) {
      console.error('Unexpected OpenAI Response:', openAiData)
      throw new Error('OpenAI returned no choices. Check your API key and quota.')
    }

    const content = openAiData.choices[0].message.content
    
    // Sometimes GPT wraps the array in a root object, we'll try to find the array
    let questions = JSON.parse(content)
    if (questions.questions) {
      questions = questions.questions
    }

    return new Response(
      JSON.stringify(questions),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
