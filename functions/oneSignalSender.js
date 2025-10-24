// Helper to send OneSignal notifications from server-side (CI or backend)
// Usage:
//   ONESIGNAL_APP_ID and ONESIGNAL_REST_KEY must be set in env before running.
//   const sender = require('./oneSignalSender');
//   await sender.sendNotification(['player-id-1'], {en: 'Title'}, {en: 'Body'}, {foo: 'bar'});

const ONESIGNAL_APP_ID = process.env.ONESIGNAL_APP_ID;
const ONESIGNAL_REST_KEY = process.env.ONESIGNAL_REST_KEY;

if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_KEY) {
  // We don't throw at load time to keep local dev easy; functions that call
  // sendNotification should handle missing config appropriately.
}

async function sendNotification(playerIds = [], headings = {en: 'Notification'}, contents = {en: ''}, data = {}) {
  if (!ONESIGNAL_APP_ID || !ONESIGNAL_REST_KEY) {
    throw new Error('OneSignal env vars (ONESIGNAL_APP_ID, ONESIGNAL_REST_KEY) are not set');
  }

  const body = {
    app_id: ONESIGNAL_APP_ID,
    include_player_ids: playerIds,
    headings,
    contents,
    data
  };

  const resp = await fetch('https://onesignal.com/api/v1/notifications', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json;charset=utf-8',
      'Authorization': `Basic ${ONESIGNAL_REST_KEY}`
    },
    body: JSON.stringify(body)
  });

  if (!resp.ok) {
    const text = await resp.text();
    const err = new Error('OneSignal send failed: ' + resp.status + ' ' + text);
    err.status = resp.status;
    err.body = text;
    throw err;
  }

  return resp.json();
}

module.exports = { sendNotification };
