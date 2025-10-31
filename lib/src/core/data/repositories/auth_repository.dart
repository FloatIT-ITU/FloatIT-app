import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<UserCredential>> signInWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign up with email and password
  Future<Result<UserCredential>> createUserWithEmailAndPassword(
    String email,
    String password,
  );

  /// Sign out current user
  Future<Result<void>> signOut();

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Reload current user
  Future<Result<void>> reloadUser();

  /// Delete current user account
  Future<Result<void>> deleteUser();

  /// Check if email is verified
  Future<Result<bool>> isEmailVerified();

  /// Send email verification
  Future<Result<void>> sendEmailVerification();

  /// Get current user
  User? get currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Stream of user changes
  Stream<User?> get userChanges;
}
