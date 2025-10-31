import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floatit/src/constants/firestore_constants.dart';

/// Centralized Firebase service to eliminate repetitive FirebaseFirestore.instance calls
/// and provide a consistent interface for all Firebase operations.
class FirebaseService {
  static final FirebaseFirestore _instance = FirebaseFirestore.instance;

  // Private constructor to prevent instantiation
  FirebaseService._();

  /// Get the Firestore instance (for dependency injection in tests)
  static FirebaseFirestore get instance => _instance;

  // ===== COLLECTIONS =====

  /// Reference to the users collection
  static CollectionReference get users =>
      _instance.collection(FirestoreConstants.users);

  /// Reference to the public_users collection
  static CollectionReference get publicUsers =>
      _instance.collection(FirestoreConstants.publicUsers);

  /// Reference to the events collection
  static CollectionReference get events =>
      _instance.collection(FirestoreConstants.events);

  /// Reference to the app collection
  static CollectionReference get app =>
      _instance.collection(FirestoreConstants.app);

  /// Reference to the templates collection
  static CollectionReference get templates =>
      _instance.collection(FirestoreConstants.templates);

  // ===== DOCUMENT REFERENCES =====

  /// Get a user document reference by UID
  static DocumentReference userDoc(String uid) => users.doc(uid);

  /// Get a public user document reference by UID
  static DocumentReference publicUserDoc(String uid) => publicUsers.doc(uid);

  /// Get an event document reference by ID
  static DocumentReference eventDoc(String eventId) => events.doc(eventId);

  /// Get the global banner document
  static DocumentReference get globalBanner =>
      app.doc(FirestoreConstants.globalBanner);

  /// Get an event banner document
  static DocumentReference eventBanner(String eventId) => eventDoc(eventId)
      .collection(FirestoreConstants.meta)
      .doc(FirestoreConstants.eventBanner);

  // ===== COMMON QUERIES =====

  /// Stream of all public users
  static Stream<QuerySnapshot> get publicUsersStream => publicUsers.snapshots();

  /// Stream of all events
  static Stream<QuerySnapshot> get eventsStream => events.snapshots();

  /// Get admin users query
  static Query get adminUsersQuery =>
      users.where(FirestoreConstants.admin, isEqualTo: true);

  /// Stream of admin users
  static Stream<QuerySnapshot> get adminUsersStream =>
      adminUsersQuery.snapshots();

  /// Future of admin users
  static Future<QuerySnapshot> get adminUsersFuture => adminUsersQuery.get();

  // ===== UTILITY METHODS =====

  /// Run a Firestore transaction
  static Future<T> runTransaction<T>(TransactionHandler<T> updateFunction) =>
      _instance.runTransaction(updateFunction);

  /// Get the current server timestamp
  static FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Get current UTC timestamp as ISO string
  static String get utcTimestamp => DateTime.now().toUtc().toIso8601String();

  /// Convert Firestore timestamp to DateTime
  static DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return null;
  }
}
