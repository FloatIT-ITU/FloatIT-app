// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:floatit/src/widgets/date_time_picker_helper.dart';

class EventDateTimeField extends StatefulWidget {
  final DateTime? initialDateTime;
  final void Function(DateTime) onChanged;
  final String label;

  const EventDateTimeField({
    super.key,
    required this.initialDateTime,
    required this.onChanged,
    required this.label,
  });

  @override
  State<EventDateTimeField> createState() => _EventDateTimeFieldState();
}

class _EventDateTimeFieldState extends State<EventDateTimeField> {
  @override
  Widget build(BuildContext context) {
    final initialDateTime = widget.initialDateTime;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      child: ListTile(
        title: Text(initialDateTime != null
            ? "${initialDateTime.toLocal().toString().split(' ')[0]} ${initialDateTime.toLocal().toString().split(' ')[1].substring(0, 5)}"
            : 'Select date and time'),
        trailing: const Icon(Icons.calendar_today),
        onTap: () async {
          final picked = await pickDateTime(context, initialDateTime);
          if (!mounted) return;
          if (picked != null) widget.onChanged(picked);
        },
      ),
    );
  }
}
