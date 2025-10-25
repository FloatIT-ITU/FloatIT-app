# FCM Sender Server

This is a small Node.js server that handles sending Firebase Cloud Messaging (FCM) push notifications securely. It runs in a Docker container deployed via Portainer.

## Setup

1. **Firebase Service Account**: Download the service account JSON from Firebase Console → Project Settings → Service Accounts → Generate Private Key. Keep it secure.

2. **Admin User Claim**: Use Firebase Admin SDK to set a custom claim for admin users:
   ```javascript
   const admin = require('firebase-admin');
   // Initialize with service account
   admin.auth().setCustomUserClaims('USER_UID', { admin: true });
   ```

3. **Environment Variable**: Set `SERVICE_ACCOUNT_JSON` to the full Firebase service account JSON (raw or base64).

## Deployment with Portainer

1. In Portainer, create a new Stack.
2. Upload or paste the `docker-compose.yml` content.
3. Ensure the `firebase_sa` secret points to your service account JSON file.
4. Deploy the stack. The server will run on port 5454.

## Environment Variables

- `SERVICE_ACCOUNT_JSON`: Firebase service account JSON (raw or base64).
- `PORT`: Port to listen on (default 5454).

## Endpoints

- `POST /send/topic`: Send to a topic (e.g., "all-users"). Requires admin Bearer token.
  Body: `{ "topic": "string", "title": "string", "body": "string", "data": {} }`

- `POST /send/user`: Send to specific users by UID or tokens. Requires admin Bearer token.
  Body: `{ "uids": ["uid1"], "tokens": ["token1"], "title": "string", "body": "string", "data": {} }`

## Client Integration

Clients (admin UI) call these endpoints with a Bearer token from `FirebaseAuth.instance.currentUser!.getIdToken()`.

Example Dart code:
```dart
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

final token = await FirebaseAuth.instance.currentUser!.getIdToken();
final response = await http.post(
  Uri.parse('https://your-fcm-sender-domain/send/topic'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: '{"topic":"all-users","title":"Test","body":"Hello"}',
);
```