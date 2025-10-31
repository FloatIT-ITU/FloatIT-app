import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'styles.dart';
import 'edit_event_page.dart';
import 'package:floatit/src/utils/navigation_utils.dart';

class AdminEventManagementPage extends StatefulWidget {
  const AdminEventManagementPage({super.key});

  @override
  State<AdminEventManagementPage> createState() =>
      _AdminEventManagementPageState();
}

class _AdminEventManagementPageState extends State<AdminEventManagementPage> {
  String _search = '';
  String _filterType = 'All';
  String _filterStatus = 'All'; // All, Upcoming, Past

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(
              title: 'Event Management', showBackArrow: true),
          Expanded(
            child: ConstrainedContent(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('startTime', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;

                  // Extract event types for filter
                  final eventTypes = <String>{};
                  for (var doc in docs) {
                    final type = (doc['type'] ?? '').toString();
                    if (type.isNotEmpty) eventTypes.add(type);
                  }
                  final typeList = ['All', ...eventTypes.toList()..sort()];

                  // Filter events
                  final now = DateTime.now();
                  final events = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final title = (data['name'] ?? '').toString().toLowerCase();
                    final location =
                        (data['location'] ?? '').toString().toLowerCase();
                    final host = (data['host'] ?? '').toString().toLowerCase();
                    final type = (data['type'] ?? '').toString();

                    // Parse event time
                    final startTimeRaw = data['startTime'];
                    DateTime? startTime;
                    if (startTimeRaw is Timestamp) {
                      startTime = startTimeRaw.toDate();
                    } else if (startTimeRaw is String) {
                      startTime = DateTime.tryParse(startTimeRaw);
                    }

                    // Search filter
                    final matchesSearch = title.contains(_search) ||
                        location.contains(_search) ||
                        host.contains(_search);

                    // Type filter
                    final matchesType =
                        _filterType == 'All' || type == _filterType;

                    // Status filter
                    bool matchesStatus = true;
                    if (_filterStatus == 'Upcoming' && startTime != null) {
                      matchesStatus = startTime.isAfter(now);
                    } else if (_filterStatus == 'Past' && startTime != null) {
                      matchesStatus = startTime.isBefore(now);
                    }

                    return matchesSearch && matchesType && matchesStatus;
                  }).toList();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText:
                                          'Search by name, location, or host',
                                      prefixIcon: Icon(Icons.search),
                                    ),
                                    onChanged: (value) => setState(() =>
                                        _search = value.trim().toLowerCase()),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _filterType,
                                    hint: const Text('Type'),
                                    isExpanded: true,
                                    items: typeList
                                        .map((e) => DropdownMenuItem(
                                            value: e, child: Text(e)))
                                        .toList(),
                                    onChanged: (value) => setState(
                                        () => _filterType = value ?? 'All'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButton<String>(
                                    value: _filterStatus,
                                    hint: const Text('Status'),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                          value: 'All', child: Text('All')),
                                      DropdownMenuItem(
                                          value: 'Upcoming',
                                          child: Text('Upcoming')),
                                      DropdownMenuItem(
                                          value: 'Past', child: Text('Past')),
                                    ],
                                    onChanged: (value) => setState(
                                        () => _filterStatus = value ?? 'All'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, i) {
                            final data =
                                events[i].data() as Map<String, dynamic>;
                            final eventId = events[i].id;
                            return _EventCard(eventId: eventId, data: data);
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
  }
}

class _EventCard extends StatelessWidget {
  final String eventId;
  final Map<String, dynamic> data;

  const _EventCard({required this.eventId, required this.data});

  Future<String> _getHostName() async {
    final hostId = data['host'] ?? '';
    if (hostId.isEmpty) return 'Unknown Host';

    try {
      // Try to get display name from public_users first
      final publicDoc = await FirebaseFirestore.instance
          .collection('public_users')
          .doc(hostId)
          .get();

      if (publicDoc.exists) {
        final publicData = publicDoc.data() ?? {};
        final displayName = publicData['displayName'];
        if (displayName != null && displayName.toString().isNotEmpty) {
          return displayName.toString();
        }
      }

      // Fallback to email from users collection
      final privateDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(hostId)
          .get();

      if (privateDoc.exists) {
        final privateData = privateDoc.data() ?? {};
        final email = privateData['email'];
        if (email != null && email.toString().isNotEmpty) {
          return email.toString();
        }
      }

      return 'User $hostId';
    } catch (e) {
      return 'Unknown Host';
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = data['name'] ?? 'Unknown Event';
    final location = data['location'] ?? 'Unknown Location';
    final type = data['type'] ?? 'Unknown Type';
    final attendeeLimit = data['attendeeLimit'] ?? 0;
    final attendees = List<String>.from(data['attendees'] ?? []);
    final waitingList = List<String>.from(data['waitingListUids'] ?? []);

    // Parse start time
    final startTimeRaw = data['startTime'];
    String startTimeStr = 'Unknown Time';
    bool isPast = false;
    if (startTimeRaw is Timestamp) {
      final dt = startTimeRaw.toDate();
      isPast = dt.isBefore(DateTime.now());
      startTimeStr =
          '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (startTimeRaw is String) {
      final dt = DateTime.tryParse(startTimeRaw);
      if (dt != null) {
        isPast = dt.isBefore(DateTime.now());
        startTimeStr =
            '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        leading: Icon(
          isPast ? Icons.event_busy : Icons.event,
          color: isPast ? Colors.grey : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isPast ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getHostName(),
              builder: (context, snapshot) {
                final hostName = snapshot.data ?? 'Loading...';
                return Text('Host: $hostName');
              },
            ),
            Text('Time: $startTimeStr'),
            Text('Location: $location'),
            Text('Type: $type'),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Attendees: ${attendees.length}/${attendeeLimit > 0 ? attendeeLimit : '∞'}',
                      style: AppTextStyles.body()
                          .copyWith(fontWeight: AppFontWeights.bold),
                    ),
                    if (waitingList.isNotEmpty)
                      Text(
                        'Waiting: ${waitingList.length}',
                        style: AppTextStyles.body().copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data['description'] != null &&
                    data['description'].toString().isNotEmpty) ...[
                  Text(
                    'Description:',
                    style: AppTextStyles.body()
                        .copyWith(fontWeight: AppFontWeights.bold),
                  ),
                  Text(
                    data['description'].toString(),
                    style: AppTextStyles.caption(),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      onPressed: () {
                        _showEditDialog(context, eventId, data);
                      },
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.people),
                      label: const Text('Attendees'),
                      onPressed: () {
                        _showAttendeesDialog(
                            context, eventId, attendees, waitingList);
                      },
                    ),
                    TextButton.icon(
                      icon: Icon(Icons.delete,
                          color: Theme.of(context).colorScheme.error),
                      label: Text('Delete',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                      onPressed: () {
                        _showDeleteConfirmation(context, eventId, title);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context, String eventId, Map<String, dynamic> data) {
    NavigationUtils.pushWithoutAnimation(
      context,
      EditEventPage(eventId: eventId, eventData: data),
    );
  }

  void _showAttendeesDialog(BuildContext context, String eventId,
      List<String> attendees, List<String> waitingList) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Event Attendees'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400, // Set a fixed height to prevent overflow
          child: FutureBuilder<Map<String, Map<String, dynamic>>>(
            future: _fetchUserDetails([...attendees, ...waitingList]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error loading attendees: ${snapshot.error}');
              }

              final userDetails = snapshot.data ?? {};

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (attendees.isNotEmpty) ...[
                      Text('Attendees (${attendees.length}):',
                          style: AppTextStyles.body()
                              .copyWith(fontWeight: AppFontWeights.bold)),
                      const SizedBox(height: 8),
                      ...attendees.map((uid) {
                        final user = userDetails[uid];
                        final name = user?['displayName'] ?? 'Unknown User';
                        final email = user?['email'] ?? 'Unknown Email';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• $name',
                                  style: AppTextStyles.body().copyWith(
                                      fontWeight: AppFontWeights.bold)),
                              Text('  $email', style: AppTextStyles.caption()),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                    if (waitingList.isNotEmpty) ...[
                      Text('Waiting List (${waitingList.length}):',
                          style: AppTextStyles.body()
                              .copyWith(fontWeight: AppFontWeights.bold)),
                      const SizedBox(height: 8),
                      ...waitingList.map((uid) {
                        final user = userDetails[uid];
                        final name = user?['displayName'] ?? 'Unknown User';
                        final email = user?['email'] ?? 'Unknown Email';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• $name',
                                  style: AppTextStyles.body().copyWith(
                                      fontWeight: AppFontWeights.bold)),
                              Text('  $email', style: AppTextStyles.caption()),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (attendees.isEmpty && waitingList.isEmpty)
                      const Text('No attendees yet.'),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, Map<String, dynamic>>> _fetchUserDetails(
      List<String> userIds) async {
    final Map<String, Map<String, dynamic>> userDetails = {};

    // Fetch user data from both collections to get complete information
    for (String userId in userIds) {
      try {
        // Fetch public data (displayName, occupation, etc.)
        final publicDoc = await FirebaseFirestore.instance
            .collection('public_users')
            .doc(userId)
            .get();

        // Fetch private data (email)
        final privateDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        final publicData =
            publicDoc.exists ? (publicDoc.data() ?? {}) : <String, dynamic>{};
        final privateData =
            privateDoc.exists ? (privateDoc.data() ?? {}) : <String, dynamic>{};

        // Merge the data, prioritizing public data for display name
        userDetails[userId] = {
          'displayName': publicData['displayName'] ??
              privateData['email'] ??
              'Unknown User',
          'email': privateData['email'] ?? 'Unknown Email',
          'occupation': publicData['occupation'] ?? '',
        };
      } catch (e) {
        // If we can't fetch user data, use fallback
        userDetails[userId] = {
          'displayName': 'User $userId',
          'email': 'Unable to load',
        };
      }
    }

    return userDetails;
  }

  void _showDeleteConfirmation(
      BuildContext context, String eventId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
            'Are you sure you want to delete "$title"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('events')
                    .doc(eventId)
                    .delete();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Event "$title" deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting event: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
