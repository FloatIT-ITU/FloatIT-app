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

class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  bool _isLoading = true;
  String _loadingMessage = 'Loading...';
  
  @override
  void initState() {
    super.initState();
    // Defer preloading to after the first build to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadData();
    });
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
                // App logo/icon
                Image.asset(
                  'assets/icon.png',
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 24),
                // Loading indicator
                const CircularProgressIndicator(),
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
              Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Back arrow placeholder (invisible but maintains layout)
                      const SizedBox(width: 48),
                      // Centered title with icon (like StandardPageBanner)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/icon.png',
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
                        icon: const Icon(Icons.settings),
                        onPressed: _openSettings,
                        tooltip: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
              // Global banners
              for (var w in bannerWidgets) w,
              // Main content - Events page (now fully loaded)
              const Expanded(child: EventsPageContent()),
              // Pool status banner at the bottom - ensure it goes to the bottom edge
              SafeArea(
                top: false,
                child: const PoolStatusBanner(),
              ),
            ],
          );
        },
      ),
    );
  }
}