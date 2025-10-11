import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initForCurrentUser() async {
    if (kIsWeb) {
      try {
        // Request permission for web push notifications with timeout
        // This prevents blocking the app if the browser doesn't support notifications
        // or if there's any issue with the permission request
        final settings = await _firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        ).timeout(
          const Duration(seconds: 5),
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          // User granted permission - set up message handlers
          _setupMessageHandlers();
        }
        // If permission not granted or initialization fails,
        // app continues to work normally without push notifications
      } catch (e) {
        // If notification setup fails (timeout, unsupported, etc.), 
        // app continues to work normally without push notifications
      }
    }
  }

  void _setupMessageHandlers() {
    try {
      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Handle foreground message
      });
    } catch (e) {
      // Message handler setup failed, notifications won't work
    }
  }

  Future<String?> getToken() async {
    if (kIsWeb) {
      try {
        final token = await _firebaseMessaging.getToken();
        return token;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Send push notification to specific users (client-side approach)
  // Note: This is a workaround since we can't send FCM from client-side
  // In production, this should be moved to server-side (Firebase Functions)
  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    String? eventId,
  }) async {
    if (userIds.isEmpty) return;

    try {
      // Get FCM tokens for the users
      final usersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIds.take(10)) // Firestore limit
          .get();

      final tokens = <String>[];
      for (final doc in usersQuery.docs) {
        final token = doc.data()['fcmToken'] as String?;
        if (token != null && token.isNotEmpty) {
          tokens.add(token);
        }
      }

      if (tokens.isEmpty) return;

      // Create notification tasks in Firestore for processing
      // In a real implementation, this would trigger server-side sending
      final batch = FirebaseFirestore.instance.batch();

      for (final token in tokens) {
        final notificationRef = FirebaseFirestore.instance
            .collection('notification_tasks')
            .doc();

        batch.set(notificationRef, {
          'token': token,
          'title': title,
          'body': body,
          'eventId': eventId,
          'createdAt': FieldValue.serverTimestamp(),
          'processed': false,
        });
      }

      await batch.commit();

      // For now, show a message that notifications would be sent
      // In production, a Cloud Function would process these tasks

    } catch (e) {
      // Handle error silently in production
    }
  }

  // Send notification to event attendees and waiting list users
  Future<void> sendEventNotification({
    required String eventId,
    required String title,
    required String body,
  }) async {
    try {
      final eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (!eventDoc.exists) return;

      final eventData = eventDoc.data()!;
      final attendees = List<String>.from(eventData['attendees'] ?? []);
      final waitingList = List<String>.from(eventData['waitingListUids'] ?? []);
      final host = eventData['host'] as String?;

      // Include host if not already in attendees
      final allUserIds = <String>[];
      allUserIds.addAll(attendees);
      allUserIds.addAll(waitingList);
      if (host != null && !allUserIds.contains(host)) {
        allUserIds.add(host);
      }

      if (allUserIds.isNotEmpty) {
        await sendNotificationToUsers(
          userIds: allUserIds,
          title: title,
          body: body,
          eventId: eventId,
        );
      }
    } catch (e) {
      // Handle error silently in production
    }
  }

  // Send notification when user gets promoted from waiting list
  Future<void> sendWaitingListPromotionNotification({
    required String userId,
    required String eventId,
    required String eventName,
  }) async {
    await sendNotificationToUsers(
      userIds: [userId],
      title: 'Spot Available!',
      body: 'You\'ve been moved from the waiting list to attendees for "$eventName"',
      eventId: eventId,
    );
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background message
  }
}
