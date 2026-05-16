import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const AGORA_APP_ID = Deno.env.get('AGORA_APP_ID')!
const AGORA_CUSTOMER_ID = Deno.env.get('AGORA_CUSTOMER_ID')!
const AGORA_CUSTOMER_SECRET = Deno.env.get('AGORA_CUSTOMER_SECRET')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

serve(async (req) => {
  try {
    const body = await req.json()
    console.log("Request:", JSON.stringify(body))

    const { channelName, roundtableId } = body
    if (!channelName) throw new Error("channelName is required")

    const basicAuth = `Basic ${btoa(`${AGORA_CUSTOMER_ID}:${AGORA_CUSTOMER_SECRET}`)}`
    const callbackUrl = `${SUPABASE_URL}/functions/v1/agora-stt-callback`

    const url = `https://api.agora.io/api/speech-to-text/v1/projects/${AGORA_APP_ID}/join`

    const payload = {
      name: `stt-${Date.now()}`,
      languages: ["tr-TR"],
      maxIdleTime: 300,
      rtcConfig: {
        channelName: channelName,
        subBotUid: "47091",
        pubBotUid: "88222"
      }
    }

    console.log(`Calling STT v7: POST ${url}`)
    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    })

    const responseText = await response.text()
    console.log(`Status: ${response.status}, Body: ${responseText}`)

    if (response.ok) {
      const result = JSON.parse(responseText)
      const agentId = result.agent_id

      // Save agent_id to roundtable so we can stop it later
      if (roundtableId && agentId) {
        const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
        const { error } = await supabase
          .from('roundtables')
          .update({ stt_agent_id: agentId })
          .eq('id', roundtableId)

        if (error) {
          console.error("DB update error:", error.message)
        } else {
          console.log("agent_id saved to roundtable:", agentId)
        }
      }

      return new Response(JSON.stringify(result), {
        status: 200,
        headers: { "Content-Type": "application/json" }
      })
    }

    return new Response(responseText, {
      status: response.status,
      headers: { "Content-Type": "application/json" }
    })

  } catch (error) {
    console.error("Error:", error.message)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    })
  }
})
