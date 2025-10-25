import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Enhanced audit logging service for admin actions and security events
class AuditLogger {
  static const String _collection = 'audit_logs';

  /// Log an admin action
  static Future<void> logAdminAction({
    required String action,
    required String targetUserId,
    required String details,
    Map<String, dynamic>? additionalData,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final logData = {
      'timestamp': FieldValue.serverTimestamp(),
      'adminUid': currentUser.uid,
      'adminEmail': currentUser.email,
      'action': action,
      'targetUserId': targetUserId,
      'details': details,
      'ipAddress': null, // Would need server-side implementation
      'userAgent': null, // Would need server-side implementation
      'additionalData': additionalData ?? {},
    };

    await FirebaseFirestore.instance.collection(_collection).add(logData);
  }

  /// Log user management actions
  static Future<void> logUserManagement({
    required String action,
    required String targetUserId,
    required String targetUserEmail,
    String? oldValue,
    String? newValue,
  }) async {
    await logAdminAction(
      action: 'user_management',
      targetUserId: targetUserId,
      details: '$action performed on user $targetUserEmail',
      additionalData: {
        'managementAction': action,
        'targetUserEmail': targetUserEmail,
        'oldValue': oldValue,
        'newValue': newValue,
      },
    );
  }

  /// Log event management actions
  static Future<void> logEventManagement({
    required String action,
    required String eventId,
    required String eventName,
    Map<String, dynamic>? changes,
  }) async {
    await logAdminAction(
      action: 'event_management',
      targetUserId: 'system', // System-level action
      details: '$action performed on event: $eventName',
      additionalData: {
        'eventId': eventId,
        'eventName': eventName,
        'changes': changes,
      },
    );
  }

  /// Log notification actions
  static Future<void> logNotificationAction({
    required String action,
    required String notificationId,
    required String title,
    int? recipientCount,
  }) async {
    await logAdminAction(
      action: 'notification_management',
      targetUserId: 'system',
      details: '$action notification: $title',
      additionalData: {
        'notificationId': notificationId,
        'title': title,
        'recipientCount': recipientCount,
      },
    );
  }

  /// Log security events
  static Future<void> logSecurityEvent({
    required String eventType,
    required String description,
    String? targetUserId,
    Map<String, dynamic>? eventData,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final logData = {
      'timestamp': FieldValue.serverTimestamp(),
      'userUid': currentUser.uid,
      'userEmail': currentUser.email,
      'eventType': eventType,
      'description': description,
      'targetUserId': targetUserId,
      'eventData': eventData ?? {},
      'severity': _getSeverityLevel(eventType),
    };

    await FirebaseFirestore.instance.collection(_collection).add(logData);
  }

  /// Log authentication events
  static Future<void> logAuthEvent({
    required String eventType,
    required String description,
    Map<String, dynamic>? eventData,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final logData = {
      'timestamp': FieldValue.serverTimestamp(),
      'userUid': currentUser?.uid,
      'userEmail': currentUser?.email,
      'eventType': eventType,
      'description': description,
      'eventData': eventData ?? {},
      'severity': _getSeverityLevel(eventType),
    };

    await FirebaseFirestore.instance.collection(_collection).add(logData);
  }

  /// Get severity level for different event types
  static String _getSeverityLevel(String eventType) {
    switch (eventType) {
      case 'admin_privilege_granted':
      case 'admin_privilege_revoked':
      case 'suspicious_login':
      case 'failed_admin_action':
        return 'high';
      case 'user_profile_updated':
      case 'event_created':
      case 'notification_sent':
        return 'medium';
      case 'successful_login':
      case 'user_registered':
        return 'low';
      default:
        return 'info';
    }
  }

  /// Clean up old audit logs (keep last 90 days)
  static Future<void> cleanupOldLogs() async {
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));
    final query = FirebaseFirestore.instance
        .collection(_collection)
        .where('timestamp', isLessThan: Timestamp.fromDate(ninetyDaysAgo));

    final snapshot = await query.get();
    final batch = FirebaseFirestore.instance.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}