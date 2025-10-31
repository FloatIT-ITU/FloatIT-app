import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floatit/src/styles.dart';
import 'package:floatit/src/widgets/swimmer_icon_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'package:floatit/src/event_service.dart';

/// A modular attendee list for event attendees or waiting lists.
class AttendeeList extends StatelessWidget {
  final String title;
  final List<Attendee> attendees;
  final bool showCount;
  final bool isAdmin;
  final String? eventId;
  final VoidCallback? onAttendeeRemoved;

  const AttendeeList({
    super.key,
    required this.title,
    required this.attendees,
    this.showCount = true,
    this.isAdmin = false,
    this.eventId,
    this.onAttendeeRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final isHostSection = title == 'Host';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty || showCount)
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                if (showCount && !isHostSection) ...[
                  if (title.isNotEmpty) const SizedBox(width: 8),
                  Text('(${attendees.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.fontWeight,
                              ) ??
                          TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                ],
              ],
            ),
          ),
        // Removed SizedBox(height: 8) to reduce space
        if (attendees.isEmpty)
          Text('None',
              style: AppTextStyles.caption(
                  Theme.of(context).colorScheme.onSurfaceVariant)),
        Align(
          alignment: isHostSection ? Alignment.centerLeft : Alignment.center,
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            children: attendees
                .map((a) => _AttendeeChip(
                      attendee: a,
                      isAdmin: isAdmin,
                      eventId: eventId,
                      onAttendeeRemoved: onAttendeeRemoved,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class Attendee {
  final String uid;
  final String name;
  final String? occupation;
  final String? avatarUrl;
  final Color? color;
  final bool isAdmin;
  const Attendee(
      {required this.uid,
      required this.name,
      this.occupation,
      this.avatarUrl,
      this.color,
      this.isAdmin = false});
}

class _AttendeeChip extends StatelessWidget {
  final Attendee attendee;
  final bool isAdmin;
  final String? eventId;
  final VoidCallback? onAttendeeRemoved;

  const _AttendeeChip({
    required this.attendee,
    this.isAdmin = false,
    this.eventId,
    this.onAttendeeRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isCurrentUser = currentUser?.uid == attendee.uid;
    final showRemoveButton = isAdmin && !isCurrentUser && eventId != null;

    return Chip(
      avatar: attendee.avatarUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(attendee.avatarUrl!))
          : SwimmerIconPicker.buildIcon(
              attendee.color ?? Theme.of(context).colorScheme.onSurfaceVariant,
              radius: 16),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(attendee.name),
              if (attendee.isAdmin)
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: Icon(Icons.star,
                      size: 14, color: Theme.of(context).colorScheme.secondary),
                ),
            ],
          ),
          if (attendee.occupation != null && attendee.occupation!.isNotEmpty)
            Text(attendee.occupation!,
                style: AppTextStyles.caption(
                    Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
      deleteIcon: showRemoveButton ? const Icon(Icons.close, size: 16) : null,
      onDeleted: showRemoveButton ? () => _removeAttendee(context) : null,
    );
  }

  void _removeAttendee(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Attendee'),
        content: Text('Remove ${attendee.name} from this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && eventId != null) {
      String? promotedUserId;

      try {
        await FirebaseService.runTransaction((txn) async {
          final eventRef = FirebaseService.eventDoc(eventId!);
          final eventSnap = await txn.get(eventRef);

          if (!eventSnap.exists) return;

          final data = eventSnap.data() as Map<String, dynamic>;
          final attendees = List<String>.from(data['attendees'] ?? []);
          final waitingList = List<String>.from(data['waitingListUids'] ?? []);

          // Remove from attendees
          attendees.remove(attendee.uid);

          // If there are people in waiting list, promote the first one
          if (waitingList.isNotEmpty) {
            promotedUserId = waitingList.removeAt(0);
            attendees.add(promotedUserId!);
          }

          txn.update(eventRef, {
            'attendees': attendees,
            'waitingListUids': waitingList,
          });
        });

        // Send system message to promoted user
        if (promotedUserId != null) {
          try {
            final eventSnap = await FirebaseFirestore.instance
                .collection('events')
                .doc(eventId)
                .get();
            final eventData = eventSnap.data();
            final eventName = eventData?['name'] ?? 'Event';

            await EventService.sendSystemMessage(
              userId: promotedUserId!,
              message:
                  'Great news! You\'ve been promoted from the waiting list to attendee for "$eventName".',
              eventId: eventId!,
            );
          } catch (e) {
            // Failed to send promotion notification - non-critical
          }
        }

        onAttendeeRemoved?.call();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${attendee.name} removed from event')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to remove attendee')),
          );
        }
      }
    }
  }
}
