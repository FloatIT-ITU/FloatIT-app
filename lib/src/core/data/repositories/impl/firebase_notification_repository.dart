import 'package:floatit/src/core/data/repositories/notification_repository.dart';
import 'package:floatit/src/core/domain/entities/notification_banner.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Firebase implementation of NotificationRepository
class FirebaseNotificationRepository implements NotificationRepository {
  const FirebaseNotificationRepository();

  @override
  Future<Result<NotificationBanner?>> getGlobalBanner() async {
    try {
      final doc = await FirebaseService.globalBanner.get();
      if (!doc.exists) return Result.right(null);

      final banner = NotificationBanner.fromJson(
        doc.id,
        doc.data()! as Map<String, dynamic>,
      );
      return Result.right(banner);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<NotificationBanner?>> getEventBanner(String eventId) async {
    try {
      final doc = await FirebaseService.eventBanner(eventId).get();
      if (!doc.exists) return Result.right(null);

      final banner = NotificationBanner.fromJson(
        doc.id,
        doc.data()! as Map<String, dynamic>,
      );
      return Result.right(banner);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> setGlobalBanner(NotificationBanner banner) async {
    try {
      await FirebaseService.globalBanner.set(banner.toJson());
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> setEventBanner(String eventId, NotificationBanner banner) async {
    try {
      await FirebaseService.eventBanner(eventId).set(banner.toJson());
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> deleteGlobalBanner() async {
    try {
      await FirebaseService.globalBanner.delete();
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Future<Result<void>> deleteEventBanner(String eventId) async {
    try {
      await FirebaseService.eventBanner(eventId).delete();
      return Result.right(null);
    } catch (e) {
      return Result.left(DatabaseFailure.unknown());
    }
  }

  @override
  Stream<Result<NotificationBanner?>> watchGlobalBanner() {
    return FirebaseService.globalBanner.snapshots().map((snapshot) {
      try {
        if (!snapshot.exists) return Result.right(null);

        final banner = NotificationBanner.fromJson(
          snapshot.id,
          snapshot.data()! as Map<String, dynamic>,
        );
        return Result.right(banner);
      } catch (e) {
        return Result.left(DatabaseFailure.unknown());
      }
    });
  }

  @override
  Stream<Result<NotificationBanner?>> watchEventBanner(String eventId) {
    return FirebaseService.eventBanner(eventId).snapshots().map((snapshot) {
      try {
        if (!snapshot.exists) return Result.right(null);

        final banner = NotificationBanner.fromJson(
          snapshot.id,
          snapshot.data()! as Map<String, dynamic>,
        );
        return Result.right(banner);
      } catch (e) {
        return Result.left(DatabaseFailure.unknown());
      }
    });
  }
}