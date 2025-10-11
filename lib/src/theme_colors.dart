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
  // Light theme palette - Custom blue theme with shaded variations
  // -----------------------------------------------------------------------
  static const Color lightPrimary = Color(0xFF458FCD); // Primary 500 - Main menu items, buttons, sections
  static const Color lightOnPrimary = Color(0xFFFFFFFF); // White text on primary buttons for better contrast
  static const Color lightSecondary = Color(0xFF2E75B8); // Primary 600 - Secondary elements, slightly darker
  static const Color lightBackground = Color(0xFFE0EDFE); // Primary 100 - More blue background
  static const Color lightSurface = Color(0xFFBDD7FC); // Primary 200 - Cards and elevated surfaces (more blue)
  static const Color lightOnBackground = Color(0xFF183856); // Primary 900 - Dark text on light background
  static const Color cardLight = Color(0xFFBDD7FC); // Primary 200 - Event cards (matches pool banner normal state)

  // Status colors for light mode
  static const Color lightSuccess = Color(0xFF22C55E); // Success 500 - Checkmarks, success states
  static const Color lightWarning = Color(0xFFF36F47); // Warning 500 - Warnings, errors
  static const Color lightText = Color(0xFF183856); // Primary 900 - Primary text color
  
  // Attendance badge colors for light mode
  static const Color lightHostingBadge = Color(0xFF2E75B8); // Primary 600 - Hosting badge (blue)
  static const Color lightAttendingBadge = Color(0xFF22C55E); // Success 500 - Attending badge (green)
  static const Color lightWaitingBadge = Color(0xFFF36F47); // Warning 500 - Waiting list badge (orange)
  static const Color lightBadgeIcon = Color(0xFFFFFFFF); // White - Icon color on badges

  // -----------------------------------------------------------------------
  // Dark theme palette - Dark blue theme with shaded variations
  // -----------------------------------------------------------------------
  static const Color darkPrimary = Color(0xFF7AB8E8); // Primary 700 Dark - Lighter for dark backgrounds
  static const Color darkOnPrimary = Color(0xFF0A1420); // Primary 50 Dark - Dark text on light primary
  static const Color darkSecondary = Color(0xFF5BA3E0); // Primary 600 Dark - Secondary elements
  static const Color darkBackground = Color(0xFF162638); // Primary 100 Dark - More blue dark background
  static const Color darkSurface = Color(0xFF1E3449); // Primary 200 Dark - Elevated surfaces (more blue)
  static const Color darkOnBackground = Color(0xFFF0F6FF); // Primary 50 Light - Light text on dark
  static const Color cardDark = Color(0xFF1E3449); // Primary 200 Dark - Event cards (matches pool banner normal state)

  // Status colors for dark mode
  static const Color darkSuccess = Color(0xFF4ADE80); // Success 400 - Brighter green for dark mode
  static const Color darkWarning = Color(0xFFF36F47); // Warning 500 - Same as light mode
  static const Color darkText = Color(0xFFF0F6FF); // Primary 50 Light - Primary text color
  
  // Attendance badge colors for dark mode
  static const Color darkHostingBadge = Color(0xFF7AB8E8); // Primary 700 Dark - Hosting badge (lighter blue)
  static const Color darkAttendingBadge = Color(0xFF4ADE80); // Success 400 - Attending badge (brighter green)
  static const Color darkWaitingBadge = Color(0xFFF78A68); // Warning 600 Dark - Waiting list badge (lighter orange)
  static const Color darkBadgeIcon = Color(0xFF0A1420); // Primary 50 Dark - Dark icon on light badges

  // -----------------------------------------------------------------------
  // Banners and special-purpose colors
  // -----------------------------------------------------------------------
  // Pool status banner - normal state matches event cards for consistency
  static const Color bannerGlobalLight = Color(0xFF458FCD); // Primary 500
  static const Color bannerGlobalDark = Color(0xFF7AB8E8); // Primary 700 Dark

  // Event-specific banners match event cards (less intrusive)
  static const Color bannerEventLight = Color(0xFFBDD7FC); // Primary 200 - Matches cardLight
  static const Color bannerEventDark = Color(0xFF1E3449); // Primary 200 Dark - Matches cardDark

  static const Color systemMessageColor = Color(0xFFE0EDFE); // Primary 100 Light - System messages

  static const Color bannerMainPagesLight = Color(0xFF458FCD); // Primary 500
  static const Color bannerMainPagesDark = Color(0xFF7AB8E8); // Primary 700 Dark

  static const Color bannerSubPagesLight = Color(0xFF2E75B8); // Primary 600
  static const Color bannerSubPagesDark = Color(0xFF5BA3E0); // Primary 600 Dark

  // Page banner text colors
  static const Color bannerTextLight = Color(0xFF183856); // Primary 900
  static const Color bannerTextDark = Color(0xFFF0F6FF); // Primary 50 Light

  // Notification banner text colors
  static const Color bannerGlobalTextLight = Color(0xFFFFFFFF); // White on primary
  static const Color bannerGlobalTextDark = Color(0xFF0A1420); // Dark on light primary

  static const Color bannerEventTextLight = Color(0xFF183856); // Primary 900 - Dark text on light banner
  static const Color bannerEventTextDark = Color(0xFFF0F6FF); // Primary 50 Light - Light text on dark banner

  // -----------------------------------------------------------------------
  // Utilities / overlay / shadows
  // -----------------------------------------------------------------------
  static const Color transparent = Color(0x00000000);
  static const Color shadow = Color(0x1A000000); // ~10% black for shadows
  static const Color primaryOverlayLow = Color(0x14458FCD); // ~8% primary color for hover states
  
  // Neutral grays for subtle UI elements
  static const Color neutralLight200 = Color(0xFFE4E4E7); // Neutral 200 Light - Borders, dividers
  static const Color neutralLight400 = Color(0xFFA1A1AA); // Neutral 400 Light - Disabled states
  static const Color neutralDark700 = Color(0xFFD4D4D8); // Neutral 700 Dark - Borders in dark mode
  static const Color neutralDark500 = Color(0xFF71717A); // Neutral 500 - Disabled states (both modes)

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
  
  /// Get the hosting badge color based on current theme brightness
  static Color hostingBadge(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightHostingBadge
        : darkHostingBadge;
  }
  
  /// Get the attending badge color based on current theme brightness
  static Color attendingBadge(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightAttendingBadge
        : darkAttendingBadge;
  }
  
  /// Get the waiting list badge color based on current theme brightness
  static Color waitingBadge(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightWaitingBadge
        : darkWaitingBadge;
  }
  
  /// Get the badge icon color based on current theme brightness
  static Color badgeIcon(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? lightBadgeIcon
        : darkBadgeIcon;
  }
}
