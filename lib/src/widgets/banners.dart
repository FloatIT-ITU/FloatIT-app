import 'package:flutter/material.dart';
import '../theme_colors.dart';
// styles.dart is not required here; banners now inherit Theme's textTheme

class PageBanner extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackArrow;
  final VoidCallback? onBack;

  const PageBanner({
    super.key,
    required this.title,
    this.actions,
    this.showBackArrow = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use theme-appropriate colors for transparent banners
    final bannerTextColor = isDark ? Colors.white : Colors.black;
  // banner background colors intentionally unused; banners are transparent now

    // Use a mostly-invisible background so the top bar is subtle in both themes.
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Material(
        color: AppThemeColors.transparent,
        child: SafeArea(
          top: true,
          child: Container(
            color: Colors.transparent,
            child: SizedBox(
              height: kToolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    if (showBackArrow)
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: bannerTextColor),
                        onPressed:
                            onBack ?? () => Navigator.of(context).maybePop(),
                      ),
                    if (!showBackArrow) const SizedBox(width: 8),
                    Text(
                      title,
                      // Inherit the full titleLarge text style from the Theme so font family,
                      // size and weight come from the app-wide textTheme (AppTextStyles).
                      style: (Theme.of(context).textTheme.titleLarge ??
                              const TextStyle())
                          .copyWith(
                        color: bannerTextColor,
                      ),
                    ),
                    const Spacer(),
                    if (actions != null)
                      Row(mainAxisSize: MainAxisSize.min, children: actions!),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StandardPageBanner extends StatelessWidget {
  final String title;
  final bool showBackArrow;
  final VoidCallback? onBack;
  final Widget? leading;

  const StandardPageBanner({
    super.key,
    required this.title,
    this.showBackArrow = false,
    this.onBack,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerTextColor = isDark ? Colors.white : Colors.black;

    return Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: true,
        child: Stack(
          children: [
            // Back arrow on the far left
            if (showBackArrow)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: bannerTextColor),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
              ),
            // Centered content (icon + title)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Custom leading widget or app icon/logo
                  leading ?? Image.asset(
                    'assets/icon.png',
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  // Page title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: bannerTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
