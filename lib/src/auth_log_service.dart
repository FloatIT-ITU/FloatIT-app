import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'auth_log_service_io.dart'
    if (dart.library.html) 'auth_log_service_web.dart';

class AuthLogService {
  static Future<void> logEvent({
    required String eventType,
    required String email,
    required String? uid,
    required bool success,
    String? errorMessage,
    String? additionalInfo,
  }) async {
    final timestamp = Timestamp.now();
    String platform;
    if (kIsWeb) {
      platform = 'web';
    } else if (Platform.isAndroid) {
      platform = 'android';
    } else if (Platform.isIOS) {
      platform = 'ios';
    } else if (Platform.isMacOS) {
      platform = 'macos';
    } else if (Platform.isWindows) {
      platform = 'windows';
    } else if (Platform.isLinux) {
      platform = 'linux';
    } else {
      platform = 'unknown';
    }
    final userAgent = await getUserAgent();
    await FirebaseFirestore.instance.collection('auth_logs').add({
      'eventType': eventType,
      'email': email,
      'uid': uid,
      'timestamp': timestamp,
      'platform': platform,
      'userAgent': userAgent,
      'success': success,
      'errorMessage': errorMessage,
      'additionalInfo': additionalInfo,
    });
  }
}
