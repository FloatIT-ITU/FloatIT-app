import 'package:floatit/src/core/domain/entities/event.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Abstract repository for event data operations
abstract class EventRepository {
  /// Get all events
  Future<Result<List<Event>>> getEvents();

  /// Get event by ID
  Future<Result<Event>> getEventById(String eventId);

  /// Create new event
  Future<Result<String>> createEvent(Event event);

  /// Update existing event
  Future<Result<void>> updateEvent(Event event);

  /// Delete event
  Future<Result<void>> deleteEvent(String eventId);

  /// Join event
  Future<Result<void>> joinEvent(String eventId, String userId);

  /// Leave event
  Future<Result<void>> leaveEvent(String eventId, String userId);

  /// Get events for user (attending or hosting)
  Future<Result<List<Event>>> getUserEvents(String userId);

  /// Stream of all events
  Stream<Result<List<Event>>> watchEvents();

  /// Stream of single event changes
  Stream<Result<Event>> watchEventById(String eventId);

  /// Stream of user events
  Stream<Result<List<Event>>> watchUserEvents(String userId);
}