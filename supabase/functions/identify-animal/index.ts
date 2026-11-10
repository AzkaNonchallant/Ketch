import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const authorization = request.headers.get("Authorization");
  if (!authorization) return json({ error: "Authentication required" }, 401);

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    { global: { headers: { Authorization: authorization } } },
  );
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) return json({ error: "Invalid session" }, 401);

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) return json({ error: "Identification service is not configured" }, 503);

  let image: string;
  let mimeType: string;
  try {
    const body = await request.json();
    image = body.image;
    mimeType = body.mimeType;
    if (typeof image !== "string" || !["image/jpeg", "image/png", "image/webp"].includes(mimeType)) {
      return json({ error: "A JPEG, PNG, or WebP image is required" }, 400);
    }
    if (image.length > 8_000_000) return json({ error: "Image is too large" }, 413);
  } catch {
    return json({ error: "Invalid request body" }, 400);
  }

  const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.0-flash";
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
  try {
    const response = await fetch(endpoint, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{
          parts: [
            { text: "Identify the animal visible in this photo. Never guess if it is unclear. Return up to 3 likely candidates, ordered by likelihood. Confidence must be between 0 and 1. If no animal is identifiable, set is_animal to false and candidates to []. Keep descriptions factual and brief. Return JSON only." },
            { inline_data: { mime_type: mimeType, data: image } },
          ],
        }],
        generationConfig: {
          responseMimeType: "application/json",
          responseSchema: {
            type: "OBJECT",
            properties: {
              is_animal: { type: "BOOLEAN" },
              candidates: {
                type: "ARRAY",
                items: {
                  type: "OBJECT",
                  properties: {
                    common_name: { type: "STRING" },
                    scientific_name: { type: "STRING" },
                    confidence: { type: "NUMBER" },
                    description: { type: "STRING" },
                  },
                  required: ["common_name", "scientific_name", "confidence", "description"],
                },
              },
            },
            required: ["is_animal", "candidates"],
          },
        },
      }),
    });
    if (!response.ok) {
      console.error("Gemini request failed", response.status);
      return json({ error: "Identification service failed. Please try again." }, 502);
    }

    const result = await response.json();
    const text = result.candidates?.[0]?.content?.parts?.[0]?.text;
    if (typeof text !== "string") return json({ error: "No identification result returned" }, 502);
    const parsed = JSON.parse(text);
    const candidates = Array.isArray(parsed.candidates)
      ? parsed.candidates.slice(0, 3).filter((candidate: Record<string, unknown>) =>
        typeof candidate.common_name === "string" &&
        typeof candidate.scientific_name === "string" &&
        typeof candidate.confidence === "number" &&
        typeof candidate.description === "string"
      )
      : [];
    return json({ is_animal: parsed.is_animal === true, candidates });
  } catch (error) {
    console.error("Identification failed", error);
    return json({ error: "Could not identify this image. Please try another photo." }, 502);
  }
});
