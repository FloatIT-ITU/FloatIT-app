import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:floatit/src/widgets/loading_widgets.dart';
import 'package:floatit/src/widgets/attendee_list.dart';
import 'package:floatit/src/constants/firestore_constants.dart';
import 'package:floatit/src/theme_colors.dart';

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

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAttendeeData(attendeeUids, isAdmin),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingWidgets.loadingIndicator(message: 'Loading attendees...', size: 40);
        }
        if (snapshot.hasError) {
          return Text('Error loading attendees: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(title.isEmpty ? 'No attendees found.' : 'No $title found.');
        }
        
        final data = snapshot.data!;
        final publicUsers = data['publicUsers'] as Map<String, DocumentSnapshot>;
        final privateUsers = data['privateUsers'] as Map<String, DocumentSnapshot>;
        
        final attendees = <Attendee>[];
        for (final uid in attendeeUids) {
          final userDoc = publicUsers[uid];
          if (userDoc == null || !userDoc.exists) continue;
          
          final userData = userDoc.data() as Map<String, dynamic>;
          final name = userData[FirestoreConstants.displayName] ?? 'Unknown';
          final occupation = userData[FirestoreConstants.occupation] ?? '';
          final color = _colorFromDynamic(userData[FirestoreConstants.iconColor]);
          
          final privateDoc = privateUsers[uid];
          final adminData = privateDoc?.data() as Map<String, dynamic>?;
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
  }
  
  /// Efficiently fetches both public and private user data in batched queries
  /// to avoid N+1 query pattern
  static Future<Map<String, dynamic>> _fetchAttendeeData(List<String> uids, bool includePrivate) async {
    if (uids.isEmpty) {
      return {
        'publicUsers': <String, DocumentSnapshot>{},
        'privateUsers': <String, DocumentSnapshot>{},
      };
    }
    
    // Firestore 'whereIn' has a limit of 10 items, so batch if needed
  final List<Future<QuerySnapshot>> publicBatches = [];
  final List<Future<QuerySnapshot>> privateBatches = [];
    
    for (int i = 0; i < uids.length; i += 10) {
      final batch = uids.skip(i).take(10).toList();
      publicBatches.add(
        FirebaseFirestore.instance
            .collection('public_users')
            .where(FieldPath.documentId, whereIn: batch)
            .get()
      );
      if (includePrivate) {
        privateBatches.add(
          FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: batch)
              .get()
        );
      }
    }
    
    final publicResults = await Future.wait(publicBatches);
  final privateResults = includePrivate && privateBatches.isNotEmpty
    ? await Future.wait(privateBatches)
    : <QuerySnapshot>[];
    
    final publicUsers = <String, DocumentSnapshot>{};
    final privateUsers = <String, DocumentSnapshot>{};
    
    for (final result in publicResults) {
      for (final doc in result.docs) {
        publicUsers[doc.id] = doc;
      }
    }
    
    for (final result in privateResults) {
      for (final doc in result.docs) {
        privateUsers[doc.id] = doc;
      }
    }
    
    return {
      'publicUsers': publicUsers,
      'privateUsers': privateUsers,
    };
  }

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
    return AppThemeColors.lightPrimary; // Default color
  }
}