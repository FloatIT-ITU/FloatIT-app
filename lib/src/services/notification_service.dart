import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../event_service.dart';
import 'github_app_service.dart';
import 'audit_logger.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  /// Send a global notification
  Future<void> sendGlobalNotification({
    required String title,
    required String body,
    required bool sendAsSystemMessage,
  }) async {
    // Input validation
    if (title.trim().isEmpty) throw ArgumentError('Title cannot be empty');
    if (body.trim().isEmpty) throw ArgumentError('Body cannot be empty');
    if (title.length > 200) throw ArgumentError('Title too long (max 200 characters)');
    if (body.length > 1000) throw ArgumentError('Body too long (max 1000 characters)');

    // Prevent potential XSS by checking for suspicious content
    final suspiciousPattern = RegExp(r'<[^>]*>|javascript:|data:|vbscript:', caseSensitive: false);
    if (suspiciousPattern.hasMatch(title) || suspiciousPattern.hasMatch(body)) {
      throw ArgumentError('Invalid characters in notification content');
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('Not authenticated');

    // Create notification document
    final notificationRef = FirebaseFirestore.instance.collection('notifications').doc();
    await notificationRef.set({
      'type': 'global',
      'title': title.trim(),
      'body': body.trim(),
      'createdByUid': currentUser.uid,
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });

    // Send banner notification
    await FirebaseFirestore.instance
        .collection('app')
        .doc('global_banner')
        .set({
      'title': title.trim(),
      'body': body.trim(),
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });

    // Send system messages to all users if requested
    if (sendAsSystemMessage) {
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('public_users')
          .get();

      final message = 'Global Notification: $title\n\n$body';
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        await EventService.sendSystemMessage(
          userId: userId,
          message: message,
          eventId: 'global',
        );
      }
    }

    // Trigger GitHub Actions for push notifications
    if (GitHubAppService.instance.isConfigured) {
      await GitHubAppService.instance.triggerNotificationDispatch(notificationRef.id);
    }

    // Audit log the global notification
    try {
      await AuditLogger.logNotificationAction(
        action: 'send_global',
        notificationId: notificationRef.id,
        title: title,
        recipientCount: sendAsSystemMessage ? null : null, // Could count users if needed
      );
    } catch (e) {
      // Audit logging failure shouldn't block notification sending
      // Silently continue - logging failures don't affect core functionality
    }
  }
}