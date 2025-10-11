import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/rate_limit_service.dart';
import 'user_statistics_service.dart';

// For testability this provider accepts optional injected Firebase
// instances. In production these default to the global singletons.

class UserProfileProvider extends ChangeNotifier {
  String? displayName;
  String? occupation;
  Color? iconColor;
  bool isAdmin = false;
  int eventsJoinedCount = 0;
  bool _loading = false;
  bool get loading => _loading;
  DateTime? _lastLoadStarted;

  // True if loading has been in progress for longer than the timeout threshold
  bool get loadTimedOut {
    if (!_loading || _lastLoadStarted == null) return false;
    return DateTime.now().difference(_lastLoadStarted!).inSeconds > 8;
  }

  final dynamic _auth;
  final FirebaseFirestore _firestore;

  // `auth` may be a FirebaseAuth instance in production or any object
  // providing a `currentUser` with a `uid` for tests.
  UserProfileProvider({dynamic auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> loadUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    _loading = true;
    _lastLoadStarted = DateTime.now();
    // Don't notify listeners immediately to avoid UI flashing during loading
    try {
      // Load public fields
      final publicDoc =
          await _firestore.collection('public_users').doc(user.uid).get();
      final publicData = publicDoc.data();
      displayName = publicData?['displayName'] as String?;
      occupation = publicData?['occupation'] as String?;
      final iconColorField = publicData?['iconColor'];
      if (iconColorField is int) {
        iconColor = Color(iconColorField);
      } else if (iconColorField is String) {
        try {
          var hex = iconColorField.replaceFirst('#', '');
          if (hex.length == 6) hex = 'ff$hex';
          final intVal = int.parse(hex, radix: 16);
          iconColor = Color(intVal);
        } catch (_) {
          iconColor = null;
        }
      } else {
        iconColor = null;
      }
      // Load private fields
      final privateDoc =
          await _firestore.collection('users').doc(user.uid).get();
      final privateData = privateDoc.data();
      isAdmin = privateData?['admin'] == true;

      // Load statistics
      await _loadUserStatistics(user.uid);
    } catch (e) {
      // Optionally handle error
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // updateIconIndex removed

  Future<void> updateIconColor(Color newColor) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (!user.email!.endsWith('@itu.dk')) {
      throw Exception('Email must end with @itu.dk to update profile');
    }
    
    // Rate limiting check
    final rateLimitService = RateLimitService.instance;
    if (!rateLimitService.isActionAllowed(user.uid, RateLimitAction.updateIconColor)) {
      return; // Silently ignore rate-limited requests
    }
    
    final int a = newColor.alpha;
    final int r = newColor.red;
    final int g = newColor.green;
    final int b = newColor.blue;
    final int colorInt = (a << 24) | (r << 16) | (g << 8) | b;
    final hex = '#${colorInt.toRadixString(16).padLeft(8, '0')}';
    await _firestore.collection('public_users').doc(user.uid).set({
      'iconColor': hex,
    }, SetOptions(merge: true));
    
    // Record action after successful update
    rateLimitService.recordAction(user.uid, RateLimitAction.updateIconColor);
    
    iconColor = newColor;
    notifyListeners();
  }

  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (!user.email!.endsWith('@itu.dk')) {
      throw Exception('Email must end with @itu.dk to update profile');
    }
    
    // Rate limiting check
    final rateLimitService = RateLimitService.instance;
    if (!rateLimitService.isActionAllowed(user.uid, RateLimitAction.updateDisplayName)) {
      return; // Silently ignore rate-limited requests
    }
    
    final name = newName.trim();
    if (name.isEmpty ||
        name.length < 2 ||
        name.length > 30 ||
        !RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(name)) {
      throw Exception(
          'Display name can only contain letters, numbers, and spaces');
    }
    await _firestore.collection('public_users').doc(user.uid).set({
      'displayName': name,
    }, SetOptions(merge: true));
    
    // Record action after successful update
    rateLimitService.recordAction(user.uid, RateLimitAction.updateDisplayName);
    
    displayName = name;
    notifyListeners();
  }

  Future<void> updateOccupation(String newOccupation) async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (!user.email!.endsWith('@itu.dk')) {
      throw Exception('Email must end with @itu.dk to update profile');
    }
    
    // Rate limiting check
    final rateLimitService = RateLimitService.instance;
    if (!rateLimitService.isActionAllowed(user.uid, RateLimitAction.updateOccupation)) {
      return; // Silently ignore rate-limited requests
    }
    
    // Only allow known occupations
    const allowed = [
      'SWU',
      'GBI',
      'BDDIT',
      'BDS',
      'MDDIT',
      'DIM',
      'E-BUSS',
      'GAMES/DT',
      'GAMES/Tech',
      'CS',
      'SD',
      'MDS',
      'MIT',
      'Employee',
      'PhD',
      'Other',
    ];
    if (!allowed.contains(newOccupation)) {
      throw Exception('Invalid occupation');
    }
    await _firestore.collection('public_users').doc(user.uid).set({
      'occupation': newOccupation,
    }, SetOptions(merge: true));
    
    // Record action after successful update
    rateLimitService.recordAction(user.uid, RateLimitAction.updateOccupation);
    
    occupation = newOccupation;
    notifyListeners();
  }

  Future<void> _loadUserStatistics(String userId) async {
    try {
      // Get events joined count from event history (only past events)
      eventsJoinedCount = await UserStatisticsService.getUserEventsJoinedCount(userId);
    } catch (e) {
      // If statistics loading fails, keep defaults (0)
      eventsJoinedCount = 0;
    }
  }
}
