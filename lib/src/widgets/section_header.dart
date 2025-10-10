import 'package:flutter/material.dart';
import 'package:floatit/src/styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final FontWeight? fontWeight;

  const SectionHeader({
    super.key,
    required this.title,
    this.padding,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      child: Text(title,
          style: AppTextStyles.subheading(
              Theme.of(context).textTheme.titleMedium?.color)),
    );
  }
}
