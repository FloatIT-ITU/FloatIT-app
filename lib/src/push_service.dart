import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class PushService {
  PushService._();
  static final instance = PushService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String?>? _tokenSub;
  StreamSubscription<RemoteMessage>? _msgSub;

  /// Expose a broadcast stream of foreground messages for the app to listen to
  final StreamController<RemoteMessage> _onMessageController = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageStream => _onMessageController.stream;

  Future<void> initialize() async {
    if (kIsWeb) {
      try {
        debugPrint('[PushService] Registering service worker...');
        final worker = await html.window.navigator.serviceWorker
            ?.register('/firebase-messaging-sw.js');
        if (worker != null) {
          debugPrint(
              '[PushService] Service worker registered successfully: ${worker.scope}');
        } else {
          debugPrint('[PushService] Service worker registration returned null.');
        }
      } catch (e, s) {
        debugPrint('[PushService] ERROR registering service worker: $e');
        debugPrint('[PushService] Stacktrace: $s');
      }
    }
    _startOnMessageListener();
  }

  /// Request permission and return whether granted
  Future<bool> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  Future<String?> getToken() async {
    try {
      // Read VAPID public key from build-time define to avoid hardcoding.
      // Supply at build: flutter build web --dart-define=VAPID_KEY="<your_public_vapid_key>"
      const vapidKey = String.fromEnvironment('VAPID_KEY');
      final vapid = kIsWeb && vapidKey.isNotEmpty ? vapidKey : null;
      debugPrint('[PushService] Getting token with VAPID key: ${vapid != null}');
      // For web, FCM requires a VAPID key for push notifications. If vapid is null
      // getToken will try without it (may fail on web). See README in project for details.
      final token = await _messaging.getToken(vapidKey: vapid);
      debugPrint('[PushService] getToken() returned: ${token ?? 'null'}');
      return token;
    } catch (e, s) {
      debugPrint('[PushService] ERROR getting token: $e');
      debugPrint('[PushService] Stacktrace: $s');
      return null;
    }
  }

  Future<bool> registerTokenForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No user logged in');
      return false;
    }
    debugPrint('Registering token for user ${user.uid}');
    final granted = await requestPermission();
    if (!granted) {
      debugPrint('Permission not granted');
      return false;
    }
    debugPrint('Permission granted, getting token...');
    final token = await getToken();
    debugPrint('Got token: $token');
    if (token == null) {
      debugPrint('Token is null');
      return false;
    }

    // Save token as its own document under fcm_tokens/{uid}/tokens/{tokenId}
    final tokenId = token.replaceAll('/', '_');
    final tokenRef = FirebaseFirestore.instance
        .collection('fcm_tokens')
        .doc(user.uid)
        .collection('tokens')
        .doc(tokenId);
    try {
      debugPrint('Saving token to Firestore...');
      await tokenRef.set({
        'token': token,
        'platform': 'web',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint('Token saved successfully');
    } catch (e) {
      debugPrint('Failed to save token to Firestore: $e');
      return false;
    }

    // Start listening for token refresh and foreground messages for this user
    _startTokenRefreshListener(user.uid);
    _startOnMessageListener();
    return true;
  }

  Future<void> unregisterAllTokensForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final token = await getToken();
      if (token == null) return;
      final tokenId = token.replaceAll('/', '_');
      final tokenRef = FirebaseFirestore.instance
        .collection('fcm_tokens')
        .doc(user.uid)
        .collection('tokens')
        .doc(tokenId);
      await tokenRef.delete();
    } catch (_) {}
    // Stop listeners
    _stopListeners();
  }


  void _startTokenRefreshListener(String uid) {
    // Ensure previous subscription removed
    _tokenSub?.cancel();
    _tokenSub = _messaging.onTokenRefresh.listen((newToken) async {
      final tokenId = newToken.replaceAll('/', '_');
      final tokenRef = FirebaseFirestore.instance
          .collection('fcm_tokens')
          .doc(uid)
          .collection('tokens')
          .doc(tokenId);
      try {
        await tokenRef.set({
          'token': newToken,
          'platform': 'web',
          'createdAt': FieldValue.serverTimestamp(),
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (_) {}
    });
  }

  void _startOnMessageListener() {
    _msgSub ??= FirebaseMessaging.onMessage.listen((message) {
      _onMessageController.add(message);
    });
  }

  void _stopListeners() {
    _tokenSub?.cancel();
    _tokenSub = null;
    _msgSub?.cancel();
    _msgSub = null;
  }

  void dispose() {
    _stopListeners();
    _onMessageController.close();
  }

  Future<bool> optIn() async {
    debugPrint('[PushService] Opt-in process started.');
    try {
      debugPrint('[PushService] Requesting notification permission...');
      final settings = await _messaging.requestPermission();
      debugPrint(
          '[PushService] Permission settings status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('[PushService] Notification permission authorized.');
        try {
          debugPrint('[PushService] Getting FCM token...');
          final token = await getToken();
          if (token != null) {
            debugPrint('[PushService] FCM token received: $token');
            await _saveTokenToFirestore(token);
            debugPrint('[PushService] FCM token saved to Firestore.');
            return true;
          } else {
            debugPrint('[PushService] Failed to get FCM token (token is null).');
            return false;
          }
        } catch (e, s) {
          debugPrint('[PushService] ERROR getting/saving FCM token: $e');
          debugPrint('[PushService] Stacktrace: $s');
          return false;
        }
      } else {
        debugPrint(
            '[PushService] Notification permission not granted. Status: ${settings.authorizationStatus}');
        return false;
      }
    } catch (e, s) {
      debugPrint('[PushService] ERROR during opt-in process: $e');
      debugPrint('[PushService] Stacktrace: $s');
      return false;
    }
  }

  Future<void> optOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final token = await getToken();
      if (token == null) return;
      final tokenId = token.replaceAll('/', '_');
      final tokenRef = FirebaseFirestore.instance
        .collection('fcm_tokens')
        .doc(user.uid)
        .collection('tokens')
        .doc(tokenId);
      await tokenRef.delete();
    } catch (_) {}
    // Stop listeners
    _stopListeners();
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final tokenId = token.replaceAll('/', '_');
    final tokenRef = FirebaseFirestore.instance
        .collection('fcm_tokens')
        .doc(user.uid)
        .collection('tokens')
        .doc(tokenId);
    try {
      await tokenRef.set({
        'token': token,
        'platform': 'web',
        'createdAt': FieldValue.serverTimestamp(),
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to save token to Firestore: $e');
    }
  }
}
