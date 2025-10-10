import 'package:flutter/material.dart';

/// Centralized font size and style constants for FloatIT UI.
class AppFontSizes {
  static const double heading = 22;
  static const double subheading = 18;
  static const double button = 16;
  static const double body = 14;
  static const double caption = 12;
}

class AppFontWeights {
  static const FontWeight bold = FontWeight.w600;
  static const FontWeight normal = FontWeight.w400;
}

class AppTextStyles {
  static TextStyle heading([Color? color]) => TextStyle(
        fontSize: AppFontSizes.heading,
        fontWeight: AppFontWeights.normal,
        color: color,
      );

  static TextStyle subheading([Color? color]) => TextStyle(
        fontSize: AppFontSizes.subheading,
        fontWeight: AppFontWeights.normal,
        color: color,
      );

  static TextStyle body([Color? color]) => TextStyle(
        fontSize: AppFontSizes.body,
        fontWeight: AppFontWeights.normal,
        color: color,
      );

  static TextStyle caption([Color? color]) => TextStyle(
        fontSize: AppFontSizes.caption,
        fontWeight: AppFontWeights.normal,
        color: color,
      );

  static TextStyle italicHeading([Color? color]) =>
      heading(color).copyWith(fontStyle: FontStyle.italic);
}

// Example usage:
// Text('Forgot password?', style: TextStyle(fontSize: AppFontSizes.body))
// Text('Login', style: TextStyle(fontSize: AppFontSizes.button, fontWeight: AppFontWeights.bold))
