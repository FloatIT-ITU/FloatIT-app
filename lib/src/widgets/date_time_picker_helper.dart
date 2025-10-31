// Helper to show a date picker followed by a time picker and return a DateTime.
import 'package:flutter/material.dart';

Future<DateTime?> pickDateTime(BuildContext context, DateTime? initial) async {
  final navigator = Navigator.of(context);
  final picked = await showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
  );
  if (picked == null) return null;
  if (!navigator.mounted) return null;
  final time = await showTimePicker(
    context: navigator.context,
    initialTime: initial != null
        ? TimeOfDay(hour: initial.hour, minute: initial.minute)
        : TimeOfDay.now(),
    builder: (builderContext, child) {
      final parent = MediaQuery.of(builderContext);
      return MediaQuery(
          data: parent.copyWith(alwaysUse24HourFormat: true), child: child!);
    },
  );
  if (time == null) return null;

  return DateTime(
      picked.year, picked.month, picked.day, time.hour, time.minute);
}
