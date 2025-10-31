/// Base class for all app failures
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  factory AuthFailure.userNotFound() =>
      const AuthFailure('User not found', code: 'user-not-found');

  factory AuthFailure.wrongPassword() =>
      const AuthFailure('Incorrect password', code: 'wrong-password');

  factory AuthFailure.emailNotVerified() =>
      const AuthFailure('Email not verified', code: 'email-not-verified');

  factory AuthFailure.invalidEmail() =>
      const AuthFailure('Invalid email address', code: 'invalid-email');

  factory AuthFailure.weakPassword() =>
      const AuthFailure('Password is too weak', code: 'weak-password');

  factory AuthFailure.userDisabled() =>
      const AuthFailure('Account has been disabled', code: 'user-disabled');

  factory AuthFailure.networkError() =>
      const AuthFailure('Network connection error', code: 'network-error');

  factory AuthFailure.unknown() =>
      const AuthFailure('An unknown authentication error occurred');
}

/// Firestore/database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});

  factory DatabaseFailure.notFound() =>
      const DatabaseFailure('Document not found', code: 'not-found');

  factory DatabaseFailure.permissionDenied() =>
      const DatabaseFailure('Permission denied', code: 'permission-denied');

  factory DatabaseFailure.networkError() =>
      const DatabaseFailure('Database connection error', code: 'network-error');

  factory DatabaseFailure.quotaExceeded() =>
      const DatabaseFailure('Database quota exceeded', code: 'quota-exceeded');

  factory DatabaseFailure.unknown() =>
      const DatabaseFailure('An unknown database error occurred');
}

/// Validation failures
class ValidationFailure extends Failure {
  final String? field;

  const ValidationFailure(super.message, {this.field, super.code});

  @override
  String toString() =>
      'ValidationFailure${field != null ? ' in $field' : ''}: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});

  factory NetworkFailure.noConnection() =>
      const NetworkFailure('No internet connection', code: 'no-connection');

  factory NetworkFailure.timeout() =>
      const NetworkFailure('Request timeout', code: 'timeout');

  factory NetworkFailure.serverError() =>
      const NetworkFailure('Server error', code: 'server-error');
}

/// Generic app failures
class AppFailure extends Failure {
  const AppFailure(super.message, {super.code});

  factory AppFailure.unknown() =>
      const AppFailure('An unexpected error occurred');

  factory AppFailure.invalidState() =>
      const AppFailure('Application is in an invalid state',
          code: 'invalid-state');
}
