import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:floatit/src/widgets/banners.dart';

import 'layout_widgets.dart';
import 'event_service.dart';

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
  bool _sendAsSystemMessage = true; // Pre-selected by default

  // GitHub App constants (replace with your values)
  static const String appId = 'YOUR_APP_ID';
  static const String installationId = 'YOUR_INSTALLATION_ID';

  // Decrypt AES (compatible with crypto-js)
  String decryptAES(String encrypted, String key) {
    final encryptedBytes = base64.decode(encrypted);
    final iv = encryptedBytes.sublist(0, 16);
    final cipherText = encryptedBytes.sublist(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(encrypt.Key.fromUtf8(key)));
    final decrypted = encrypter.decrypt(encrypt.Encrypted(cipherText), iv: encrypt.IV(iv));
    return decrypted;
  }

  // Helper to generate JWT
  String generateJWT(String privateKeyPem) {
    final jwt = JWT(
      {
        'iss': appId,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 600,
      },
    );
    return jwt.sign(RSAPrivateKey(privateKeyPem), algorithm: JWTAlgorithm.RS256);
  }

  // Get installation token
  Future<String> getInstallationToken(String jwt) async {
    final response = await http.post(
      Uri.parse('https://api.github.com/app/installations/$installationId/access_tokens'),
      headers: {
        'Authorization': 'Bearer $jwt',
        'Accept': 'application/vnd.github+json',
      },
    );
    if (response.statusCode != 201) throw Exception('Failed to get token: ${response.body}');
    final data = jsonDecode(response.body);
    return data['token'];
  }

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
                          color:
                              Theme.of(context).colorScheme.primaryContainer,
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
                                        title: const Text(
                                            'Remove Global Banner?'),
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
                                            content: Text(
                                                'Global banner removed')));
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
                    CheckboxListTile(
                      title: const Text('Also send as system message to all users'),
                      subtitle: const Text('Send this notification as a personal message to all app users'),
                      value: _sendAsSystemMessage,
                      onChanged: (value) => setState(() => _sendAsSystemMessage = value ?? true),
                    ),
                    // Live preview
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_title.isEmpty ? 'Preview Title' : _title,
                                style:
                                    Theme.of(context).textTheme.titleMedium),
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
                        final currentUser = FirebaseAuth.instance.currentUser;
                        if (currentUser == null) {
                          messenger.showSnackBar(const SnackBar(content: Text('Not authenticated')));
                          return;
                        }
                        
                        // Create notification document
                        final notificationRef = FirebaseFirestore.instance.collection('notifications').doc();
                        await notificationRef.set({
                          'type': 'global',
                          'title': _title,
                          'body': _body,
                          'createdByUid': currentUser.uid,
                          'createdAt': FieldValue.serverTimestamp(),
                          'sent': false,
                        });

                        // Send banner notification
                        await FirebaseFirestore.instance
                            .collection('app')
                            .doc('global_banner')
                            .set({
                          'title': _title,
                          'body': _body,
                          'createdAt':
                              DateTime.now().toUtc().toIso8601String(),
                        });

                        // Send system messages to all users if requested
                        if (_sendAsSystemMessage) {
                          try {
                            final usersSnapshot = await FirebaseFirestore.instance
                                .collection('public_users')
                                .get();
                            
                            final message = 'Global Notification: ${_title.trim()}\n\n${_body.trim()}';
                            for (final userDoc in usersSnapshot.docs) {
                              final userId = userDoc.id;
                              await EventService.sendSystemMessage(
                                userId: userId,
                                message: message,
                                eventId: 'global', // Use 'global' as eventId for global notifications
                              );
                            }
                          } catch (e) {
                            // Log error but don't fail the whole operation
                            // System messages are not critical
                          }
                        }

                        // Trigger GitHub Actions for push notifications
                        try {
                          // Fetch encrypted key and passphrase
                          final keyDoc = await FirebaseFirestore.instance.collection('admin_config').doc('github_app_key').get();
                          final encryptedKey = keyDoc.data()?['encrypted_key'] as String?;
                          final storedPassphrase = keyDoc.data()?['passphrase'] as String?;
                          if (encryptedKey == null || storedPassphrase == null) throw Exception('GitHub config not found');

                          // Decrypt
                          final privateKeyPem = decryptAES(encryptedKey, storedPassphrase);

                          // Generate JWT
                          final jwt = generateJWT(privateKeyPem);

                          // Get installation token
                          final token = await getInstallationToken(jwt);

                          // Dispatch
                          final response = await http.post(
                            Uri.parse('https://api.github.com/repos/FloatIT-ITU/FloatIT-app/dispatches'),
                            headers: {
                              'Authorization': 'token $token',
                              'Accept': 'application/vnd.github+json',
                              'Content-Type': 'application/json',
                            },
                            body: '{"event_type": "send_notification", "client_payload": {"notificationId": "${notificationRef.id}"}}',
                          );
                          if (response.statusCode != 204) {
                            messenger.showSnackBar(SnackBar(content: Text('Failed to trigger push notifications: ${response.statusCode}')));
                          }
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('Error triggering push notifications: $e')));
                        }

                        if (!mounted) return;
                        messenger.showSnackBar(const SnackBar(
                            content: Text('Global notification sent')));
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