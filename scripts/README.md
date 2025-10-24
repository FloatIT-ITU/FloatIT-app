# Notification System

This directory contains scripts for sending push notifications via GitHub Actions and FCM.

## Setup

1. Create a Firebase service account with Firestore read and FCM send permissions.
2. Add the service account JSON as a GitHub secret: `FIREBASE_SERVICE_ACCOUNT_JSON`.
3. Add the Firebase project ID as `FIREBASE_PROJECT_ID`.

## Usage

The `gh-action-send-notifs.js` script is run by the GitHub Actions workflow when triggered by repository_dispatch.

To trigger manually (for testing):
```bash
curl -X POST -H "Authorization: token YOUR_PAT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/FloatIT-ITU/FloatIT-app/dispatches \
  -d '{"event_type":"send_notification","client_payload":{"notificationId":"abc123"}}'
```

Replace `abc123` with the actual notification document ID from Firestore.