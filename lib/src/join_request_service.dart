import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for managing join/leave requests for events
/// Requests are queued and processed by Cloud Functions
class JoinRequestService {
  JoinRequestService._();

  /// Request to join an event
  /// Creates a pending request that will be processed by Cloud Functions
  /// Throws ArgumentError if inputs are invalid
  static Future<void> requestJoin({
    required String eventId,
    required String uid,
    FirebaseFirestore? firestore,
  }) async {
    if (eventId.isEmpty) {
      throw ArgumentError('eventId cannot be empty');
    }
    if (uid.isEmpty) {
      throw ArgumentError('uid cannot be empty');
    }
    
    final fs = firestore ?? FirebaseFirestore.instance;
    await fs.collection('join_requests').add({
      'eventId': eventId,
      'uid': uid,
      'type': 'join',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'processedAt': null,
    });
  }

  /// Request to leave an event
  /// Creates a pending request that will be processed by Cloud Functions
  /// Throws ArgumentError if inputs are invalid
  static Future<void> requestLeave({
    required String eventId,
    required String uid,
    FirebaseFirestore? firestore,
  }) async {
    if (eventId.isEmpty) {
      throw ArgumentError('eventId cannot be empty');
    }
    if (uid.isEmpty) {
      throw ArgumentError('uid cannot be empty');
    }
    
    final fs = firestore ?? FirebaseFirestore.instance;
    await fs.collection('join_requests').add({
      'eventId': eventId,
      'uid': uid,
      'type': 'leave',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'processedAt': null,
    });
  }
}
