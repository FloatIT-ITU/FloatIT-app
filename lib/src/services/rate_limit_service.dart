import 'package:flutter/foundation.dart';

/// Service for rate limiting user actions to prevent spam
/// Tracks when users last performed specific actions and enforces cooldown periods
class RateLimitService {
  // Singleton pattern
  RateLimitService._();
  static final RateLimitService instance = RateLimitService._();

  // Map of userId -> action -> last action timestamp
  final Map<String, Map<String, DateTime>> _lastActionTimes = {};

  // Cooldown durations for different actions
  static const Duration _eventActionCooldown = Duration(seconds: 3);
  static const Duration _poolRefreshCooldown = Duration(seconds: 10);
  static const Duration _profileUpdateCooldown = Duration(seconds: 2);

  /// Check if an action is allowed for a user
  /// Returns true if allowed, false if still in cooldown
  bool isActionAllowed(String userId, String actionType) {
    if (!_lastActionTimes.containsKey(userId)) {
      return true;
    }

    final userActions = _lastActionTimes[userId]!;
    if (!userActions.containsKey(actionType)) {
      return true;
    }

    final lastActionTime = userActions[actionType]!;
    final cooldownDuration = _getCooldownDuration(actionType);
    final timeSinceLastAction = DateTime.now().difference(lastActionTime);

    return timeSinceLastAction >= cooldownDuration;
  }

  /// Record that a user has performed an action
  void recordAction(String userId, String actionType) {
    if (!_lastActionTimes.containsKey(userId)) {
      _lastActionTimes[userId] = {};
    }
    _lastActionTimes[userId]![actionType] = DateTime.now();
  }

  /// Get remaining cooldown time in seconds for an action
  /// Returns 0 if no cooldown is active
  int getRemainingCooldown(String userId, String actionType) {
    if (!_lastActionTimes.containsKey(userId)) {
      return 0;
    }

    final userActions = _lastActionTimes[userId]!;
    if (!userActions.containsKey(actionType)) {
      return 0;
    }

    final lastActionTime = userActions[actionType]!;
    final cooldownDuration = _getCooldownDuration(actionType);
    final timeSinceLastAction = DateTime.now().difference(lastActionTime);
    final remainingDuration = cooldownDuration - timeSinceLastAction;

    if (remainingDuration.isNegative) {
      return 0;
    }

    return remainingDuration.inSeconds;
  }

  /// Clear all rate limit data for a user (useful when they sign out)
  void clearUserData(String userId) {
    _lastActionTimes.remove(userId);
  }

  /// Clear all rate limit data
  void clearAll() {
    _lastActionTimes.clear();
  }

  /// Get cooldown duration for a specific action type
  Duration _getCooldownDuration(String actionType) {
    switch (actionType) {
      case RateLimitAction.joinEvent:
      case RateLimitAction.leaveEvent:
        return _eventActionCooldown;
      case RateLimitAction.poolRefresh:
        return _poolRefreshCooldown;
      case RateLimitAction.updateDisplayName:
      case RateLimitAction.updateOccupation:
      case RateLimitAction.updateIconColor:
        return _profileUpdateCooldown;
      default:
        if (kDebugMode) {
          print('Unknown action type: $actionType, using default cooldown');
        }
        return const Duration(seconds: 2);
    }
  }
}

/// Action type constants for rate limiting
class RateLimitAction {
  static const String joinEvent = 'join_event';
  static const String leaveEvent = 'leave_event';
  static const String poolRefresh = 'pool_refresh';
  static const String updateDisplayName = 'update_display_name';
  static const String updateOccupation = 'update_occupation';
  static const String updateIconColor = 'update_icon_color';
}
