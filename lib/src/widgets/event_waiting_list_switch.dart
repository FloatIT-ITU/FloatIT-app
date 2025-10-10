import 'package:flutter/material.dart';

class EventWaitingListSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;

  const EventWaitingListSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Enable Waiting List'),
      value: value,
      onChanged: onChanged,
    );
  }
}
