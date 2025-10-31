import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'layout_widgets.dart';

class AdminSendNotificationPage extends StatefulWidget {
  const AdminSendNotificationPage({super.key});

  @override
  State<AdminSendNotificationPage> createState() =>
      _AdminSendNotificationPageState();
}

class _AdminSendNotificationPageState extends State<AdminSendNotificationPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _body = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(
              title: 'Send Global Notification', showBackArrow: true),
          Expanded(
            child: ConstrainedContent(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Current global banner (if any)
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('app')
                          .doc('global_banner')
                          .snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData ||
                            snap.data == null ||
                            !snap.data!.exists) {
                          return const SizedBox.shrink();
                        }
                        final data = snap.data!.data()!;
                        return Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(data['title'] ?? '',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimaryContainer,
                                              fontWeight: FontWeight.w600)),
                                      if ((data['body'] ?? '')
                                          .toString()
                                          .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6.0),
                                          child: Text(data['body'] ?? '',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimaryContainer)),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_forever,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                  tooltip: 'Remove global banner',
                                  onPressed: () async {
                                    final scaffoldMessenger =
                                        ScaffoldMessenger.of(context);
                                    final navigator = Navigator.of(context);
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title:
                                            const Text('Remove Global Banner?'),
                                        content: const Text(
                                            'This will remove the current global banner for all users.'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  navigator.pop(false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () =>
                                                  navigator.pop(true),
                                              child: const Text('Remove')),
                                        ],
                                      ),
                                    );
                                    if (confirm != true) return;
                                    await FirebaseFirestore.instance
                                        .collection('app')
                                        .doc('global_banner')
                                        .delete();
                                    if (!mounted) return;
                                    scaffoldMessenger.showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Global banner removed')));
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'This page sends global notifications for the app. If you want to set an event-specific notification, go to the event page itself.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Title'),
                      onChanged: (v) => setState(() => _title = v),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Title is required'
                          : null,
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Body'),
                      onChanged: (v) => setState(() => _body = v),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Body is required'
                          : null,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    // Live preview
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_title.isEmpty ? 'Preview Title' : _title,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text(
                                _body.isEmpty
                                    ? 'Preview body text will appear here.'
                                    : _body,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() != true) {
                          return;
                        }
                        final messenger = ScaffoldMessenger.of(context);

                        // Send banner notification
                        await FirebaseFirestore.instance
                            .collection('app')
                            .doc('global_banner')
                            .set({
                          'title': _title,
                          'body': _body,
                          'createdAt': DateTime.now().toUtc().toIso8601String(),
                        });

                        // Create pending notification document
                        try {
                          final currentUser = FirebaseAuth.instance.currentUser;
                          await FirebaseFirestore.instance
                              .collection('admin_notifications')
                              .add({
                            'title': _title,
                            'body': _body,
                            'status': 'pending',
                            'createdAt': DateTime.now().toUtc().toIso8601String(),
                            'createdBy': currentUser?.uid,
                          });
                        } catch (e) {
                          // Error creating pending notification: $e
                        }

                        // Send push notifications immediately via Vercel function
                        try {
                          const vercelUrl = 'https://vercel-functions-ohmlzwgw7-pheadars-projects.vercel.app/api/send-notification';
                          final response = await http.post(
                            Uri.parse(vercelUrl),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({}),
                          );

                          if (response.statusCode == 200) {
                            final result = jsonDecode(response.body);
                            messenger.showSnackBar(SnackBar(
                                content: Text('Global notification sent immediately! Processed ${result['results']['admin']['processed']} notifications')));
                          } else {
                            messenger.showSnackBar(const SnackBar(
                                content: Text('Banner sent, but push notifications may be delayed')));
                          }
                        } catch (e) {
                          messenger.showSnackBar(const SnackBar(
                              content: Text('Banner sent, but push notifications may be delayed')));
                        }
                      },
                      child: const Text('Send Global Notification'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
