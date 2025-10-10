import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:floatit/src/core/data/repositories/user_repository.dart';
import 'package:floatit/src/core/domain/entities/user.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Firebase implementation of UserRepository
class FirebaseUserRepository implements UserRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  const FirebaseUserRepository(this._firebaseAuth);

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return Result.right(null);

      final userDoc = await FirebaseService.userDoc(firebaseUser.uid).get();
      if (!userDoc.exists) return Result.right(null);

      final user = User.fromJson(firebaseUser.uid, userDoc.data()! as Map<String, dynamic>);
      return Result.right(user);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<User>> getUserById(String userId) async {
    try {
      final userDoc = await FirebaseService.userDoc(userId).get();
      if (!userDoc.exists) {
        return Result.left(DatabaseFailure.notFound());
      }

      final user = User.fromJson(userId, userDoc.data()! as Map<String, dynamic>);
      return Result.right(user);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<User>> getPublicUserById(String userId) async {
    try {
      final publicUserDoc = await FirebaseService.publicUserDoc(userId).get();
      if (!publicUserDoc.exists) {
        return Result.left(DatabaseFailure.notFound());
      }

      final user = User.fromJson(userId, publicUserDoc.data()! as Map<String, dynamic>);
      return Result.right(user);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> updateUserProfile(User user) async {
    try {
      await FirebaseService.userDoc(user.id).update(user.toJson());
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<List<User>>> getAdminUsers() async {
    try {
      final querySnapshot = await FirebaseService.adminUsersFuture;
      final users = querySnapshot.docs.map((doc) {
        return User.fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      return Result.right(users);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<bool>> userDocumentExists(String userId) async {
    try {
      final userDoc = await FirebaseService.userDoc(userId).get();
      return Result.right(userDoc.exists);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> createUserDocument(User user) async {
    try {
      await FirebaseService.userDoc(user.id).set(user.toJson());
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Stream<Result<User?>> watchCurrentUser() {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return Result.right(null);

      try {
        final userDoc = await FirebaseService.userDoc(firebaseUser.uid).get();
        if (!userDoc.exists) return Result.right(null);

        final user = User.fromJson(firebaseUser.uid, userDoc.data()! as Map<String, dynamic>);
        return Result.right(user);
      } catch (e) {
        return Result.left(DatabaseFailure.unknown());
      }
    });
  }

  @override
  Stream<Result<User>> watchUserById(String userId) {
    return FirebaseService.userDoc(userId).snapshots().map((snapshot) {
      try {
        if (!snapshot.exists) {
          return Result.left(DatabaseFailure.notFound());
        }

        final user = User.fromJson(userId, snapshot.data()! as Map<String, dynamic>);
        return Result.right(user);
      } catch (e) {
        return Result.left(DatabaseFailure.unknown());
      }
    });
  }
}