import 'package:flutter/material.dart';
import '../colors.dart';
import '../spacing.dart';
import '../typography.dart';

/// Primary button with consistent styling
class FloatITPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const FloatITPrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? FloatITSpacing.buttonHeightMd;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: FloatITColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
          ),
          textStyle: FloatITTypography.labelLarge,
        ),
        child: isLoading
            ? const SizedBox(
                width: FloatITSpacing.iconMd,
                height: FloatITSpacing.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: FloatITSpacing.iconMd),
                    const SizedBox(width: FloatITSpacing.sm),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}

/// Secondary button with outline styling
class FloatITSecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const FloatITSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? FloatITSpacing.buttonHeightMd;

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: buttonHeight,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: FloatITColors.primary,
          side: const BorderSide(color: FloatITColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FloatITSpacing.borderRadiusMd),
          ),
          textStyle: FloatITTypography.labelLarge,
        ),
        child: isLoading
            ? const SizedBox(
                width: FloatITSpacing.iconMd,
                height: FloatITSpacing.iconMd,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(FloatITColors.primary),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: FloatITSpacing.iconMd),
                    const SizedBox(width: FloatITSpacing.sm),
                  ],
                  Text(text),
                ],
              ),
      ),
    );
  }
}

/// Text button for less prominent actions
class FloatITTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const FloatITTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: FloatITColors.primary,
        textStyle: FloatITTypography.labelLarge,
      ),
      child: isLoading
          ? const SizedBox(
              width: FloatITSpacing.iconMd,
              height: FloatITSpacing.iconMd,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(FloatITColors.primary),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: FloatITSpacing.iconMd),
                  const SizedBox(width: FloatITSpacing.sm),
                ],
                Text(text),
              ],
            ),
    );
  }
}

/// Icon button with consistent styling
class FloatITIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double? size;
  final EdgeInsetsGeometry? padding;

  const FloatITIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: color ?? FloatITColors.primary,
      iconSize: size ?? FloatITSpacing.iconMd,
      padding: padding ?? const EdgeInsets.all(FloatITSpacing.sm),
      constraints: const BoxConstraints(),
    );
  }
}

/// Floating action button with consistent styling
class FloatITFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const FloatITFloatingActionButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? FloatITColors.secondary,
      foregroundColor: foregroundColor ?? Colors.white,
      child: Icon(icon),
    );
  }
}
