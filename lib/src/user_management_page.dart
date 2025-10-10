import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'styles.dart';
import 'package:provider/provider.dart';
import 'user_profile_provider.dart';
import 'user_service.dart';
import 'utils/validation_utils.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String _search = '';
  String _filterOccupation = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, userProfile, child) {
        final currentUserIsAdmin = userProfile.isAdmin;
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StandardPageBanner(title: 'User Management', showBackArrow: true),
              Expanded(
                child: ConstrainedContent(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('public_users').snapshots(),
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
                      final occupationList = ['All', ...occupations.toList()..sort()];
                      final users = docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['displayName'] ?? '').toString().toLowerCase();
                        final email = (data['email'] ?? '').toString().toLowerCase();
                        final occupation = (data['occupation'] ?? '').toString();
                        final matchesSearch = name.contains(_search) || email.contains(_search);
                        final matchesFilter = _filterOccupation == 'All' || occupation == _filterOccupation;
                        return matchesSearch && matchesFilter;
                      }).toList();
                      users.sort((a, b) {
                        final nameA = ((a.data() as Map<String, dynamic>)['displayName'] ?? '').toString().toLowerCase();
                        final nameB = ((b.data() as Map<String, dynamic>)['displayName'] ?? '').toString().toLowerCase();
                        return nameA.compareTo(nameB);
                      });
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
                                    onChanged: (value) => setState(() => _search = value.trim().toLowerCase()),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<String>(
                                  value: _filterOccupation,
                                  items: occupationList.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (value) => setState(() => _filterOccupation = value ?? 'All'),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: users.length,
                              itemBuilder: (context, i) {
                                final data = users[i].data() as Map<String, dynamic>;
                                final userId = users[i].id;
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
            leading: isAdmin
                ? Icon(Icons.shield,
                    color: Theme.of(context).colorScheme.secondary)
                : const Icon(Icons.person_2),
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
                    Text('Occupation: ${data['occupation'] ?? 'Unknown'}'),
                    if (currentUserIsAdmin) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.edit_note, size: 16),
                        onPressed: () => _editOccupation(context),
                        tooltip: 'Edit occupation',
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('Email: $email')),
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
                      if (isAdmin)
                        Text('Admin',
                            style: AppTextStyles.body()
                                .copyWith(fontWeight: AppFontWeights.bold)),
                      const SizedBox(width: 8),
                      Switch(
                        value: isAdmin,
                        onChanged: (value) => _toggleAdminStatus(context, value),
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
    final action = makeAdmin ? 'grant admin permissions to' : 'revoke admin permissions from';
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully ${makeAdmin ? 'granted' : 'revoked'} admin permissions for $displayName'),
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

    if (newName != null && newName.isNotEmpty && newName != data['displayName']) {
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
    final controller = TextEditingController(text: data['occupation'] ?? '');
    final newOccupation = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Occupation'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Occupation'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
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
}
