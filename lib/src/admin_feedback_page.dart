import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'messages_page.dart';
import 'theme_colors.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:floatit/src/layout_widgets.dart';

/// A small red circle indicator for unread items
class UnreadIndicator extends StatelessWidget {
  const UnreadIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    );
  }
}

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  /// Check if there are any unread feedback messages
  static Future<bool> hasUnreadFeedback() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('feedback')
          .where('status', isEqualTo: 'unread')
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  State<AdminFeedbackPage> createState() => _AdminFeedbackPageState();
}

class _AdminFeedbackPageState extends State<AdminFeedbackPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(title: 'Feedback Messages', showBackArrow: true),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('feedback')
                  .orderBy('status', descending: true) // unread first (unread > read alphabetically)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final feedbackDocs = snapshot.data?.docs ?? [];

                // Separate unread and read feedback
                final unreadDocs = feedbackDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] as String?) == 'unread';
                }).toList();

                final readDocs = feedbackDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return (data['status'] as String?) != 'unread';
                }).toList();

                if (feedbackDocs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.feedback_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No feedback messages yet',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'User feedback will appear here',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: ConstrainedContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${feedbackDocs.length} feedback message${feedbackDocs.length != 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Unread messages
                        if (unreadDocs.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Unread Messages',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...unreadDocs.map((doc) => _buildFeedbackItem(doc)),
                        ],
                        // Separator if both groups exist
                        if (unreadDocs.isNotEmpty && readDocs.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 24),
                        ],
                        // Read messages
                        if (readDocs.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Read Messages',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...readDocs.map((doc) => _buildFeedbackItem(doc)),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackItem(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userId = data['userId'] as String?;
    final userEmail = data['userEmail'] as String? ?? 'Unknown';
    final message = data['message'] as String? ?? '';
    final timestamp = data['createdAt'] as Timestamp?;
    final status = data['status'] as String? ?? 'unread';

    final formattedDate = timestamp != null
        ? DateFormat('MMM d, yyyy • HH:mm').format(timestamp.toDate())
        : 'Unknown date';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info with profile
              FutureBuilder<DocumentSnapshot>(
                future: userId != null
                    ? FirebaseFirestore.instance.collection('public_users').doc(userId).get()
                    : null,
                builder: (context, profileSnapshot) {
                  final profileData = profileSnapshot.data?.data() as Map<String, dynamic>?;
                  final displayName = profileData?['displayName'] as String? ?? 'Unknown';
                  final occupation = profileData?['occupation'] as String? ?? 'Not set';

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              occupation,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              userEmail,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'unread'
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: status == 'unread'
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _respondToUser(doc.id, userId, userEmail, message),
                    icon: const Icon(Icons.reply, size: 16),
                    label: const Text('Respond'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (status == 'unread')
                    TextButton.icon(
                      onPressed: () => _markAsRead(doc.id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark as Read'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => _deleteFeedback(doc.id),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _respondToUser(String feedbackId, String? userId, String userEmail, String feedbackMessage) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot respond: user ID not found')),
      );
      return;
    }
    // Create (or update) a feedback-specific conversation document.
    // Use a conversation id unique to the feedback item so that each feedback has its own thread.
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in as admin to respond')),
          );
        }
        return;
      }

      final firestore = FirebaseFirestore.instance;
      final conversationId = 'feedback_$feedbackId';
      final conversationRef = firestore.collection('messages').doc(conversationId);
      final messageId = firestore.collection('messages').doc().id;

      final adminUid = currentUser.uid;
      if (adminUid == userId) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot send a message to yourself')));
        return;
      }
  final initialText = 'Regarding your feedback: "$feedbackMessage"\n\n[Admin will respond]';

      final conversationSnap = await conversationRef.get();
      if (!conversationSnap.exists) {
        // Create new feedback-scoped conversation
        await conversationRef.set({
          'participants': [adminUid, userId],
          'eventId': null,
          'feedbackId': feedbackId,
          'lastMessage': initialText,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount': {userId: 1},
          'createdAt': FieldValue.serverTimestamp(),
          'deleteAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
          'messages': {
            messageId: {
              'senderId': adminUid,
              'text': initialText,
              'timestamp': FieldValue.serverTimestamp(),
            }
          }
        });
      } else {
        // Append a stub admin message referencing the feedback (keeps thread linked to feedback)
        await conversationRef.update({
          'messages.$messageId': {
            'senderId': adminUid,
            'text': initialText,
            'timestamp': FieldValue.serverTimestamp(),
          },
          'lastMessage': initialText,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadCount.$userId': FieldValue.increment(1),
        });
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationPage(
              conversationId: conversationId,
              otherUserId: userId,
              otherUserName: userEmail,
              iconColor: AppThemeColors.lightPrimary,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create conversation for feedback')),
        );
      }
    }
  }

  Future<void> _markAsRead(String feedbackId) async {
    try {
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedbackId)
          .update({'status': 'read'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update feedback status')),
        );
      }
    }
  }

  Future<void> _deleteFeedback(String feedbackId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('feedback')
            .doc(feedbackId)
            .delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Feedback deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete feedback')),
          );
        }
      }
    }
  }
}