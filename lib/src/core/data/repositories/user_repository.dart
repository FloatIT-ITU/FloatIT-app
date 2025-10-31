import 'package:floatit/src/core/domain/entities/user.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Abstract repository for user data operations
abstract class UserRepository {
  /// Get current authenticated user
  Future<Result<User?>> getCurrentUser();

  /// Get user by ID
  Future<Result<User>> getUserById(String userId);

  /// Get public user data by ID
  Future<Result<User>> getPublicUserById(String userId);

  /// Update user profile
  Future<Result<void>> updateUserProfile(User user);

  /// Get all admin users
  Future<Result<List<User>>> getAdminUsers();

  /// Check if user document exists
  Future<Result<bool>> userDocumentExists(String userId);

  /// Create user document
  Future<Result<void>> createUserDocument(User user);

  /// Stream of current user changes
  Stream<Result<User?>> watchCurrentUser();

  /// Stream of user changes by ID
  Stream<Result<User>> watchUserById(String userId);
}
