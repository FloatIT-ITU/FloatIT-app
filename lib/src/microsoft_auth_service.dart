import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'auth_utils.dart';

/// Service for handling Microsoft OAuth authentication
class MicrosoftAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Sign in with Microsoft account
  /// Returns UserCredential on success, throws FirebaseAuthException on error
  Future<UserCredential> signInWithMicrosoft() async {
    try {
      // Create Microsoft OAuth provider
      final provider = OAuthProvider('microsoft.com');

      // Optional: Add scopes for additional permissions
      provider.addScope('email');
      provider.addScope('profile');

      // Optional: Set custom parameters
      // For ITU-only login, we can add a domain hint
      provider.setCustomParameters({
        'tenant': 'common', // Allows any Microsoft account (personal or org)
        'prompt': 'select_account', // Always show account picker
        // Uncomment below if ITU has a specific tenant ID:
        // 'domain_hint': 'itu.dk',
      });

      // Sign in with popup on web, redirect on mobile
      UserCredential userCredential;
      if (kIsWeb) {
        userCredential = await _firebaseAuth.signInWithPopup(provider);
      } else {
        userCredential = await _firebaseAuth.signInWithProvider(provider);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Microsoft sign-in error: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Validate that the signed-in user has an @itu.dk email
  /// Signs out the user if validation fails
  Future<bool> validateItuEmail(User user) async {
    final email = user.email;

    if (email == null || !AuthUtils.isItuEmail(email)) {
      if (kDebugMode) {
        print('Microsoft sign-in: Non-ITU email detected: $email');
      }

      // Sign out the user
      await _firebaseAuth.signOut();
      return false;
    }

    if (AuthUtils.isForbiddenEmail(email)) {
      if (kDebugMode) {
        print('Microsoft sign-in: Forbidden email detected: $email');
      }

      // Sign out the user
      await _firebaseAuth.signOut();
      return false;
    }

    return true;
  }
}
