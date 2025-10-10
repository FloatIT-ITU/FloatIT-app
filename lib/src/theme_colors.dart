import 'package:flutter/material.dart';

/// Centralized color palette for the app.
///
/// This file intentionally groups colors by purpose and theme so it's clear
/// which values are used for light vs dark modes. Add new colors here when
/// they should be reused across widgets instead of being inlined locally.
class AppThemeColors {
  // -----------------------------------------------------------------------
  // Light theme palette - Blue shades
  // -----------------------------------------------------------------------
  static const Color lightPrimary = Color(0xFF1976D2); // Medium blue
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF2196F3); // Bright blue
  static const Color lightBackground = Color(0xFFE3F2FD); // Very light blue
  static const Color lightSurface = Color(0xFFBBDEFB); // Light blue surface
  static const Color lightOnBackground = Color(0xFF0D47A1); // Dark blue text
  static const Color cardLight = Color(0xFF90CAF9); // Light blue cards

  // -----------------------------------------------------------------------
  // Dark theme palette - Blue shades
  // -----------------------------------------------------------------------
  static const Color darkPrimary = Color(0xFF64B5F6); // Light blue for dark theme
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkSecondary = Color(0xFF1976D2); // Medium blue
  static const Color darkBackground = Color(0xFF0D1B2A); // Dark blue background
  static const Color darkSurface = Color(0xFF1B263B); // Dark blue surface
  static const Color darkOnBackground = Color(0xFFE0E1DD); // Light text on dark
  static const Color cardDark = Color(0xFF415A77); // Medium dark blue cards

  // -----------------------------------------------------------------------
  // Banners and special-purpose colors - Blue shades
  static const Color bannerGlobalLight = Color(0xFF42A5F5); // Light blue
  static const Color bannerGlobalDark = Color(0xFF42A5F5);

  static const Color bannerEventLight = Color(0xFF64B5F6); // Lighter blue
  static const Color bannerEventDark = Color(0xFF64B5F6);

  static const Color bannerMainPagesLight = Color(0xFF1976D2); // Medium blue
  static const Color bannerMainPagesDark = Color(0xFF1976D2);

  static const Color bannerSubPagesLight = Color(0xFF1976D2); // Medium blue
  static const Color bannerSubPagesDark = Color(0xFF1976D2);

// Page banner text colors (not global or event notifications)
  static const Color bannerTextLight = Color(0xFFFFFFFF);
  static const Color bannerTextDark = Color(0xFFFFFFFF);

  // Notification banner text colors (global/event-scoped banners)
  static const Color bannerGlobalTextLight = Color(0xFF000000);
  static const Color bannerGlobalTextDark = Color(0xFF000000);

  static const Color bannerEventTextLight = Color(0xFF000000);
  static const Color bannerEventTextDark = Color(0xFF000000);
  // -----------------------------------------------------------------------
  // Utilities / overlay / shadows
  // Keep these documented so it's obvious where they're intended to be used.
  // - `transparent`: alias for a fully transparent color (use where explicit
  //   transparency helps readability; otherwise `Colors.transparent` is fine).
  // - `shadow`: default BoxShadow color (black with ~10% alpha). Prefer using
  //   this rather than repeating alpha math across the repo.
  // - `primaryOverlayLow`: a low-opacity overlay using the light primary color
  //   (approx 8% alpha). Used for subtle highlighted backgrounds.
  static const Color transparent = Color(0x00000000);
  static const Color shadow = Color(0x1A000000); // ~10% black
  static const Color primaryOverlayLow = Color(0x141976D2); // ~8% medium blue
}
