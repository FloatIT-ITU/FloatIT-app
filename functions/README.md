Notification sender (for GitHub Actions)

This small helper reads unsent documents from `notifications` and sends FCM
notifications to tokens stored under `fcm_tokens/{uid}/tokens/{tokenId}`.

How it works

- The script `send_watcher.js` reads up to 50 unsent notifications (`sent==false`).
- For each notification it loads token documents for the recipient and calls FCM.
- Invalid tokens are removed from Firestore automatically.
- The script marks notifications as `sent: true` and `sentAt` on success.

Running locally

1. Install dependencies:

```powershell
cd functions
npm ci
```

2. Place a service account JSON in `functions/service-account.json` (downloaded from Firebase Console > Project settings > Service accounts)

3. Run:

```powershell
node send_watcher.js
```

Using GitHub Actions (recommended for automated runs)

1. Create a repository secret named `FCM_SERVICE_ACCOUNT` and paste the entire service account JSON as the secret value.
2. The workflow `.github/workflows/send-notifications.yml` will write the secret to `functions/service-account.json` at runtime and run the script on schedule (every 5 minutes). You can also trigger it manually from Actions -> Run workflow.

Security notes

- DO NOT commit the service account JSON to the repo.
- The Admin SDK bypasses Firestore rules; treat the service account as a secret.
- Ensure only trusted admins can create `notifications` documents (your Firestore rules already restrict creation to admins).