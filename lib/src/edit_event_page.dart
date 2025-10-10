import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:floatit/src/widgets/event_date_time_field.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:floatit/src/services/firebase_service.dart';

import 'layout_widgets.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EditEventPage({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late String eventName;
  late String location;
  late String description;
  DateTime? startTime;
  DateTime? endTime;
  late int attendeeLimit;
  late bool waitingList;
  late String type;
  String? host;

  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _attendeeLimitController = TextEditingController();

  Future<QuerySnapshot>? _adminsFuture;

  @override
  void initState() {
    super.initState();
    _loadEventData();
    _adminsFuture = FirebaseService.adminUsersFuture;
  }

  void _loadEventData() {
    final data = widget.eventData;

    eventName = data['name'] ?? '';
    location = data['location'] ?? '';
    description = data['description'] ?? '';
    attendeeLimit = data['attendeeLimit'] ?? 10;
    waitingList = data['waitingList'] ?? false;
    type = data['type'] ?? 'practice';
    host = data['host'];

    // Parse start time
    final startTimeRaw = data['startTime'];
    if (startTimeRaw is Timestamp) {
      startTime = startTimeRaw.toDate();
    } else if (startTimeRaw is String) {
      startTime = DateTime.tryParse(startTimeRaw);
    }

    // Parse end time
    final endTimeRaw = data['endTime'];
    if (endTimeRaw is Timestamp) {
      endTime = endTimeRaw.toDate();
    } else if (endTimeRaw is String) {
      endTime = DateTime.tryParse(endTimeRaw);
    }

    // Initialize controllers
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

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    try {
      final updateData = {
        'name': eventName,
        'location': location,
        'description': description,
        'startTime': startTime?.toUtc().toIso8601String(),
        'endTime': endTime?.toUtc().toIso8601String(),
        'attendeeLimit': attendeeLimit,
        'waitingList': waitingList,
        'type': type,
        'host': host,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating event: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StandardPageBanner(title: 'Edit Event', showBackArrow: true),
          Expanded(
            child: SingleChildScrollView(
              child: ConstrainedContent(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _eventNameController,
                        decoration: const InputDecoration(
                          labelText: 'Event Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an event name';
                          }
                          return null;
                        },
                        onSaved: (value) => eventName = value!.trim(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                        onSaved: (value) => location = value!.trim(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        onSaved: (value) => description = value?.trim() ?? '',
                      ),
                      const SizedBox(height: 16),
                      EventDateTimeField(
                        label: 'Start Time *',
                        initialDateTime: startTime,
                        onChanged: (dateTime) => startTime = dateTime,
                      ),
                      const SizedBox(height: 16),
                      EventDateTimeField(
                        label: 'End Time',
                        initialDateTime: endTime,
                        onChanged: (dateTime) => endTime = dateTime,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _attendeeLimitController,
                        decoration: const InputDecoration(
                          labelText: 'Attendee Limit',
                          border: OutlineInputBorder(),
                          hintText: 'Leave empty for unlimited',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final num = int.tryParse(value);
                            if (num == null || num < 0) {
                              return 'Please enter a valid number';
                            }
                          }
                          return null;
                        },
                        onSaved: (value) {
                          attendeeLimit = value != null && value.isNotEmpty
                              ? int.parse(value)
                              : 0;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Enable Waiting List'),
                        value: waitingList,
                        onChanged: (value) => setState(() => waitingList = value),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: const InputDecoration(
                          labelText: 'Event Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'practice', child: Text('Practice')),
                          DropdownMenuItem(value: 'competition', child: Text('Competition')),
                          DropdownMenuItem(value: 'social', child: Text('Social')),
                          DropdownMenuItem(value: 'meeting', child: Text('Meeting')),
                          DropdownMenuItem(value: 'other', child: Text('Other')),
                        ],
                        onChanged: (value) => setState(() => type = value ?? 'practice'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an event type';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<QuerySnapshot>(
                        future: _adminsFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }

                          final admins = snapshot.data!.docs;
                          return DropdownButtonFormField<String>(
                            value: host,
                            decoration: const InputDecoration(
                              labelText: 'Host',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select a host (optional)'),
                            items: admins.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              final email = data['email'] ?? 'Unknown';
                              return DropdownMenuItem(
                                value: doc.id,
                                child: Text(email),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => host = value),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _updateEvent,
                        child: const Text('Update Event'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}