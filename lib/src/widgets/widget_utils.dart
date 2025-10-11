import 'package:flutter/material.dart';
import '../theme_colors.dart';
import '../constants/app_constants.dart';

/// Common widget patterns and utilities to reduce repetitive code and widget nesting
class WidgetUtils {
  WidgetUtils._();
  
  /// Create a standard card with consistent styling
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? elevation,
    Color? color,
    VoidCallback? onTap,
  }) {
    Widget cardChild = child;
    
    if (padding != null) {
      cardChild = Padding(padding: padding, child: cardChild);
    }
    
    final card = Card(
      elevation: elevation ?? 1,
      color: color,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: Paddings.sm, 
        vertical: Paddings.xs,
      ),
      child: cardChild,
    );
    
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadii.md),
        child: card,
      );
    }
    
    return card;
  }
  
  /// Create a section with header and content
  static Widget section({
    required String title,
    required Widget child,
    EdgeInsetsGeometry? padding,
    List<Widget>? actions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: padding ?? const EdgeInsets.all(Paddings.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (actions != null) ...actions,
            ],
          ),
        ),
        child,
      ],
    );
  }
  
  /// Create a list tile with consistent styling
  static Widget listTile({
    Widget? leading,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool dense = false,
  }) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
      dense: dense,
    );
  }
  
  /// Create a form section with consistent spacing
  static Widget formSection({
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
    double spacing = Spacing.md,
  }) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(Paddings.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children
            .expand((widget) => [widget, SizedBox(height: spacing)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }
  
  /// Create a button bar with consistent spacing
  static Widget buttonBar({
    required List<Widget> children,
    MainAxisAlignment alignment = MainAxisAlignment.end,
    double spacing = Spacing.md,
  }) {
    return Padding(
      padding: const EdgeInsets.all(Paddings.md),
      child: Row(
        mainAxisAlignment: alignment,
        children: children
            .expand((widget) => [widget, SizedBox(width: spacing)])
            .take(children.length * 2 - 1)
            .toList(),
      ),
    );
  }
  
  /// Create an info banner with icon and message
  static Widget infoBanner({
    required BuildContext context,
    required String message,
    IconData icon = Icons.info_outline,
    Color? backgroundColor,
    Color? textColor,
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin ?? const EdgeInsets.all(Paddings.md),
      padding: const EdgeInsets.all(Paddings.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppThemeColors.primary(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(BorderRadii.md),
        border: Border.all(color: AppThemeColors.primary(context).withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor ?? AppThemeColors.primary(context), size: IconSizes.md),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor ?? AppThemeColors.primary(context)),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Create a status badge
  static Widget statusBadge(
    BuildContext context, {
    required String text,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBgColor = isDark 
        ? AppThemeColors.darkSurface 
        : AppThemeColors.lightSurface;
    final defaultTextColor = AppThemeColors.text(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Paddings.sm,
        vertical: Paddings.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBgColor,
        borderRadius: BorderRadius.circular(BorderRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: IconSizes.sm, color: textColor ?? defaultTextColor),
            const SizedBox(width: Spacing.xs),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor ?? defaultTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Create a responsive layout that switches between column and row
  static Widget responsiveLayout({
    required List<Widget> children,
    double breakpoint = 600,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > breakpoint) {
          return Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          );
        } else {
          return Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            children: children,
          );
        }
      },
    );
  }
  
  /// Create a safe area wrapper with consistent padding
  static Widget safeWrapper({
    required Widget child,
    EdgeInsetsGeometry? padding,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(Paddings.md),
        child: child,
      ),
    );
  }
}

/// Extension methods for common widget operations
extension WidgetExtensions on Widget {
  /// Add padding to any widget
  Widget paddingAll(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }
  
  /// Add horizontal padding
  Widget paddingHorizontal(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: this,
    );
  }
  
  /// Add vertical padding
  Widget paddingVertical(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: this,
    );
  }
  
  /// Add margin using Container
  Widget marginAll(double margin) {
    return Container(
      margin: EdgeInsets.all(margin),
      child: this,
    );
  }
  
  /// Wrap in Expanded widget
  Widget expanded({int flex = 1}) {
    return Expanded(flex: flex, child: this);
  }
  
  /// Wrap in Flexible widget
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }
  
  /// Center the widget
  Widget centered() {
    return Center(child: this);
  }
  
  /// Add a tap handler
  Widget onTap(VoidCallback? onTap) {
    return InkWell(onTap: onTap, child: this);
  }
}

/// Utility functions for spacing
class SpacingUtils {
  /// Vertical spacing widgets
  static Widget get xs => const SizedBox(height: Spacing.xs);
  static Widget get sm => const SizedBox(height: Spacing.sm);
  static Widget get md => const SizedBox(height: Spacing.md);
  static Widget get lg => const SizedBox(height: Spacing.lg);
  static Widget get xl => const SizedBox(height: Spacing.xl);
  static Widget get xxl => const SizedBox(height: Spacing.xxl);
  
  /// Horizontal spacing widgets
  static Widget get hXs => const SizedBox(width: Spacing.xs);
  static Widget get hSm => const SizedBox(width: Spacing.sm);
  static Widget get hMd => const SizedBox(width: Spacing.md);
  static Widget get hLg => const SizedBox(width: Spacing.lg);
  static Widget get hXl => const SizedBox(width: Spacing.xl);
  static Widget get hXxl => const SizedBox(width: Spacing.xxl);
  
  /// Custom spacing
  static Widget vertical(double height) => SizedBox(height: height);
  static Widget horizontal(double width) => SizedBox(width: width);
}