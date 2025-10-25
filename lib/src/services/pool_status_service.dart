import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

/// Service to fetch pool status from Sundby Bad website
class PoolStatusService {
  static const String _poolStatusUrl = 'https://svoemkbh.kk.dk/svoemmeanlaeg/svoemmehaller/sundby-bad';
  static const Duration _cacheDuration = Duration(minutes: 5);
  static const Duration _requestTimeout = Duration(seconds: 10);
  
  // CORS proxies to try in order (first working one is used)
  static const List<String> _corsProxies = [
    'https://api.allorigins.win/raw?url=',
    'https://cors-anywhere.herokuapp.com/',
    'https://thingproxy.freeboard.io/fetch/',
  ];
  
  DateTime? _lastFetchTime;
  String? _cachedStatus;
  
  /// Fetch the current pool status from the website
  /// Returns null if unable to fetch or parse the status
  Future<String?> fetchPoolStatus() async {
    // Return cached status if still valid
    if (_cachedStatus != null && _lastFetchTime != null) {
      final timeSinceLastFetch = DateTime.now().difference(_lastFetchTime!);
      if (timeSinceLastFetch < _cacheDuration) {
        return _cachedStatus;
      }
    }
    
    // Try each CORS proxy in order
    for (final proxy in _corsProxies) {
      final fetchUrl = '$proxy${Uri.encodeComponent(_poolStatusUrl)}';
      
      try {
        final response = await http.get(
          Uri.parse(fetchUrl),
          headers: {
            'User-Agent': 'FloatIT-App/1.0',
            'Accept': 'text/html',
          },
        ).timeout(_requestTimeout);
        
        if (response.statusCode == 200) {
          final status = _parsePoolStatus(response.body);
          if (status != null) {
            _cachedStatus = status;
            _lastFetchTime = DateTime.now();
            return status;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('PoolStatus: Error with proxy $proxy: $e');
        }
        // Continue to next proxy
        continue;
      }
    }
    
    // If all proxies failed, try direct fetch (for non-web platforms)
    if (!kIsWeb) {
      try {
        final response = await http.get(
          Uri.parse(_poolStatusUrl),
          headers: {
            'User-Agent': 'FloatIT-App/1.0',
            'Accept': 'text/html',
          },
        ).timeout(_requestTimeout);
        
        if (response.statusCode == 200) {
          final status = _parsePoolStatus(response.body);
          if (status != null) {
            _cachedStatus = status;
            _lastFetchTime = DateTime.now();
            return status;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('PoolStatus: Error with direct fetch: $e');
        }
      }
    }
    
    return null;
  }
  
  /// Parse the HTML to extract the pool status
  String? _parsePoolStatus(String htmlContent) {
    try {
      final document = html_parser.parse(htmlContent);
      
      // Find the h2 with "Driftsinfo" text
      final headers = document.querySelectorAll('h2.field--name-title');
      
      for (final header in headers) {
        final headerText = header.text.trim();
        if (headerText.toLowerCase().contains('driftsinfo')) {
          // Find the next sibling div with the status
          var nextElement = header.nextElementSibling;
          
          // Try to find the teaser field
          while (nextElement != null) {
            if (nextElement.classes.contains('field--name-teaser')) {
              final status = nextElement.text.trim();
              if (status.isNotEmpty) {
                return status;
              }
            }
            // Also check children
            final teaserDiv = nextElement.querySelector('.field--name-teaser');
            if (teaserDiv != null) {
              final status = teaserDiv.text.trim();
              if (status.isNotEmpty) {
                return status;
              }
            }
            nextElement = nextElement.nextElementSibling;
          }
        }
      }
      
      // Alternative: try to find any element with both classes
      final teaserElements = document.querySelectorAll('.field--name-teaser.field--type-string');
      for (final element in teaserElements) {
        final status = element.text.trim();
        if (status.isNotEmpty) {
          return status;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('PoolStatus: Parse error: $e');
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
