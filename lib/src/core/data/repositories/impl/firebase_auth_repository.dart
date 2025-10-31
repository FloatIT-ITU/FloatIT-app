import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/core/data/repositories/auth_repository.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Firebase implementation of AuthRepository
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;

  const FirebaseAuthRepository(this._firebaseAuth);

  @override
  Future<Result<UserCredential>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.right(userCredential);
    } on FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthExceptionToFailure(e);
      return Result.left(failure);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  Future<Result<UserCredential>> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.right(userCredential);
    } on FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthExceptionToFailure(e);
      return Result.left(failure);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return Result.right(null);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return Result.right(null);
    } on FirebaseAuthException catch (e) {
      final failure = _mapFirebaseAuthExceptionToFailure(e);
      return Result.left(failure);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  Future<Result<void>> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return Result.right(null);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  Future<Result<void>> deleteUser() async {
    try {
      await _firebaseAuth.currentUser?.delete();
      return Result.right(null);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  Future<Result<bool>> isEmailVerified() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return Result.left(AuthFailure.userNotFound());
      return Result.right(user.emailVerified);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  Future<Result<void>> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
      return Result.right(null);
    } catch (e) {
      return Result.left(AuthFailure.unknown());
    }
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Stream<User?> get userChanges => _firebaseAuth.userChanges();

  /// Map Firebase Auth exceptions to domain failures
  AuthFailure _mapFirebaseAuthExceptionToFailure(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthFailure.userNotFound();
      case 'wrong-password':
        return AuthFailure.wrongPassword();
      case 'invalid-email':
        return AuthFailure.invalidEmail();
      case 'user-disabled':
        return AuthFailure.userDisabled();
      case 'weak-password':
        return AuthFailure.weakPassword();
      case 'email-already-in-use':
        return AuthFailure('Email already in use', code: e.code);
      case 'operation-not-allowed':
        return AuthFailure('Operation not allowed', code: e.code);
      case 'network-request-failed':
        return AuthFailure.networkError();
      default:
        return AuthFailure.unknown();
    }
  }
}
