import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:floatit/src/pool_status_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:floatit/src/services/rate_limit_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:floatit/src/theme_colors.dart';
import 'package:floatit/src/layout_widgets.dart';

/// A persistent banner that displays the pool status at the bottom of the screen
class PoolStatusBanner extends StatelessWidget {
  const PoolStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PoolStatusProvider>(
      builder: (context, provider, child) {
        final status = provider.currentStatus;

        // Don't show banner if there's no status
        if (status == null || status.isEmpty) {
          return const SizedBox.shrink();
        }

        final isNormal = provider.isNormalStatus;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final backgroundColor = !isNormal
            ? AppThemeColors.warning(context)
            : isDark
                ? AppThemeColors.bannerEventDark
                : AppThemeColors.bannerEventLight;
        final textColor = !isNormal
            ? AppThemeColors.badgeIcon(context)
            : isDark
                ? AppThemeColors.bannerEventTextDark
                : AppThemeColors.bannerEventTextLight;
        final iconColor = !isNormal
            ? AppThemeColors.badgeIcon(context)
            : isDark
                ? AppThemeColors.bannerEventTextDark
                : AppThemeColors.bannerEventTextLight;

        return Material(
          elevation: 4,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: backgroundColor,
                  width: 2,
                ),
              ),
            ),
            child: ConstrainedContent(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(
                    isNormal ? Icons.check_circle : Icons.warning,
                    color: iconColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          const TextSpan(text: 'Sundby Bad '),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {
                                // Open the Sundby Bad website
                                final uri = Uri.parse(
                                    'https://svoemkbh.kk.dk/svoemmeanlaeg/svoemmehaller/sundby-bad');
                                launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              },
                              child: Text(
                                'Status',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(text: ': $status'),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: iconColor,
                      size: 20,
                    ),
                    onPressed: provider.isLoading
                        ? null
                        : () {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            final rateLimitService = RateLimitService.instance;
                            if (!rateLimitService.isActionAllowed(
                                user.uid, RateLimitAction.poolRefresh)) {
                              return;
                            }

                            rateLimitService.recordAction(
                                user.uid, RateLimitAction.poolRefresh);
                            provider.forceRefresh(user.uid);
                          },
                    tooltip: 'Refresh status',
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
        );
      },
    );
  }
}
