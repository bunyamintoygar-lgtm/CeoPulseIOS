import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1"
import { Image } from "https://deno.land/x/imagescript@1.2.15/mod.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const payload = await req.json()
    const { record, old_record } = payload
    const language = record.language || 'tr'

    if (record.status !== 'active') {
      return new Response(JSON.stringify({ message: 'Survey is not active, skipping image generation.' }), { status: 200 })
    }

    if (record.cover_image_url && old_record && record.title === old_record.title) {
       return new Response(JSON.stringify({ message: 'Title unchanged and image exists, skipping.' }), { status: 200 })
    }

    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OPENAI_API_KEY is not set')
    }

    // 2. OpenAI GPT Image 2 Call (ChatGPT 5.5 Quality)
    const langContext = language === 'tr' ? 'Turkish' : 'English'
    const prompt = `A premium, ultra-high-definition corporate cover image for a CEO survey. 
    Main Title to include as clear text in the image: "${record.title}".
    Theme: "${record.category_id}". 
    Style: High-end corporate photography, cinematic lighting, sophisticated minimalist design.
    IMPORTANT: Render the text "${record.title}" perfectly in ${langContext} language with correct characters and typography.`

    const openAiResponse = await fetch('https://api.openai.com/v1/images/generations', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: "gpt-image-2", 
        prompt: prompt,
        n: 1,
        size: "1024x1024",
        quality: "high"
      }),
    })

    if (!openAiResponse.ok) {
      const errorData = await openAiResponse.json()
      console.error('OpenAI API Error:', errorData)
      throw new Error(`OpenAI API failed: ${JSON.stringify(errorData)}`)
    }

    const openAiData = await openAiResponse.json()
    if (!openAiData.data || openAiData.data.length === 0) {
      throw new Error('OpenAI image generation failed')
    }

    const imageUrl = openAiData.data[0].url

    // 3. Download the generated image
    const imageRes = await fetch(imageUrl)
    const arrayBuffer = await imageRes.arrayBuffer()

    // 4. AUTOMATIC COMPRESSION & RESIZING
    console.log("Processing image: Resizing to 512x512 and compressing to JPEG...")
    const img = await Image.decode(arrayBuffer)
    img.resize(512, 512)
    const compressedBuffer = await img.encodeJPEG(70) // 70% quality JPEG

    // 5. Upload to Supabase Storage as .jpg
    const fileName = `${record.id}/cover_small.jpg`
    const { error: uploadError } = await supabaseClient.storage
      .from('surveys')
      .upload(fileName, compressedBuffer, {
        contentType: 'image/jpeg',
        upsert: true
      })

    if (uploadError) throw uploadError

    const { data: { publicUrl } } = supabaseClient.storage
      .from('surveys')
      .getPublicUrl(fileName)

    // 6. Update Database
    const { error: updateError } = await supabaseClient
      .from('surveys')
      .update({ cover_image_url: publicUrl })
      .eq('id', record.id)

    if (updateError) throw updateError

    return new Response(
      JSON.stringify({ success: true, url: publicUrl, size: compressedBuffer.byteLength }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error) {
    console.error(error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
