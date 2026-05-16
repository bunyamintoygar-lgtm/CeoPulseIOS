import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

serve(async (req) => {
  try {
    const body = await req.json()
    console.log("Fake LLM received:", JSON.stringify(body).substring(0, 500))

    // Agora sends OpenAI-compatible chat format.
    // The last user message contains the transcribed speech.
    const messages: Array<{role: string, content: string}> = body.messages ?? []
    const userMessages = messages.filter(m => m.role === "user")
    const lastUserMessage = userMessages[userMessages.length - 1]

    if (lastUserMessage?.content) {
      const content = lastUserMessage.content
      console.log("Transcribed speech:", content)

      // Extract roundtable ID from system message or metadata
      const systemMsg = messages.find(m => m.role === "system")
      const channelMatch = systemMsg?.content?.match(/channel:([a-f0-9-]+)/i)
      const roundtableId = channelMatch?.[1] ?? body.channel_name ?? body.channelName

      if (roundtableId && content.trim().length > 0) {
        // Save transcript to DB
        const { error } = await supabase
          .from('roundtable_transcripts')
          .insert({
            roundtable_id: roundtableId,
            content: content.trim(),
            // user_id will be null for AI-captured transcripts
          })

        if (error) {
          console.error("DB insert error:", error.message)
        } else {
          console.log("Transcript saved for roundtable:", roundtableId)
        }
      }
    }

    // Return minimal OpenAI-compatible response so the bot stays silent
    return new Response(JSON.stringify({
      id: "chatcmpl-" + Date.now(),
      object: "chat.completion",
      created: Math.floor(Date.now() / 1000),
      model: "gpt-3.5-turbo",
      choices: [{
        index: 0,
        message: {
          role: "assistant",
          content: "."
        },
        finish_reason: "stop"
      }],
      usage: {
        prompt_tokens: 1,
        completion_tokens: 1,
        total_tokens: 2
      }
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    })

  } catch (error) {
    console.error("Fake LLM error:", error.message)
    // Always return a valid OpenAI response even on error
    return new Response(JSON.stringify({
      id: "chatcmpl-error",
      object: "chat.completion",
      created: Math.floor(Date.now() / 1000),
      model: "gpt-3.5-turbo",
      choices: [{ index: 0, message: { role: "assistant", content: "." }, finish_reason: "stop" }],
      usage: { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 }
    }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    })
  }
})
