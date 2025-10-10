import 'package:flutter/material.dart';
import 'package:floatit/src/core/di/dependency_injection.dart';
import 'package:floatit/src/core/domain/entities/event.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/error_message_utils.dart';

/// Enhanced events provider with clean architecture
class EventsProvider extends ChangeNotifier {
  final _di = DependencyInjection.instance;

  List<Event> _events = [];
  Map<String, Event> _eventsMap = {}; // For fast lookups
  bool _isLoading = false;
  Failure? _error;
  String? _selectedEventId;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  bool get hasError => _error != null;

  /// Get user-friendly error message
  String? get errorMessage => _error != null ? ErrorMessageUtils.getUserFriendlyMessage(_error!) : null;
  String? get selectedEventId => _selectedEventId;

  Event? get selectedEvent {
    if (_selectedEventId == null) return null;
    return _eventsMap[_selectedEventId];
  }

  /// Load all events
  Future<void> loadEvents() async {
    _setLoading(true);
    _clearError();

    final result = await _di.getEventsUseCase();

    result.fold(
      (failure) => _setError(failure),
      (events) {
        _events = events;
        _eventsMap = {for (final event in events) event.id: event};
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Load event by ID
  Future<Event?> loadEventById(String eventId) async {
    _setLoading(true);
    _clearError();

    final result = await _di.getEventByIdUseCase(eventId);

    Event? event;
    result.fold(
      (failure) => _setError(failure),
      (loadedEvent) {
        event = loadedEvent;
        // Update in list if exists, otherwise add
        final index = _events.indexWhere((e) => e.id == eventId);
        if (index >= 0) {
          _events[index] = loadedEvent;
        } else {
          _events.add(loadedEvent);
        }
        _eventsMap[eventId] = loadedEvent;
        notifyListeners();
      },
    );

    _setLoading(false);
    return event;
  }

  /// Create new event
  Future<String?> createEvent(Event event) async {
    _setLoading(true);
    _clearError();

    final result = await _di.createEventUseCase(event);

    String? eventId;
    result.fold(
      (failure) => _setError(failure),
      (id) {
        eventId = id;
        // Add to local list with generated ID
        final newEvent = event.copyWith(id: id);
        _events.add(newEvent);
        _eventsMap[id] = newEvent;
        notifyListeners();
      },
    );

    _setLoading(false);
    return eventId;
  }

  /// Update existing event
  Future<bool> updateEvent(Event event) async {
    _setLoading(true);
    _clearError();

    final result = await _di.updateEventUseCase(event);

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) {
        success = true;
        // Update in local list
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index >= 0) {
          _events[index] = event;
        }
        _eventsMap[event.id] = event;
        notifyListeners();
      },
    );

    _setLoading(false);
    return success;
  }

  /// Delete event
  Future<bool> deleteEvent(String eventId) async {
    _setLoading(true);
    _clearError();

    final result = await _di.deleteEventUseCase(eventId);

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) {
        success = true;
        _events.removeWhere((e) => e.id == eventId);
        _eventsMap.remove(eventId);
        if (_selectedEventId == eventId) {
          _selectedEventId = null;
        }
        notifyListeners();
      },
    );

    _setLoading(false);
    return success;
  }

  /// Join event
  Future<bool> joinEvent(String eventId, String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _di.joinEventUseCase(eventId, userId);

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) async {
        success = true;
        // Reload the specific event to get updated data
        await loadEventById(eventId);
      },
    );

    _setLoading(false);
    return success;
  }

  /// Leave event
  Future<bool> leaveEvent(String eventId, String userId) async {
    _setLoading(true);
    _clearError();

    final result = await _di.leaveEventUseCase(eventId, userId);

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) async {
        success = true;
        // Reload the specific event to get updated data
        await loadEventById(eventId);
      },
    );

    _setLoading(false);
    return success;
  }

  /// Select event for detailed view
  void selectEvent(String? eventId) {
    _selectedEventId = eventId;
    notifyListeners();
  }

  /// Get upcoming events
  List<Event> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) =>
        event.startTime != null &&
        event.startTime!.isAfter(now) &&
        !event.isPast).toList()
      ..sort((a, b) => a.startTime!.compareTo(b.startTime!));
  }

  /// Get past events
  List<Event> get pastEvents {
    return _events.where((event) => event.isPast).toList()
      ..sort((a, b) => (b.endTime ?? b.startTime)!.compareTo(a.endTime ?? a.startTime!));
  }

  /// Clear all events
  void clearEvents() {
    _events.clear();
    _selectedEventId = null;
    _clearError();
    notifyListeners();
  }

  /// Refresh events
  Future<void> refreshEvents() async {
    await loadEvents();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(Failure error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}