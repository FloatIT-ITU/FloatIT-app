import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:floatit/src/widgets/markdown_renderer.dart';

/// A widget that displays the basic details of an event.
/// Shows name, start/end times, location with map link, and description.
class EventDetailsDisplay extends StatelessWidget {
  final Map<String, dynamic> eventData;

  const EventDetailsDisplay({
    super.key,
    required this.eventData,
  });

  @override
  Widget build(BuildContext context) {
    final start = DateTime.tryParse(eventData['startTime'] ?? '')?.toLocal();
    final end = DateTime.tryParse(eventData['endTime'] ?? '')?.toLocal();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eventData['name'] ?? 'Untitled Event',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        if (start != null)
          Text('Start: ${DateFormat('EEE, MMM d, y HH:mm').format(start)}'),
        if (end != null)
          Text('End: ${DateFormat('EEE, MMM d, y HH:mm').format(end)}'),
        if (eventData['location'] != null &&
            eventData['location'].toString().isNotEmpty)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text('Location: ${eventData['location']}')),
              IconButton(
                icon: Icon(Icons.map,
                    color: Theme.of(context).colorScheme.primary),
                tooltip: 'Open in Google Maps',
                onPressed: () {
                  final loc = Uri.encodeComponent(eventData['location']);
                  final url =
                      'https://www.google.com/maps/search/?api=1&query=$loc';
                  launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        if (eventData['description'] != null &&
            eventData['description'].toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
            child: SimpleMarkdown(data: eventData['description'] ?? ''),
          ),
      ],
    );
  }
}
