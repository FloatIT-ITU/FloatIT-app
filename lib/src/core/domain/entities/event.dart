/// Domain entity representing an event
class Event {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final DateTime? startTime;
  final DateTime? endTime;
  final int attendeeLimit;
  final bool waitingList;
  final String type;
  final String? hostId;
  final List<String> attendees;
  final List<String> waitingListUids;
  final bool recurring;
  final String? frequency;
  final DateTime? createdAt;
  final DateTime? editedAt;

  const Event({
    required this.id,
    required this.name,
    this.description,
    this.location,
    this.startTime,
    this.endTime,
    this.attendeeLimit = 10,
    this.waitingList = false,
    this.type = 'practice',
    this.hostId,
    this.attendees = const [],
    this.waitingListUids = const [],
    this.recurring = false,
    this.frequency,
    this.createdAt,
    this.editedAt,
  });

  /// Valid event types
  static const List<String> validTypes = ['practice', 'competition', 'social'];

  /// Valid frequency types for recurring events
  static const List<String> validFrequencies = ['daily', 'weekly', 'monthly'];

  /// Validate event name
  static bool isValidName(String name) {
    return name.trim().isNotEmpty && name.length <= 100;
  }

  /// Validate description
  static bool isValidDescription(String? description) {
    if (description == null) return true;
    return description.length <= 1000;
  }

  /// Validate location
  static bool isValidLocation(String? location) {
    if (location == null) return true;
    return location.trim().isNotEmpty && location.length <= 200;
  }

  /// Validate attendee limit
  static bool isValidAttendeeLimit(int limit) {
    return limit >= 1 && limit <= 1000;
  }

  /// Validate event type
  static bool isValidType(String type) {
    return validTypes.contains(type);
  }

  /// Validate frequency
  static bool isValidFrequency(String? frequency) {
    if (frequency == null) return true;
    return validFrequencies.contains(frequency);
  }

  /// Validate dates
  static bool areValidDates(DateTime? startTime, DateTime? endTime) {
    if (startTime == null && endTime == null) return true;
    if (startTime == null || endTime == null) return false;
    return endTime.isAfter(startTime);
  }

  /// Validate event data
  static String? validate({
    required String name,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    required int attendeeLimit,
    required String type,
    String? frequency,
    required bool recurring,
  }) {
    if (!isValidName(name)) {
      return 'Event name must be 1-100 characters';
    }

    if (!isValidDescription(description)) {
      return 'Description must be 1000 characters or less';
    }

    if (!isValidLocation(location)) {
      return 'Location must be 1-200 characters';
    }

    if (!isValidAttendeeLimit(attendeeLimit)) {
      return 'Attendee limit must be between 1 and 1000';
    }

    if (!isValidType(type)) {
      return 'Invalid event type. Must be: ${validTypes.join(", ")}';
    }

    if (recurring && !isValidFrequency(frequency)) {
      return 'Invalid frequency. Must be: ${validFrequencies.join(", ")}';
    }

    if (!areValidDates(startTime, endTime)) {
      return 'End time must be after start time';
    }

    return null; // Valid
  }

  /// Sanitize event input
  Event sanitize() {
    return copyWith(
      name: name.trim(),
      description: description?.trim(),
      location: location?.trim(),
    );
  }

  /// Create a copy with modified fields
  Event copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    int? attendeeLimit,
    bool? waitingList,
    String? type,
    String? hostId,
    List<String>? attendees,
    List<String>? waitingListUids,
    bool? recurring,
    String? frequency,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      attendeeLimit: attendeeLimit ?? this.attendeeLimit,
      waitingList: waitingList ?? this.waitingList,
      type: type ?? this.type,
      hostId: hostId ?? this.hostId,
      attendees: attendees ?? this.attendees,
      waitingListUids: waitingListUids ?? this.waitingListUids,
      recurring: recurring ?? this.recurring,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// Check if event is in the past
  bool get isPast {
    if (endTime == null) return false;
    return endTime!.isBefore(DateTime.now());
  }

  /// Check if event is upcoming
  bool get isUpcoming {
    if (startTime == null) return false;
    return startTime!.isAfter(DateTime.now());
  }

  /// Check if user is attending
  bool isAttending(String userId) => attendees.contains(userId);

  /// Check if user is on waiting list
  bool isOnWaitingList(String userId) => waitingListUids.contains(userId);

  /// Check if user is host
  bool isHost(String userId) => hostId == userId;

  /// Get current attendee count
  int get currentAttendeeCount => attendees.length;

  /// Check if event is full
  bool get isFull => currentAttendeeCount >= attendeeLimit;

  /// Check if waiting list is available
  bool get hasWaitingList => waitingList && isFull;

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'location': location,
      'startTime': startTime?.toUtc().toIso8601String(),
      'endTime': endTime?.toUtc().toIso8601String(),
      'attendeeLimit': attendeeLimit,
      'waitingList': waitingList,
      'type': type,
      'host': hostId,
      'attendees': attendees,
      'waitingListUids': waitingListUids,
      'recurring': recurring,
      'frequency': frequency,
      'createdAt': createdAt?.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory Event.fromJson(String id, Map<String, dynamic> json) {
    return Event(
      id: id,
      name: json['name'] as String? ?? 'Untitled Event',
      description: json['description'] as String?,
      location: json['location'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      attendeeLimit: json['attendeeLimit'] as int? ?? 10,
      waitingList: json['waitingList'] as bool? ?? false,
      type: json['type'] as String? ?? 'practice',
      hostId: json['host'] as String?,
      attendees: List<String>.from(json['attendees'] ?? []),
      waitingListUids: List<String>.from(json['waitingListUids'] ?? []),
      recurring: json['recurring'] as bool? ?? false,
      frequency: json['frequency'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      editedAt: json['editedAt'] != null
          ? DateTime.tryParse(json['editedAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Event(id: $id, name: $name, startTime: $startTime, attendees: ${attendees.length}/$attendeeLimit)';
  }
}