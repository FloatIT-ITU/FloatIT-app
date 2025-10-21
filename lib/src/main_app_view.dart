import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_page.dart';
import 'notification_provider.dart';
import 'pending_requests_provider.dart';
import 'user_profile_provider.dart';
import 'theme_colors.dart';
import 'package:floatit/src/widgets/notification_banner.dart';
import 'package:floatit/src/widgets/pool_status_banner.dart';
import 'events_page_content.dart';
import 'package:floatit/src/utils/navigation_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floatit/src/widgets/loading_widgets.dart';

class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  bool _isLoading = true;
  String _loadingMessage = 'Loading...';
  bool _isAdmin = false;
  bool _hasUnreadFeedback = false;
  StreamSubscription<QuerySnapshot>? _feedbackSubscription;
  
  @override
  void initState() {
    super.initState();
    // Defer preloading to after the first build to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadData();
    });
  }
  
  @override
  void dispose() {
    _feedbackSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _preloadData() async {
    // Store providers before async operation to avoid BuildContext issues
    final userProvider = Provider.of<UserProfileProvider>(context, listen: false);
    final pendingProvider = Provider.of<PendingRequestsProvider>(context, listen: false);
    
    try {
      if (mounted) setState(() => _loadingMessage = 'Loading user data...');
      
      // Load user profile
      await userProvider.loadUserProfile();
      
      // Wait a bit for notifications to load (they load via streams)
      if (mounted) setState(() => _loadingMessage = 'Loading notifications...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Load pending requests (will only load if user is admin)
      if (mounted) setState(() => _loadingMessage = 'Loading admin data...');
      await pendingProvider.loadForCurrentUser();
      
      // Brief pause to ensure smooth transition
      await Future.delayed(const Duration(milliseconds: 200));
      
    } catch (e) {
      // Continue even if some data fails to load
    } finally {
      // Check admin status and setup real-time feedback listener
      await _checkAdminStatus();
      if (_isAdmin) {
        _setupFeedbackListener();
      }
      
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _openSettings() {
    NavigationUtils.pushWithoutAnimation(
      context,
      const SettingsPage(),
    );
  }

  Future<void> _checkAdminStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _isAdmin = data['admin'] == true;
      }
    } catch (e) {
      _isAdmin = false;
    }
  }

  /// Setup real-time listener for unread feedback (admins only)
  void _setupFeedbackListener() {
    _feedbackSubscription = FirebaseFirestore.instance
        .collection('feedback')
        .where('status', isEqualTo: 'unread')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _hasUnreadFeedback = snapshot.docs.isNotEmpty;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Loading indicator (use app-branded spinning loader)
                LoadingWidgets.loadingIndicator(size: 64),
                const SizedBox(height: 16),
                // Loading message
                Text(
                  _loadingMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Consumer<NotificationProvider?>(
        builder: (context, notifications, _) {
          final globalBanner = notifications?.globalBanner;
          final List<Widget> bannerWidgets = [];

          if (globalBanner != null) {
            final bg = Theme.of(context).brightness == Brightness.dark
                ? AppThemeColors.bannerGlobalDark
                : AppThemeColors.bannerGlobalLight;
            bannerWidgets.add(NotificationBanner(
              title: globalBanner['title'] ?? '',
              body: globalBanner['body'] ?? '',
              backgroundColor: bg,
              isGlobal: true,
            ));
          }

          return Column(
            children: [
              // Custom top bar - transparent background
              Center(
                child: Container(
                  height: kToolbarHeight,
                  width: 720, // kContentMaxWidth
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: SafeArea(
                    child: Row(
                    children: [
                      // Centered title with icon (like StandardPageBanner)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/float_it.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Events',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Settings button on the right
                      IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.settings),
                            if (_isAdmin && _hasUnreadFeedback)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onPressed: _openSettings,
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
              ),
              // Global banners
              ...bannerWidgets,
              // Main content - Events page (now fully loaded)
              const Expanded(child: EventsPageContent()),
              // Pool status banner at the bottom
              // Don't use SafeArea here - let it extend to the very bottom
              const PoolStatusBanner(),
            ],
          );
        },
      ),
      // Ensure body doesn't resize for keyboard
      resizeToAvoidBottomInset: false,
    );
  }
}