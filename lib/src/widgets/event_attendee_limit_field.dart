import 'package:flutter/material.dart';

class EventAttendeeLimitField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EventAttendeeLimitField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Max Attendees',
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
