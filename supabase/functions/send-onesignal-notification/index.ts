// send-onesignal-notification.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// ✅ Initialize Supabase client
const supabase = createClient(Deno.env.get("SUPABASE_URL"), Deno.env.get("SUPABASE_SERVICE_ROLE_KEY"));
// ✅ Read OneSignal secrets
const ONESIGNAL_APP_ID = Deno.env.get("ONESIGNAL_APP_ID");
const ONESIGNAL_REST_KEY = Deno.env.get("ONESIGNAL_REST_KEY");
serve(async (req)=>{
  try {
    const { title, body, receiverId } = await req.json();
    // ✅ Fetch device tokens from Supabase
    let tokensQuery;
    if (receiverId) {
      tokensQuery = supabase.from("device_tokens").select("token").eq("user_id", receiverId);
    } else {
      tokensQuery = supabase.from("device_tokens").select("token");
    }
    const { data: tokens, error } = await tokensQuery;
    if (error) throw error;
    if (!tokens || tokens.length === 0) {
      return new Response(JSON.stringify({
        error: "No tokens found"
      }), {
        status: 400
      });
    }
    // ✅ Send notification via OneSignal REST API
    const response = await fetch("https://onesignal.com/api/v1/notifications", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Basic ${ONESIGNAL_REST_KEY}`
      },
      body: JSON.stringify({
        app_id: ONESIGNAL_APP_ID,
        include_player_ids: tokens.map((t)=>t.token),
        headings: {
          en: title
        },
        contents: {
          en: body
        },
        android_channel_id: "high_importance_channel",
        ios_sound: "default",
        android_sound: "default"
      })
    });
    const result = await response.json();
    // ✅ Save notification to Supabase table
    await supabase.from("notifications").insert({
      user_id: receiverId || null,
      title,
      body,
      read: false,
      created_at: new Date().toISOString()
    });
    return new Response(JSON.stringify({
      success: true,
      result
    }), {
      headers: {
        "Content-Type": "application/json"
      }
    });
  } catch (err) {
    console.error("❌ Error:", err);
    return new Response(JSON.stringify({
      error: err.message
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json"
      }
    });
  }
});
