import 'package:flutter/material.dart';

class EventNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EventNameField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Event Name',
        border: OutlineInputBorder(),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
