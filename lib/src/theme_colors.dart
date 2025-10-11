import 'package:flutter/material.dart';

/// Centralized color palette for the FloatIT app.
///
/// This file defines all colors used throughout the application.
/// Colors are organized by theme (light/dark) and purpose for easy maintenance.
///
/// HOW TO CHANGE COLORS:
/// =====================
///
/// For Light Mode:
/// - Update the 'Light theme palette' section below
/// - Colors will automatically apply to all widgets using AppThemeColors
///
/// For Dark Mode:
/// - Update the 'Dark theme palette' section below
/// - Add corresponding dark mode colors for any new light mode colors
///
/// Color Usage Guide:
/// - primary: Main brand color for buttons, active states, highlights
/// - secondary: Secondary actions, less prominent elements
/// - background: Main app background color
/// - surface: Card backgrounds, elevated surfaces
/// - onBackground: Text color on background
/// - success: Positive actions, checkmarks, confirmations
/// - warning: Warnings, errors, destructive actions
/// - text: Primary text color
///
/// After changing colors, restart the app to see changes.
/// All colors are applied through the MaterialApp theme in app.dart
class AppThemeColors {
  // -----------------------------------------------------------------------
  // Light theme palette - Custom blue theme
  // -----------------------------------------------------------------------
  static const Color lightPrimary = Color(0xFF458FCD); // Main menu items, buttons, sections
  static const Color lightOnPrimary = Color(0xFF0A1420); // Text on primary color
  static const Color lightSecondary = Color(0xFF458FCD); // Secondary elements
  static const Color lightBackground = Color(0xFFC5DFF7); // Main background
  static const Color lightSurface = Color(0xFFC5DFF7); // Surface backgrounds
  static const Color lightOnBackground = Color(0xFF0A1420); // Text color
  static const Color cardLight = Color(0xFFC5DFF7); // Card backgrounds

  // Status colors for light mode
  static const Color lightSuccess = Color(0xFF22C55E); // Checkmarks, success states
  static const Color lightWarning = Color(0xFFF36F47); // Warnings, errors
  static const Color lightText = Color(0xFF0A1420); // Primary text color

  // -----------------------------------------------------------------------
  // Dark theme palette - Dark blue theme (maintain contrast)
  // -----------------------------------------------------------------------
  static const Color darkPrimary = Color(0xFF458FCD); // Same as light for consistency
  static const Color darkOnPrimary = Color(0xFF0A1420); // Text on primary
  static const Color darkSecondary = Color(0xFF458FCD); // Secondary elements
  static const Color darkBackground = Color(0xFF0D1B2A); // Dark background
  static const Color darkSurface = Color(0xFF1B263B); // Dark surfaces
  static const Color darkOnBackground = Color(0xFFE0E1DD); // Light text on dark
  static const Color cardDark = Color(0xFF415A77); // Dark card backgrounds

  // Status colors for dark mode
  static const Color darkSuccess = Color(0xFF22C55E); // Checkmarks, success states
  static const Color darkWarning = Color(0xFFF36F47); // Warnings, errors
  static const Color darkText = Color(0xFFE0E1DD); // Primary text color

  // -----------------------------------------------------------------------
  // Banners and special-purpose colors
  // -----------------------------------------------------------------------
  static const Color bannerGlobalLight = Color(0xFF458FCD);
  static const Color bannerGlobalDark = Color(0xFF458FCD);

  static const Color bannerEventLight = Color(0xFF458FCD);
  static const Color bannerEventDark = Color(0xFF458FCD);

  static const Color systemMessageColor = Color(0xFFFFFFFF);

  static const Color bannerMainPagesLight = Color(0xFF458FCD);
  static const Color bannerMainPagesDark = Color(0xFF458FCD);

  static const Color bannerSubPagesLight = Color(0xFF458FCD);
  static const Color bannerSubPagesDark = Color(0xFF458FCD);

  // Page banner text colors
  static const Color bannerTextLight = Color(0xFF0A1420);
  static const Color bannerTextDark = Color(0xFFE0E1DD);

  // Notification banner text colors
  static const Color bannerGlobalTextLight = Color(0xFF0A1420);
  static const Color bannerGlobalTextDark = Color(0xFF0A1420);

  static const Color bannerEventTextLight = Color(0xFF0A1420);
  static const Color bannerEventTextDark = Color(0xFF0A1420);

  // -----------------------------------------------------------------------
  // Utilities / overlay / shadows
  // -----------------------------------------------------------------------
  static const Color transparent = Color(0x00000000);
  static const Color shadow = Color(0x1A000000); // ~10% black
  static const Color primaryOverlayLow = Color(0x14458FCD); // ~8% primary color

  // -----------------------------------------------------------------------
  // Helper methods for theme-aware colors
  // -----------------------------------------------------------------------

  /// Get the appropriate primary color based on current theme brightness
  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightPrimary
        : darkPrimary;
  }

  /// Get the appropriate success color based on current theme brightness
  static Color success(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightSuccess
        : darkSuccess;
  }

  /// Get the appropriate warning color based on current theme brightness
  static Color warning(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightWarning
        : darkWarning;
  }

  /// Get the appropriate text color based on current theme brightness
  static Color text(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightText
        : darkText;
  }
}
