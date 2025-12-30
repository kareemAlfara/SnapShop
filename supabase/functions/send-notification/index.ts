import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

serve(async (req) => {
  try {
    const { title, body, fcmToken } = await req.json();

    if (!fcmToken) {
      return new Response(JSON.stringify({ error: "Missing fcmToken" }), { status: 400 });
    }

    const serverKey = Deno.env.get("FIREBASE_SERVER_KEY");
    if (!serverKey) {
      return new Response(JSON.stringify({ error: "Missing FIREBASE_SERVER_KEY" }), { status: 500 });
    }

    const message = {
      to: fcmToken,
      notification: {
        title: title ?? "New Notification",
        body: body ?? "You have a new message",
      },
    };

    const response = await fetch("https://fcm.googleapis.com/fcm/send", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `key=${serverKey}`,
      },
      body: JSON.stringify(message),
    });

    const result = await response.json();
    return new Response(JSON.stringify(result), { status: 200 });
  } catch (error) {
    console.error("Error:", error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }
});
