import 'package:floatit/src/core/data/repositories/user_repository.dart';
import 'package:floatit/src/core/domain/entities/user.dart';
import 'package:floatit/src/shared/utils/either.dart';
import 'package:floatit/src/shared/errors/failures.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  final UserRepository _userRepository;

  const GetCurrentUserUseCase(this._userRepository);

  Future<Result<User?>> call() {
    return _userRepository.getCurrentUser();
  }
}

/// Use case for getting user by ID
class GetUserByIdUseCase {
  final UserRepository _userRepository;

  const GetUserByIdUseCase(this._userRepository);

  Future<Result<User>> call(String userId) {
    return _userRepository.getUserById(userId);
  }
}

/// Use case for getting public user by ID
class GetPublicUserByIdUseCase {
  final UserRepository _userRepository;

  const GetPublicUserByIdUseCase(this._userRepository);

  Future<Result<User>> call(String userId) {
    return _userRepository.getPublicUserById(userId);
  }
}

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final UserRepository _userRepository;

  const UpdateUserProfileUseCase(this._userRepository);

  Future<Result<void>> call(User user) async {
    // Validate user data before updating
    final validationError = User.validate(
      email: user.email,
      displayName: user.displayName,
      occupation: user.occupation,
      iconColor: user.iconColor,
    );

    if (validationError != null) {
      return Either.left(ValidationFailure(validationError));
    }

    // Sanitize user data
    final sanitizedUser = user.sanitize();

    return _userRepository.updateUserProfile(sanitizedUser);
  }
}

/// Use case for getting admin users
class GetAdminUsersUseCase {
  final UserRepository _userRepository;

  const GetAdminUsersUseCase(this._userRepository);

  Future<Result<List<User>>> call() {
    return _userRepository.getAdminUsers();
  }
}

/// Use case for checking if user document exists
class UserDocumentExistsUseCase {
  final UserRepository _userRepository;

  const UserDocumentExistsUseCase(this._userRepository);

  Future<Result<bool>> call(String userId) {
    return _userRepository.userDocumentExists(userId);
  }
}

/// Use case for creating user document
class CreateUserDocumentUseCase {
  final UserRepository _userRepository;

  const CreateUserDocumentUseCase(this._userRepository);

  Future<Result<void>> call(User user) {
    return _userRepository.createUserDocument(user);
  }
}