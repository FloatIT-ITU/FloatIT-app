import 'package:flutter/material.dart';
import '../layout_widgets.dart';
import '../theme_colors.dart';

/// Reusable notification/banner widget used for global and event-scoped banners.
///
/// The widget keeps layout consistent and picks text color based on whether
/// the banner is a global or event banner and the current brightness.
class NotificationBanner extends StatefulWidget {
  final String title;
  final String? body;
  final Color backgroundColor;
  final VoidCallback? onTap;
  final bool isGlobal;
  final VoidCallback? onDismiss;
  final bool useSafeArea;

  const NotificationBanner({
    super.key,
    required this.title,
    this.body,
    required this.backgroundColor,
    this.onTap,
    this.isGlobal = false,
    this.onDismiss,
    this.useSafeArea = true,
  });

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = widget.isGlobal
        ? (isDark ? AppThemeColors.bannerGlobalTextDark : AppThemeColors.bannerGlobalTextLight)
        : (isDark ? AppThemeColors.bannerEventTextDark : AppThemeColors.bannerEventTextLight);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          color: widget.backgroundColor,
          child: widget.useSafeArea ? SafeArea(
            top: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: ConstrainedContent(
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: widget.onTap,
                        child: Row(
                          children: [
                            Icon(
                              widget.isGlobal ? Icons.campaign : Icons.event_note,
                              color: textColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if ((widget.body ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        widget.body ?? '',
                                        style: TextStyle(
                                          color: textColor.withOpacity(0.8),
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.onDismiss != null)
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: textColor.withOpacity(0.7),
                          size: 18,
                        ),
                        onPressed: _handleDismiss,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ) : Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Icon(
                  widget.isGlobal ? Icons.campaign : Icons.event_note,
                  color: textColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: InkWell(
                    onTap: widget.onTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        if ((widget.body ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              widget.body ?? '',
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.onDismiss != null)
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: textColor.withOpacity(0.7),
                      size: 16,
                    ),
                    onPressed: _handleDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
