import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const OPENAI_API_KEY = Deno.env.get('OPENAI_API_KEY')

serve(async (req) => {
  // CORS handling
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
    const { text } = await req.json()

    if (!text) {
      return new Response(JSON.stringify({ error: 'Text is required' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    const response = await fetch('https://api.openai.com/v1/moderations', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
      },
      body: JSON.stringify({
        input: text,
      }),
    })

    const result = await response.json()
    
    // Check if any results were flagged
    const flagged = result.results?.[0]?.flagged || false
    const categories = result.results?.[0]?.categories || {}
    
    // Find the primary reason for flagging
    let reason = null
    if (flagged) {
      const offendingCategory = Object.keys(categories).find(key => categories[key] === true)
      reason = offendingCategory ? `Uygunsuz içerik tespit edildi: ${offendingCategory}` : "Topluluk kuralları ihlali tespit edildi."
    }

    return new Response(
      JSON.stringify({ flagged, reason }),
      { 
        headers: { 
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*' 
        } 
      }
    )

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
    })
  }
})
