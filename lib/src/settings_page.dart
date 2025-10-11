import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? _isAdmin;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
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
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                NavigationUtils.pushWithoutAnimation(
                                  context,
                                  const AdminPage(),
                                );
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
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.email_outlined),
                                title: Text(email),
                              ),
                              const Divider(height: 1),
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
                              // Push token debug UI removed for production branch
                              const Divider(height: 1),
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
                            Builder(builder: (context) {
                              final theme = Theme.of(context);
                              final textColor = theme.textTheme.bodyMedium?.color ?? theme.colorScheme.onSurfaceVariant;
                              return RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTextStyles.body(textColor),
                                  children: [
                                    const TextSpan(text: 'Made by FloatIT '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: Icon(Icons.pool, size: 16, color: theme.colorScheme.primary),
                                    ),
                                    const TextSpan(text: '\nIT University of Copenhagen\n\nInspired by the '),
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
