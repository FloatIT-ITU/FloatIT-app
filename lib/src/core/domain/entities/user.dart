/// Domain entity representing a user in the system
class User {
  final String id;
  final String email;
  final String? displayName;
  final String? occupation;
  final int? iconColor;
  final bool isAdmin;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.occupation,
    this.iconColor,
    this.isAdmin = false,
    this.createdAt,
  });

  /// Email validation regex
  static final RegExp _emailRegex = RegExp(
    r'^[^@]+@[^@]+\.[^@]+$',
  );

  /// Validate email format
  static bool isValidEmail(String email) {
    return email.isNotEmpty && _emailRegex.hasMatch(email);
  }

  /// Validate display name
  static bool isValidDisplayName(String? displayName) {
    if (displayName == null) return true;
    return displayName.trim().isNotEmpty && displayName.length <= 50;
  }

  /// Validate occupation
  static bool isValidOccupation(String? occupation) {
    if (occupation == null) return true;
    return occupation.trim().isNotEmpty && occupation.length <= 100;
  }

  /// Validate icon color
  static bool isValidIconColor(int? iconColor) {
    if (iconColor == null) return true;
    return iconColor >= 0 && iconColor <= 0xFFFFFFFF;
  }

  /// Validate user data
  static String? validate({
    required String email,
    String? displayName,
    String? occupation,
    int? iconColor,
  }) {
    if (!isValidEmail(email)) {
      return 'Invalid email format';
    }

    if (!isValidDisplayName(displayName)) {
      return 'Display name must be 1-50 characters';
    }

    if (!isValidOccupation(occupation)) {
      return 'Occupation must be 1-100 characters';
    }

    if (!isValidIconColor(iconColor)) {
      return 'Invalid icon color';
    }

    return null; // Valid
  }

  /// Sanitize user input
  User sanitize() {
    return copyWith(
      email: email.toLowerCase().trim(),
      displayName: displayName?.trim(),
      occupation: occupation?.trim(),
    );
  }

  /// Create a copy with modified fields
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? occupation,
    int? iconColor,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      occupation: occupation ?? this.occupation,
      iconColor: iconColor ?? this.iconColor,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'occupation': occupation,
      'iconColor': iconColor,
      'admin': isAdmin,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory User.fromJson(String id, Map<String, dynamic> json) {
    return User(
      id: id,
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String?,
      occupation: json['occupation'] as String?,
      iconColor: json['iconColor'] as int?,
      isAdmin: json['admin'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.email == email &&
        other.displayName == displayName &&
        other.occupation == occupation &&
        other.iconColor == iconColor &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        displayName.hashCode ^
        occupation.hashCode ^
        iconColor.hashCode ^
        isAdmin.hashCode;
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, isAdmin: $isAdmin)';
  }
}