import 'package:floatit/src/core/data/repositories/notification_repository.dart';
import 'package:floatit/src/core/domain/entities/notification_banner.dart';
import 'package:floatit/src/shared/utils/either.dart';
import 'package:floatit/src/shared/errors/failures.dart';

/// Use case for getting global banner
class GetGlobalBannerUseCase {
  final NotificationRepository _notificationRepository;

  const GetGlobalBannerUseCase(this._notificationRepository);

  Future<Result<NotificationBanner?>> call() {
    return _notificationRepository.getGlobalBanner();
  }
}

/// Use case for getting event banner
class GetEventBannerUseCase {
  final NotificationRepository _notificationRepository;

  const GetEventBannerUseCase(this._notificationRepository);

  Future<Result<NotificationBanner?>> call(String eventId) {
    return _notificationRepository.getEventBanner(eventId);
  }
}

/// Use case for setting global banner
class SetGlobalBannerUseCase {
  final NotificationRepository _notificationRepository;

  const SetGlobalBannerUseCase(this._notificationRepository);

  Future<Result<void>> call(NotificationBanner banner) async {
    // Validate banner data before setting
    final validationError = NotificationBanner.validate(
      title: banner.title,
      body: banner.body,
      expiresAt: banner.expiresAt,
    );

    if (validationError != null) {
      return Either.left(ValidationFailure(validationError));
    }

    // Sanitize banner data
    final sanitizedBanner = banner.sanitize();

    return _notificationRepository.setGlobalBanner(sanitizedBanner);
  }
}

/// Use case for setting event banner
class SetEventBannerUseCase {
  final NotificationRepository _notificationRepository;

  const SetEventBannerUseCase(this._notificationRepository);

  Future<Result<void>> call(String eventId, NotificationBanner banner) async {
    // Validate banner data before setting
    final validationError = NotificationBanner.validate(
      title: banner.title,
      body: banner.body,
      expiresAt: banner.expiresAt,
    );

    if (validationError != null) {
      return Either.left(ValidationFailure(validationError));
    }

    // Sanitize banner data
    final sanitizedBanner = banner.sanitize();

    return _notificationRepository.setEventBanner(eventId, sanitizedBanner);
  }
}

/// Use case for deleting global banner
class DeleteGlobalBannerUseCase {
  final NotificationRepository _notificationRepository;

  const DeleteGlobalBannerUseCase(this._notificationRepository);

  Future<Result<void>> call() {
    return _notificationRepository.deleteGlobalBanner();
  }
}

/// Use case for deleting event banner
class DeleteEventBannerUseCase {
  final NotificationRepository _notificationRepository;

  const DeleteEventBannerUseCase(this._notificationRepository);

  Future<Result<void>> call(String eventId) {
    return _notificationRepository.deleteEventBanner(eventId);
  }
}