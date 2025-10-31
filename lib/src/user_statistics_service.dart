import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatisticsService {
  static const String collectionName = 'user_event_history';

  /// Record when a user joins an event
  static Future<void> recordEventJoin(
      String userId, String eventId, DateTime eventDate) async {
    final fs = FirebaseFirestore.instance;
    final docId = '${userId}_$eventId';

    await fs.collection(collectionName).doc(docId).set({
      'userId': userId,
      'eventId': eventId,
      'eventDate': Timestamp.fromDate(eventDate),
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove record when a user leaves an event
  static Future<void> removeEventJoin(String userId, String eventId) async {
    final fs = FirebaseFirestore.instance;
    final docId = '${userId}_$eventId';

    await fs.collection(collectionName).doc(docId).delete();
  }

  /// Get user's joined events count (only past events, excluding events where user was host)
  static Future<int> getUserEventsJoinedCount(String userId,
      {DateTime? since, DateTime? until}) async {
    final fs = FirebaseFirestore.instance;
    final now = DateTime.now();

    Query query = fs
        .collection(collectionName)
        .where('userId', isEqualTo: userId)
        .where('eventDate',
            isLessThanOrEqualTo: Timestamp.fromDate(now)); // Only past events

    if (since != null) {
      query = query.where('eventDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(since));
    }
    if (until != null) {
      query = query.where('eventDate',
          isLessThanOrEqualTo: Timestamp.fromDate(until));
    }

    final snapshot = await query.get();

    // Filter out events where the user was the host
    int count = 0;
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final eventId = data['eventId'] as String;

      // Check if user was the host of this event
      final eventDoc = await fs.collection('events').doc(eventId).get();
      if (eventDoc.exists) {
        final eventData = eventDoc.data() as Map<String, dynamic>;
        final hostId = eventData['host'] as String?;

        // Only count if user was NOT the host
        if (hostId != userId) {
          count++;
        }
      }
    }

    return count;
  }

  /// Calculate user rank for a specific period (only past events)
  static Future<String> calculateUserRank(String userId, String period) async {
    final fs = FirebaseFirestore.instance;
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // Define date ranges
    DateTime? since;

    switch (period) {
      case 'allTime':
        // No date restrictions - all past events
        since = null;
        break;
      case 'monthly':
        // Current month
        since = DateTime(currentYear, currentMonth, 1);
        break;
      case 'semester':
        // Current semester
        if (currentMonth >= 8 || currentMonth <= 1) {
          // Autumn Semester: Aug 1 to Jan 31
          since = DateTime(currentYear - (currentMonth <= 1 ? 1 : 0), 8, 1);
        } else {
          // Spring Semester: Feb 1 to Jul 31
          since = DateTime(currentYear, 2, 1);
        }
        break;
      default:
        return '--';
    }

    // Get all users' event counts for this period
    final allUsersSnapshot = await fs.collection(collectionName).get();
    final userCounts = <String, int>{};

    // Group by user and count events in the period
    for (final doc in allUsersSnapshot.docs) {
      final data = doc.data();
      final docUserId = data['userId'] as String;
      final eventDate = (data['eventDate'] as Timestamp).toDate();

      // Check if event is in the past and within the period
      if (eventDate.isAfter(now)) continue; // Skip future events

      bool inPeriod = true;
      if (since != null && eventDate.isBefore(since)) inPeriod = false;

      if (inPeriod) {
        userCounts[docUserId] = (userCounts[docUserId] ?? 0) + 1;
      }
    }

    if (userCounts.isEmpty) return '--';

    // Sort by count descending
    final sortedUsers = userCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Find user rank
    final userIndex = sortedUsers.indexWhere((entry) => entry.key == userId);
    if (userIndex != -1) {
      return '#${userIndex + 1}';
    } else {
      // User not in rankings (count = 0)
      return '#${sortedUsers.length + 1}';
    }
  }

  /// Get leaderboard data for a specific period
  static Future<List<Map<String, dynamic>>> getLeaderboard(String period,
      {String? currentUserId}) async {
    final fs = FirebaseFirestore.instance;
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    // Define date ranges
    DateTime? since;

    switch (period) {
      case 'allTime':
        since = null;
        break;
      case 'monthly':
        since = DateTime(currentYear, currentMonth, 1);
        break;
      case 'semester':
        if (currentMonth >= 8 || currentMonth <= 1) {
          since = DateTime(currentYear - (currentMonth <= 1 ? 1 : 0), 8, 1);
        } else {
          since = DateTime(currentYear, 2, 1);
        }
        break;
      default:
        return [];
    }

    // Get all users' event counts for this period
    final allUsersSnapshot = await fs.collection(collectionName).get();
    final userCounts = <String, int>{};
    final userEventDates = <String, List<DateTime>>{};

    // Group by user and count events in the period
    for (final doc in allUsersSnapshot.docs) {
      final data = doc.data();
      final docUserId = data['userId'] as String;
      final eventDate = (data['eventDate'] as Timestamp).toDate();
      final eventId = data['eventId'] as String;

      // Check if event is in the past and within the period
      if (eventDate.isAfter(now)) continue; // Skip future events

      bool inPeriod = true;
      if (since != null && eventDate.isBefore(since)) inPeriod = false;

      if (inPeriod) {
        // Check if user was the host of this event
        final eventDoc = await fs.collection('events').doc(eventId).get();
        if (eventDoc.exists) {
          final eventData = eventDoc.data() as Map<String, dynamic>;
          final hostId = eventData['host'] as String?;

          // Only count if user was NOT the host
          if (hostId != docUserId) {
            userCounts[docUserId] = (userCounts[docUserId] ?? 0) + 1;
            userEventDates[docUserId] = (userEventDates[docUserId] ?? [])
              ..add(eventDate);
          }
        }
      }
    }

    if (userCounts.isEmpty) return [];

    // Sort by count descending, then by most recent event date
    final sortedUsers = userCounts.entries.toList()
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) return countCompare;

        // If counts are equal, sort by most recent event
        final aDates = userEventDates[a.key] ?? [];
        final bDates = userEventDates[b.key] ?? [];
        if (aDates.isEmpty && bDates.isEmpty) return 0;
        if (aDates.isEmpty) return 1;
        if (bDates.isEmpty) return -1;

        final aLatest = aDates.reduce((a, b) => a.isAfter(b) ? a : b);
        final bLatest = bDates.reduce((a, b) => a.isAfter(b) ? a : b);
        return bLatest.compareTo(aLatest);
      });

    // Get user display names
    final leaderboard = <Map<String, dynamic>>[];
    for (int i = 0; i < sortedUsers.length && i < 10; i++) {
      final entry = sortedUsers[i];
      final userDoc = await fs.collection('public_users').doc(entry.key).get();
      final userData = userDoc.data();
      final displayName = userData?['displayName'] as String? ?? 'Unknown User';

      leaderboard.add({
        'userId': entry.key,
        'displayName': displayName,
        'eventCount': entry.value,
        'rank': i + 1,
        'isCurrentUser': entry.key == currentUserId,
      });
    }

    // If current user is not in top 10, add them with their rank
    if (currentUserId != null) {
      final currentUserIndex =
          sortedUsers.indexWhere((entry) => entry.key == currentUserId);
      if (currentUserIndex >= 10 || currentUserIndex == -1) {
        final currentUserCount = userCounts[currentUserId] ?? 0;
        final userDoc =
            await fs.collection('public_users').doc(currentUserId).get();
        final userData = userDoc.data();
        final displayName =
            userData?['displayName'] as String? ?? 'Unknown User';

        leaderboard.add({
          'userId': currentUserId,
          'displayName': displayName,
          'eventCount': currentUserCount,
          'rank': currentUserIndex != -1
              ? currentUserIndex + 1
              : sortedUsers.length + 1,
          'isCurrentUser': true,
        });
      }
    }

    return leaderboard;
  }

  /// Migrate existing event data to event history
  static Future<void> migrateExistingEventHistory() async {
    final fs = FirebaseFirestore.instance;

    // Get all users from public_users
    final usersSnapshot = await fs.collection('public_users').get();

    for (final userDoc in usersSnapshot.docs) {
      final userId = userDoc.id;

      // Get user's joined events
      final eventsSnapshot = await fs
          .collection('events')
          .where('attendees', arrayContains: userId)
          .get();

      // Record each event join
      for (final eventDoc in eventsSnapshot.docs) {
        final eventData = eventDoc.data();
        final startTimeStr = eventData['startTime'] as String?;

        if (startTimeStr != null) {
          final eventDate = DateTime.tryParse(startTimeStr)?.toLocal();
          if (eventDate != null) {
            await recordEventJoin(userId, eventDoc.id, eventDate);
          }
        }
      }
    }
  }
}
