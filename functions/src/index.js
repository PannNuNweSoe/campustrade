const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

function buildFallbackReply(message, itemContext) {
  const lower = message.toLowerCase();
  const title = itemContext.title || 'the item';
  const price = itemContext.price || 'the listed price';
  const condition = itemContext.condition || 'not specified';

  if (/available|still there|sold/.test(lower)) {
    return `${title} is still available right now.`;
  }

  if (/price|discount|best|last|offer|\d+/.test(lower)) {
    return `The current listed price is ${price}. If you want, you can share your offer.`;
  }

  if (/condition|scratch|damage|new|used/.test(lower)) {
    return `The item condition is ${condition}.`;
  }

  if (/where|meet|pickup|location/.test(lower)) {
    return 'Meet-up can be arranged on campus in a safe public area.';
  }

  return `Thanks for your question about ${title}. Could you clarify what detail you need (price, condition, availability, or meetup)?`;
}

function buildPrompt(message, itemContext) {
  return `You are a campus marketplace chat assistant.
Answer the buyer question using ONLY the provided item context.
If the answer is not in context, say that clearly and ask a short follow-up.
Do not invent facts, numbers, condition, or availability.
Keep response to 1-3 short sentences.

Item context:
- Item ID: ${itemContext.itemId || 'unknown'}
- Title: ${itemContext.title || 'unknown'}
- Description: ${itemContext.description || 'unknown'}
- Price: ${itemContext.price || 'unknown'}
- Condition: ${itemContext.condition || 'unknown'}
- Owner UID: ${itemContext.ownerUid || 'unknown'}

Buyer question:
${message}`;
}

async function askGemini(prompt, apiKey) {
  const response = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [
          {
            role: 'user',
            parts: [{ text: prompt }],
          },
        ],
        generationConfig: {
          temperature: 0.2,
          maxOutputTokens: 160,
        },
      }),
    }
  );

  if (!response.ok) {
    const body = await response.text();
    throw new Error(`Gemini request failed: ${response.status} ${body}`);
  }

  const data = await response.json();
  const text =
    data?.candidates?.[0]?.content?.parts?.find((p) => typeof p?.text === 'string')?.text ||
    '';

  return text.trim();
}

exports.askChatAssistant = onCall({ region: 'asia-southeast1' }, async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'You must sign in first.');
  }

  const uid = request.auth.uid;
  const chatId = `${request.data?.chatId || ''}`.trim();
  const message = `${request.data?.message || ''}`.trim();
  const itemContext = request.data?.itemContext || {};

  if (!chatId) {
    throw new HttpsError('invalid-argument', 'chatId is required.');
  }

  if (!message) {
    throw new HttpsError('invalid-argument', 'message is required.');
  }

  const chatRef = db.collection('chats').doc(chatId);
  const chatSnap = await chatRef.get();

  if (!chatSnap.exists) {
    throw new HttpsError('not-found', 'Chat not found.');
  }

  const chatData = chatSnap.data() || {};
  const participants = Array.isArray(chatData.participants) ? chatData.participants : [];

  if (!participants.includes(uid)) {
    throw new HttpsError('permission-denied', 'You are not a participant of this chat.');
  }

  let reply = buildFallbackReply(message, itemContext);

  const apiKey = process.env.GEMINI_API_KEY;
  if (apiKey) {
    try {
      const prompt = buildPrompt(message, itemContext);
      const aiReply = await askGemini(prompt, apiKey);
      if (aiReply) {
        reply = aiReply;
      }
    } catch (error) {
      console.error('askChatAssistant AI error:', error);
    }
  }

  await chatRef.collection('messages').add({
    text: reply,
    sender: 'ai-assistant',
    senderType: 'assistant',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { reply };
});
