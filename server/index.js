const express = require('express');
const admin = require('firebase-admin');
const cors = require('cors');

const PORT = process.env.PORT || 8080;

// Load service account: prefer Docker secret mounted at /run/secrets/firebase_sa.json
let serviceAccount;
const fs = require('fs');
if (process.env.SERVICE_ACCOUNT_JSON) {
  // SERVICE_ACCOUNT_JSON may be the raw JSON or a base64-encoded string.
  const raw = process.env.SERVICE_ACCOUNT_JSON.trim();
  try {
    // First try raw JSON
    serviceAccount = JSON.parse(raw);
  } catch (e1) {
    try {
      // Try base64 decode then parse
      const decoded = Buffer.from(raw, 'base64').toString('utf8');
      serviceAccount = JSON.parse(decoded);
    } catch (e2) {
      console.error('Failed to parse SERVICE_ACCOUNT_JSON (not valid JSON or base64):', e2.message);
      process.exit(1);
    }
  }
} else {
  const p = '/run/secrets/firebase_sa.json';
  if (!fs.existsSync(p)) {
    console.error('No service account found. Set SERVICE_ACCOUNT_JSON env or mount /run/secrets/firebase_sa.json');
    process.exit(1);
  }
  serviceAccount = JSON.parse(fs.readFileSync(p, 'utf8'));
}

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

const app = express();
app.use(express.json());
// Allow cross-origin requests from your deployed web app. During testing this
// allows any origin; in production restrict this to your GitHub Pages domain.
app.use(cors({
  origin: [
    'https://floatit-itu.github.io',
  ],
  credentials: true
}));

const jwt = require('jsonwebtoken');

// Middleware: verify Firebase ID token
async function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid Authorization header' });
  }
  const idToken = authHeader.split('Bearer ')[1];
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    console.log('Decoded token uid:', decodedToken.uid);
    console.log('Admin claim:', decodedToken.admin);
    req.user = decodedToken;
    // Optional: check if user has admin claim
    if (!decodedToken.admin) {
      console.log('Access denied: no admin claim');
      return res.status(403).json({ error: 'Admin access required' });
    }
    next();
  } catch (error) {
    console.warn('Token verification failed:', error.message);
    res.status(401).json({ error: 'Invalid token' });
  }
}

// POST /send/topic
app.post('/send/topic', requireAuth, async (req, res) => {
  const { topic, title, body, data } = req.body;
  if (!topic || !title) return res.status(400).json({ error: 'topic and title required' });

  const message = {
    topic,
    notification: { title, body: body || '' },
    data: data || {},
  };

  try {
    const resp = await admin.messaging().send(message);
    
    // Log the action
    await admin.firestore().collection('server_logs').add({
      action: 'send_topic',
      adminUid: req.user.uid,
      details: { topic, title, body },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deleteAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)), // 15 days
    });
    
    res.json({ success: true, resp });
  } catch (err) {
    console.error('FCM send error', err);
    
    // Log the error
    await admin.firestore().collection('server_logs').add({
      action: 'send_topic_error',
      adminUid: req.user.uid,
      details: { topic, title, body, error: err.message },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deleteAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)),
    });
    
    res.status(500).json({ error: err.message });
  }
});

// POST /send/user - send to token(s) or uid (if uid -> collect tokens from fcm_tokens)
app.post('/send/user', requireAuth, async (req, res) => {
  const { tokens, uids, title, body, data } = req.body;
  let targetTokens = Array.isArray(tokens) ? tokens.slice() : [];

  // If uids provided, read tokens from Firestore fcm_tokens/{uid}/tokens
  if (Array.isArray(uids) && uids.length) {
    try {
      const db = admin.firestore();
      for (const uid of uids) {
        const snap = await db.collection('fcm_tokens').doc(uid).collection('tokens').get();
        snap.forEach(d => {
          const tok = d.data().token;
          if (tok) targetTokens.push(tok);
        });
      }
    } catch (err) {
      console.error('Error reading tokens', err);
      return res.status(500).json({ error: 'Failed collecting tokens' });
    }
  }

  if (!targetTokens.length) return res.status(400).json({ error: 'No tokens' });

  const message = {
    notification: { title: title || '', body: body || '' },
    data: data || {},
  };

  try {
    const resp = await admin.messaging().sendEachForMulticast({
      tokens: targetTokens,
      notification: { title: title || '', body: body || '' },
      data: data || {},
    });
    
    // Log the action
    await admin.firestore().collection('server_logs').add({
      action: 'send_user',
      adminUid: req.user.uid,
      details: { uids, tokensCount: targetTokens.length, title, body, successCount: resp.successCount, failureCount: resp.failureCount },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deleteAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)),
    });
    
    res.json({ success: true, resp });
  } catch (err) {
    console.error('FCM send error', err);
    
    // Log the error
    await admin.firestore().collection('server_logs').add({
      action: 'send_user_error',
      adminUid: req.user.uid,
      details: { uids, tokensCount: targetTokens.length, title, body, error: err.message },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deleteAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)),
    });
    
    res.status(500).json({ error: err.message });
  }
});

// POST /admin/set-claim - set custom claim for a user (requires admin)
app.post('/admin/set-claim', requireAuth, async (req, res) => {
  const { uid, admin: isAdmin } = req.body;
  if (!uid || typeof isAdmin !== 'boolean') {
    return res.status(400).json({ error: 'uid and admin (boolean) required' });
  }
  try {
    await admin.auth().setCustomUserClaims(uid, { admin: isAdmin });
    
    // Log the action
    await admin.firestore().collection('server_logs').add({
      action: 'set_admin_claim',
      adminUid: req.user.uid,
      details: { targetUid: uid, admin: isAdmin },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deleteAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)),
    });
    
    res.json({ success: true, message: `Admin claim ${isAdmin ? 'set' : 'removed'} for ${uid}` });
  } catch (err) {
    console.error('Error setting custom claim:', err);
    
    // Log the error
    await admin.firestore().collection('server_logs').add({
      action: 'set_admin_claim_error',
      adminUid: req.user.uid,
      details: { targetUid: uid, admin: isAdmin, error: err.message },
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      deleteAt: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)),
    });
    
    res.status(500).json({ error: err.message });
  }
});

app.get('/', (req, res) => res.send('FCM sender running'));
app.listen(PORT, () => console.log(`Listening ${PORT}`));