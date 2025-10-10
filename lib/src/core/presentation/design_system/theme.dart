import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'spacing.dart';

/// Theme configuration for FloatIT app
/// Provides consistent theming across light and dark modes
class FloatITTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: FloatITColors.primary,
      primaryContainer: FloatITColors.primaryLight,
      secondary: FloatITColors.secondary,
      secondaryContainer: FloatITColors.secondaryLight,
      tertiary: FloatITColors.accent,
      tertiaryContainer: FloatITColors.accentLight,
      error: FloatITColors.error,
      surface: FloatITColors.surface,
      surfaceContainer: FloatITColors.surfaceVariant,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onError: Colors.white,
      onSurface: FloatITColors.onSurface,
      onSurfaceVariant: FloatITColors.onSurfaceVariant,
    ),

    // Typography
    textTheme: const TextTheme(
      displayLarge: FloatITTypography.displayLarge,
      displayMedium: FloatITTypography.displayMedium,
      displaySmall: FloatITTypography.displaySmall,
      headlineLarge: FloatITTypography.headlineLarge,
      headlineMedium: FloatITTypography.headlineMedium,
      headlineSmall: FloatITTypography.headlineSmall,
      titleLarge: FloatITTypography.titleLarge,
      titleMedium: FloatITTypography.titleMedium,
      titleSmall: FloatITTypography.titleSmall,
      bodyLarge: FloatITTypography.bodyLarge,
      bodyMedium: FloatITTypography.bodyMedium,
      bodySmall: FloatITTypography.bodySmall,
      labelLarge: FloatITTypography.labelLarge,
      labelMedium: FloatITTypography.labelMedium,
      labelSmall: FloatITTypography.labelSmall,
    ),

    // Component themes
    appBarTheme: const AppBarTheme(
      backgroundColor: FloatITColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: FloatITTypography.headlineSmall,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FloatITColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, FloatITSpacing.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        ),
        textStyle: FloatITTypography.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FloatITColors.primary,
        minimumSize: const Size(double.infinity, FloatITSpacing.buttonHeightMd),
        side: const BorderSide(color: FloatITColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        ),
        textStyle: FloatITTypography.labelLarge,
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: FloatITColors.primary,
        textStyle: FloatITTypography.labelLarge,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FloatITColors.surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        borderSide: const BorderSide(color: FloatITColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        borderSide: const BorderSide(color: FloatITColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        borderSide: const BorderSide(color: FloatITColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        borderSide: const BorderSide(color: FloatITColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: FloatITSpacing.md,
        vertical: FloatITSpacing.md,
      ),
      hintStyle: FloatITTypography.bodyMedium.copyWith(
        color: FloatITColors.textHint,
      ),
      labelStyle: FloatITTypography.bodyMedium.copyWith(
        color: FloatITColors.textSecondary,
      ),
    ),

    cardTheme: CardTheme(
      color: FloatITColors.surface,
      elevation: FloatITSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(FloatITSpacing.borderRadiusLg)),
      ),
      margin: EdgeInsets.zero,
    ),

    chipTheme: ChipThemeData(
      backgroundColor: FloatITColors.surfaceVariant,
      selectedColor: FloatITColors.primaryLight,
      checkmarkColor: Colors.white,
      labelStyle: FloatITTypography.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusFull),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: FloatITColors.secondary,
      foregroundColor: Colors.white,
      sizeConstraints: BoxConstraints.tightFor(
        width: FloatITSpacing.fabSize,
        height: FloatITSpacing.fabSize,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: FloatITColors.surface,
      selectedItemColor: FloatITColors.primary,
      unselectedItemColor: FloatITColors.textSecondary,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Spacing
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme
    colorScheme: const ColorScheme.dark(
      primary: FloatITColors.primaryDark,
      primaryContainer: FloatITColors.primary,
      secondary: FloatITColors.secondaryDark,
      secondaryContainer: FloatITColors.secondary,
      tertiary: FloatITColors.accentDark,
      tertiaryContainer: FloatITColors.accent,
      error: FloatITColors.error,
      surface: Color(0xFF1E1E1E),
      surfaceContainer: Color(0xFF2D2D2D),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onError: Colors.white,
      onSurface: Colors.white,
      onSurfaceVariant: Color(0xFFBDBDBD),
    ),

    // Typography (same as light theme)
    textTheme: const TextTheme(
      displayLarge: FloatITTypography.displayLarge,
      displayMedium: FloatITTypography.displayMedium,
      displaySmall: FloatITTypography.displaySmall,
      headlineLarge: FloatITTypography.headlineLarge,
      headlineMedium: FloatITTypography.headlineMedium,
      headlineSmall: FloatITTypography.headlineSmall,
      titleLarge: FloatITTypography.titleLarge,
      titleMedium: FloatITTypography.titleMedium,
      titleSmall: FloatITTypography.titleSmall,
      bodyLarge: FloatITTypography.bodyLarge,
      bodyMedium: FloatITTypography.bodyMedium,
      bodySmall: FloatITTypography.bodySmall,
      labelLarge: FloatITTypography.labelLarge,
      labelMedium: FloatITTypography.labelMedium,
      labelSmall: FloatITTypography.labelSmall,
    ),

    // Component themes
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: FloatITTypography.headlineSmall,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: FloatITColors.primaryDark,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, FloatITSpacing.buttonHeightMd),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        ),
        textStyle: FloatITTypography.labelLarge,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FloatITColors.primary,
        minimumSize: const Size(double.infinity, FloatITSpacing.buttonHeightMd),
        side: const BorderSide(color: FloatITColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
        ),
        textStyle: FloatITTypography.labelLarge,
      ),
    ),

    textButtonTheme: const TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(FloatITColors.primary),
        textStyle: WidgetStatePropertyAll(FloatITTypography.labelLarge),
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2D2D2D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(FloatITSpacing.borderRadiusMd)),
        borderSide: BorderSide(color: Color(0xFF5D5D5D)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(FloatITSpacing.borderRadiusMd)),
        borderSide: BorderSide(color: Color(0xFF5D5D5D)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(FloatITSpacing.borderRadiusMd)),
        borderSide: BorderSide(color: FloatITColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(FloatITSpacing.borderRadiusMd)),
        borderSide: BorderSide(color: FloatITColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: FloatITSpacing.md,
        vertical: FloatITSpacing.md,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0.25,
        color: Color(0xFF9E9E9E),
      ),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.55,
        letterSpacing: 0.25,
        color: Color(0xFFBDBDBD),
      ),
    ),

    cardTheme: CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: FloatITSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(FloatITSpacing.borderRadiusLg)),
      ),
      margin: EdgeInsets.zero,
    ),

    chipTheme: const ChipThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      selectedColor: FloatITColors.primaryDark,
      checkmarkColor: Colors.white,
      labelStyle: FloatITTypography.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(FloatITSpacing.borderRadiusFull)),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: FloatITColors.secondaryDark,
      foregroundColor: Colors.white,
      sizeConstraints: BoxConstraints.tightFor(
        width: FloatITSpacing.fabSize,
        height: FloatITSpacing.fabSize,
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: FloatITColors.primary,
      unselectedItemColor: Color(0xFFBDBDBD),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),

    // Spacing
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}