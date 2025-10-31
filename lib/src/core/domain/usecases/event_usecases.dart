import 'package:floatit/src/core/data/repositories/event_repository.dart';
import 'package:floatit/src/core/domain/entities/event.dart';
import 'package:floatit/src/shared/utils/either.dart';
import 'package:floatit/src/shared/errors/failures.dart';

/// Use case for getting all events
class GetEventsUseCase {
  final EventRepository _eventRepository;

  const GetEventsUseCase(this._eventRepository);

  Future<Result<List<Event>>> call() {
    return _eventRepository.getEvents();
  }
}

/// Use case for getting event by ID
class GetEventByIdUseCase {
  final EventRepository _eventRepository;

  const GetEventByIdUseCase(this._eventRepository);

  Future<Result<Event>> call(String eventId) {
    return _eventRepository.getEventById(eventId);
  }
}

/// Use case for creating event
class CreateEventUseCase {
  final EventRepository _eventRepository;

  const CreateEventUseCase(this._eventRepository);

  Future<Result<String>> call(Event event) async {
    // Validate event data before creating
    final validationError = Event.validate(
      name: event.name,
      description: event.description,
      location: event.location,
      startTime: event.startTime,
      endTime: event.endTime,
      attendeeLimit: event.attendeeLimit,
      type: event.type,
      frequency: event.frequency,
      recurring: event.recurring,
    );

    if (validationError != null) {
      return Either.left(ValidationFailure(validationError));
    }

    // Sanitize event data
    final sanitizedEvent = event.sanitize();

    return _eventRepository.createEvent(sanitizedEvent);
  }
}

/// Use case for updating event
class UpdateEventUseCase {
  final EventRepository _eventRepository;

  const UpdateEventUseCase(this._eventRepository);

  Future<Result<void>> call(Event event) async {
    // Validate event data before updating
    final validationError = Event.validate(
      name: event.name,
      description: event.description,
      location: event.location,
      startTime: event.startTime,
      endTime: event.endTime,
      attendeeLimit: event.attendeeLimit,
      type: event.type,
      frequency: event.frequency,
      recurring: event.recurring,
    );

    if (validationError != null) {
      return Either.left(ValidationFailure(validationError));
    }

    // Sanitize event data
    final sanitizedEvent = event.sanitize();

    return _eventRepository.updateEvent(sanitizedEvent);
  }
}

/// Use case for deleting event
class DeleteEventUseCase {
  final EventRepository _eventRepository;

  const DeleteEventUseCase(this._eventRepository);

  Future<Result<void>> call(String eventId) {
    return _eventRepository.deleteEvent(eventId);
  }
}

/// Use case for joining event
class JoinEventUseCase {
  final EventRepository _eventRepository;

  const JoinEventUseCase(this._eventRepository);

  Future<Result<void>> call(String eventId, String userId) {
    return _eventRepository.joinEvent(eventId, userId);
  }
}

/// Use case for leaving event
class LeaveEventUseCase {
  final EventRepository _eventRepository;

  const LeaveEventUseCase(this._eventRepository);

  Future<Result<void>> call(String eventId, String userId) {
    return _eventRepository.leaveEvent(eventId, userId);
  }
}

/// Use case for getting user events
class GetUserEventsUseCase {
  final EventRepository _eventRepository;

  const GetUserEventsUseCase(this._eventRepository);

  Future<Result<List<Event>>> call(String userId) {
    return _eventRepository.getUserEvents(userId);
  }
}
