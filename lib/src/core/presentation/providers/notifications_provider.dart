import 'package:flutter/material.dart';
import 'package:floatit/src/core/di/dependency_injection.dart';
import 'package:floatit/src/core/domain/entities/notification_banner.dart';
import 'package:floatit/src/shared/errors/failures.dart';
import 'package:floatit/src/shared/utils/error_message_utils.dart';

/// Enhanced notifications provider with clean architecture
class NotificationsProvider extends ChangeNotifier {
  final _di = DependencyInjection.instance;

  NotificationBanner? _globalBanner;
  final Map<String, NotificationBanner> _eventBanners = {};
  bool _isLoading = false;
  Failure? _error;

  NotificationBanner? get globalBanner => _globalBanner;
  Map<String, NotificationBanner> get eventBanners => _eventBanners;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  bool get hasError => _error != null;

  /// Get user-friendly error message
  String? get errorMessage =>
      _error != null ? ErrorMessageUtils.getUserFriendlyMessage(_error!) : null;

  /// Load global banner
  Future<void> loadGlobalBanner() async {
    _setLoading(true);
    _clearError();

    final result = await _di.getGlobalBannerUseCase();

    result.fold(
      (failure) => _setError(failure),
      (banner) {
        _globalBanner = banner;
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Load event banner
  Future<void> loadEventBanner(String eventId) async {
    _setLoading(true);
    _clearError();

    final result = await _di.getEventBannerUseCase(eventId);

    result.fold(
      (failure) => _setError(failure),
      (banner) {
        if (banner != null) {
          _eventBanners[eventId] = banner;
        } else {
          _eventBanners.remove(eventId);
        }
        notifyListeners();
      },
    );

    _setLoading(false);
  }

  /// Set global banner
  Future<bool> setGlobalBanner(NotificationBanner banner) async {
    _setLoading(true);
    _clearError();

    final result = await _di.setGlobalBannerUseCase(banner);

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) {
        success = true;
        _globalBanner = banner;
        notifyListeners();
      },
    );

    _setLoading(false);
    return success;
  }

  /// Set event banner
  Future<bool> setEventBanner(String eventId, NotificationBanner banner) async {
    _setLoading(true);
    _clearError();

    final result = await _di.setEventBannerUseCase(eventId, banner);

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) {
        success = true;
        _eventBanners[eventId] = banner;
        notifyListeners();
      },
    );

    _setLoading(false);
    return success;
  }

  /// Delete global banner
  Future<bool> deleteGlobalBanner() async {
    _setLoading(true);
    _clearError();

    final result = await _di.deleteGlobalBannerUseCase();

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) {
        success = true;
        _globalBanner = null;
        notifyListeners();
      },
    );

    _setLoading(false);
    return success;
  }

  /// Delete event banner
  Future<bool> deleteEventBanner(String eventId) async {
    _setLoading(true);
    _clearError();

    final result = await _di.deleteEventBannerUseCase(eventId);

    bool success = false;
    result.fold(
      (failure) => _setError(failure),
      (_) {
        success = true;
        _eventBanners.remove(eventId);
        notifyListeners();
      },
    );

    _setLoading(false);
    return success;
  }

  /// Get banner for specific event (checks both global and event-specific)
  NotificationBanner? getBannerForEvent(String? eventId) {
    if (eventId != null && _eventBanners.containsKey(eventId)) {
      return _eventBanners[eventId];
    }
    return _globalBanner;
  }

  /// Check if there are any active banners
  bool get hasActiveBanners {
    if (_globalBanner != null && !_globalBanner!.isExpired) {
      return true;
    }
    return _eventBanners.values.any((banner) => !banner.isExpired);
  }

  /// Get all active banners
  List<NotificationBanner> get activeBanners {
    final banners = <NotificationBanner>[];

    if (_globalBanner != null && !_globalBanner!.isExpired) {
      banners.add(_globalBanner!);
    }

    banners.addAll(
      _eventBanners.values.where((banner) => !banner.isExpired),
    );

    return banners;
  }

  /// Clear all banners
  void clearBanners() {
    _globalBanner = null;
    _eventBanners.clear();
    _clearError();
    notifyListeners();
  }

  /// Refresh all banners
  Future<void> refreshBanners() async {
    await loadGlobalBanner();
    // Note: Event banners would need to be refreshed individually or in bulk
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
