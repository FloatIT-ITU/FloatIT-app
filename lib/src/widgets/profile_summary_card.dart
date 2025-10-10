import 'package:flutter/material.dart';
import 'package:floatit/src/styles.dart';
import 'package:floatit/src/widgets/swimmer_icon_picker.dart';
import 'package:floatit/src/user_profile_provider.dart';
import 'package:floatit/src/profile_details_page.dart';
import 'package:provider/provider.dart';
import 'package:floatit/src/utils/navigation_utils.dart';

/// A reusable profile summary card for settings and other pages.
class ProfileSummaryCard extends StatelessWidget {
  final VoidCallback? onTap;
  const ProfileSummaryCard({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfileProvider>(context);
    String name =
        (profile.displayName != null && profile.displayName!.trim().isNotEmpty)
            ? profile.displayName!
            : 'Name not set';
    return Card(
      elevation: 2,
      child: ListTile(
        leading: SwimmerIconPicker.buildIcon(
            profile.iconColor ?? Theme.of(context).colorScheme.primary,
            radius: 24),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: AppTextStyles.subheading(),
            ),
            if (profile.isAdmin)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(Icons.star,
                    size: 18, color: Theme.of(context).colorScheme.secondary),
              ),
          ],
        ),
        subtitle: Text(
          (profile.occupation != null && profile.occupation!.trim().isNotEmpty)
              ? profile.occupation!
              : 'Occupation not set',
        ),
        trailing: const Icon(Icons.edit),
        onTap: onTap ??
            () {
              NavigationUtils.pushWithoutAnimation(
                context,
                const ProfileDetailsPage(),
              );
            },
      ),
    );
  }
}
