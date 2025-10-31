import 'package:flutter/material.dart';

/// Domain entity representing a notification banner
class NotificationBanner {
  final String id;
  final String title;
  final String? body;
  final Color backgroundColor;
  final bool isGlobal;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const NotificationBanner({
    required this.id,
    required this.title,
    this.body,
    required this.backgroundColor,
    this.isGlobal = false,
    this.createdAt,
    this.expiresAt,
  });

  /// Validate title
  static bool isValidTitle(String title) {
    return title.trim().isNotEmpty && title.length <= 100;
  }

  /// Validate body
  static bool isValidBody(String? body) {
    if (body == null) return true;
    return body.length <= 500;
  }

  /// Validate expiration date
  static bool isValidExpirationDate(DateTime? expiresAt) {
    if (expiresAt == null) return true;
    return expiresAt.isAfter(DateTime.now());
  }

  /// Validate banner data
  static String? validate({
    required String title,
    String? body,
    DateTime? expiresAt,
  }) {
    if (!isValidTitle(title)) {
      return 'Title must be 1-100 characters';
    }

    if (!isValidBody(body)) {
      return 'Body must be 500 characters or less';
    }

    if (!isValidExpirationDate(expiresAt)) {
      return 'Expiration date must be in the future';
    }

    return null; // Valid
  }

  /// Sanitize banner input
  NotificationBanner sanitize() {
    return copyWith(
      title: title.trim(),
      body: body?.trim(),
    );
  }

  /// Create a copy with modified fields
  NotificationBanner copyWith({
    String? id,
    String? title,
    String? body,
    Color? backgroundColor,
    bool? isGlobal,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return NotificationBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isGlobal: isGlobal ?? this.isGlobal,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Check if banner is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if banner has content
  bool get hasContent {
    return title.trim().isNotEmpty || (body?.trim().isNotEmpty ?? false);
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'backgroundColor': backgroundColor.value,
      'isGlobal': isGlobal,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory NotificationBanner.fromJson(String id, Map<String, dynamic> json) {
    return NotificationBanner(
      id: id,
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      backgroundColor:
          Color(json['backgroundColor'] as int? ?? Colors.orange.value),
      isGlobal: json['isGlobal'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationBanner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationBanner(id: $id, title: $title, isGlobal: $isGlobal)';
  }
}
