import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_statistics_service.dart';

class EventService {
  EventService._();

  /// Atomically join an event: if space available the user is added to
  /// `attendees`, otherwise appended to `waitingListUids`.
  ///
  /// Throws ArgumentError if inputs are invalid
  /// Throws Exception if event doesn't exist
  static Future<void> joinEvent({
    required String eventId,
    required String userId,
    required int attendeeLimit,
    FirebaseFirestore? firestore,
  }) async {
    if (eventId.isEmpty) {
      throw ArgumentError('eventId cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    final fs = firestore ?? FirebaseFirestore.instance;
    final eventRef = fs.collection('events').doc(eventId);

    // Get event date before joining
    final eventSnap = await fs.collection('events').doc(eventId).get();
    if (!eventSnap.exists) {
      throw Exception('Event not found');
    }

    final eventData = eventSnap.data();
    final startTimeStr = eventData?['startTime'] as String?;
    final eventDate = startTimeStr != null
        ? DateTime.tryParse(startTimeStr)?.toLocal()
        : null;

    await fs.runTransaction((tx) async {
      final snap = await tx.get(eventRef);
      if (!snap.exists) throw Exception('Event not found');
      final data = snap.data() as Map<String, dynamic>;
      final attendees = List<String>.from(data['attendees'] ?? []);
      final waiting = List<String>.from(data['waitingListUids'] ?? []);

      if (attendees.contains(userId) || waiting.contains(userId)) return;

      final limit =
          attendeeLimit >= 0 ? attendeeLimit : (data['attendeeLimit'] ?? 0);
      if (attendees.length < limit) {
        attendees.add(userId);
      } else {
        waiting.add(userId);
      }

      tx.update(eventRef, {
        'attendees': attendees,
        'waitingListUids': waiting,
        'editedAt': DateTime.now().toUtc().toIso8601String(),
      });
    });

    // Update user statistics if we successfully joined as attendee
    if (eventDate != null) {
      try {
        await UserStatisticsService.recordEventJoin(userId, eventId, eventDate);
      } catch (e) {
        // Statistics update failed - non-critical, don't throw
      }
    }
  }

  /// Atomically leave an event: removes the user from attendees/waiting list
  /// and promotes the first waiting user (FIFO) into attendees if applicable.
  ///
  /// Throws ArgumentError if inputs are invalid
  /// Throws Exception if event doesn't exist
  static Future<void> leaveEvent({
    required String eventId,
    required String userId,
    FirebaseFirestore? firestore,
  }) async {
    if (eventId.isEmpty) {
      throw ArgumentError('eventId cannot be empty');
    }
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    final fs = firestore ?? FirebaseFirestore.instance;
    final eventRef = fs.collection('events').doc(eventId);

    // Get event date before leaving
    final eventSnap = await fs.collection('events').doc(eventId).get();
    if (!eventSnap.exists) {
      throw Exception('Event not found');
    }

    final eventData = eventSnap.data();
    final startTimeStr = eventData?['startTime'] as String?;
    final eventDate = startTimeStr != null
        ? DateTime.tryParse(startTimeStr)?.toLocal()
        : null;

    String? promotedUserId;

    await fs.runTransaction((tx) async {
      final snap = await tx.get(eventRef);
      if (!snap.exists) throw Exception('Event not found');
      final data = snap.data() as Map<String, dynamic>;
      final attendees = List<String>.from(data['attendees'] ?? []);
      final waiting = List<String>.from(data['waitingListUids'] ?? []);

      final wasAttendee = attendees.remove(userId);
      waiting.remove(userId);
      if (wasAttendee && waiting.isNotEmpty) {
        promotedUserId = waiting.removeAt(0);
        attendees.add(promotedUserId!);
      }

      tx.update(eventRef, {
        'attendees': attendees,
        'waitingListUids': waiting,
        'editedAt': DateTime.now().toUtc().toIso8601String(),
      });
    });

    // Update user statistics if we successfully left as attendee
    if (eventDate != null) {
      try {
        await UserStatisticsService.removeEventJoin(userId, eventId);
      } catch (e) {
        // Statistics update failed - non-critical, don't throw
      }
    }

    // Send system message to promoted user
    if (promotedUserId != null) {
      try {
        final eventSnap = await fs.collection('events').doc(eventId).get();
        final eventData = eventSnap.data();
        final eventName = eventData?['name'] ?? 'Event';

        await sendSystemMessage(
          userId: promotedUserId!,
          message:
              'Great news! You\'ve been promoted from the waiting list to attendee for "$eventName".',
          eventId: eventId,
          firestore: fs,
        );
      } catch (e) {
        // Failed to send promotion notification - non-critical
      }
    }
  }

  /// Send a system message to a user (used for event notifications)
  ///
  /// Throws ArgumentError if inputs are invalid
  static Future<void> sendSystemMessage({
    required String userId,
    required String message,
    required String eventId,
    FirebaseFirestore? firestore,
  }) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }
    if (message.isEmpty) {
      throw ArgumentError('message cannot be empty');
    }
    if (eventId.isEmpty) {
      throw ArgumentError('eventId cannot be empty');
    }

    final fs = firestore ?? FirebaseFirestore.instance;

    // Create a unique conversation ID for system-user communication
    final conversationId = 'system_$userId';

    try {
      await fs.runTransaction((tx) async {
        final messageRef = fs.collection('messages').doc(conversationId);
        final messageSnap = await tx.get(messageRef);

        // Generate unique message ID
        final messageId = fs.collection('messages').doc().id;

        if (!messageSnap.exists) {
          // Create new conversation thread
          tx.set(messageRef, {
            'participants': ['system', userId],
            'eventId': eventId,
            'lastMessage': message,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'unreadCount': {userId: 1},
            'createdAt': FieldValue.serverTimestamp(),
            // System conversations should not be replyable by users
            'replyable': false,
            'deleteAt': Timestamp.fromDate(
                DateTime.now().add(const Duration(days: 15))),
            'messages': {
              messageId: {
                'senderId': 'system',
                'text': message,
                'timestamp': FieldValue.serverTimestamp(),
              }
            }
          });
        } else {
          // Update existing conversation
          tx.update(messageRef, {
            'messages.$messageId': {
              'senderId': 'system',
              'text': message,
              'timestamp': FieldValue.serverTimestamp(),
            },
            'lastMessage': message,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'unreadCount.$userId': FieldValue.increment(1),
            // Ensure replyable stays false for system conversations
            'replyable': false,
            'deleteAt': Timestamp.fromDate(
                DateTime.now().add(const Duration(days: 15))),
          });
        }
      });
    } catch (e) {
      // Log error but don't throw - system messages are not critical
    }
  }
}
