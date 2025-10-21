import 'package:flutter/material.dart';
import '../theme_colors.dart';
import '../layout_widgets.dart';
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
    // Use theme-appropriate colors for transparent banners
    final bannerTextColor = AppThemeColors.text(context);
  // banner background colors intentionally unused; banners are transparent now

    // Use a mostly-invisible background so the top bar is subtle in both themes.
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Material(
        color: AppThemeColors.transparent,
        child: SafeArea(
          top: true,
          child: ConstrainedContent(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SizedBox(
              height: kToolbarHeight,
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
    final bannerTextColor = AppThemeColors.text(context);

    return Container(
      height: kToolbarHeight,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        top: true,
        child: ConstrainedContent(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                    'assets/float_it.png',
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
      ),
    );
  }
}
