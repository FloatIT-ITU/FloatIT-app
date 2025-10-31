import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:floatit/src/widgets/banners.dart';

class AdminServerLogsPage extends StatelessWidget {
  const AdminServerLogsPage({super.key});

  String _formatTimestamp(Timestamp? ts) {
    if (ts == null) return 'Unknown';
    final dt = ts.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt);
  }

  String _formatAction(String action) {
    switch (action) {
      case 'send_topic':
        return 'Sent Topic Notification';
      case 'send_topic_error':
        return 'Topic Notification Error';
      case 'send_user':
        return 'Sent User Notification';
      case 'send_user_error':
        return 'User Notification Error';
      case 'set_admin_claim':
        return 'Set Admin Claim';
      case 'set_admin_claim_error':
        return 'Admin Claim Error';
      default:
        return action;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(title: 'Server Logs', showBackArrow: true),
          Expanded(
            child: ConstrainedContent(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('server_logs')
                    .orderBy('timestamp', descending: true)
                    .limit(100)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text('No server logs found'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      final action = _formatAction(data['action'] ?? '');
                      final timestamp = _formatTimestamp(data['timestamp']);
                      final adminUid = data['adminUid'] ?? 'Unknown';
                      final details = data['details'] ?? {};

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: ExpansionTile(
                          title: Text(action),
                          subtitle: Text(
                              'Admin: ${adminUid.substring(0, 8)}... • $timestamp'),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Action: $action',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('Admin UID: $adminUid'),
                                  Text('Timestamp: $timestamp'),
                                  const SizedBox(height: 8),
                                  const Text('Details:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(details.toString()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
