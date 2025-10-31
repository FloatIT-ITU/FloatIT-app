import 'package:flutter/material.dart';

/// Domain entity representing an attendee with their profile information
class Attendee {
  final String id;
  final String name;
  final String? occupation;
  final Color color;
  final bool isAdmin;
  final String? avatarUrl;

  const Attendee({
    required this.id,
    required this.name,
    this.occupation,
    this.color = Colors.blue,
    this.isAdmin = false,
    this.avatarUrl,
  });

  /// Create a copy with modified fields
  Attendee copyWith({
    String? id,
    String? name,
    String? occupation,
    Color? color,
    bool? isAdmin,
    String? avatarUrl,
  }) {
    return Attendee(
      id: id ?? this.id,
      name: name ?? this.name,
      occupation: occupation ?? this.occupation,
      color: color ?? this.color,
      isAdmin: isAdmin ?? this.isAdmin,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  /// Create from user data (used when building attendee lists)
  factory Attendee.fromUserData(
      String id, Map<String, dynamic> userData, bool isAdmin) {
    return Attendee(
      id: id,
      name: userData['displayName'] as String? ?? 'Unknown',
      occupation: userData['occupation'] as String?,
      color: _colorFromDynamic(userData['iconColor']),
      isAdmin: isAdmin,
    );
  }

  /// Convert color value from dynamic (int or hex string) to Color
  static Color _colorFromDynamic(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    }
    if (colorValue is String) {
      final hexValue = colorValue.replaceFirst('#', '');
      if (hexValue.length == 6) {
        return Color(int.parse('FF$hexValue', radix: 16));
      } else if (hexValue.length == 8) {
        return Color(int.parse(hexValue, radix: 16));
      }
    }
    return Colors.blue; // Default color
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendee &&
        other.id == id &&
        other.name == name &&
        other.occupation == occupation &&
        other.color == color &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        occupation.hashCode ^
        color.hashCode ^
        isAdmin.hashCode;
  }

  @override
  String toString() {
    return 'Attendee(id: $id, name: $name, isAdmin: $isAdmin)';
  }
}
