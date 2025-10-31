import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/core/data/repositories/auth_repository.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Use case for signing in with email and password
class SignInUseCase {
  final AuthRepository _authRepository;

  const SignInUseCase(this._authRepository);

  Future<Result<UserCredential>> call(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }
}

/// Use case for signing up with email and password
class SignUpUseCase {
  final AuthRepository _authRepository;

  const SignUpUseCase(this._authRepository);

  Future<Result<UserCredential>> call(String email, String password) {
    return _authRepository.createUserWithEmailAndPassword(email, password);
  }
}

/// Use case for signing out
class SignOutUseCase {
  final AuthRepository _authRepository;

  const SignOutUseCase(this._authRepository);

  Future<Result<void>> call() {
    return _authRepository.signOut();
  }
}

/// Use case for sending password reset email
class SendPasswordResetUseCase {
  final AuthRepository _authRepository;

  const SendPasswordResetUseCase(this._authRepository);

  Future<Result<void>> call(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }
}

/// Use case for checking email verification status
class IsEmailVerifiedUseCase {
  final AuthRepository _authRepository;

  const IsEmailVerifiedUseCase(this._authRepository);

  Future<Result<bool>> call() {
    return _authRepository.isEmailVerified();
  }
}

/// Use case for sending email verification
class SendEmailVerificationUseCase {
  final AuthRepository _authRepository;

  const SendEmailVerificationUseCase(this._authRepository);

  Future<Result<void>> call() {
    return _authRepository.sendEmailVerification();
  }
}
