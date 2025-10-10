import 'package:flutter/material.dart';
import 'package:floatit/src/styles.dart';

/// A modular event tile for use in event lists.
class EventTile extends StatelessWidget {
  final String title;
  final String location;
  final DateTime dateTime;
  final int attendeeCount;
  final int maxAttendees;
  final VoidCallback? onTap;
  final Widget? trailing;

  const EventTile({
    super.key,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.attendeeCount,
    required this.maxAttendees,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        title: Text(title, style: AppTextStyles.heading()),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location, style: AppTextStyles.body()),
            Text(
              '${dateTime.toLocal().toString().split(' ')[0]} • ${TimeOfDay.fromDateTime(dateTime).format(context)}',
              style: AppTextStyles.caption(
                  Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            Text('Attendees: $attendeeCount / $maxAttendees',
                style: AppTextStyles.caption()),
          ],
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
