import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:floatit/src/widgets/attendee_list.dart';
import 'package:floatit/src/services/firebase_service.dart';
import 'package:floatit/src/constants/firestore_constants.dart';

/// A widget that builds an attendee list from a list of user IDs.
/// Handles fetching user data from both public_users and users collections.
class AttendeeListBuilder extends StatelessWidget {
  final String title;
  final List<String> attendeeUids;
  final bool showCount;
  final bool isAdmin;
  final String? eventId;
  final VoidCallback? onAttendeeRemoved;

  const AttendeeListBuilder({
    super.key,
    required this.title,
    required this.attendeeUids,
    this.showCount = false,
    this.isAdmin = false,
    this.eventId,
    this.onAttendeeRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (attendeeUids.isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<QuerySnapshot>(
      future: FirebaseService.publicUsers
          .where(FieldPath.documentId, whereIn: attendeeUids)
          .get(),
      builder: (context, userSnap) {
        if (userSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnap.hasData || userSnap.data!.docs.isEmpty) {
          return Text(title.isEmpty ? 'No attendees found.' : 'No $title found.');
        }
        final users = userSnap.data!.docs;
        final userMap = {for (var doc in users) doc.id: doc};
        return FutureBuilder<List<DocumentSnapshot>>(
          future: Future.wait(attendeeUids.map((uid) =>
              FirebaseService.userDoc(uid).get())),
          builder: (context, adminSnap) {
            if (adminSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final attendees = <Attendee>[];
            for (int i = 0; i < attendeeUids.length; i++) {
              final uid = attendeeUids[i];
              final userDoc = userMap[uid];
              if (userDoc == null) continue;
              final data = userDoc.data() as Map<String, dynamic>;
              final name = data[FirestoreConstants.displayName] ?? 'Unknown';
              final occupation = data[FirestoreConstants.occupation] ?? '';
              final color = _colorFromDynamic(data[FirestoreConstants.iconColor]);
              final adminData = adminSnap.data?[i].data() as Map<String, dynamic>?;
              final isAdmin = adminData?[FirestoreConstants.admin] == true;
              attendees.add(Attendee(
                  uid: uid,
                  name: name,
                  occupation: occupation,
                  avatarUrl: null,
                  color: color,
                  isAdmin: isAdmin));
            }
            return AttendeeList(
              title: title,
              attendees: attendees,
              showCount: showCount,
              isAdmin: isAdmin,
              eventId: eventId,
              onAttendeeRemoved: onAttendeeRemoved,
            );
          },
        );
      },
    );
  }

  Color _colorFromDynamic(dynamic colorValue) {
    if (colorValue is int) {
      return Color(colorValue);
    }
    return Colors.blue; // Default color
  }
}