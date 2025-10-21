import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'push_service.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic>? _globalBanner;
  final Map<String, Map<String, dynamic>?> _eventBanners = {};
  final Map<String, StreamSubscription<DocumentSnapshot>> _eventSubs = {};
  
  // Stream subscriptions that need to be disposed
  StreamSubscription<DocumentSnapshot>? _globalBannerSub;
  StreamSubscription<QuerySnapshot>? _notificationsSub;
  StreamSubscription<User?>? _authSub;

  List<Map<String, dynamic>> get notifications => _notifications;
  Map<String, dynamic>? get globalBanner => _globalBanner;
  Map<String, dynamic>? get activeEventBanner {
    if (_eventBanners.isEmpty) return null;
    // pick the most recent by createdAt if present
    MapEntry<String, Map<String, dynamic>?>? latest;
    for (var e in _eventBanners.entries) {
      final data = e.value;
      if (data == null) continue;
      if (latest == null) {
        latest = e;
        continue;
      }
      final a = data['createdAt']?.toString() ?? '';
      final b = latest.value?['createdAt']?.toString() ?? '';
      if (a.isEmpty && b.isEmpty) continue;
      if (a.isEmpty) continue;
      if (b.isEmpty || a.compareTo(b) > 0) latest = e;
    }
    return latest?.value;
  }

  NotificationProvider() {
    _init();
    // Listen for foreground FCM messages and surface them as in-app notifications
    // By default we persist notifications to Firestore so they appear in the
    // server-side list; set _persistForegroundNotifications=false to disable.
    _listenToForegroundMessages();
  }

  // Whether to write foreground messages into Firestore notifications
  // (so they persist and can be marked read). You can turn this off if you
  // prefer to only show ephemeral in-app banners.
  final bool _persistForegroundNotifications = true;

  void _listenToForegroundMessages() {
    PushService.instance.onMessageStream.listen((message) async {
      // Convert RemoteMessage into a simple map used by the UI
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final map = <String, dynamic>{
        'id': id,
        'title': message.notification?.title ?? 'Notification',
        'body': message.notification?.body ?? '',
  'data': message.data,
        'createdAt': DateTime.now().toUtc().toIso8601String(),
        'read': false,
      };

      // Prepend to local list and notify listeners
      _notifications = [map, ..._notifications];
      notifyListeners();

      // Optionally persist to Firestore notifications collection so it can be
      // shared across devices and appear in the same UI that reads notifications.
      try {
        if (_persistForegroundNotifications) {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final doc = await _fs.collection('notifications').add({
              'recipientUid': user.uid,
              'title': map['title'],
              'body': map['body'],
              'data': map['data'],
              'createdAt': Timestamp.now(),
              'read': false,
            });
            // update local id with Firestore id
            map['id'] = doc.id;
          }
        }
      } catch (e) {
        // ignore persistence failures - we still show the in-memory notification
      }
    });
  }

  void _init() {
    // Listen to global banner
    _globalBannerSub = _fs.collection('app').doc('global_banner').snapshots().listen((snap) {
      _globalBanner = snap.exists ? snap.data() : null;
      notifyListeners();
    });
    
    // Listen to user notifications when signed in (real-time updates).
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      // Cancel previous notifications subscription if any
      _notificationsSub?.cancel();
      
      if (user == null) {
        _notifications = [];
        notifyListeners();
        return;
      }
      
      _notificationsSub = _fs
          .collection('notifications')
          .where('recipientUid', isEqualTo: user.uid)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snap) {
        _notifications =
            snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
        notifyListeners();
      });

      // Also track event-scoped banners for events the user is attending or hosting.
      _setupEventBannerListeners(user.uid);
    });
  }

  Future<void> _setupEventBannerListeners(String uid) async {
    // Clean up any existing subs
    for (var s in _eventSubs.values) {
      s.cancel();
    }
    _eventSubs.clear();
    _eventBanners.clear();
    notifyListeners();

    try {
      // events where user is an attendee
      final attendeeSnap = await _fs
          .collection('events')
          .where('attendees', arrayContains: uid)
          .get();
      final hostSnap =
          await _fs.collection('events').where('host', isEqualTo: uid).get();
      final ids = <String>{};
      ids.addAll(attendeeSnap.docs.map((d) => d.id));
      ids.addAll(hostSnap.docs.map((d) => d.id));
      for (var id in ids) {
        final sub = _fs
            .collection('events')
            .doc(id)
            .collection('meta')
            .doc('event_banner')
            .snapshots()
            .listen((snap) {
          _eventBanners[id] =
              snap.exists ? (snap.data() as Map<String, dynamic>) : null;
          notifyListeners();
        });
        _eventSubs[id] = sub;
      }
    } catch (e) {
      // Failed to setup event banner listeners
    }
  }

  Future<void> loadForUser(String uid) async {
    _fs
        .collection('notifications')
        .where('recipientUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .get()
        .then((snap) {
      _notifications = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      notifyListeners();
    }).catchError((_) {});
  }

  Future<void> markRead(String id) async {
    await _fs.collection('notifications').doc(id).update(
        {'read': true, 'readAt': DateTime.now().toUtc().toIso8601String()});
  }
  
  @override
  void dispose() {
    // Cancel all stream subscriptions to prevent memory leaks
    _globalBannerSub?.cancel();
    _notificationsSub?.cancel();
    _authSub?.cancel();
    
    for (var sub in _eventSubs.values) {
      sub.cancel();
    }
    _eventSubs.clear();
    
    super.dispose();
  }
}
