import 'package:cloud_firestore/cloud_firestore.dart';

class EventService {
  EventService._();

  /// Atomically join an event: if space available the user is added to
  /// `attendees`, otherwise appended to `waitingListUids`.
  static Future<void> joinEvent({
    required String eventId,
    required String userId,
    required int attendeeLimit,
    FirebaseFirestore? firestore,
  }) async {
    final fs = firestore ?? FirebaseFirestore.instance;
    final eventRef = fs.collection('events').doc(eventId);
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
  }

  /// Atomically leave an event: removes the user from attendees/waiting list
  /// and promotes the first waiting user (FIFO) into attendees if applicable.
  static Future<void> leaveEvent({
    required String eventId,
    required String userId,
    FirebaseFirestore? firestore,
  }) async {
    final fs = firestore ?? FirebaseFirestore.instance;
    final eventRef = fs.collection('events').doc(eventId);
    await fs.runTransaction((tx) async {
      final snap = await tx.get(eventRef);
      if (!snap.exists) throw Exception('Event not found');
      final data = snap.data() as Map<String, dynamic>;
      final attendees = List<String>.from(data['attendees'] ?? []);
      final waiting = List<String>.from(data['waitingListUids'] ?? []);

      final wasAttendee = attendees.remove(userId);
      waiting.remove(userId);
      if (wasAttendee && waiting.isNotEmpty) {
        attendees.add(waiting.removeAt(0));
      }

      tx.update(eventRef, {
        'attendees': attendees,
        'waitingListUids': waiting,
        'editedAt': DateTime.now().toUtc().toIso8601String(),
      });
    });
  }
}
