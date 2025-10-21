import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:floatit/src/user_profile_provider.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:floatit/src/widgets/section_header.dart';
import 'package:floatit/src/widgets/profile_summary_card.dart';
import 'package:floatit/src/widgets/change_password_dialog.dart';
import 'package:floatit/src/privacy_policy_page.dart';
import 'admin_page.dart';
import 'statistics_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'styles.dart';
import 'layout_widgets.dart';

import 'theme_provider.dart';
import 'package:floatit/src/utils/navigation_utils.dart';
import 'package:floatit/src/widgets/loading_widgets.dart';
import 'admin_feedback_page.dart';
import 'push_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? _isAdmin;
  bool _hasUnreadFeedback = false;
  StreamSubscription<QuerySnapshot>? _feedbackSubscription;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _setupFeedbackListener();
  }

  @override
  void dispose() {
    _feedbackSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No need to recheck feedback - we have real-time updates
  }

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _isAdmin = data['admin'] == true;
        });
      }
    } catch (e) {
      setState(() {
        _isAdmin = false;
      });
    }
  }

  Future<void> _checkUnreadFeedback() async {
    final hasUnread = await AdminFeedbackPage.hasUnreadFeedback();
    if (mounted) {
      setState(() {
        _hasUnreadFeedback = hasUnread;
      });
    }
  }

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

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Send Feedback'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'We appreciate your feedback! Please share your thoughts, suggestions, or report any issues.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: feedbackController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Enter your feedback here...',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final feedback = feedbackController.text.trim();
                          if (feedback.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter your feedback')),
                            );
                            return;
                          }

                          setState(() => isSubmitting = true);
                          bool submitSuccess = false;

                          try {
                            await _submitFeedback(feedback);
                            submitSuccess = true;
                          } catch (e) {
                            // Error handled below
                          }

                          if (!mounted) return;
                          setState(() => isSubmitting = false);

                          if (submitSuccess) {
                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thank you for your feedback!')),
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to send feedback. Please try again.')),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitFeedback(String feedback) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final fs = FirebaseFirestore.instance;
    await fs.collection('feedback').add({
      'userId': user.uid,
      'userEmail': user.email,
      'message': feedback,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'unread', // unread, read, responded
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profile, _) {
        return Scaffold(
          body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StandardPageBanner(title: 'Settings', showBackArrow: true),
            Expanded(
              child: SingleChildScrollView(
                child: ConstrainedContent(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      // Profile summary section
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: ProfileSummaryCard(),
                      ),
                      const SizedBox(height: 24),
                      // Admin section (only visible to admins)
                      if (_isAdmin == true) ...[
                        const SectionHeader(title: 'Admin'),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            elevation: 1,
                            child: ListTile(
                              leading: const Icon(Icons.admin_panel_settings),
                              title: const Text('Admin Panel'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_hasUnreadFeedback) const UnreadIndicator(),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () {
                                NavigationUtils.pushWithoutAnimation(
                                  context,
                                  const AdminPage(),
                                ).then((_) {
                                  // Refresh unread status when returning from admin page
                                  _checkUnreadFeedback();
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Account section - moved down
                      const SectionHeader(title: 'Account'),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.brightness_6),
                                title: const Text('Dark mode'),
                                trailing: Consumer<ThemeProvider>(
                                  builder: (context, theme, _) => Switch(
                                    value: theme.mode == ThemeMode.dark,
                                    onChanged: (v) async {
                                      await theme.setMode(v ? ThemeMode.dark : ThemeMode.light);
                                    },
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: const Icon(Icons.lock_outline),
                                title: const Text('Change Password'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const ChangePasswordDialog(),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.logout),
                                title: const Text('Sign out'),
                                onTap: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Sign out'),
                                      content: const Text('Are you sure you want to sign out?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Sign out'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await FirebaseAuth.instance.signOut();
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop(); // Go back after signing out
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.notifications),
                                title: const Text('Enable notifications'),
                                trailing: Consumer<UserProfileProvider>(
                                  builder: (context, profile, _) => Switch(
                                    value: profile.notificationsEnabled,
                                    onChanged: (v) async {
                                      final messenger = ScaffoldMessenger.of(context);
                                      // Enabling: first ask for permission
                                      if (v) {
                                        try {
                                          final granted = await PushService.instance.requestPermission();
                                          if (!granted) {
                                            messenger.showSnackBar(const SnackBar(content: Text('Notifications permission was not granted')));
                                            // Ensure UI reflects actual state
                                            await profile.setNotificationsEnabled(false);
                                            return;
                                          }

                                          // Persist preference and register token
                                          await profile.setNotificationsEnabled(true);
                                          final registered = await PushService.instance.registerTokenForCurrentUser();
                                          if (registered != true) {
                                            messenger.showSnackBar(const SnackBar(content: Text('Failed to register for notifications')));
                                            // Rollback preference in UI
                                            await profile.setNotificationsEnabled(false);
                                          }
                                        } catch (e) {
                                          messenger.showSnackBar(const SnackBar(content: Text('Failed to enable notifications')));
                                          await profile.setNotificationsEnabled(false);
                                        }
                                      } else {
                                        // Disabling: unregister tokens and persist opt-out
                                        try {
                                          await PushService.instance.unregisterAllTokensForCurrentUser();
                                        } catch (_) {}
                                        try {
                                          await profile.setNotificationsEnabled(false);
                                        } catch (_) {
                                          messenger.showSnackBar(const SnackBar(content: Text('Failed to update notification preference')));
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                                title: Text('Delete Account', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                onTap: () async {
                                  if (!context.mounted) return;
                                  final messenger = ScaffoldMessenger.of(context);
                                  final navigator = Navigator.of(context);
                                  // ignore: use_build_context_synchronously
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Account'),
                                      content: const Text('Are you sure you want to delete your account?\nThis action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    try {
                                      final user = FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        await user.delete();
                                        if (!context.mounted) return;
                                        messenger.showSnackBar(const SnackBar(content: Text('Account deleted')));
                                        navigator.pop(); // Go back after deletion
                                      }
                                    } on FirebaseAuthException catch (e) {
                                      String msg = e.message ?? 'Failed to delete account.';
                                      if (e.code == 'requires-recent-login') {
                                        msg = 'Please sign in again to delete your account.';
                                      }
                                      if (!context.mounted) return;
                                      messenger.showSnackBar(SnackBar(content: Text(msg)));
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Statistics section - new
                      const SectionHeader(title: 'Statistics'),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          elevation: 1,
                          child: ListTile(
                            leading: const Icon(Icons.event_available),
                            title: Text('Events Joined: ${profile.eventsJoinedCount}'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              NavigationUtils.pushWithoutAnimation(
                                context,
                                const StatisticsPage(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // About section
                      const SectionHeader(title: 'About'),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          elevation: 1,
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.privacy_tip_outlined),
                                title: const Text('Privacy Policy'),
                                onTap: () {
                                  NavigationUtils.pushWithoutAnimation(
                                    context,
                                    const PrivacyPolicyPage(),
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.facebook),
                                title: const Text('Facebook Group'),
                                onTap: () async {
                                  final url = Uri.parse('https://www.facebook.com/groups/floatit.itucph/');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.feedback_outlined),
                                title: const Text('Send Feedback'),
                                onTap: () {
                                  _showFeedbackDialog(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Text('Made by FloatIT', textAlign: TextAlign.center, style: AppTextStyles.body()),
                            const SizedBox(height: 8),
                            // Center the app icon on its own row
                            Center(
                              child: ThemeAwareAppIcon(width: 40, height: 40),
                            ),
                            const SizedBox(height: 4),
                            Text('IT University of Copenhagen', textAlign: TextAlign.center, style: AppTextStyles.body()),
                            const SizedBox(height: 8),
                            Builder(builder: (context) {
                              final theme = Theme.of(context);
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTextStyles.body(theme.colorScheme.onSurfaceVariant),
                                  children: [
                                    const TextSpan(text: '\nInspired by the '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () async {
                                          final url = Uri.parse('https://github.com/AnalogIO/');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url, mode: LaunchMode.externalApplication);
                                          }
                                        },
                                        child: Text('AnalogIO team', style: TextStyle(color: theme.colorScheme.primary, decoration: TextDecoration.underline)),
                                      ),
                                    ),
                                    const TextSpan(text: ' and\ntheir beautiful Coffee Card App '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(Icons.favorite, size: 16, color: Colors.red),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        );
      },
    );
  }
}
