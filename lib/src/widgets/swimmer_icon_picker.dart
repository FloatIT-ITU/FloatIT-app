import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../theme_colors.dart';

class SwimmerIconPicker extends StatefulWidget {
  final Color selectedColor;
  final void Function(Color) onColorSelected;
  const SwimmerIconPicker(
      {super.key, required this.selectedColor, required this.onColorSelected});

  static const IconData _swimmerIcon = Icons.pool;

  /// Returns a swimmer icon avatar with the given color and radius.
  static Widget buildIcon(Color color,
      {double radius = 32, BuildContext? context}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: radius,
      child: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppThemeColors.shadow,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: Icon(_swimmerIcon,
            color: AppThemeColors.lightBadgeIcon, size: radius),
      ),
    );
  }

  @override
  State<SwimmerIconPicker> createState() => _SwimmerIconPickerState();
}

class _SwimmerIconPickerState extends State<SwimmerIconPicker> {
  late Color pickerColor;

  @override
  void initState() {
    super.initState();
    pickerColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16.0),
        ),
        ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: (color) {
            setState(() {
              pickerColor = color;
            });
          },
          enableAlpha: false,
          displayThumbColor: true,
          pickerAreaHeightPercent: 0.7,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(pickerColor);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
}
