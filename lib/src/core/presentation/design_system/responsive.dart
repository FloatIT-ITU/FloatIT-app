import 'package:flutter/material.dart';

/// Responsive layout utilities for FloatIT app
/// Provides helpers for responsive design across different screen sizes
class FloatITResponsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Screen size categories
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Responsive padding
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  // Responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    if (isMobile(context)) {
      return baseSpacing * 0.8;
    } else if (isTablet(context)) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.2;
    }
  }

  // Responsive text scaling
  static double getTextScale(BuildContext context) {
    if (isMobile(context)) {
      return 0.9;
    } else if (isTablet(context)) {
      return 1.0;
    } else {
      return 1.1;
    }
  }

  // Grid layout helpers
  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) {
      return 1;
    } else if (isTablet(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Card sizing
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getScreenPadding(context);
    final availableWidth = screenWidth - padding.left - padding.right;

    if (isMobile(context)) {
      return availableWidth;
    } else if (isTablet(context)) {
      return (availableWidth - 16) / 2; // 16 is grid spacing
    } else {
      return (availableWidth - 32) / 3; // 32 is grid spacing
    }
  }

  // Dialog sizing
  static Size getDialogSize(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmall = isSmallScreen(context);

    return Size(
      isSmall ? screenSize.width * 0.9 : 400,
      isSmall ? screenSize.height * 0.8 : 600,
    );
  }

  // Navigation helpers
  static bool shouldUseBottomNav(BuildContext context) {
    return isMobile(context);
  }

  static bool shouldUseSideNav(BuildContext context) {
    return isDesktop(context);
  }

  // Orientation helpers
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}

/// Extension methods for responsive widgets
extension ResponsiveExtensions on BuildContext {
  bool get isMobile => FloatITResponsive.isMobile(this);
  bool get isTablet => FloatITResponsive.isTablet(this);
  bool get isDesktop => FloatITResponsive.isDesktop(this);
  bool get isSmallScreen => FloatITResponsive.isSmallScreen(this);
  bool get isLargeScreen => FloatITResponsive.isLargeScreen(this);
  bool get isPortrait => FloatITResponsive.isPortrait(this);
  bool get isLandscape => FloatITResponsive.isLandscape(this);

  EdgeInsets get screenPadding => FloatITResponsive.getScreenPadding(this);
  double getTextScale() => FloatITResponsive.getTextScale(this);
  int get gridCrossAxisCount => FloatITResponsive.getGridCrossAxisCount(this);
  double get cardWidth => FloatITResponsive.getCardWidth(this);
  Size get dialogSize => FloatITResponsive.getDialogSize(this);

  bool get shouldUseBottomNav => FloatITResponsive.shouldUseBottomNav(this);
  bool get shouldUseSideNav => FloatITResponsive.shouldUseSideNav(this);
}
