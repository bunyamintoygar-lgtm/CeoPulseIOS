import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  try {
    const body = await req.json()
    console.log("Agora Callback Received:", JSON.stringify(body))

    // Agora STT results usually come in the payload
    // We filter for productId 20 (Speech-to-Text)
    if (body.productId === 20) {
      const { sid, payload } = body
      
      // Handle different event types (123 is usually transcription result)
      // Note: Actual implementation depends on Agora's specific STT version settings
      // If Agora is configured to send JSON, we process it here.
      
      if (payload && payload.content) {
         const supabase = createClient(
          Deno.env.get('SUPABASE_URL') ?? '',
          Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
        )

        // Insert into our transcripts table
        // We need to map 'sid' or 'cname' to our roundtable_id
        // For now, we assume the payload contains the roundtable_id in a custom field or we look it up
        
        // This is a simplified handler. Real-world Agora STT callback often needs 
        // to handle partial vs final results.
        
        const { error } = await supabase
          .from('roundtable_transcripts')
          .insert({
            roundtable_id: payload.roundtable_id,
            user_id: payload.user_id,
            content: payload.content
          })

        if (error) throw error
      }
    }

    return new Response(JSON.stringify({ message: "Success" }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 400,
    })
  }
})
