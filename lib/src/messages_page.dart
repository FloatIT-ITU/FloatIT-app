import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'package:floatit/src/layout_widgets.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view messages')),
      );
    }

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(
            title: 'Messages',
            showBackArrow: true,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .where('participants', arrayContains: currentUser.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('No messages'),
                    ),
                  );
                }

                final conversations = snapshot.data!.docs;

                return ConstrainedContent(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final data = conversation.data() as Map<String, dynamic>;
                      
                      return _ConversationTile(
                        conversationId: conversation.id,
                        data: data,
                        currentUserId: currentUser.uid,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final String conversationId;
  final Map<String, dynamic> data;
  final String currentUserId;

  const _ConversationTile({
    required this.conversationId,
    required this.data,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final participants = List<String>.from(data['participants'] ?? []);
    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    // Skip conversations with no other participants (e.g., self-messaging)
    if (otherUserId.isEmpty) {
      return const SizedBox.shrink();
    }

    final lastMessage = data['lastMessage'] as String? ?? '';
    final lastMessageTime = data['lastMessageTime'] as Timestamp?;
    final unreadCount = (data['unreadCount'] as Map<String, dynamic>?)?[currentUserId] as int? ?? 0;
    final eventId = data['eventId'] as String?;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseService.publicUserDoc(otherUserId).get(),
      builder: (context, userSnapshot) {
        String otherUserName = 'Unknown User';
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
          otherUserName = userData?['displayName'] ?? userData?['email'] ?? 'Unknown User';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            elevation: 1,
            child: ListTile(
              leading: CircleAvatar(
                child: Text(otherUserName[0].toUpperCase()),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(otherUserName)),
                  if (unreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eventId != null) ...[
                    const SizedBox(height: 4),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseService.eventDoc(eventId).get(),
                      builder: (context, eventSnapshot) {
                        if (eventSnapshot.hasData && eventSnapshot.data!.exists) {
                          final eventData = eventSnapshot.data!.data() as Map<String, dynamic>?;
                          final eventName = eventData?['name'] ?? 'Event';
                          final eventDate = eventData?['startTime'];
                          String dateString = '';
                          if (eventDate != null) {
                            try {
                              final dateTime = eventDate is String 
                                ? DateTime.parse(eventDate) 
                                : (eventDate as Timestamp).toDate();
                              dateString = DateFormat('MMMM d, y').format(dateTime.toLocal());
                            } catch (_) {
                              // Ignore date parsing errors
                            }
                          }
                          final displayText = dateString.isNotEmpty 
                            ? 'Re: $eventName - $dateString'
                            : 'Re: $eventName';
                          return Text(
                            displayText,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (lastMessageTime != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(lastMessageTime.toDate()),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConversationPage(
                      conversationId: conversationId,
                      otherUserId: otherUserId,
                      otherUserName: otherUserName,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat.Hm().format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(time);
    } else {
      return DateFormat.MMMd().format(time);
    }
  }
}

class ConversationPage extends StatefulWidget {
  final String conversationId;
  final String otherUserId;
  final String otherUserName;

  const ConversationPage({
    super.key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  Future<void> _markAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(widget.conversationId)
        .update({
      'unreadCount.${currentUser.uid}': 0,
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    _messageController.clear();

    try {
      // Generate unique message ID
      final messageId = FirebaseFirestore.instance.collection('messages').doc().id;
      
      // Update thread with new message
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(widget.conversationId)
          .update({
        'messages.$messageId': {
          'senderId': currentUser.uid,
          'text': messageText,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.${widget.otherUserId}': FieldValue.increment(1),
        'deleteAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
      });

      // Get sender name for notification
      // final userDoc = await FirebaseService.userDoc(currentUser.uid).get();
      // final userData = userDoc.data() as Map<String, dynamic>?;
      // final userName = userData?['displayName'] ?? currentUser.email ?? 'Someone';

      // Send push notification
      // final pushService = PushService();
      // await pushService.sendNotificationToUsers(
      //   userIds: [widget.otherUserId],
      //   title: 'Message from $userName',
      //   body: messageText,
      // );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StandardPageBanner(
            title: widget.otherUserName,
            showBackArrow: true,
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(widget.conversationId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('No messages'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                final messagesMap = data['messages'] as Map<String, dynamic>? ?? {};
                final messages = messagesMap.values.map((msg) => msg as Map<String, dynamic>).toList();
                
                // Sort messages by timestamp descending (most recent first)
                messages.sort((a, b) {
                  final aTime = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  final bTime = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                  return bTime.compareTo(aTime);
                });

                final eventId = data['eventId'] as String?;

                return Column(
                  children: [
                    if (eventId != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: FutureBuilder<DocumentSnapshot>(
                          future: FirebaseService.eventDoc(eventId).get(),
                          builder: (context, eventSnapshot) {
                            if (eventSnapshot.hasData && eventSnapshot.data!.exists) {
                              final eventData = eventSnapshot.data!.data() as Map<String, dynamic>?;
                              final eventName = eventData?['name'] ?? 'Event';
                              final eventDate = eventData?['startTime'];
                              String dateString = '';
                              if (eventDate != null) {
                                try {
                                  final dateTime = eventDate is String 
                                    ? DateTime.parse(eventDate) 
                                    : (eventDate as Timestamp).toDate();
                                  dateString = DateFormat('MMMM d, y').format(dateTime.toLocal());
                                } catch (_) {
                                  // Ignore date parsing errors
                                }
                              }
                              final displayText = dateString.isNotEmpty 
                                ? 'Re: $eventName - $dateString'
                                : 'Re: $eventName';
                              return Text(
                                displayText,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    Expanded(
                      child: ConstrainedContent(
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final data = message;
                            final senderId = data['senderId'] as String;
                            final text = data['text'] as String;
                            final timestamp = data['timestamp'] as Timestamp?;
                            final isMe = senderId == currentUser.uid;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(text),
                                      if (timestamp != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat.Hm().format(timestamp.toDate()),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ConstrainedContent(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
