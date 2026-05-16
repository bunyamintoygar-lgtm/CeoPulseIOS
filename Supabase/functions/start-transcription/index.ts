import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const AGORA_APP_ID = Deno.env.get('AGORA_APP_ID')
const AGORA_CUSTOMER_ID = Deno.env.get('AGORA_CUSTOMER_ID')
const AGORA_CUSTOMER_SECRET = Deno.env.get('AGORA_CUSTOMER_SECRET')

serve(async (req) => {
  const { roundtableId, channelName } = await req.json()

  // 1. Acquire Resource ID
  const acquireResponse = await fetch(`https://api.agora.io/v1/projects/${AGORA_APP_ID}/rtsc/speech-to-text/builderTokens`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${btoa(`${AGORA_CUSTOMER_ID}:${AGORA_CUSTOMER_SECRET}`)}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ instanceId: channelName })
  })
  
  const { tokenName } = await acquireResponse.json()

  // 2. Start Transcription Task
  const startResponse = await fetch(`https://api.agora.io/v1/projects/${AGORA_APP_ID}/rtsc/speech-to-text/tasks?builderToken=${tokenName}`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${btoa(`${AGORA_CUSTOMER_ID}:${AGORA_CUSTOMER_SECRET}`)}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      audioQueriesConfig: {
        subscribeAudioUids: ["#allstream#"],
        subscribeStatus: "all"
      },
      config: {
        features: ["recognize"],
        recognizeConfig: {
          language: "tr-TR", // Türkçe Desteği!
          model: "general",
          output: {
            languages: ["tr-TR"],
            mode: "json" // JSON formatında istiyoruz
          }
        }
      },
      callbackConfig: {
        iVercallbackUrl: `https://${Deno.env.get('MY_PROJECT_REF')}.functions.supabase.co/agora-stt-callback`
      }
    })
  })

  const result = await startResponse.json()
  return new Response(JSON.stringify(result), { status: 200 })
})
