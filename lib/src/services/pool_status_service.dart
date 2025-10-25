import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service to fetch pool status from Sundby Bad website
class PoolStatusService {
  static const String _cloudFunctionUrl = 'https://us-central1-floatit-app.cloudfunctions.net/getPoolStatus';
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const Duration _requestTimeout = Duration(seconds: 10);
  
  DateTime? _lastFetchTime;
  String? _cachedStatus;
  
  /// Fetch the current pool status from the website via Cloud Function
  /// Returns null if unable to fetch or parse the status
  Future<String?> fetchPoolStatus() async {
    // Return cached status if still valid
    if (_cachedStatus != null && _lastFetchTime != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceLastFetch < _cacheDuration) {
        return _cachedStatus;
      }
    }
    
    try {
      final response = await http.get(
        Uri.parse(_cloudFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(_requestTimeout);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'] as String?;
        if (status != null && status.isNotEmpty) {
          _cachedStatus = status;
          _lastFetchTime = DateTime.now();
          return status;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('PoolStatus: Error fetching from Cloud Function: $e');
      }
    }
    
    return null;
  }
  
  /// Check if the status indicates normal operation
  bool isNormalStatus(String? status) {
    if (status == null) return true; // Default to normal if unknown
    return status.toLowerCase().contains('normal');
  }
  
  /// Clear the cache to force a fresh fetch on next request
  void clearCache() {
    _cachedStatus = null;
    _lastFetchTime = null;
  }
}
