import 'package:flutter/material.dart';

/// Theme-related constants and color definitions
class AppThemeColors {
  AppThemeColors._();
  
  // ===== PRIMARY THEME COLORS =====
  static const lightPrimary = Color(0xFF2196F3); // Blue
  static const darkPrimary = Color(0xFF1976D2); // Darker blue
  
  // ===== BANNER COLORS =====
  // Global banners (admin notifications)
  static const bannerGlobalLight = Color(0xFFE3F2FD); // Light blue
  static const bannerGlobalDark = Color(0xFF1A237E); // Dark blue
  static const bannerGlobalTextLight = Color(0xFF0D47A1); // Dark blue text
  static const bannerGlobalTextDark = Color(0xFFBBDEFB); // Light blue text
  
  // Event banners (event-specific notifications)
  static const bannerEventLight = Color(0xFFF3E5F5); // Light purple
  static const bannerEventDark = Color(0xFF4A148C); // Dark purple
  static const bannerEventTextLight = Color(0xFF6A1B9A); // Dark purple text
  static const bannerEventTextDark = Color(0xFFE1BEE7); // Light purple text
  
  // ===== CARD/SURFACE COLORS =====
  static const cardLight = Color(0xFFFFFFFF); // White
  static const cardDark = Color(0xFF2E2E2E); // Dark grey
  
  // ===== STATUS COLORS =====
  static const success = Color(0xFF4CAF50); // Green
  static const warning = Color(0xFFFF9800); // Orange
  static const error = Color(0xFFF44336); // Red
  static const info = Color(0xFF2196F3); // Blue
  
  // ===== SWIMMER ICON COLORS =====
  static const iconColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFF44336), // Red
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF795548), // Brown
  ];
  
  // ===== GRADIENTS =====
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const errorGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Additional theme-specific border radius constants
class ThemeBorderRadii {
  ThemeBorderRadii._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0; // Fully rounded
}

/// Opacity constants
class Opacities {
  Opacities._();
  
  static const double disabled = 0.38;
  static const double hint = 0.60;
  static const double secondary = 0.74;
  static const double overlay = 0.16;
  static const double focus = 0.12;
  static const double hover = 0.08;
  static const double selected = 0.08;
}

/// Duration constants for animations
class AnimationDurations {
  AnimationDurations._();
  
  static const fast = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
  static const verySlow = Duration(milliseconds: 750);
}