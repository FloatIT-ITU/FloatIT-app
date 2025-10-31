import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'styles.dart';
import 'package:provider/provider.dart';
import 'user_profile_provider.dart';
import 'user_service.dart';
import 'utils/validation_utils.dart';
import 'widgets/swimmer_icon_picker.dart';
import 'theme_colors.dart';
import 'external_config.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _search = '';
  String _filterOccupation = 'All';
  String _adminFilter = 'All';
  String _sortBy = 'name';

  Future<Map<String, Map<String, dynamic>?>> _fetchPrivateMap(
      List<String> ids) async {
    final Map<String, Map<String, dynamic>?> result = {};
    for (final id in ids) {
      final snap =
          await FirebaseFirestore.instance.collection('users').doc(id).get();
      result[id] = snap.data();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfile, child) {
        final currentUserIsAdmin = userProfile.isAdmin;
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StandardPageBanner(
                  title: 'User Management', showBackArrow: true),
              Expanded(
                child: ConstrainedContent(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('public_users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      final occupations = <String>{};
                      for (var doc in docs) {
                        final occ = (doc['occupation'] ?? '').toString();
                        if (occ.isNotEmpty) occupations.add(occ);
                      }
                      final occupationList = [
                        'All',
                        ...occupations.toList()..sort()
                      ];
                      // Initial filter by search and occupation
                      final baseFiltered = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['displayName'] ?? '')
                            .toString()
                            .toLowerCase();
                        final email =
                            (data['email'] ?? '').toString().toLowerCase();
                        final occupation =
                            (data['occupation'] ?? '').toString();
                        final matchesSearch =
                            name.contains(_search) || email.contains(_search);
                        final matchesFilter = _filterOccupation == 'All' ||
                            occupation == _filterOccupation;
                        return matchesSearch && matchesFilter;
                      }).toList();

                      // Fetch private user data for admin filtering / sorting
                      final ids = baseFiltered.map((d) => d.id).toList();
                      return FutureBuilder<Map<String, Map<String, dynamic>?>>(
                        future: _fetchPrivateMap(ids),
                        builder: (context, privateSnapshot) {
                          if (!privateSnapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final privateMap = privateSnapshot.data!;

                          // Apply admin filter
                          final filtered = baseFiltered.where((doc) {
                            final priv = privateMap[doc.id];
                            final isAdmin = priv?['admin'] == true;
                            if (_adminFilter == 'All') return true;
                            if (_adminFilter == 'Admins') return isAdmin;
                            return !isAdmin; // Users
                          }).toList();

                          // Sort
                          if (_sortBy == 'name') {
                            filtered.sort((a, b) {
                              final nameA = ((a.data() as Map<String, dynamic>)[
                                          'displayName'] ??
                                      '')
                                  .toString()
                                  .toLowerCase();
                              final nameB = ((b.data() as Map<String, dynamic>)[
                                          'displayName'] ??
                                      '')
                                  .toString()
                                  .toLowerCase();
                              return nameA.compareTo(nameB);
                            });
                          } else if (_sortBy == 'lastLogin') {
                            filtered.sort((a, b) {
                              final pa = privateMap[a.id];
                              final pb = privateMap[b.id];
                              final da = pa?['lastLogin'];
                              final db = pb?['lastLogin'];
                              final ta = da is Timestamp
                                  ? da.toDate().millisecondsSinceEpoch
                                  : (da is DateTime
                                      ? da.millisecondsSinceEpoch
                                      : 0);
                              final tb = db is Timestamp
                                  ? db.toDate().millisecondsSinceEpoch
                                  : (db is DateTime
                                      ? db.millisecondsSinceEpoch
                                      : 0);
                              return tb.compareTo(ta); // most recent first
                            });
                          }

                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          labelText: 'Search by name or email',
                                          prefixIcon: Icon(Icons.search),
                                        ),
                                        onChanged: (value) => setState(() =>
                                            _search =
                                                value.trim().toLowerCase()),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: _filterOccupation,
                                      items: occupationList
                                          .map((e) => DropdownMenuItem(
                                              value: e, child: Text(e)))
                                          .toList(),
                                      onChanged: (value) => setState(() =>
                                          _filterOccupation = value ?? 'All'),
                                    ),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: _adminFilter,
                                      items: const [
                                        DropdownMenuItem<String>(
                                            value: 'All', child: Text('All')),
                                        DropdownMenuItem<String>(
                                            value: 'Admins',
                                            child: Text('Admins')),
                                        DropdownMenuItem<String>(
                                            value: 'Users',
                                            child: Text('Users')),
                                      ],
                                      onChanged: (value) => setState(
                                          () => _adminFilter = value ?? 'All'),
                                    ),
                                    const SizedBox(width: 8),
                                    DropdownButton<String>(
                                      value: _sortBy,
                                      items: const [
                                        DropdownMenuItem<String>(
                                            value: 'name',
                                            child: Text('Sort: A→Z')),
                                        DropdownMenuItem<String>(
                                            value: 'lastLogin',
                                            child: Text('Sort: Last login')),
                                      ],
                                      onChanged: (value) => setState(
                                          () => _sortBy = value ?? 'name'),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, i) {
                                    final data = filtered[i].data()
                                        as Map<String, dynamic>;
                                    final userId = filtered[i].id;
                                    return _UserCard(
                                      userId: userId,
                                      data: data,
                                      currentUserIsAdmin: currentUserIsAdmin,
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      // (old users list removed - replaced by filtered FutureBuilder above)
                    },
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

class _UserCard extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> data;
  final bool currentUserIsAdmin;
  const _UserCard({
    required this.userId,
    required this.data,
    required this.currentUserIsAdmin,
  });

  Future<Map<String, dynamic>?> _getPrivateData() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data();
  }

  Color _colorFromDynamic(dynamic value) {
    try {
      if (value == null) return AppThemeColors.lightOnBackground;
      if (value is int) return Color(value);
      if (value is String) {
        var s = value.trim();
        if (s.startsWith('#')) s = s.substring(1);
        if (s.startsWith('0x')) s = s.substring(2);
        // If only RGB provided (6 chars), add opaque alpha
        if (s.length <= 6) s = 'ff${s.padLeft(6, '0')}';
        final v = int.parse(s, radix: 16);
        return Color(v);
      }
    } catch (e) {
      // Color parse error, use default
    }
    return AppThemeColors.lightOnBackground;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _getPrivateData(),
      builder: (context, snapshot) {
        final private = snapshot.data ?? {};
        final isAdmin = private['admin'] == true;
        final lastLoginRaw = private['lastLogin'];
        String lastLoginStr = '';
        if (lastLoginRaw is Timestamp) {
          final dt = lastLoginRaw.toDate();
          lastLoginStr =
              '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } else if (lastLoginRaw is DateTime) {
          final dt = lastLoginRaw;
          lastLoginStr =
              '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
        } else {
          lastLoginStr = lastLoginRaw?.toString() ?? '';
        }
        final email = private['email'] ?? 'Unknown';
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                SwimmerIconPicker.buildIcon(
                  _colorFromDynamic(data['iconColor']),
                  radius: 20,
                ),
                if (isAdmin)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Icon(Icons.star, size: 12, color: Colors.white),
                  ),
              ],
            ),
            title: currentUserIsAdmin
                ? Row(
                    children: [
                      Expanded(child: Text(data['displayName'] ?? 'Unknown')),
                      IconButton(
                        icon: const Icon(Icons.edit_note, size: 16),
                        onPressed: () => _editDisplayName(context),
                        tooltip: 'Edit display name',
                      ),
                    ],
                  )
                : Text(data['displayName'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (currentUserIsAdmin) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_note, size: 16),
                        onPressed: () => _editOccupation(context),
                        tooltip: 'Edit occupation',
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                        child: Text(
                            'Occupation: ${data['occupation'] ?? 'Unknown'}')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final uri =
                              Uri(scheme: 'mailto', path: email.toString());
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        child: Text('Email: $email',
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).colorScheme.primary)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('Last login: $lastLoginStr')),
                  ],
                ),
              ],
            ),
            trailing: currentUserIsAdmin
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.message, size: 20),
                        onPressed: () => _sendMessageToUser(context),
                        tooltip: 'Send message',
                      ),
                      const SizedBox(width: 8),
                      if (isAdmin)
                        Text('Admin',
                            style: AppTextStyles.body()
                                .copyWith(fontWeight: AppFontWeights.bold)),
                      const SizedBox(width: 8),
                      Switch(
                        value: isAdmin,
                        onChanged: (value) =>
                            _toggleAdminStatus(context, value),
                      ),
                    ],
                  )
                : isAdmin
                    ? Text('Admin',
                        style: AppTextStyles.body()
                            .copyWith(fontWeight: AppFontWeights.bold))
                    : null,
          ),
        );
      },
    );
  }

  Future<void> _toggleAdminStatus(BuildContext context, bool makeAdmin) async {
    final displayName = data['displayName'] ?? 'Unknown';
    final action = makeAdmin
        ? 'grant admin permissions to'
        : 'revoke admin permissions from';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Action'),
        content: Text('Are you sure you want to $action $displayName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(makeAdmin ? 'Grant Admin' : 'Revoke Admin'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await UserService.updateAdminStatus(userId, makeAdmin);
        // Also update custom claims via server
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final idToken = await currentUser.getIdToken();
          final response = await http.post(
            Uri.parse(
                'https://floatit-notifications.tinybo.eu/admin/set-claim'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: '{"uid":"$userId","admin":$makeAdmin}',
          );
          if (response.statusCode != 200) {
            // Log error but don't fail the operation
          }
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Successfully ${makeAdmin ? 'granted' : 'revoked'} admin permissions for $displayName'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update admin status: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editDisplayName(BuildContext context) async {
    final controller = TextEditingController(text: data['displayName'] ?? '');
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Display Name'),
            autofocus: true,
            validator: (value) => ValidationUtils.validateDisplayName(value),
            maxLength: 30,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != data['displayName']) {
      try {
        await UserService.updateDisplayName(userId, newName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Display name updated to "$newName"')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update display name: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editOccupation(BuildContext context) async {
    const occupations = [
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
    String? selected = data['occupation'];
    if (selected != null && !occupations.contains(selected)) {
      selected = 'Other'; // Default to Other if current is not in list
    }
    final newOccupation = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Occupation'),
        content: DropdownButton<String>(
          value: selected,
          items: occupations
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (newOccupation != null && newOccupation != data['occupation']) {
      try {
        await UserService.updateOccupation(userId, newOccupation);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Occupation updated to "$newOccupation"')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update occupation: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _sendMessageToUser(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.uid == userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot send a message to yourself')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => _SendMessageDialog(
        recipientName: data['displayName'] ?? 'Unknown User',
        recipientId: userId,
      ),
    );
  }
}

class _SendMessageDialog extends StatefulWidget {
  final String recipientName;
  final String recipientId;

  const _SendMessageDialog({
    required this.recipientName,
    required this.recipientId,
  });

  @override
  State<_SendMessageDialog> createState() => _SendMessageDialogState();
}

class _SendMessageDialogState extends State<_SendMessageDialog> {
  final _formKey = GlobalKey<FormState>();
  String _message = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Message to ${widget.recipientName}'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Message'),
              onChanged: (v) => setState(() => _message = v),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Message is required'
                  : null,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState?.validate() != true) return;

            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser == null) {
              messenger.showSnackBar(
                const SnackBar(
                    content: Text('You must be logged in to send messages')),
              );
              return;
            }

            try {
              final firestore = FirebaseFirestore.instance;

              // Generate conversation ID (sorted to ensure consistency)
              final participants = [currentUser.uid, widget.recipientId]
                ..sort();
              final conversationId = participants.join('_');

              // Check if conversation exists
              final conversationDoc = await firestore
                  .collection('messages')
                  .doc(conversationId)
                  .get();

              final messageId = firestore.collection('messages').doc().id;

              if (conversationDoc.exists) {
                // Update existing conversation
                await firestore
                    .collection('messages')
                    .doc(conversationId)
                    .update({
                  'messages.$messageId': {
                    'senderId': currentUser.uid,
                    'text': _message.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  },
                  'lastMessage': _message.trim(),
                  'lastMessageTime': FieldValue.serverTimestamp(),
                  'unreadCount.${widget.recipientId}': FieldValue.increment(1),
                  'deleteAt': Timestamp.fromDate(
                      DateTime.now().add(const Duration(days: 15))),
                });
              } else {
                // Create new conversation
                await firestore.collection('messages').doc(conversationId).set({
                  'participants': participants,
                  'eventId':
                      null, // Regular user conversation, not event-related
                  'lastMessage': _message.trim(),
                  'lastMessageTime': FieldValue.serverTimestamp(),
                  'unreadCount': {widget.recipientId: 1},
                  'createdAt': FieldValue.serverTimestamp(),
                  'deleteAt': Timestamp.fromDate(
                      DateTime.now().add(const Duration(days: 15))),
                  'messages': {
                    messageId: {
                      'senderId': currentUser.uid,
                      'text': _message.trim(),
                      'timestamp': FieldValue.serverTimestamp(),
                    }
                  }
                });
              }

              // Create pending notification document
              try {
                // Get sender's display name
                final senderDoc = await firestore
                    .collection('public_users')
                    .doc(currentUser.uid)
                    .get();
                final senderName = senderDoc.exists 
                    ? (senderDoc.data()?['displayName'] ?? 'Admin')
                    : 'Admin';

                await firestore
                    .collection('message_notifications')
                    .add({
                  'recipientId': widget.recipientId,
                  'senderId': currentUser.uid,
                  'senderName': senderName,
                  'message': _message.trim(),
                  'conversationId': conversationId,
                  'status': 'pending',
                  'createdAt': DateTime.now().toUtc().toIso8601String(),
                });

                // Send push notification immediately via Vercel function
                try {
                                    const vercelUrl = '${ExternalConfig.vercelFunctionsUrl}/api/send-notification';
                  await http.post(
                    Uri.parse(vercelUrl),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode({}),
                  );
                } catch (e) {
                  // Push notification failed, but message was sent
                }
              } catch (e) {
                // Error creating pending notification: $e
                // Don't fail the message send
              }

              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(
                    content: Text('Message sent to ${widget.recipientName}')),
              );
            } catch (e) {
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Failed to send message')),
              );
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}
