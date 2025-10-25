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
app.use(cors());

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
    res.json({ success: true, resp });
  } catch (err) {
    console.error('FCM send error', err);
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
    const resp = await admin.messaging().sendToDevice(targetTokens, message);
    res.json({ success: true, resp });
  } catch (err) {
    console.error('FCM send error', err);
    res.status(500).json({ error: err.message });
  }
});

// POST /admin/set-claim - set custom claim for a user (requires admin)
app.post('/admin/set-claim', requireAuth, async (req, res) => {
  const { uid, admin } = req.body;
  if (!uid || typeof admin !== 'boolean') {
    return res.status(400).json({ error: 'uid and admin (boolean) required' });
  }
  try {
    await admin.auth().setCustomUserClaims(uid, { admin });
    res.json({ success: true, message: `Admin claim ${admin ? 'set' : 'removed'} for ${uid}` });
  } catch (err) {
    console.error('Error setting custom claim:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/', (req, res) => res.send('FCM sender running'));
app.listen(PORT, () => console.log(`Listening ${PORT}`));