import 'package:flutter/material.dart';
import 'main_app_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'user_profile_provider.dart';
import 'pending_requests_provider.dart';
import 'microsoft_auth_service.dart';
import 'widgets/microsoft_sign_in_button.dart';
import 'widgets/background_image.dart';
import 'push_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // In production and CI, require real auth and email verification.
    // Development bypass was removed to ensure consistent auth behavior.

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const EmailPasswordLoginScreen();
        }
        final user = snapshot.data!;
        return FutureBuilder<bool>(
          future: AuthGate._userDocExists(user),
          builder: (context, docSnapshot) {
            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator()));
            }
            if (docSnapshot.hasError) {
              FirebaseAuth.instance.signOut();
              return const EmailPasswordLoginScreen();
            }
            final exists = docSnapshot.data ?? false;
            // If doc missing, create a safe default users doc
            // Microsoft accounts are automatically verified, so no verification check needed
            if (!exists) {
              FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                'email': user.email,
                'admin': false,
                'createdAt': FieldValue.serverTimestamp(),
                'lastLogin': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true)).catchError((_) {});
            }
            // Ensure user profile is loaded and lastLogin is updated after successful login.
            // Schedule loadUserProfile to run after this build frame to avoid
            // calling notifyListeners() during the widget build phase.
            final profile =
                Provider.of<UserProfileProvider>(context, listen: false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              profile.loadUserProfile();
            });
            // Also refresh pending requests provider now that we have a signed-in user.
            final pending =
                Provider.of<PendingRequestsProvider>(context, listen: false);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              pending.loadForCurrentUser();
            });
            // Initialize FCM token for push notifications
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final pushService = PushService();
              final token = await pushService.getToken();
              if (token != null) {
                // Store FCM token in user's document for targeted notifications
                FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                  'fcmToken': token,
                  'lastTokenUpdate': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true)).catchError((_) {});
              }
            });
            FirebaseFirestore.instance.collection('users').doc(user.uid).set({
              'lastLogin': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true)).catchError((_) {});
            return const _ProfileCompletionGate(child: AppNavigation());
          },
        );
      },
    );
  }

  static Future<bool> _userDocExists(User user) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }
}

// BackgroundImage is provided by widgets/background_image.dart

class _ProfileCompletionGate extends StatefulWidget {
  final Widget child;
  const _ProfileCompletionGate({required this.child});

  @override
  State<_ProfileCompletionGate> createState() => _ProfileCompletionGateState();
}

class _ProfileCompletionGateState extends State<_ProfileCompletionGate> {
  bool _hasLoadedOnce = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profile, _) {
        // Track if we've finished loading at least once
        if (!profile.loading && !_hasLoadedOnce) {
          _hasLoadedOnce = true;
        }
        
        // Show loading indicator until we've loaded at least once
        if (profile.loading || !_hasLoadedOnce) {
          // If loading has been happening for too long, offer a retry and sign out option.
          if (profile.loadTimedOut) {
            return Scaffold(
              appBar: AppBar(title: const Text('Loading Profile')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                          'Taking longer than expected to load your profile.'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await profile.loadUserProfile();
                        },
                        child: const Text('Retry'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        
        // Profile setup is now optional with auto-populated defaults
        // Users can edit their profile from settings if desired
        return widget.child;
      },
    );
  }
}

class EmailPasswordLoginScreen extends StatefulWidget {
  const EmailPasswordLoginScreen({super.key});

  @override
  State<EmailPasswordLoginScreen> createState() =>
      _EmailPasswordLoginScreenState();
}

class _EmailPasswordLoginScreenState extends State<EmailPasswordLoginScreen> {
  String? _emailError;
  bool _microsoftLoading = false;
  final MicrosoftAuthService _microsoftAuthService = MicrosoftAuthService();

  Future<void> _signInWithMicrosoft() async {
    setState(() {
      _microsoftLoading = true;
      _emailError = null;
    });
    
    try {
      // Sign in with Microsoft
      final userCredential = await _microsoftAuthService.signInWithMicrosoft();
      final user = userCredential.user;
      
      if (user == null) {
        throw Exception('Sign-in failed: No user returned');
      }
      
      // Validate @itu.dk email
      final isValid = await _microsoftAuthService.validateItuEmail(user);
      
      if (!isValid) {
        if (mounted) {
          setState(() {
            _emailError = 'Only @itu.dk accounts are allowed.';
          });
        }
        return;
      }
      
      // Microsoft accounts are automatically verified
      // Create user docs if missing
      final usersDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (!usersDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'email': user.email,
          'admin': false,
          'lastLogin': FieldValue.serverTimestamp(),
          'authProvider': 'microsoft',
        });
      } else {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'lastLogin': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      
      final publicDoc = await FirebaseFirestore.instance
          .collection('public_users')
          .doc(user.uid)
          .get();
      
      // Check if we need to create or update the display name
      final needsProfileCreation = !publicDoc.exists;
      String? currentDisplayName;
      if (publicDoc.exists) {
        currentDisplayName = publicDoc.data()?['displayName'] as String?;
      }
      
      final needsNameUpdate = currentDisplayName == null || 
                               currentDisplayName.isEmpty || 
                               currentDisplayName == 'User' ||
                               currentDisplayName == 'not set';
      
      if (needsProfileCreation || needsNameUpdate) {
        
        // Extract first name from Microsoft account display name
        // Priority 1: Try credential's additional user info (most reliable on first login)
        String fullName = '';
        
        if (userCredential.additionalUserInfo?.profile != null) {
          final profile = userCredential.additionalUserInfo!.profile!;
          fullName = profile['name'] as String? ?? 
                     profile['displayName'] as String? ?? 
                     profile['given_name'] as String? ?? '';
        }
        
        // Priority 2: Try user object (may be null on first login)
        if (fullName.isEmpty) {
          fullName = user.displayName ?? '';
        }
        
        // Priority 3: Try reloading user and checking again
        if (fullName.isEmpty) {
          await user.reload();
          final updatedUser = FirebaseAuth.instance.currentUser;
          fullName = updatedUser?.displayName ?? '';
        }
        
        final firstName = fullName.split(' ').first.trim();
        final displayName = firstName.isNotEmpty ? firstName : 'User';
        
        if (needsProfileCreation) {
          // Create new profile with all fields
          await FirebaseFirestore.instance
              .collection('public_users')
              .doc(user.uid)
              .set({
            'displayName': displayName,
            'occupation': 'Other',
            'iconColor': 4280391411, // Default to Colors.blue.value
          });
        } else {
          // Update only the displayName if it was a placeholder
          await FirebaseFirestore.instance
              .collection('public_users')
              .doc(user.uid)
              .set({
            'displayName': displayName,
          }, SetOptions(merge: true));
        }
      }
      
      // Success! The StreamBuilder will handle navigation
    } on FirebaseAuthException catch (e) {
      final code = e.code.toLowerCase();
      
      if (mounted) {
        setState(() {
          if (code == 'popup-closed-by-user' || code == 'cancelled') {
            _emailError = 'Sign-in cancelled.';
          } else if (code == 'account-exists-with-different-credential') {
            _emailError = 'An account already exists with this email using a different sign-in method.';
          } else {
            _emailError = 'Microsoft sign-in failed: ${e.message}';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _emailError = 'Microsoft sign-in failed: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _microsoftLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.transparent, // Dark background in dark mode
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image covers entire screen
          const BackgroundImage(
              opacity: 0.25, assetPath: 'assets/login_bg.jpg', blurSigma: 2.0),
          // Content on top
          Column(
            children: [
              // Transparent banner
              Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: SafeArea(
                  top: true,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App icon/logo
                        Image.asset(
                          'assets/icon.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        // App title
                        const Text(
                          'FloatIT ITU',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Microsoft-only login
                    final centerForm = Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Microsoft Sign-In button
                            _microsoftLoading
                                ? const CircularProgressIndicator()
                                : MicrosoftSignInButton(
                                    onPressed: () => _signInWithMicrosoft(),
                                    isLoading: _microsoftLoading,
                                    text: 'ITU Login',
                                  ),
                            // Error message display
                            if (_emailError != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _emailError!,
                                        style: TextStyle(color: Colors.red[700]),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );

                    // Form content (no background image here since it's now at screen level)
                    return centerForm;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      // Use a short timeout so a slow / unreachable Firestore doesn't block the UI.
      await UserService.isAdmin(user.uid)
          .timeout(const Duration(seconds: 4), onTimeout: () => false);
      if (!mounted) return;
      // Admin status checked but not currently used in UI
    } catch (e) {
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const MainAppView();
  }
}
