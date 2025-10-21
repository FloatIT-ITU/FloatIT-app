const admin = require('firebase-admin');
const fs = require('fs');

// Load service account from ./service-account.json (written by GitHub Actions or by you locally)
if (!fs.existsSync('./service-account.json')) {
  console.error('service-account.json not found. Please provide a service account JSON at ./service-account.json');
  process.exit(1);
}

const serviceAccount = require('./service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
const messaging = admin.messaging();

console.log('Notification watcher starting...');

// Simple polling approach: find unsent notifications and send them, mark sent.
// This is intentionally simple and works well inside GitHub Actions scheduled runs.

async function sendPending() {
  const snap = await db.collection('notifications').where('sent', '==', false).limit(50).get();
  if (snap.empty) {
    console.log('No pending notifications');
    return;
  }

  for (const doc of snap.docs) {
    const data = doc.data();
    const recipientUid = data.recipientUid;
    if (!recipientUid) {
      await doc.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), error: 'no-recipient' });
      continue;
    }

    // Respect user opt-out: check public_users.notificationsEnabled
    try {
      const publicDoc = await db.collection('public_users').doc(recipientUid).get();
      const pu = publicDoc.exists ? publicDoc.data() : null;
      if (pu && pu.notificationsEnabled === false) {
        await doc.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), error: 'user-opted-out' });
        console.log('Skipping notification - user opted out', recipientUid);
        continue;
      }
    } catch (e) {
      console.warn('Failed to read public_users for', recipientUid, e);
    }

    const tokensSnap = await db.collection('fcm_tokens').doc(recipientUid).collection('tokens').get();
    const tokens = tokensSnap.docs.map(d => d.data().token).filter(Boolean);
    // Record tokensCount for diagnostics
    if (!tokens.length) {
      await doc.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), error: 'no-tokens', tokensCount: 0, lastAttemptAt: admin.firestore.FieldValue.serverTimestamp() });
      console.log('No tokens for', recipientUid);
      continue;
    }

    const payload = {
      notification: {
        title: data.title || 'FloatIT',
        body: data.body || '',
      },
      data: data.data || {}
    };

    try {
      const resp = await messaging.sendToDevice(tokens, payload);
      // cleanup invalid tokens
      const invalidTokens = [];
      resp.results.forEach((r, i) => {
        if (r.error) {
          const code = r.error.code;
          if (code === 'messaging/invalid-registration-token' || code === 'messaging/registration-token-not-registered') {
            invalidTokens.push(tokens[i]);
          }
        }
      });

      if (invalidTokens.length) {
        // remove invalid tokens documents
        for (const t of invalidTokens) {
          const tokenId = t.replace(/\//g, '_');
          await db.collection('fcm_tokens').doc(recipientUid).collection('tokens').doc(tokenId).delete().catch(() => {});
        }
      }
      // Persist diagnostics on successful send
      await doc.ref.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), tokensCount: tokens.length, invalidTokensRemoved: invalidTokens.length });
      console.log('Sent notification', doc.id, 'tokens:', tokens.length, 'invalidRemoved:', invalidTokens.length);
    } catch (e) {
      console.error('Send error', e);
      await doc.ref.update({ error: String(e), tokensCount: tokens ? tokens.length : 0, lastAttemptAt: admin.firestore.FieldValue.serverTimestamp() }).catch(() => {});
    }
  }
}

// Run once (GitHub Actions will run it on schedule)
sendPending().then(() => process.exit(0)).catch((e) => {
  console.error(e);
  process.exit(1);
});
