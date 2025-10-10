import 'package:flutter/material.dart';
import 'package:floatit/src/styles.dart';

/// Small badge showing user's attendance status for an event.
///
/// - If `attending` is true: shows a green circle with a check and the label
///   "attending" below the icon.
/// - If `waiting` is true: shows an orange circle with an hourglass and the
///   label "waiting list" below the icon.
/// - If neither is true: renders nothing.
/// - If `hosting` is true: shows a purple circle with a star and the label
///   "hosting" below the icon. This takes priority over attending/waiting.

class AttendanceBadge extends StatelessWidget {
  final bool attending;
  final bool waiting;
  final bool hosting;
  final bool compact;
  const AttendanceBadge(
      {super.key,
      this.attending = false,
      this.waiting = false,
      this.hosting = false,
      this.compact = false});

  @override
  Widget build(BuildContext context) {
    // Hosting takes priority over attending/waiting.
    if (!hosting && !attending && !waiting) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final labelStyle = AppTextStyles.caption(theme.colorScheme.onSurfaceVariant)
        .copyWith(fontSize: 11);

    // If compact mode is requested show icon-only (tooltip preserves meaning)
    if (compact) {
      if (hosting) {
        return Tooltip(
          message: 'You are hosting this event',
          child: Semantics(
            label: 'Hosting',
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.purple.shade600,
              child: const Icon(Icons.star, size: 16, color: Colors.white),
            ),
          ),
        );
      }
      if (attending) {
        return Tooltip(
          message: 'You are attending this event',
          child: Semantics(
            label: 'Attending',
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.green.shade600,
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
        );
      }
      // waiting
      return Tooltip(
        message: 'You are on the waiting list',
        child: Semantics(
          label: 'Waiting list',
          child: CircleAvatar(
            radius: 14,
            backgroundColor: Colors.orange.shade600,
            child: const Icon(Icons.hourglass_bottom, size: 16, color: Colors.white),
          ),
        ),
      );
    }

    // Full (labelled) mode
    if (hosting) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'You are hosting this event',
            child: Semantics(
              label: 'Hosting',
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.purple.shade600,
                child: const Icon(Icons.star, size: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Hosting', style: labelStyle),
        ],
      );
    }

    if (attending) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'You are attending this event',
            child: Semantics(
              label: 'Attending',
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Colors.green.shade600,
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('Attending', style: labelStyle),
        ],
      );
    }

    // waiting
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'You are on the waiting list',
          child: Semantics(
            label: 'Waiting list',
            child: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.orange.shade600,
              child: const Icon(Icons.hourglass_bottom, size: 16, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('On waiting list', style: labelStyle),
      ],
    );
  }
}
