import 'package:flutter/material.dart';

/// A reusable card widget for statistics sections.
/// Provides consistent styling with the same background as other stats cards.
class StatisticsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const StatisticsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}