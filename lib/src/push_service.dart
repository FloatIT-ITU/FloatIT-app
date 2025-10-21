import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html; // ignore: avoid_web_libraries_in_flutter

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
        await html.window.navigator.serviceWorker!.register('/firebase-messaging-sw.js');
        print('Service worker registered'); // ignore: avoid_print
      } catch (e) {
        print('Failed to register service worker: $e'); // ignore: avoid_print
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
      // For web, FCM requires a VAPID key for push notifications. If vapid is null
      // getToken will try without it (may fail on web). See README in project for details.
      final token = await _messaging.getToken(vapidKey: vapid);
      print('getToken() returned: $token'); // ignore: avoid_print
      return token;
    } catch (e) {
      print('getToken() error: $e'); // ignore: avoid_print
      print('If error mentions "messaging/unsupported-browser" or VAPID, you need to:'); // ignore: avoid_print
      print('1. Go to Firebase Console > Project Settings > Cloud Messaging'); // ignore: avoid_print
      print('2. Generate Web Push certificate (VAPID key)'); // ignore: avoid_print
      print('3. Add the key to push_service.dart getToken() method'); // ignore: avoid_print
      return null;
    }
  }

  Future<bool> registerTokenForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in'); // ignore: avoid_print
      return false;
    }
    print('Registering token for user ${user.uid}'); // ignore: avoid_print
    final granted = await requestPermission();
    if (!granted) {
      print('Permission not granted'); // ignore: avoid_print
      return false;
    }
    print('Permission granted, getting token...'); // ignore: avoid_print
    final token = await getToken();
    print('Got token: $token'); // ignore: avoid_print
    if (token == null) {
      print('Token is null'); // ignore: avoid_print
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
      print('Saving token to Firestore...'); // ignore: avoid_print
      await tokenRef.set({
      'token': token,
      'platform': 'web',
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('Token saved successfully'); // ignore: avoid_print
    } catch (e) {
      print('Failed to save token to Firestore: $e'); // ignore: avoid_print
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
}
