import 'package:floatit/src/widgets/banners.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floatit/src/widgets/attendee_list.dart'; // Normalize import
import 'package:floatit/src/widgets/notification_banner.dart';
import 'package:floatit/src/widgets/attendee_list_builder.dart';
import 'package:floatit/src/widgets/event_details_display.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'package:floatit/src/event_service.dart';
import 'package:floatit/src/theme_colors.dart';
import 'package:floatit/src/user_statistics_service.dart';
import 'package:floatit/src/layout_widgets.dart';
import 'user_profile_provider.dart';
// import 'notification_provider.dart'; (removed, no longer needed)
// import 'push_service.dart'; (removed, push notifications fully removed)
import 'package:floatit/src/widgets/event_name_field.dart';
import 'package:floatit/src/widgets/event_description_field.dart';
import 'package:floatit/src/widgets/event_location_field.dart';
import 'package:floatit/src/widgets/event_date_time_field.dart';
import 'package:floatit/src/widgets/event_attendee_limit_field.dart';
import 'package:floatit/src/widgets/event_type_dropdown.dart';
import 'package:floatit/src/widgets/event_host_dropdown.dart';
import 'package:floatit/src/widgets/event_waiting_list_switch.dart';
import 'package:floatit/src/widgets/swimmer_icon_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pending_requests_provider.dart';
import 'package:provider/provider.dart';
import 'services/rate_limit_service.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;
  const EventDetailsPage({super.key, required this.eventId});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  Widget _buildPageBannerAndPromotion(
      {required bool isAdmin, required bool editing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StandardPageBanner(
          title: editing ? 'Edit Event' : 'Event Details',
          showBackArrow: true,
          onBack: editing
              ? () => setState(() => _editing = false)
              : () => Navigator.of(context).maybePop(),
        ),
        // Add actions row for admin editing if needed
        if (isAdmin && !editing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseService.eventBanner(widget.eventId).snapshots(),
                  builder: (context, snap) {
                    final hasBanner = snap.hasData && snap.data!.exists;
                    return IconButton(
                      icon: Icon(hasBanner ? Icons.notifications_off : Icons.notifications),
                      tooltip: hasBanner ? 'Remove Notification' : 'Send Notification',
                      onPressed: hasBanner
                          ? () => _showRemoveNotificationDialog(context)
                          : () => _showSendNotificationDialog(context),
                    );
                  },
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Event',
                  onPressed: () => setState(() => _editing = true),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildJoinLeaveButton(Map<String, dynamic> eventData) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();
    final uid = user.uid;
    final attendeeUidsRaw = List<String>.from(eventData['attendees'] ?? []);
    final waitingListUids =
        List<String>.from(eventData['waitingListUids'] ?? []);
    final maxAttendees = eventData['attendeeLimit'] ?? 0;
    final hostId = eventData['host'] as String?;
    // Count host as attendee if not already in attendees
    int attendeeCount = attendeeUidsRaw.length;
    if (hostId != null && !attendeeUidsRaw.contains(hostId)) {
      attendeeCount += 1;
    }
    final isAttendee = attendeeUidsRaw.contains(uid);
    final isWaiting = waitingListUids.contains(uid);
    final isHost = hostId == uid;
    String buttonText;
    if (isHost) {
      buttonText = 'You are the Host';
    } else if (isAttendee) {
      buttonText = 'Leave Event';
    } else if (isWaiting) {
      buttonText = 'Leave Waiting List';
    } else if (maxAttendees == 0 || attendeeCount < maxAttendees) {
      buttonText = 'Join Event';
    } else {
      buttonText = 'Join Waiting List';
    }
    final pendingProvider = Provider.of<PendingRequestsProvider>(context);
    final isPending = pendingProvider.isPending(widget.eventId);
    final displayText = isPending ? 'Requested' : buttonText;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ElevatedButton(
        onPressed: (isHost)
            ? null
            : () async {
                // Rate limiting check
                final rateLimitService = RateLimitService.instance;
                final actionType = isAttendee || isWaiting 
                    ? RateLimitAction.leaveEvent 
                    : RateLimitAction.joinEvent;
                
                if (!rateLimitService.isActionAllowed(uid, actionType)) {
                  return;
                }
                
                try {
                  // Record the action before processing
                  rateLimitService.recordAction(uid, actionType);
                  
                  await FirebaseService.runTransaction((txn) async {
                    final eventRef = FirebaseService.eventDoc(widget.eventId);
                    final eventSnap = await txn.get(eventRef);
                    if (!eventSnap.exists) throw Exception('Event not found');
                    final data = eventSnap.data()! as Map<String, dynamic>;
                    List<String> attendees =
                        List<String>.from(data['attendees'] ?? []);
                    List<String> waitingList =
                        List<String>.from(data['waitingListUids'] ?? []);
                    final maxAttendees = data['attendeeLimit'] ?? 0;
                    final hostId = data['host'] as String?;
                    int attendeeCount = attendees.length;
                    if (hostId != null && !attendees.contains(hostId)) {
                      attendeeCount += 1;
                    }
                    bool leftAttendee = false;
                    if (attendees.contains(uid)) {
                      attendees.remove(uid);
                      leftAttendee = true;
                    } else if (waitingList.contains(uid)) {
                      waitingList.remove(uid);
                    } else {
                      if (maxAttendees == 0 || attendeeCount < maxAttendees) {
                        attendees.add(uid);
                      } else {
                        waitingList.add(uid);
                      }
                    }
                    // Promote from waiting list if space is available
                    int newAttendeeCount = attendees.length;
                    if (hostId != null && !attendees.contains(hostId)) {
                      newAttendeeCount += 1;
                    }
                    if (leftAttendee &&
                        (maxAttendees == 0 || newAttendeeCount < maxAttendees) &&
                        waitingList.isNotEmpty) {
                      // Promote first user in waiting list
                      attendees.add(waitingList.first);
                      waitingList.removeAt(0);
                    }
                    txn.update(eventRef, {
                      'attendees': attendees,
                      'waitingListUids': waitingList,
                    });
                  });
                  
                  // Record statistics for join/leave actions
                  try {
                    final eventData = await FirebaseService.eventDoc(widget.eventId).get();
                    final eventMap = eventData.data() as Map<String, dynamic>?;
                    final startTimeStr = eventMap?['startTime'] as String?;
                    final eventDate = startTimeStr != null ? DateTime.tryParse(startTimeStr)?.toLocal() : null;
                    
                    if (eventDate != null) {
                      if (actionType == RateLimitAction.leaveEvent) {
                        // User left the event (either attendee or waiting list)
                        await UserStatisticsService.removeEventJoin(uid, widget.eventId);
                      } else if (actionType == RateLimitAction.joinEvent) {
                        // User joined the event (either as attendee or waiting)
                        await UserStatisticsService.recordEventJoin(uid, widget.eventId, eventDate);
                      }
                    }
                  } catch (e) {
                    // Statistics recording failed - non-critical, don't show error
                  }
                  
                  if (!mounted) return;
                  String actionMsg;
                  if (isAttendee) {
                    actionMsg = 'Left event';
                  } else if (isWaiting) {
                    actionMsg = 'Left waiting list';
                  } else if (maxAttendees == 0 || attendeeUidsRaw.length < maxAttendees) {
                    actionMsg = 'Joined event';
                  } else {
                    actionMsg = 'Joined waiting list';
                  }
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(actionMsg)));
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')));
                  }
                }
                // Refresh provider cache and event
                await pendingProvider.refresh();
                if (!mounted) return;
                await _loadEvent();
                if (!mounted) return;
                await _loadHost();
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 6),
            Text(displayText),
          ],
        ),
      ),
    );
  }

  bool _editing = false;
  Map<String, dynamic>? _eventData;
  bool _loading = true;
  bool _saving = false;
  final _formKey = GlobalKey<FormState>();

  // Host info cache
  Attendee? _hostAttendee;
  bool _hostLoading = false;
  String? _hostError;
  String? _loadedHostId;

  // Parse Firestore stored color values which may be int or hex string.
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
  void initState() {
    super.initState();
    _loadEvent();
    _loadHost();
  }

  Future<void> _loadHost([String? hostId]) async {
    setState(() {
      _hostLoading = true;
      _hostError = null;
    });
    try {
      if (hostId == null) {
        final eventDoc = await FirebaseService.eventDoc(widget.eventId).get();
        final eventData = eventDoc.data() as Map<String, dynamic>?;
        hostId = eventData?['host'] as String?;
      }
      if (hostId == null || hostId.isEmpty) {
        setState(() {
          _hostAttendee = null;
          _hostLoading = false;
        });
        return;
      }
      // Try public profile first
      final publicDoc = await FirebaseService.publicUserDoc(hostId).get();
      final publicData = publicDoc.data() as Map<String, dynamic>?;
      String name = 'Unknown';
      String occupation = '';
      Color color = AppThemeColors.lightOnBackground;
      bool hostIsAdmin = false;

      if (publicData != null) {
        // Public profile available -> use it
        name = publicData['displayName'] ?? (publicData['email'] ?? hostId);
        occupation = publicData['occupation'] ?? '';
        color = _colorFromDynamic(publicData['iconColor']);
      } else {
        // No public profile. Only attempt to read the private `users/{hostId}`
        // document if the current user is the host themselves or an admin.
        final authUser = FirebaseAuth.instance.currentUser;
        bool canReadPrivateHost = false;

        if (authUser != null) {
          if (authUser.uid == hostId) {
            // Owner may read their own private doc per rules
            canReadPrivateHost = true;
          } else {
            // Check whether the current user is an admin by reading their own
            // private doc (allowed since it's the owner's doc). If they're an
            // admin, they may read other private user docs per rules.
            try {
              final myPrivate = await FirebaseService.userDoc(authUser.uid).get();
              final myData = myPrivate.data() as Map<String, dynamic>?;
              if (myData != null && myData['admin'] == true) {
                canReadPrivateHost = true;
              }
            } catch (_) {
              // If we can't read our own private doc for any reason, assume
              // we are not admin and don't attempt to read the host's private doc.
              canReadPrivateHost = false;
            }
          }
        }

        if (canReadPrivateHost) {
          final privateDoc = await FirebaseService.userDoc(hostId).get();
          final privateData = privateDoc.data() as Map<String, dynamic>?;
          if (privateData != null) {
            name = privateData['displayName'] ?? privateData['email'] ?? hostId;
            occupation = privateData['occupation'] ?? '';
            color = _colorFromDynamic(privateData['iconColor']);
            hostIsAdmin = privateData['admin'] == true;
          } else {
            // If even the private doc doesn't exist, fallback to auth info
            if (authUser != null && authUser.uid == hostId) {
              name = authUser.displayName ?? authUser.email ?? hostId;
            }
          }
        } else {
          // Don't attempt to read other users' private docs — that will
          // trigger permission-denied for normal users. Use a safe fallback
          // to avoid errors and show minimal host info.
          name = hostId;
          occupation = '';
          color = AppThemeColors.lightOnBackground;
          hostIsAdmin = false;
        }
      }

      setState(() {
        _hostAttendee = Attendee(
            uid: hostId!,
            name: name,
            occupation: occupation,
            avatarUrl: null,
            color: color,
            isAdmin: hostIsAdmin);
        _hostLoading = false;
        _loadedHostId = hostId;
      });
    } catch (e) {
      // Prevent tight retry loops when a hostId can't be resolved: mark
      // this hostId as 'loaded' so we don't repeatedly re-attempt while
      // the stream rebuilds quickly. A future change to the host field
      // will still trigger a reload.
      setState(() {
        _hostError = 'Host not found: ${hostId ?? 'unknown'}';
        _hostAttendee = null;
        _hostLoading = false;
        if (hostId != null && hostId.isNotEmpty) _loadedHostId = hostId;
      });
    }
  }

  Future<void> _loadEvent() async {
    setState(() => _loading = true);
    final doc = await FirebaseService.eventDoc(widget.eventId).get();
    setState(() {
      _eventData = doc.data() as Map<String, dynamic>?;
      _loading = false;
    });
  }

  Future<void> _contactHost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || _hostAttendee == null) return;

    final hostId = _hostAttendee!.uid;

    // Prevent messaging yourself
    if (currentUser.uid == hostId) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot message yourself')),
        );
      }
      return;
    }

    final messageController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact host'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send a message to ${_hostAttendee!.name}:'),
            const SizedBox(height: 12),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed == true && messageController.text.trim().isNotEmpty) {
      try {
        final messageText = messageController.text.trim();
        
        // Create or get thread ID (sorted user IDs to ensure consistency)
        final participants = [currentUser.uid, hostId]..sort();
        final threadId = '${participants[0]}_${participants[1]}_${widget.eventId}';
        
        final threadRef = FirebaseFirestore.instance.collection('messages').doc(threadId);
        final threadDoc = await threadRef.get();
        
        // Generate unique message ID
        final messageId = FirebaseFirestore.instance.collection('messages').doc().id;
        
        if (!threadDoc.exists) {
          // Create new thread with first message
          await threadRef.set({
            'participants': participants,
            'eventId': widget.eventId,
            'messages': {
              messageId: {
                'senderId': currentUser.uid,
                'text': messageText,
                'timestamp': FieldValue.serverTimestamp(),
              }
            },
            'unreadCount': {
              currentUser.uid: 0,
              hostId: 1,
            },
            'lastMessage': messageText,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'deleteAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
          });
        } else {
          // Update existing thread with new message
          await threadRef.update({
            'messages.$messageId': {
              'senderId': currentUser.uid,
              'text': messageText,
              'timestamp': FieldValue.serverTimestamp(),
            },
            'unreadCount.$hostId': FieldValue.increment(1),
            'lastMessage': messageText,
            'lastMessageTime': FieldValue.serverTimestamp(),
            'deleteAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 15))),
          });
        }
        
        // Send push notification
        // final pushService = PushService();
        // await pushService.sendNotificationToUsers(
        //   userIds: [hostId],
        //   title: 'Message from $userName',
        //   body: messageText,
        //   eventId: widget.eventId,
        // );
        
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent to host')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: $e')),
          );
        }
      }
    }
    
    messageController.dispose();
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    // Ensure host is in attendees, and previous host is removed if changed
    final docRef = FirebaseService.eventDoc(widget.eventId);
    final doc = await docRef.get();
    final oldData = doc.data() as Map<String, dynamic>?;
    final oldHost = oldData?['host'] as String?;
    final newHost = _eventData!['host'] as String?;
    List<String> attendees = List<String>.from(_eventData!['attendees'] ?? []);
    if (oldHost != null && oldHost != newHost) {
      attendees.remove(oldHost);
    }
    if (newHost != null && !attendees.contains(newHost)) {
      attendees.add(newHost);
    }
    _eventData!['attendees'] = attendees;

    await docRef.update(_eventData!);
    setState(() {
      _editing = false;
      _saving = false;
    });
    await _loadEvent();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<UserProfileProvider>().isAdmin;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_eventData == null) {
      return const Scaffold(body: Center(child: Text('Event not found.')));
    }
    // Removed notificationProvider as it's no longer used here
    // Removed globalBanner as it's no longer used here
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPageBannerAndPromotion(isAdmin: isAdmin, editing: _editing),
          // Show event notification banner always (full width)
          _buildEventBanner(),
          // Main content constrained
          Expanded(
            child: ConstrainedContent(
              child: _editing ? _buildEditForm(isAdmin) : _buildDetailsView(isAdmin),
            ),
          ),
        ],
      ),
    );
  }

  // Display event-scoped banner (attendees see it)
  Widget _buildEventBanner() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.eventBanner(widget.eventId).snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || !snap.data!.exists) return const SizedBox.shrink();
        final data = snap.data!.data() as Map<String, dynamic>;
        final bg = Theme.of(context).brightness == Brightness.dark
            ? AppThemeColors.bannerEventDark
            : AppThemeColors.bannerEventLight;
        return NotificationBanner(
          title: data['title'] ?? '',
          body: data['body'] ?? '',
          backgroundColor: bg,
        );
      },
    );
  }

  Widget _buildDetailsView(bool isAdmin) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.eventDoc(widget.eventId).snapshots(),
      builder: (context, eventSnap) {
        if (!eventSnap.hasData || !eventSnap.data!.exists) {
          return const Center(child: Text('Event not found.'));
        }
        final eventData = eventSnap.data!.data() as Map<String, dynamic>;
        final attendeeUidsRaw = List<String>.from(eventData['attendees'] ?? []);
        final waitingListUids =
            List<String>.from(eventData['waitingListUids'] ?? []);
        // no promotion detection here anymore
        final maxAttendees = eventData['attendeeLimit'] ?? 0;
        final hostId = eventData['host'] as String?;
        // If the host changed in the event stream, reload host info
        if (hostId != _loadedHostId && !_hostLoading) {
          // Avoid calling setState during the build phase -- schedule the
          // host load to run after the current frame finishes.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (hostId != _loadedHostId && !_hostLoading) {
              _loadHost(hostId);
            }
          });
        }
        // Remove host from attendee list, but count them in the attendee total
        final attendeeUids = hostId == null
            ? attendeeUidsRaw
            : attendeeUidsRaw.where((id) => id != hostId).toList();
        final attendeeCount = attendeeUidsRaw.length +
            ((hostId != null && !attendeeUidsRaw.contains(hostId)) ? 1 : 0);
        final listKey = ValueKey(
            '${attendeeUidsRaw.join(',')}-${waitingListUids.join(',')}');
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: ListView(
                key: listKey,
                padding: const EdgeInsets.all(16),
                children: [
                  EventDetailsDisplay(eventData: eventData),
                  // Join/Leave button above Host section
                  _buildJoinLeaveButton(eventData),
                  // Host section (moved here, now uses cached host info)
                  if (_hostLoading)
                    const Center(child: CircularProgressIndicator()),
                  if (_hostError != null)
                    Text(_hostError!,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                  if (!_hostLoading &&
                      _hostError == null &&
                      _hostAttendee != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AttendeeList(
                              title: 'Host',
                              attendees: [_hostAttendee!],
                              showCount: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _contactHost,
                            icon: const Icon(Icons.mail),
                            label: const Text('Contact host'),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(maxAttendees == 0 ? 'Attendees ($attendeeCount)' : 'Attendees ($attendeeCount/$maxAttendees)',
                          style: Theme.of(context).textTheme.titleMedium),
                      if (isAdmin)
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          onPressed: () => _showAddUserDialog(context, eventData),
                          tooltip: 'Add attendee',
                        ),
                    ],
                  ),
                  if (attendeeUids.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
                      child: AttendeeListBuilder(
                        title: '',
                        attendeeUids: attendeeUids,
                        showCount: false,
                        isAdmin: isAdmin,
                        eventId: widget.eventId,
                        onAttendeeRemoved: () => setState(() {}),
                      ),
                    ),

                  // Waiting list below attendee list
                  if (waitingListUids.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: AttendeeListBuilder(
                        title: 'Waiting List',
                        attendeeUids: waitingListUids,
                        showCount: true,
                        isAdmin: isAdmin,
                        eventId: widget.eventId,
                        onAttendeeRemoved: () => setState(() {}),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditForm(bool isAdmin) {
    final data = _eventData!;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          EventNameField(
            controller: TextEditingController(text: data['name'] ?? '')
              ..selection =
                  TextSelection.collapsed(offset: (data['name'] ?? '').length),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            onChanged: (v) => _eventData!['name'] = v,
          ),
          const SizedBox(height: 12),
          EventLocationField(
            controller: TextEditingController(text: data['location'] ?? '')
              ..selection = TextSelection.collapsed(
                  offset: (data['location'] ?? '').length),
            onChanged: (v) => _eventData!['location'] = v,
          ),
          const SizedBox(height: 12),
          EventDescriptionField(
            controller: TextEditingController(text: data['description'] ?? '')
              ..selection = TextSelection.collapsed(
                  offset: (data['description'] ?? '').length),
            onChanged: (v) => _eventData!['description'] = v,
          ),
          const SizedBox(height: 12),
          EventAttendeeLimitField(
            controller: TextEditingController(
                text: data['attendeeLimit']?.toString() ?? '')
              ..selection = TextSelection.collapsed(
                  offset: (data['attendeeLimit']?.toString() ?? '').length),
            onChanged: (v) =>
                _eventData!['attendeeLimit'] = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 12),
          EventDateTimeField(
            initialDateTime: DateTime.tryParse(data['startTime'] ?? ''),
            label: 'Start Time',
            onChanged: (dt) => setState(
                () => _eventData!['startTime'] = dt.toUtc().toIso8601String()),
          ),
          const SizedBox(height: 12),
          EventDateTimeField(
            initialDateTime: DateTime.tryParse(data['endTime'] ?? ''),
            label: 'End Time',
            onChanged: (dt) => setState(
                () => _eventData!['endTime'] = dt.toUtc().toIso8601String()),
          ),
          const SizedBox(height: 12),
          EventTypeDropdown(
            value: data['type'] ?? 'practice',
            eventTypes: const ['practice', 'competition', 'other'],
            onChanged: (v) =>
                setState(() => _eventData!['type'] = v ?? 'practice'),
          ),
          const SizedBox(height: 12),
          FutureBuilder<QuerySnapshot>(
            future: FirebaseService.adminUsersFuture,
            builder: (context, adminSnap) {
              if (adminSnap.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (adminSnap.hasError) {
                return const Text('Error loading admins');
              } else if (!adminSnap.hasData || adminSnap.data!.docs.isEmpty) {
                return const Text('No admins found');
              }
              final adminDocs = adminSnap.data!.docs;
              final adminUids = adminDocs.map((doc) => doc.id).toList();
              if (adminUids.isEmpty) {
                return EventHostDropdown(
                  value: data['host'],
                  items: const [
                    DropdownMenuItem<String>(
                        value: null, child: Text('No admins found'))
                  ],
                  onChanged: (v) => setState(() => _eventData!['host'] = v),
                );
              }
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseService.publicUsers
                    .where(FieldPath.documentId, whereIn: adminUids)
                    .get(),
                builder: (context, publicSnap) {
                  if (publicSnap.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (publicSnap.hasError) {
                    return const Text('Error loading admin names');
                  }
                  final publicDocs = publicSnap.data?.docs ?? [];
                  final publicMap = {
                    for (var doc in publicDocs) doc.id: doc.data()
                  };
                  return EventHostDropdown(
                    value: data['host'],
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('Select host')),
                      ...adminDocs.map((admin) {
                        final public =
                            publicMap[admin.id] as Map<String, dynamic>? ?? {};
                        final displayName = (public['displayName'] is String &&
                                (public['displayName'] as String)
                                    .trim()
                                    .isNotEmpty)
                            ? public['displayName'] as String
                            : (public['email'] ?? admin.id);
                        return DropdownMenuItem<String>(
                          value: admin.id,
                          child: Text(displayName),
                        );
                      }),
                    ],
                    onChanged: (v) => setState(() => _eventData!['host'] = v),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),
          EventWaitingListSwitch(
            value: data['waitingList'] ?? false,
            onChanged: (v) => setState(() => _eventData!['waitingList'] = v),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton(
                onPressed: _saving ? null : _saveEvent,
                child: _saving
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed:
                    _saving ? null : () => setState(() => _editing = false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, Map<String, dynamic> eventData) async {
    final selectedUser = await showDialog<String>(
      context: context,
      builder: (context) => const _AddUserDialog(),
    );

    if (selectedUser != null) {
      await _addUserToEvent(selectedUser, eventData);
    }
  }

  Future<void> _addUserToEvent(String userId, Map<String, dynamic> eventData) async {
    try {
      await FirebaseService.runTransaction((txn) async {
        final eventRef = FirebaseService.eventDoc(widget.eventId);
        final eventSnap = await txn.get(eventRef);

        if (!eventSnap.exists) return;

        final data = eventSnap.data() as Map<String, dynamic>;
        final attendees = List<String>.from(data['attendees'] ?? []);
        final waitingList = List<String>.from(data['waitingListUids'] ?? []);
        final maxAttendees = data['attendeeLimit'] ?? 0;

        // Don't add if already an attendee
        if (attendees.contains(userId)) return;

        // Remove from waiting list if present
        waitingList.remove(userId);

        // Add to attendees if there's space or unlimited
        if (maxAttendees == 0 || attendees.length < maxAttendees) {
          attendees.add(userId);
        } else {
          // Add to waiting list if full
          waitingList.add(userId);
        }

        txn.update(eventRef, {
          'attendees': attendees,
          'waitingListUids': waitingList,
        });
      });

      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added to event')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add user to event')),
        );
      }
    }
  }

  void _showSendNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SendNotificationDialog(eventId: widget.eventId),
    );
  }

  void _showRemoveNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Event Notification'),
        content: const Text('This will remove the current event notification. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);

              try {
                final doc = FirebaseService.eventBanner(widget.eventId);
                await doc.delete();

                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Event notification removed')),
                );
              } catch (e) {
                if (!mounted) return;
                messenger.showSnackBar(
                  const SnackBar(content: Text('Failed to remove notification')),
                );
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _SendNotificationDialog extends StatefulWidget {
  final String eventId;

  const _SendNotificationDialog({required this.eventId});

  @override
  State<_SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<_SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _body = '';
  bool _sendAsSystemMessage = true; // Pre-selected by default

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Event Notification'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (v) => setState(() => _title = v),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Title is required'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Message'),
              onChanged: (v) => setState(() => _body = v),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Message is required'
                  : null,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text('Also send as system message to attendees'),
              subtitle: const Text('Send this notification as a personal message to all event attendees and waiting list members'),
              value: _sendAsSystemMessage,
              onChanged: (value) => setState(() => _sendAsSystemMessage = value ?? true),
              dense: true,
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

            try {
              final doc = FirebaseService.eventBanner(widget.eventId);
              await doc.set({
                'title': _title.trim(),
                'body': _body.trim(),
                'createdAt': DateTime.now().toUtc().toIso8601String(),
              });

              // Send system messages to attendees if requested
              if (_sendAsSystemMessage) {
                try {
                  final eventDoc = await FirebaseService.eventDoc(widget.eventId).get();
                  if (eventDoc.exists) {
                    final eventData = eventDoc.data() as Map<String, dynamic>;
                    final attendees = List<String>.from(eventData['attendees'] ?? []);
                    final waitingList = List<String>.from(eventData['waitingListUids'] ?? []);
                    
                    // Combine attendees and waiting list
                    final allRecipients = {...attendees, ...waitingList}.toList();
                    
                    // Send system message to each recipient
                    final message = 'Event Notification: ${_title.trim()}\n\n${_body.trim()}';
                    for (final userId in allRecipients) {
                      await EventService.sendSystemMessage(
                        userId: userId,
                        message: message,
                        eventId: widget.eventId,
                      );
                    }
                  }
                } catch (e) {
                  // Log error but don't fail the whole operation
                  // System messages are not critical
                }
              }

              if (!mounted) return;
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Event notification sent')),
              );
            } catch (e) {
              if (!mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Failed to send notification')),
              );
            }
          },
          child: const Text('Send'),
        ),
      ],
    );
  }
}

class _AddUserDialog extends StatefulWidget {
  const _AddUserDialog();

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final usersSnap = await FirebaseService.publicUsers.get();
      final users = usersSnap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;
        return {
          'uid': doc.id,
          'name': data['displayName'] ?? 'Unknown',
          'occupation': data['occupation'] ?? '',
          'color': data['iconColor'],
        };
      }).where((user) => user != null).cast<Map<String, dynamic>>().toList();

      setState(() {
        _users = users;
        _filteredUsers = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load users')),
        );
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = user['name'].toString().toLowerCase();
        final occupation = user['occupation'].toString().toLowerCase();
        return name.contains(query) || occupation.contains(query);
      }).toList();
    });
  }

  /// Convert color value from dynamic (int or hex string) to Color
  Color _colorFromDynamic(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    }
    if (colorValue is String) {
      final hexValue = colorValue.replaceFirst('#', '');
      if (hexValue.length == 6) {
        return Color(int.parse('FF$hexValue', radix: 16));
      } else if (hexValue.length == 8) {
        return Color(int.parse(hexValue, radix: 16));
      }
    }
    return Colors.blue; // Default color
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Attendee'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredUsers.isEmpty
                      ? const Center(child: Text('No users found'))
                      : ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return ListTile(
                              leading: SwimmerIconPicker.buildIcon(
                                _colorFromDynamic(user['color']),
                                radius: 16,
                              ),
                              title: Text(user['name']),
                              subtitle: user['occupation'].isNotEmpty
                                  ? Text(user['occupation'])
                                  : null,
                              onTap: () => Navigator.of(context).pop(user['uid']),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
