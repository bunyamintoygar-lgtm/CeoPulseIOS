import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  try {
    const body = await req.json()
    console.log("Agora Callback Received:", JSON.stringify(body))

    // productId 20 = Speech-to-Text
    if (body.productId === 20) {
      const payload = body.payload
      if (!payload) return new Response("No payload", { status: 200 })

      console.log("Processing payload:", JSON.stringify(payload))

      // Agora results can be in different fields depending on the mode
      // Let's try to find text and uid robustly
      let text = payload.content || payload.text
      let agoraUid = payload.uid || payload.userId
      
      // If content is missing, it might be in words array
      if (!text && payload.words && payload.words.length > 0) {
        text = payload.words.map((w: any) => w.text).join('')
      }
      
      if (text && agoraUid) {
        const supabase = createClient(
          Deno.env.get('SUPABASE_URL') ?? '',
          Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        // 1. Find user_id from agora_uid
        const { data: participant, error: pError } = await supabase
          .from('roundtable_participants')
          .select('user_id, roundtable_id')
          .eq('agora_uid', agoraUid)
          .maybeSingle() // Use maybeSingle to avoid 406 error if not found

        if (participant) {
          console.log(`Mapping found: UID ${agoraUid} -> User ${participant.user_id}`)
          // 2. Insert into transcripts
          const { error: iError } = await supabase
            .from('roundtable_transcripts')
            .insert({
              roundtable_id: participant.roundtable_id,
              user_id: participant.user_id,
              content: text
            })

          if (iError) console.error("Insert Error:", iError)
          else console.log("Transcript saved successfully")
        } else {
          console.log("Participant not found for agora_uid:", agoraUid)
        }
      }
    }

    return new Response(JSON.stringify({ message: "Processed" }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    console.error("Callback processing error:", error)
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 200, // Always return 200 to Agora to avoid retries
    })
  }
})
