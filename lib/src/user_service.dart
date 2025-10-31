import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  /// Check if a user has admin privileges
  /// Returns false if user document doesn't exist or on error
  static Future<bool> isAdmin(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.exists && doc.data()?['admin'] == true;
    } catch (e) {
      // Return false on error (user won't have admin access)
      return false;
    }
  }

  /// Update admin status for a user
  /// Throws FirebaseException on failure
  static Future<void> updateAdminStatus(String userId, bool isAdmin) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'admin': isAdmin,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update user occupation in public profile
  /// Throws FirebaseException on failure
  static Future<void> updateOccupation(String userId, String occupation) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    // Sanitize occupation input (basic validation)
    final sanitizedOccupation = occupation.trim();
    if (sanitizedOccupation.length > 100) {
      throw ArgumentError('Occupation must be 100 characters or less');
    }

    await FirebaseFirestore.instance
        .collection('public_users')
        .doc(userId)
        .set({
      'occupation': sanitizedOccupation,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Update user display name in public profile
  /// Throws FirebaseException on failure
  static Future<void> updateDisplayName(
      String userId, String displayName) async {
    if (userId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }

    // Sanitize display name input (basic validation)
    final sanitizedName = displayName.trim();
    if (sanitizedName.isEmpty) {
      throw ArgumentError('Display name cannot be empty');
    }
    if (sanitizedName.length > 50) {
      throw ArgumentError('Display name must be 50 characters or less');
    }

    await FirebaseFirestore.instance
        .collection('public_users')
        .doc(userId)
        .set({
      'displayName': sanitizedName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
