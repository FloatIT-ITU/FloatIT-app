/*
  This script expects:
  - SERVICE_ACCOUNT_PATH env pointing to service-account.json (written by workflow)
  - github.event.client_payload available via env var GITHUB_EVENT_PAYLOAD
  client_payload should contain either { notificationId } or a full payload.
*/
const admin = require('firebase-admin');
const fs = require('fs');

const SERVICE_ACCOUNT_PATH = process.env.SERVICE_ACCOUNT_PATH || './service-account.json';
if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error('Missing service account at', SERVICE_ACCOUNT_PATH);
  process.exit(1);
}
const svc = JSON.parse(fs.readFileSync(SERVICE_ACCOUNT_PATH, 'utf8'));

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(svc),
  });
}
const db = admin.firestore();
const messaging = admin.messaging();

function chunk(arr, n) {
  const out = [];
  for (let i = 0; i < arr.length; i += n) out.push(arr.slice(i, i + n));
  return out;
}

async function loadPayload() {
  const raw = process.env.GITHUB_EVENT_PAYLOAD;
  if (!raw) throw new Error('missing GITHUB_EVENT_PAYLOAD');
  const payload = JSON.parse(raw);
  if (payload.notificationId) {
    const doc = await db.collection('notifications').doc(payload.notificationId).get();
    if (!doc.exists) throw new Error('notification doc not found');
    return { docRef: doc.ref, data: doc.data(), id: payload.notificationId };
  }
  if (payload.payload) return { docRef: null, data: payload.payload, id: null };
  throw new Error('invalid payload');
}

async function resolveTokens(data) {
  const tokens = []; // {token, docRef?}
  if (data.type === 'global') {
    const users = await db.collection('fcm_tokens').get();
    for (const u of users.docs) {
      const tSnap = await db.collection('fcm_tokens').doc(u.id).collection('tokens').get();
      for (const t of tSnap.docs) {
        const tok = t.data().token;
        if (tok) tokens.push({ token: tok, docRef: t.ref });
      }
    }
  } else if (data.type === 'event' && data.eventId) {
    const ev = await db.collection('events').doc(data.eventId).get();
    if (!ev.exists) return tokens;
    const recipients = [...(ev.data().attendees || []), ...(ev.data().waitingList || [])];
    for (const uid of recipients) {
      const tSnap = await db.collection('fcm_tokens').doc(uid).collection('tokens').get();
      for (const t of tSnap.docs) {
        const tok = t.data().token;
        if (tok) tokens.push({ token: tok, docRef: t.ref });
      }
    }
  } else {
    // allow an explicit list of tokens in data.tokenList (useful for testing)
    if (Array.isArray(data.tokenList)) {
      for (const tok of data.tokenList) tokens.push({ token: tok });
    }
  }
  return tokens;
}

(async function main(){
  try {
    const info = await loadPayload();
    const data = info.data;
    const docRef = info.docRef;

    const recipients = await resolveTokens(data);
    if (!recipients.length) {
      if (docRef) await docRef.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), tokensCount: 0 });
      console.log('no tokens found');
      return;
    }

    const tokenStrs = recipients.map(r=>r.token);
    const batches = chunk(tokenStrs, 500);
    const invalid = [];

    for (const batch of batches) {
      const payload = {
        notification: { title: data.title || 'FloatIT', body: data.body || '' },
        data: data.data || {}
      };
      const resp = await messaging.sendToDevice(batch, payload);
      resp.results.forEach((r, i) => {
        if (r.error) {
          const code = r.error.code;
          if (code === 'messaging/invalid-registration-token' || code === 'messaging/registration-token-not-registered') {
            invalid.push(batch[i]);
          }
        }
      });
    }

    if (invalid.length) {
      for (const bad of invalid) {
        const found = recipients.find(x=>x.token===bad);
        if (found && found.docRef) await found.docRef.delete().catch(()=>{});
      }
    }

    if (docRef) {
      await docRef.update({
        sent: true,
        sentAt: admin.firestore.FieldValue.serverTimestamp(),
        tokensCount: tokenStrs.length,
        invalidTokensRemoved: invalid.length
      });
    }

    console.log('sent to', tokenStrs.length);
  } catch (err) {
    console.error('fatal', err);
    process.exit(1);
  }
})();