import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:floatit/src/services/pool_status_service.dart';

/// Provider for managing pool status state across the app
class PoolStatusProvider extends ChangeNotifier {
  final PoolStatusService _service = PoolStatusService();
  Timer? _refreshTimer;

  String? _currentStatus;
  bool _isLoading = false;
  DateTime? _lastUpdateTime;

  static const Duration _refreshInterval = Duration(minutes: 15);

  PoolStatusProvider() {
    // Fetch initial status
    fetchStatus();

    // Set up periodic refresh
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      fetchStatus();
    });
  }

  /// The current pool status text
  String? get currentStatus => _currentStatus;

  /// Whether the provider is currently fetching status
  bool get isLoading => _isLoading;

  /// When the status was last updated
  DateTime? get lastUpdateTime => _lastUpdateTime;

  /// Whether the current status indicates normal operation
  bool get isNormalStatus => _service.isNormalStatus(_currentStatus);

  /// Fetch the latest pool status
  Future<void> fetchStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final status = await _service.fetchPoolStatus();
      if (status != null) {
        _currentStatus = status;
        _lastUpdateTime = DateTime.now();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching pool status: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Force a refresh by clearing the cache and fetching again
  /// Returns true if refresh was allowed, false if rate limited
  Future<bool> forceRefresh(String userId) async {
    // Rate limiting is now handled at the UI level
    _service.clearCache();
    await fetchStatus();
    return true;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
