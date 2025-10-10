import 'package:flutter/material.dart';

class EventHostDropdown extends StatelessWidget {
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final void Function(String?)? onChanged;

  const EventHostDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Host',
        border: OutlineInputBorder(),
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}
