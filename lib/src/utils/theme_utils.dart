import 'package:flutter/material.dart';
import '../theme/theme_constants.dart';

/// Theme utilities and helper functions for consistent theming across the app
class ThemeUtils {
  ThemeUtils._();
  
  /// Get text color based on theme brightness
  static Color getTextColor(BuildContext context, {bool onSurface = false}) {
    final theme = Theme.of(context);
    return onSurface 
        ? theme.colorScheme.onSurface 
        : theme.colorScheme.onSurface;
  }
  
  /// Get appropriate banner text color
  static Color getBannerTextColor(BuildContext context, {bool isGlobal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isGlobal) {
      return isDark 
          ? AppThemeColors.bannerGlobalTextDark 
          : AppThemeColors.bannerGlobalTextLight;
    } else {
      return isDark 
          ? AppThemeColors.bannerEventTextDark 
          : AppThemeColors.bannerEventTextLight;
    }
  }
  
  /// Get appropriate banner background color
  static Color getBannerBackgroundColor(BuildContext context, {bool isGlobal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isGlobal) {
      return isDark 
          ? AppThemeColors.bannerGlobalDark 
          : AppThemeColors.bannerGlobalLight;
    } else {
      return isDark 
          ? AppThemeColors.bannerEventDark 
          : AppThemeColors.bannerEventLight;
    }
  }
  
  /// Get card color based on theme
  static Color getCardColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppThemeColors.cardDark : AppThemeColors.cardLight;
  }
  
  /// Create a consistent button style
  static ButtonStyle getButtonStyle(
    BuildContext context, {
    ButtonType type = ButtonType.primary,
    ButtonSize size = ButtonSize.medium,
  }) {
    final theme = Theme.of(context);
    
    Color backgroundColor;
    Color foregroundColor;
    
    switch (type) {
      case ButtonType.primary:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case ButtonType.secondary:
        backgroundColor = theme.colorScheme.secondary;
        foregroundColor = theme.colorScheme.onSecondary;
        break;
      case ButtonType.error:
        backgroundColor = theme.colorScheme.error;
        foregroundColor = theme.colorScheme.onError;
        break;
      case ButtonType.surface:
        backgroundColor = theme.colorScheme.surface;
        foregroundColor = theme.colorScheme.onSurface;
        break;
    }
    
    double fontSize;
    EdgeInsets padding;
    
    switch (size) {
      case ButtonSize.small:
        fontSize = 12;
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        break;
      case ButtonSize.medium:
        fontSize = 14;
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
        break;
      case ButtonSize.large:
        fontSize = 16;
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
        break;
    }
    
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ThemeBorderRadii.md),
      ),
    );
  }
  
  /// Create consistent input decoration
  static InputDecoration getInputDecoration({
    required String label,
    String? hint,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? errorText,
    bool filled = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      errorText: errorText,
      filled: filled,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeBorderRadii.md),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeBorderRadii.md),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeBorderRadii.md),
        borderSide: const BorderSide(color: AppThemeColors.lightPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ThemeBorderRadii.md),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
  
  /// Get text style variants
  static TextStyle getTextStyle(
    BuildContext context, 
    TextStyleVariant variant,
  ) {
    final theme = Theme.of(context);
    
    switch (variant) {
      case TextStyleVariant.displayLarge:
        return theme.textTheme.displayLarge ?? const TextStyle(fontSize: 32, fontWeight: FontWeight.bold);
      case TextStyleVariant.displayMedium:
        return theme.textTheme.displayMedium ?? const TextStyle(fontSize: 28, fontWeight: FontWeight.bold);
      case TextStyleVariant.headlineLarge:
        return theme.textTheme.headlineLarge ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
      case TextStyleVariant.headlineMedium:
        return theme.textTheme.headlineMedium ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
      case TextStyleVariant.titleLarge:
        return theme.textTheme.titleLarge ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.w500);
      case TextStyleVariant.titleMedium:
        return theme.textTheme.titleMedium ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
      case TextStyleVariant.bodyLarge:
        return theme.textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
      case TextStyleVariant.bodyMedium:
        return theme.textTheme.bodyMedium ?? const TextStyle(fontSize: 14);
      case TextStyleVariant.bodySmall:
        return theme.textTheme.bodySmall ?? const TextStyle(fontSize: 12);
      case TextStyleVariant.labelLarge:
        return theme.textTheme.labelLarge ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
      case TextStyleVariant.labelMedium:
        return theme.textTheme.labelMedium ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
      case TextStyleVariant.labelSmall:
        return theme.textTheme.labelSmall ?? const TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
    }
  }
  
  /// Create shadow styles
  static List<BoxShadow> getShadow(ShadowType type) {
    switch (type) {
      case ShadowType.none:
        return [];
      case ShadowType.subtle:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
      case ShadowType.medium:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      case ShadowType.strong:
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
    }
  }
  
  /// Check if current theme is dark
  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
  
  /// Get elevation for cards/surfaces
  static double getElevation(ElevationType type) {
    switch (type) {
      case ElevationType.none:
        return 0;
      case ElevationType.subtle:
        return 1;
      case ElevationType.medium:
        return 4;
      case ElevationType.high:
        return 8;
    }
  }
}

// ===== ENUMS FOR THEME VARIANTS =====

enum ButtonType { primary, secondary, error, surface }

enum ButtonSize { small, medium, large }

enum TextStyleVariant {
  displayLarge,
  displayMedium,
  headlineLarge,
  headlineMedium,
  titleLarge,
  titleMedium,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

enum ShadowType { none, subtle, medium, strong }

enum ElevationType { none, subtle, medium, high }

// ===== THEME EXTENSIONS =====

/// Extension methods for Theme-related operations
extension ThemeExtensions on BuildContext {
  /// Quick access to theme
  ThemeData get theme => Theme.of(this);
  
  /// Quick access to color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Quick access to text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Check if theme is dark
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  /// Get appropriate text color
  Color get onBackground => colors.onSurface;
  Color get onSurface => colors.onSurface;
  Color get onPrimary => colors.onPrimary;
  
  /// Quick access to common colors
  Color get primary => colors.primary;
  Color get secondary => colors.secondary;
  Color get error => colors.error;
  Color get surface => colors.surface;
  Color get background => colors.surface;
}