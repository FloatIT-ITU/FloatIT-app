import 'package:floatit/src/core/data/repositories/event_repository.dart';
import 'package:floatit/src/core/domain/entities/event.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/either.dart';
import 'package:floatit/src/push_service.dart';

/// Firebase implementation of EventRepository
class FirebaseEventRepository implements EventRepository {
  const FirebaseEventRepository();

  @override
  Future<Result<List<Event>>> getEvents() async {
    try {
      final querySnapshot = await FirebaseService.events.get();
      final events = querySnapshot.docs.map((doc) {
        return Event.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      return Result.right(events);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<Event>> getEventById(String eventId) async {
    try {
      final eventDoc = await FirebaseService.eventDoc(eventId).get();
      if (!eventDoc.exists) {
        return Result.left(DatabaseFailure.notFound());
      }

      final event = Event.fromJson(eventId, eventDoc.data()! as Map<String, dynamic>);
      return Result.right(event);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<String>> createEvent(Event event) async {
    try {
      final docRef = await FirebaseService.events.add(event.toJson());
      return Result.right(docRef.id);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> updateEvent(Event event) async {
    try {
      await FirebaseService.eventDoc(event.id).update(event.toJson());
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> deleteEvent(String eventId) async {
    try {
      await FirebaseService.eventDoc(eventId).delete();
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> joinEvent(String eventId, String userId) async {
    try {
      await FirebaseService.runTransaction((transaction) async {
        final eventRef = FirebaseService.eventDoc(eventId);
        final eventSnap = await transaction.get(eventRef);

        if (!eventSnap.exists) {
          throw Exception('Event not found');
        }

        final eventData = eventSnap.data()! as Map<String, dynamic>;
        final attendees = List<String>.from(eventData['attendees'] ?? []);
        final waitingList = List<String>.from(eventData['waitingListUids'] ?? []);
        final maxAttendees = eventData['attendeeLimit'] as int? ?? 10;

        // Remove from waiting list if present
        waitingList.remove(userId);

        // Add to attendees if there's space
        if (!attendees.contains(userId) && attendees.length < maxAttendees) {
          attendees.add(userId);
        }

        transaction.update(eventRef, {
          'attendees': attendees,
          'waitingListUids': waitingList,
        });
      });
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> leaveEvent(String eventId, String userId) async {
    try {
      String? promotedUserId;
      String? eventName;

      await FirebaseService.runTransaction((transaction) async {
        final eventRef = FirebaseService.eventDoc(eventId);
        final eventSnap = await transaction.get(eventRef);

        if (!eventSnap.exists) {
          throw Exception('Event not found');
        }

        final eventData = eventSnap.data()! as Map<String, dynamic>;
        final attendees = List<String>.from(eventData['attendees'] ?? []);
        final waitingList = List<String>.from(eventData['waitingListUids'] ?? []);
        final attendeeLimit = eventData['attendeeLimit'] as int? ?? 0;

        eventName = eventData['name'] as String?;

        // Remove from both lists
        attendees.remove(userId);
        waitingList.remove(userId);

        // Check if we can promote someone from waiting list
        if (attendees.length < attendeeLimit && waitingList.isNotEmpty) {
          promotedUserId = waitingList.removeAt(0);
          attendees.add(promotedUserId!);
        }

        transaction.update(eventRef, {
          'attendees': attendees,
          'waitingListUids': waitingList,
        });
      });

      // Send notification to promoted user if any
      if (promotedUserId != null && eventName != null) {
        final pushService = PushService();
        await pushService.sendWaitingListPromotionNotification(
          userId: promotedUserId!,
          eventId: eventId,
          eventName: eventName!,
        );
      }

      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<List<Event>>> getUserEvents(String userId) async {
    try {
      // Get events where user is host or attendee
      final hostEventsQuery = FirebaseService.events.where('host', isEqualTo: userId);
      final attendeeEventsQuery = FirebaseService.events.where('attendees', arrayContains: userId);

      final [hostSnapshot, attendeeSnapshot] = await Future.wait([
        hostEventsQuery.get(),
        attendeeEventsQuery.get(),
      ]);

      final eventIds = <String>{};
      final events = <Event>[];

      // Add host events
      for (final doc in hostSnapshot.docs) {
        if (!eventIds.contains(doc.id)) {
          eventIds.add(doc.id);
          events.add(Event.fromJson(doc.id, doc.data() as Map<String, dynamic>));
        }
      }

      // Add attendee events
      for (final doc in attendeeSnapshot.docs) {
        if (!eventIds.contains(doc.id)) {
          eventIds.add(doc.id);
          events.add(Event.fromJson(doc.id, doc.data() as Map<String, dynamic>));
        }
      }

      return Result.right(events);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Stream<Result<List<Event>>> watchEvents() {
    return FirebaseService.events.snapshots().map((snapshot) {
      try {
        final events = snapshot.docs.map((doc) {
          return Event.fromJson(doc.id, doc.data() as Map<String, dynamic>);
        }).toList();
        return Result.right(events);
      } catch (e) {
        return Result.left(DatabaseFailure.unknown());
      }
    });
  }

  @override
  Stream<Result<Event>> watchEventById(String eventId) {
    return FirebaseService.eventDoc(eventId).snapshots().map((snapshot) {
      try {
        if (!snapshot.exists) {
          return Result.left(DatabaseFailure.notFound());
        }

        final event = Event.fromJson(eventId, snapshot.data()! as Map<String, dynamic>);
        return Result.right(event);
      } catch (e) {
        return Result.left(DatabaseFailure.unknown());
      }
    });
  }

  @override
  Stream<Result<List<Event>>> watchUserEvents(String userId) {
    // This is complex to implement efficiently with Firestore streams
    // For now, return a stream that periodically fetches user events
    // In a production app, you might want to use a more sophisticated approach
    return Stream.periodic(const Duration(seconds: 30)).asyncMap((_) async {
      return await getUserEvents(userId);
    });
  }
}