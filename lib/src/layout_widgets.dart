import 'package:flutter/material.dart';

import 'layout_constants.dart';

/// A small helper that centers page content, constrains its maximum width to
/// `kContentMaxWidth` and applies the standard horizontal padding used across
/// the app.
class ConstrainedContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ConstrainedContent({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kContentMaxWidth),
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0),
          child: child,
        ),
      ),
    );
  }
}
