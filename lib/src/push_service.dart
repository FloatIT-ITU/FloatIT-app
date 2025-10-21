import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

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
        print('Service worker registered');
      } catch (e) {
        print('Failed to register service worker: $e');
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
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  Future<bool> registerTokenForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in');
      return false;
    }
    print('Registering token for user ${user.uid}');
    final granted = await requestPermission();
    if (!granted) {
      print('Permission not granted');
      return false;
    }
    print('Permission granted, getting token...');
    final token = await getToken();
    print('Got token: $token');
    if (token == null) {
      print('Token is null');
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
      await tokenRef.set({
      'token': token,
      'platform': 'web',
      'createdAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
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
