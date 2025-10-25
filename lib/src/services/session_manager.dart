import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Service for managing user session timeouts and security policies
class SessionManager extends ChangeNotifier {
  static final SessionManager instance = SessionManager._();

  SessionManager._() {
    _initialize();
  }

  // Session configuration
  static const Duration _maxSessionDuration = Duration(days: 60); // 2 months maximum session
  static const Duration _inactivityTimeout = Duration(days: 30); // 1 month inactivity timeout
  static const Duration _checkInterval = Duration(days: 1); // Check daily

  // Session state
  DateTime? _sessionStartTime;
  DateTime? _lastActivityTime;
  Timer? _checkTimer;

  void _initialize() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _startSession();
      } else {
        _endSession();
      }
    });
  }

  void _startSession() {
    final now = DateTime.now();
    _sessionStartTime = now;
    _lastActivityTime = now;
    _scheduleNextCheck();
    notifyListeners();
  }

  void _endSession() {
    _checkTimer?.cancel();
    _sessionStartTime = null;
    _lastActivityTime = null;
    notifyListeners();
  }

  void _scheduleNextCheck() {
    _checkTimer?.cancel();
    _checkTimer = Timer(_checkInterval, _performSessionCheck);
  }

  void _performSessionCheck() {
    if (_sessionStartTime == null || _lastActivityTime == null) return;

    final now = DateTime.now();
    final sessionDuration = now.difference(_sessionStartTime!);
    final inactivityDuration = now.difference(_lastActivityTime!);

    // Check if session has exceeded maximum duration or inactivity timeout
    if (sessionDuration >= _maxSessionDuration || inactivityDuration >= _inactivityTimeout) {
      _performLogout();
    } else {
      // Schedule next check
      _scheduleNextCheck();
    }
  }

  void _performLogout() {
    FirebaseAuth.instance.signOut();
    _endSession();
  }

  /// Record user activity to update last activity time
  void recordActivity() {
    if (FirebaseAuth.instance.currentUser == null) return;

    _lastActivityTime = DateTime.now();
    notifyListeners();
  }

  /// Force logout
  void forceLogout() {
    _performLogout();
  }

  /// Get remaining session time (minimum of max session and inactivity timeout)
  Duration getRemainingSessionTime() {
    if (_sessionStartTime == null || _lastActivityTime == null) return Duration.zero;

    final now = DateTime.now();
    final sessionRemaining = _maxSessionDuration - now.difference(_sessionStartTime!);
    final inactivityRemaining = _inactivityTimeout - now.difference(_lastActivityTime!);

    final remaining = sessionRemaining < inactivityRemaining ? sessionRemaining : inactivityRemaining;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get session start time
  DateTime? get sessionStartTime => _sessionStartTime;

  /// Get last activity time
  DateTime? get lastActivityTime => _lastActivityTime;

  /// Check if user is currently authenticated and session is active
  bool get isAuthenticated => FirebaseAuth.instance.currentUser != null &&
                             _sessionStartTime != null &&
                             _lastActivityTime != null;

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }
}

/// Widget that wraps the app to provide session management
class SessionProvider extends StatefulWidget {
  final Widget child;

  const SessionProvider({super.key, required this.child});

  @override
  State<SessionProvider> createState() => _SessionProviderState();
}

class _SessionProviderState extends State<SessionProvider> with WidgetsBindingObserver {
  final SessionManager _sessionManager = SessionManager.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Record activity when app resumes
        _sessionManager.recordActivity();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is not active, no activity recorded
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _sessionManager.recordActivity,
      onPanDown: (_) => _sessionManager.recordActivity,
      onScaleStart: (_) => _sessionManager.recordActivity,
      child: widget.child,
    );
  }
}