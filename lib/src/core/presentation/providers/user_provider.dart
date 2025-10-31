import 'package:flutter/material.dart';
import 'package:floatit/src/core/di/dependency_injection.dart';
import 'package:floatit/src/core/domain/entities/user.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/error_message_utils.dart';

/// Enhanced user profile provider with clean architecture
class UserProvider extends ChangeNotifier {
  final _di = DependencyInjection.instance;

  User? _currentUser;
  bool _isLoading = false;
  Failure? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  bool get hasError => _error != null;

  /// Get user-friendly error message
  String? get errorMessage =>
      _error != null ? ErrorMessageUtils.getUserFriendlyMessage(_error!) : null;

  /// Load current user profile
  Future<void> loadCurrentUser() async {
    _setLoading(true);
    _clearError();

    final result = await _di.getCurrentUserUseCase();

    result.fold(
      (failure) => _setError(failure),
      (user) {
        _currentUser = user;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Update user profile
  Future<void> updateProfile(User user) async {
    _setLoading(true);
    _clearError();

    final result = await _di.updateUserProfileUseCase(user);

    result.fold(
      (failure) => _setError(failure),
      (_) {
        _currentUser = user;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Check if user document exists and create if needed
  Future<bool> ensureUserDocumentExists() async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    final existsResult = await _di.userDocumentExistsUseCase(_currentUser!.id);

    final exists = existsResult.fold(
      (failure) {
        _setError(failure);
        return false;
      },
      (exists) => exists,
    );

    if (!exists) {
      // Create user document
      final createResult = await _di.createUserDocumentUseCase(_currentUser!);
      createResult.fold(
        (failure) => _setError(failure),
        (_) => null,
      );
    }

    _setLoading(false);
    return exists || !hasError;
  }

  /// Clear current user (logout)
  void clearUser() {
    _currentUser = null;
    _clearError();
    notifyListeners();
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    await loadCurrentUser();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(Failure error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
