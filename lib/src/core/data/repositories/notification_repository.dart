import 'package:floatit/src/core/domain/entities/notification_banner.dart';
import 'package:floatit/src/shared/utils/either.dart';

/// Abstract repository for notification data operations
abstract class NotificationRepository {
  /// Get global notification banner
  Future<Result<NotificationBanner?>> getGlobalBanner();

  /// Get event-specific notification banner
  Future<Result<NotificationBanner?>> getEventBanner(String eventId);

  /// Create or update global banner
  Future<Result<void>> setGlobalBanner(NotificationBanner banner);

  /// Create or update event banner
  Future<Result<void>> setEventBanner(
      String eventId, NotificationBanner banner);

  /// Delete global banner
  Future<Result<void>> deleteGlobalBanner();

  /// Delete event banner
  Future<Result<void>> deleteEventBanner(String eventId);

  /// Stream of global banner changes
  Stream<Result<NotificationBanner?>> watchGlobalBanner();

  /// Stream of event banner changes
  Stream<Result<NotificationBanner?>> watchEventBanner(String eventId);
}
