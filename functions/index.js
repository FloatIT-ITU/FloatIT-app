const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// Firestore onCreate trigger for notifications collection
// When a document is created in `notifications/{docId}`, this function will
// attempt to send a push notification to the recipient's saved FCM tokens.
exports.sendNotificationOnCreate = functions
  .region('europe-west1')
  .firestore.document('notifications/{docId}')
  .onCreate(async (snap, context) => {
    const data = snap.data() || {};
    const docRef = snap.ref;

    const recipientUid = data.recipientUid;
    if (!recipientUid) {
      await docRef.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), error: 'no-recipient' });
      return null;
    }

    try {
      // Respect opt-out
      const publicDoc = await db.collection('public_users').doc(recipientUid).get();
      const pu = publicDoc.exists ? publicDoc.data() : null;
      if (pu && pu.notificationsEnabled === false) {
        await docRef.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), error: 'user-opted-out' });
        console.log('Skipping notification - user opted out', recipientUid);
        return null;
      }
    } catch (e) {
      console.warn('Failed to read public_users for', recipientUid, e);
    }

    const tokensSnap = await db.collection('fcm_tokens').doc(recipientUid).collection('tokens').get();
    const tokens = tokensSnap.docs.map(d => d.data().token).filter(Boolean);
    if (!tokens.length) {
      await docRef.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), error: 'no-tokens', tokensCount: 0 });
      console.log('No tokens for', recipientUid);
      return null;
    }

    const payload = {
      notification: {
        title: data.title || 'FloatIT',
        body: data.body || ''
      },
      data: data.data || {}
    };

    try {
      const resp = await messaging.sendToDevice(tokens, payload);
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
        for (const t of invalidTokens) {
          const tokenId = t.replace(/\//g, '_');
          await db.collection('fcm_tokens').doc(recipientUid).collection('tokens').doc(tokenId).delete().catch(() => {});
        }
      }

      await docRef.update({ sent: true, sentAt: admin.firestore.FieldValue.serverTimestamp(), tokensCount: tokens.length, invalidTokensRemoved: invalidTokens.length });
      console.log('Sent notification', snap.id, 'tokens:', tokens.length, 'invalidRemoved:', invalidTokens.length);
    } catch (e) {
      console.error('Send error', e);
      await docRef.update({ error: String(e), tokensCount: tokens ? tokens.length : 0, lastAttemptAt: admin.firestore.FieldValue.serverTimestamp() }).catch(() => {});
    }

    return null;
  });
