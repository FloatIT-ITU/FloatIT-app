Notification sender

This folder contains a Cloud Functions implementation that triggers onCreate for `notifications/{docId}` and sends notifications using the Firebase Admin SDK. This is the recommended production approach.

Quick deploy guide (Cloud Functions)

1. Install Firebase CLI: https://firebase.google.com/docs/cli
2. Authenticate and select your project:

```bash
firebase login
firebase use --add
```

3. Install dependencies and deploy:

```bash
cd functions
npm install
firebase deploy --only functions:sendNotificationOnCreate
```

Notes

- Cloud Functions use the project default credentials; you do not need a service-account JSON in the repo.
- For low traffic, the free tier is typically sufficient. If you expect larger volumes or need guaranteed concurrency, enable Blaze billing.

OneSignal helper
-----------------

This repository includes a small server helper `functions/oneSignalSender.js` that
wraps the OneSignal REST API. To use it from CI or a server, set the following
environment variables and call the helper from your code:

- `ONESIGNAL_APP_ID` - your OneSignal App ID
- `ONESIGNAL_REST_KEY` - your OneSignal REST API key (keep secret)

Example (Node):

```js
const { sendNotification } = require('./oneSignalSender');
await sendNotification(['player-id-1'], {en: 'Hello'}, {en: 'World'}, {foo: 'bar'});
```

Security: Keep `ONESIGNAL_REST_KEY` out of client bundles. For CI use repository secrets
and for server use environment variables or secret managers.
