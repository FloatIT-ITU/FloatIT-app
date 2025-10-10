/// Constants for Firestore collection and field names
/// to avoid typos and make refactoring easier
class FirestoreConstants {
  // Collections
  static const String users = 'users';
  static const String publicUsers = 'public_users';
  static const String events = 'events';
  static const String app = 'app';
  static const String templates = 'templates';

  // User fields
  static const String admin = 'admin';
  static const String displayName = 'displayName';
  static const String email = 'email';
  static const String occupation = 'occupation';
  static const String iconColor = 'iconColor';

  // Event fields
  static const String attendees = 'attendees';
  static const String waitingListUids = 'waitingListUids';
  static const String host = 'host';
  static const String name = 'name';
  static const String description = 'description';
  static const String location = 'location';
  static const String startTime = 'startTime';
  static const String endTime = 'endTime';
  static const String attendeeLimit = 'attendeeLimit';
  static const String waitingList = 'waitingList';
  static const String type = 'type';
  static const String recurring = 'recurring';
  static const String frequency = 'frequency';
  static const String createdAt = 'createdAt';
  static const String editedAt = 'editedAt';

  // Subcollections
  static const String meta = 'meta';
  static const String eventBanner = 'event_banner';

  // Global banner
  static const String globalBanner = 'global_banner';
  static const String title = 'title';
  static const String body = 'body';
}