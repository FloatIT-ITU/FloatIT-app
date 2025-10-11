import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'event_details_page.dart';
import 'join_request_service.dart';
import 'package:floatit/src/widgets/attendance_badge.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'layout_widgets.dart';
import 'theme_colors.dart';
import 'package:floatit/src/utils/navigation_utils.dart';

class EventsPageContent extends StatefulWidget {
  const EventsPageContent({super.key});

  @override
  State<EventsPageContent> createState() => _EventsPageContentState();
}

class _EventsPageContentState extends State<EventsPageContent> {
  String _selectedEventType = 'all';
  late StreamController<List<DocumentSnapshot>> _eventsController;
  late Stream<List<DocumentSnapshot>> _filteredEventsStream;

  @override
  void initState() {
    super.initState();
    _eventsController = StreamController<List<DocumentSnapshot>>.broadcast();
    _setupFilteredEventsStream();
  }

  @override
  void dispose() {
    _eventsController.close();
    super.dispose();
  }

  // Example join/leave logic for first-come-first-serve
  Future<void> joinEvent(
      String eventId, String userId, int attendeeLimit) async {
    await JoinRequestService.requestJoin(eventId: eventId, uid: userId);
  }

  Future<void> leaveEvent(String eventId, String userId) async {
    await JoinRequestService.requestLeave(eventId: eventId, uid: userId);
  }

  void _setupFilteredEventsStream() {
    // Create a stream that emits every minute for time-based filtering
    final timerStream = Stream.periodic(const Duration(minutes: 1));

    // Listen to Firestore events stream and emit filtered docs when data changes
    FirebaseService.events
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs)
        .listen((docs) {
      _eventsController.add(_filterEvents(docs));
    });

    // Also emit filtered docs when timer fires (for time-based filtering)
    timerStream.listen((_) {
      FirebaseService.events
          .orderBy('startTime')
          .get()
          .then((snapshot) {
            final docs = snapshot.docs;
            _eventsController.add(_filterEvents(docs));
          });
    });

    _filteredEventsStream = _eventsController.stream;
  }

  List<DocumentSnapshot> _filterEvents(List<DocumentSnapshot> docs) {
    final now = DateTime.now().toUtc();
    var events = docs.where((doc) {
      final endTimeStr = doc['endTime'] as String?;
      if (endTimeStr == null) return true;
      final endTime = DateTime.tryParse(endTimeStr);
      return endTime == null || endTime.isAfter(now);
    });

    final typeFilter = _selectedEventType;
    if (typeFilter != 'all') {
      events = events.where((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        final t = data != null && data.containsKey('type') ? data['type'] : (doc['type'] as String?);
        return t == typeFilter;
      });
    }

    return events.toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
        stream: _filteredEventsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events yet!'));
          }
          final eventsList = snapshot.data!;
          
          return ConstrainedContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter at the top right - always visible
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          value: _selectedEventType,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: InputBorder.none,
                            filled: false,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All')),
                            DropdownMenuItem(value: 'practice', child: Text('Practice')),
                            DropdownMenuItem(value: 'competition', child: Text('Competition')),
                            DropdownMenuItem(value: 'other', child: Text('Other')),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedEventType = v;
                            });
                            // Emit new filtered data immediately when filter changes
                            FirebaseService.events
                                .orderBy('startTime')
                                .get()
                                .then((snapshot) {
                                  final docs = snapshot.docs;
                                  _eventsController.add(_filterEvents(docs));
                                });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Event list or empty message
                Expanded(
                  child: eventsList.isEmpty
                      ? const Center(child: Text('No upcoming events!'))
                      : ListView.builder(
                          itemCount: eventsList.length,
                          itemBuilder: (context, i) {
                            final doc = eventsList[i];
                            final eventId = doc.id;
                            return _EventCard(
                              key: ValueKey(eventId),
                              eventId: eventId,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
    );
  }
}

/// Small, private widget that renders an event's banner + card and manages
/// its own StreamBuilders so the parent list remains simple and readable.
class _EventCard extends StatelessWidget {
  final String eventId;

  const _EventCard({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseService.eventDoc(eventId).snapshots(),
      builder: (context, eventSnapshot) {
        // Only log connection state changes, not every build
        if (eventSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        if (!eventSnapshot.hasData) return const SizedBox.shrink();
        final eventData = eventSnapshot.data!.data() as Map<String, dynamic>?;
        if (eventData == null) return const SizedBox.shrink();

        // Card content - ALL data from real-time stream
        final start = DateTime.tryParse(eventData['startTime']?.toString() ?? '')?.toLocal();
        final eventName = eventData['name'] ?? 'Untitled Event';
        final now = DateTime.now();
        String eventDate = '';
        if (start != null) {
          if (start.year == now.year) {
            eventDate = DateFormat('EEE, MMM d').format(start);
          } else {
            eventDate = DateFormat('EEE, MMM d, y').format(start);
          }
        }
        final eventTime = start != null ? DateFormat.Hm().format(start) : '';
        final location = eventData['location'] ?? '';

        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseService.eventBanner(eventId).snapshots(),
          builder: (context, bannerSnapshot) {
            Widget? bannerSection;
            if (bannerSnapshot.hasData && bannerSnapshot.data!.exists) {
              final bannerData = bannerSnapshot.data!.data() as Map<String, dynamic>?;
              if (bannerData != null &&
                  ((bannerData['title'] ?? '').toString().isNotEmpty ||
                   (bannerData['body'] ?? '').toString().isNotEmpty)) {
                bannerSection = Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppThemeColors.bannerEventDark
                        : AppThemeColors.bannerEventLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: InkWell(
                    onTap: () => NavigationUtils.pushWithoutAnimation(
                      context,
                      EventDetailsPage(eventId: eventId),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bannerData['title'] ?? '',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppThemeColors.bannerEventTextDark
                                : AppThemeColors.bannerEventTextLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if ((bannerData['body'] ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              bannerData['body'] ?? '',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? AppThemeColors.bannerEventTextDark
                                    : AppThemeColors.bannerEventTextLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Event banner integrated into the card
                  if (bannerSection != null) ...[
                    bannerSection,
                    const Divider(height: 1, thickness: 1),
                  ],
                  // Event details
                  InkWell(
                    onTap: () => NavigationUtils.pushWithoutAnimation(
                      context,
                      EventDetailsPage(eventId: eventId),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(eventName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                if (eventDate.isNotEmpty) Text('$eventDate${eventTime.isNotEmpty ? ' at $eventTime' : ''}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                if (location.isNotEmpty) ...[const SizedBox(height: 2), Text(location, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))],
                              ],
                            ),
                          ),
                          if (user != null)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AttendanceBadge(
                                  attending: (eventData['attendees'] as List<dynamic>?)?.contains(user.uid) ?? false,
                                  waiting: (eventData['waitingListUids'] as List<dynamic>?)?.contains(user.uid) ?? false,
                                  hosting: eventData['host'] == user.uid,
                                ),
                                const SizedBox(height: 8),
                                // Display attendee count
                                Builder(
                                  builder: (context) {
                                    final attendees = eventData['attendees'] as List<dynamic>? ?? [];
                                    final hostUid = eventData['host'] as String?;
                                    final attendeeCount = hostUid != null && hostUid.isNotEmpty && !attendees.contains(hostUid)
                                        ? attendees.length + 1
                                        : attendees.length;
                                    final attendeeLimit = eventData['attendeeLimit'] ?? 0;
                                    final attendeeText = attendeeLimit == 0 
                                        ? '$attendeeCount attendees' 
                                        : '$attendeeCount/$attendeeLimit attendees';
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        attendeeText,
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}