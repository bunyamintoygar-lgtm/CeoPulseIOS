import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { Image } from "https://deno.land/x/imagescript@1.2.15/mod.ts"
import { decode as base64Decode } from "https://deno.land/std@0.168.0/encoding/base64.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const payload = await req.json().catch(() => null)
    if (!payload || !payload.record) throw new Error('Input record is missing')

    const record = payload.record
    console.log(`--- GPT Image 2 Generation: ${record.title} ---`)

    const openaiApiKey = Deno.env.get('OPENAI_API_KEY') || ""
    const supabaseUrl = Deno.env.get('SUPABASE_URL') || ""
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ""

    const supabaseClient = createClient(supabaseUrl, supabaseKey)

    const response = await fetch('https://api.openai.com/v1/images/generations', {
      method: 'POST',
      headers: { 'Authorization': `Bearer ${openaiApiKey}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        model: "gpt-image-2", 
        prompt: `A premium corporate cover image. The title "${record.title}" must be clearly and elegantly rendered as text in the center. Theme: "${record.category_id}". Sophisticated minimalist business style.`, 
        n: 1, 
        size: "1024x1024",
        quality: "low"
      }),
    })

    const result = await response.json()
    if (!response.ok) throw new Error(`OpenAI Error: ${result.error?.message || JSON.stringify(result)}`)

    let imageBuffer: Uint8Array;
    const imageData = result.data?.[0];

    if (imageData?.b64_json) {
      console.log("Image received as Base64. Decoding...")
      imageBuffer = base64Decode(imageData.b64_json)
    } else if (imageData?.url) {
      console.log("Image received as URL. Downloading...")
      const imageRes = await fetch(imageData.url)
      imageBuffer = new Uint8Array(await imageRes.arrayBuffer())
    } else {
      throw new Error("No image data (URL or Base64) found in OpenAI response")
    }

    // Process (Resize & Compress)
    console.log("Processing image...")
    const img = await Image.decode(imageBuffer)
    img.resize(512, 512)
    const compressed = await img.encodeJPEG(70)

    const path = `${record.id}/cover_small.jpg`
    const { error: uploadError } = await supabaseClient.storage.from('surveys').upload(path, compressed, {
      contentType: 'image/jpeg',
      upsert: true
    })
    if (uploadError) throw uploadError

    const { data: { publicUrl } } = supabaseClient.storage.from('surveys').getPublicUrl(path)

    await supabaseClient.from('surveys').update({ cover_image_url: publicUrl }).eq('id', record.id)

    console.log("SUCCESS! Premium image saved.")
    return new Response(JSON.stringify({ success: true, url: publicUrl }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200
    })

  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err)
    console.error("GENERATION_ERROR:", msg)
    return new Response(JSON.stringify({ error: msg }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500
    })
  }
})
