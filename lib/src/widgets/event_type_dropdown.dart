import 'package:flutter/material.dart';

class EventTypeDropdown extends StatelessWidget {
  final String? value;
  final List<String> eventTypes;
  final void Function(String?)? onChanged;

  const EventTypeDropdown({
    super.key,
    required this.value,
    required this.eventTypes,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Event Type',
        border: OutlineInputBorder(),
      ),
      items: eventTypes
          .map((type) => DropdownMenuItem(
                value: type,
                child: Text(
                  type[0].toUpperCase() + type.substring(1),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}
