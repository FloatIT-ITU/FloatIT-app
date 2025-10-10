import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _notifications = [];
  Map<String, dynamic>? _globalBanner;
  final Map<String, Map<String, dynamic>?> _eventBanners = {};
  final Map<String, StreamSubscription<DocumentSnapshot>> _eventSubs = {};

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
  }

  void _init() {
    // Listen to global banner
    _fs.collection('app').doc('global_banner').snapshots().listen((snap) {
      _globalBanner = snap.exists ? snap.data() : null;
      notifyListeners();
    });
    // Listen to user notifications when signed in (real-time updates).
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        _notifications = [];
        notifyListeners();
        return;
      }
      _fs
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
}
