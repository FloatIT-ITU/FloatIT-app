import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingRequestsProvider extends ChangeNotifier {
  PendingRequestsProvider._private();
  static final PendingRequestsProvider _instance =
      PendingRequestsProvider._private();
  factory PendingRequestsProvider() => _instance;

  final FirebaseFirestore _fs = FirebaseFirestore.instance;
  Map<String, String> _pendingForEvent = {}; // eventId -> requestType

  bool isPending(String eventId) => _pendingForEvent.containsKey(eventId);
  String? pendingType(String eventId) => _pendingForEvent[eventId];

  Future<void> loadForCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _pendingForEvent = {};
      notifyListeners();
      return;
    }
    final q = await _fs
        .collection('join_requests')
        .where('uid', isEqualTo: user.uid)
        .where('processedAt', isEqualTo: null)
        .get();
    final map = <String, String>{};
    for (final doc in q.docs) {
      final data = doc.data();
      final eid = data['eventId'] as String?;
      final type = data['type'] as String?;
      if (eid != null && type != null) map[eid] = type;
    }
    _pendingForEvent = map;
    notifyListeners();
  }

  Future<void> refresh() async => loadForCurrentUser();
}
