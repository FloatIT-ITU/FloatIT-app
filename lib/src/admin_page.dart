import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:floatit/src/widgets/section_header.dart';
import 'package:floatit/src/create_event_page.dart';
// import 'admin_requests_page.dart';
import 'admin_send_notification_page.dart';
import 'user_management_page.dart';
import 'admin_event_management_page.dart';
import 'admin_feedback_page.dart';
import 'package:floatit/src/utils/navigation_utils.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(title: 'Admin', showBackArrow: true),
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedContent(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Events section
                    const SectionHeader(title: 'Events'),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.add_box_outlined),
                            title: const Text('Create Event'),
                            onTap: () {
                              NavigationUtils.pushWithoutAnimation(
                                context,
                                const CreateEventPage(),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.event_note_outlined),
                            title: const Text('Event Management'),
                            onTap: () {
                              NavigationUtils.pushWithoutAnimation(
                                context,
                                const AdminEventManagementPage(),
                              );
                            },
                          ),
                          // Edit Event removed per request
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Users section
                    const SectionHeader(title: 'Users'),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      child: ListTile(
                        leading: const Icon(Icons.people_outline),
                        title: const Text('User Management'),
                        onTap: () {
                          NavigationUtils.pushWithoutAnimation(
                            context,
                            const UserManagementPage(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Notifications section
                    const SectionHeader(title: 'Notifications'),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            leading: const Icon(
                                Icons.notifications_active_outlined),
                            title: const Text('Notifications (Global)'),
                            onTap: () {
                              NavigationUtils.pushWithoutAnimation(
                                context,
                                const AdminSendNotificationPage(),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.feedback_outlined),
                            title: const Text('Feedback Messages'),
                            onTap: () {
                              NavigationUtils.pushWithoutAnimation(
                                context,
                                const AdminFeedbackPage(),
                              );
                            },
                          ),
                          // Guidance moved to the Notifications page itself.
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Queued Join Requests removed
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
