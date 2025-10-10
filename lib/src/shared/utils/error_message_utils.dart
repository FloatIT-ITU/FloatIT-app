import 'package:floatit/src/shared/errors/failures.dart';

/// Utility class for converting technical failures into user-friendly messages
class ErrorMessageUtils {
  /// Convert a Failure into a user-friendly error message
  static String getUserFriendlyMessage(Failure failure) {
    if (failure is AuthFailure) {
      return _getAuthErrorMessage(failure);
    } else if (failure is DatabaseFailure) {
      return _getDatabaseErrorMessage(failure);
    } else if (failure is ValidationFailure) {
      return _getValidationErrorMessage(failure);
    } else if (failure is NetworkFailure) {
      return _getNetworkErrorMessage(failure);
    } else if (failure is AppFailure) {
      return _getAppErrorMessage(failure);
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Get user-friendly auth error messages
  static String _getAuthErrorMessage(AuthFailure failure) {
    switch (failure.code) {
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-not-verified':
        return 'Please verify your email address before signing in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'network-error':
        return 'Network connection error. Please check your internet connection.';
      default:
        return 'Sign in failed. Please try again.';
    }
  }

  /// Get user-friendly database error messages
  static String _getDatabaseErrorMessage(DatabaseFailure failure) {
    switch (failure.code) {
      case 'not-found':
        return 'The requested information could not be found.';
      case 'permission-denied':
        return 'You don\'t have permission to perform this action.';
      case 'network-error':
        return 'Database connection error. Please check your internet connection.';
      case 'quota-exceeded':
        return 'Service temporarily unavailable. Please try again later.';
      default:
        return 'Unable to load data. Please try again.';
    }
  }

  /// Get user-friendly validation error messages
  static String _getValidationErrorMessage(ValidationFailure failure) {
    final field = failure.field;
    if (field != null) {
      return '${_capitalizeFirst(field)}: ${failure.message}';
    }
    return failure.message;
  }

  /// Get user-friendly network error messages
  static String _getNetworkErrorMessage(NetworkFailure failure) {
    switch (failure.code) {
      case 'no-connection':
        return 'No internet connection. Please check your network.';
      case 'timeout':
        return 'Request timed out. Please try again.';
      case 'server-error':
        return 'Server error. Please try again later.';
      default:
        return 'Network error. Please check your connection.';
    }
  }

  /// Get user-friendly app error messages
  static String _getAppErrorMessage(AppFailure failure) {
    switch (failure.code) {
      case 'invalid-state':
        return 'Application error. Please restart the app.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  /// Capitalize the first letter of a string
  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Get a retry action message based on the failure type
  static String getRetryActionMessage(Failure failure) {
    if (failure is NetworkFailure || failure is DatabaseFailure && failure.code == 'network-error') {
      return 'Check your internet connection and try again.';
    } else if (failure is AuthFailure) {
      return 'Please check your credentials and try again.';
    } else {
      return 'Try again or contact support if the problem persists.';
    }
  }
}