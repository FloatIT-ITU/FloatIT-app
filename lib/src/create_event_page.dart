// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:floatit/src/widgets/date_time_picker_helper.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:floatit/src/services/firebase_service.dart';

import 'layout_widgets.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  String eventName = '';
  String location = '';
  String description = '';
  DateTime? startTime;
  DateTime? endTime;
  int attendeeLimit = 10;
  bool waitingList = false;
  String type = 'practice';
  String? host;
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _attendeeLimitController =
      TextEditingController(text: '10');
  // Recurring events removed — only single events supported now.
  Future<QuerySnapshot>? _adminsFuture;
  final Map<String, Future<QuerySnapshot>> _publicUsersFutureCache = {};

  @override
  void initState() {
    super.initState();
    _adminsFuture = FirebaseService.adminUsersFuture;
    _eventNameController.text = eventName;
    _descriptionController.text = description;
    _locationController.text = location;
    _attendeeLimitController.text = attendeeLimit.toString();
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _attendeeLimitController.dispose();
    super.dispose();
  }

  Future<void> _showCopyFromEventDialog() async {
    final snap = await FirebaseService.events
        .orderBy('createdAt', descending: true)
        .limit(4)
        .get();
    final docs = snap.docs;
    await showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Copy details from event'),
        content: SizedBox(
          width: double.maxFinite,
          child: docs.isEmpty
              ? const Text('No events found')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final d = docs[i];
                    final data = (d.data() as Map<String, dynamic>?) ?? {};
                    final name = data['name'] ?? '<no name>';
                    final start = data['startTime'];
                    String subtitle = '';
                    DateTime? sd;
                    if (start is String) {
                      try {
                        sd = DateTime.parse(start);
                      } catch (_) {}
                    } else if (start is Timestamp) {
                      sd = start.toDate();
                    }
                    if (sd != null) subtitle = sd.toLocal().toString();
                    return ListTile(
                      title: Text(name.toString()),
                      subtitle: subtitle.isEmpty ? null : Text(subtitle),
                      onTap: () {
                        setState(() {
                          eventName = data['name'] as String? ?? '';
                          _eventNameController.text = eventName;

                          description = data['description'] as String? ?? '';
                          _descriptionController.text = description;

                          location = data['location'] as String? ?? '';
                          _locationController.text = location;

                          attendeeLimit = (data['attendeeLimit'] is int)
                              ? data['attendeeLimit'] as int
                              : int.tryParse(
                                      (data['attendeeLimit'] ?? '').toString())
                                  ?? 10;
                          _attendeeLimitController.text = attendeeLimit.toString();

                          waitingList = data['waitingList'] == true;
                          type = data['type'] as String? ?? 'practice';
                          host = data['host'] as String?;

                          final st = data['startTime'];
                          if (st is String) {
                            try {
                              startTime = DateTime.parse(st).toLocal();
                            } catch (_) {
                              startTime = null;
                            }
                          } else if (st is Timestamp) {
                            startTime = st.toDate();
                          } else {
                            startTime = null;
                          }

                          final et = data['endTime'];
                          if (et is String) {
                            try {
                              endTime = DateTime.parse(et).toLocal();
                            } catch (_) {
                              endTime = null;
                            }
                          } else if (et is Timestamp) {
                            endTime = et.toDate();
                          } else {
                            endTime = null;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(c).pop(),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                setState(() {
                  eventName = '';
                  description = '';
                  location = '';
                  startTime = null;
                  endTime = null;
                  attendeeLimit = 10;
                  waitingList = false;
                  type = 'practice';
                  host = null;
                });
                Navigator.of(c).pop();
              },
              child: const Text('Clear')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(title: 'Create Event', showBackArrow: true),
          Expanded(
            child: ConstrainedContent(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              icon: Icon(Icons.copy_all, color: Theme.of(context).colorScheme.onSurface),
                              label: Text('Copy From Event', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                              onPressed: _showCopyFromEventDialog,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _eventNameController,
                              decoration:
                                  const InputDecoration(labelText: 'Event Name'),
                              onChanged: (v) => setState(() => eventName = v),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionController,
                              decoration:
                                  const InputDecoration(labelText: 'Description'),
                              minLines: 1,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              onChanged: (v) => setState(() => description = v),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _locationController,
                                    decoration: const InputDecoration(
                                        labelText: 'Location'),
                                    onChanged: (v) =>
                                        setState(() => location = v),
                                    validator: (v) =>
                                        v == null || v.isEmpty
                                            ? 'Required'
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.map_outlined),
                                  tooltip: 'Open in Google Maps',
                                  onPressed: location.trim().isEmpty
                                      ? null
                                      : () async {
                                          final query =
                                              Uri.encodeComponent(location);
                                          final url = Uri.parse(
                                              'https://www.google.com/maps/search/?api=1&query=$query');
                                          if (await canLaunchUrl(url)) {
                                            await launchUrl(url,
                                                mode: LaunchMode
                                                    .externalApplication);
                                          }
                                        },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ListTile(
                              title: Text(startTime == null
                                  ? 'Select Start Time'
                                  : startTime.toString()),
                              leading: const Icon(Icons.access_time),
                              onTap: () async {
                                final picked =
                                    await pickDateTime(context, startTime ?? DateTime.now());
                                if (!mounted) return;
                                if (picked != null) {
                                  setState(() => startTime = picked);
                                }
                              },
                            ),
                            ListTile(
                              title: Text(endTime == null
                                  ? 'Select End Time'
                                  : endTime.toString()),
                              leading: const Icon(Icons.access_time_outlined),
                              onTap: () async {
                                final initial =
                                    endTime ?? startTime ?? DateTime.now();
                                final picked = await pickDateTime(context, initial);
                                if (!mounted) return;
                                if (picked != null) setState(() => endTime = picked);
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _attendeeLimitController,
                              decoration:
                                  const InputDecoration(labelText: 'Attendee Limit'),
                              keyboardType: TextInputType.number,
                              onChanged: (v) =>
                                  setState(() => attendeeLimit = int.tryParse(v) ?? 10),
                              validator: (v) =>
                                  (int.tryParse(v ?? '') ?? 0) >= 0
                                      ? null
                                      : 'Must be >= 0',
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: const Text('Enable Waiting List'),
                              value: waitingList,
                              onChanged: (v) => setState(() => waitingList = v),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: type,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: const [
                                DropdownMenuItem(value: 'practice', child: Text('Practice')),
                                DropdownMenuItem(value: 'competition', child: Text('Competition')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                              ],
                              onChanged: (v) => setState(() => type = v ?? 'practice'),
                            ),
                            const SizedBox(height: 12),
                            FutureBuilder<QuerySnapshot>(
                              future: _adminsFuture,
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
                                  return DropdownButtonFormField<String>(
                                    value: host,
                                    decoration: const InputDecoration(labelText: 'Host'),
                                    items: const [DropdownMenuItem(value: null, child: Text('No admins found'))],
                                    onChanged: (v) => setState(() => host = v),
                                    validator: (v) => v == null ? 'Please select an admin' : null,
                                  );
                                }
                                final key = adminUids.join(',');
                                final future = _publicUsersFutureCache[key] ??= FirebaseFirestore.instance.collection('public_users').where(FieldPath.documentId, whereIn: adminUids).get();

                                return FutureBuilder<QuerySnapshot>(
                                  future: future,
                                  builder: (context, publicSnap) {
                                    if (publicSnap.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    } else if (publicSnap.hasError) {
                                      return const Text('Error loading admin names');
                                    }
                                    final publicDocs = publicSnap.data?.docs ?? [];
                                    final publicMap = {for (var doc in publicDocs) doc.id: doc.data()};
                                    return DropdownButtonFormField<String>(
                                      value: host,
                                      decoration: const InputDecoration(labelText: 'Host'),
                                      items: [
                                        const DropdownMenuItem(value: null, child: Text('Select host')),
                                        ...adminDocs.map((admin) {
                                          final public = publicMap[admin.id] as Map<String, dynamic>? ?? {};
                                          final displayName = (public['displayName'] is String && (public['displayName'] as String).trim().isNotEmpty) ? public['displayName'] as String : (public['email'] ?? admin.id);
                                          return DropdownMenuItem<String>(value: admin.id, child: Text(displayName));
                                        }),
                                      ],
                                      onChanged: (v) => setState(() => host = v),
                                      validator: (v) => v == null ? 'Please select an admin' : null,
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState?.validate() != true) {
                                  return;
                                }
                                final now = DateTime.now().toUtc();
                                final nowIso = now.toIso8601String();

                                final baseData = {
                                  'name': eventName,
                                  'description': description,
                                  'location': location,
                                  'attendeeLimit': attendeeLimit,
                                  'waitingList': waitingList,
                                  'type': type,
                                  'host': host,
                                  'recurring': false,
                                  'frequency': 'single',
                                  'createdAt': nowIso,
                                  'editedAt': nowIso,
                                  'attendees': <String>[],
                                  'waitingListUids': <String>[],
                                };

                                final ev = Map<String, dynamic>.from(baseData);
                                if (startTime != null) ev['startTime'] = startTime!.toUtc().toIso8601String();
                                if (endTime != null) ev['endTime'] = endTime!.toUtc().toIso8601String();
                                await FirebaseService.events.add(ev);

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created!')));
                                Navigator.of(context).pop();
                              },
                              child: const Text('Create Event'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
