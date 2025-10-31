import 'package:flutter/material.dart';

/// Color system for FloatIT app
/// Provides consistent colors across the application
class FloatITColors {
  // Primary colors - Blue shades
  static const Color primary = Color(0xFF1976D2); // Deep blue
  static const Color primaryLight = Color(0xFF42A5F5); // Light blue
  static const Color primaryDark = Color(0xFF1565C0); // Dark blue

  // Secondary colors - Blue shades
  static const Color secondary = Color(0xFF2196F3); // Bright blue
  static const Color secondaryLight = Color(0xFF64B5F6); // Lighter blue
  static const Color secondaryDark = Color(0xFF1976D2); // Medium blue

  // Accent colors - Blue shades
  static const Color accent = Color(0xFF0D47A1); // Navy blue
  static const Color accentLight = Color(0xFF1976D2); // Medium blue
  static const Color accentDark = Color(0xFF0D47A1); // Dark navy

  // Semantic colors - Blue shades
  static const Color success = Color(0xFF1976D2); // Blue for success
  static const Color warning = Color(0xFF42A5F5); // Light blue for warning
  static const Color error = Color(0xFF0D47A1); // Dark blue for error
  static const Color info = Color(0xFF2196F3); // Bright blue for info

  // Neutral colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);

  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFBDBDBD);

  // Swimmer icon colors (for profile customization) - All blue shades
  static const List<Color> swimmerColors = [
    Color(0xFF0D47A1), // Dark navy
    Color(0xFF1565C0), // Dark blue
    Color(0xFF1976D2), // Medium blue
    Color(0xFF2196F3), // Bright blue
    Color(0xFF42A5F5), // Light blue
    Color(0xFF64B5F6), // Lighter blue
    Color(0xFF90CAF9), // Very light blue
    Color(0xFFBBDEFB), // Pale blue
  ];

  // Event type colors - Blue shades
  static const Color practiceColor = Color(0xFF1976D2); // Medium blue
  static const Color competitionColor = Color(0xFF2196F3); // Bright blue
  static const Color socialColor = Color(0xFF42A5F5); // Light blue

  // Status colors - Blue shades
  static const Color joinedEvent = Color(0xFF1976D2); // Medium blue
  static const Color waitingList = Color(0xFF64B5F6); // Light blue
  static const Color fullEvent = Color(0xFF0D47A1); // Dark blue
  static const Color availableEvent = Color(0xFF42A5F5); // Light blue
}
