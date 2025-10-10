import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:provider/provider.dart';
import 'package:floatit/src/user_profile_provider.dart';
import 'package:floatit/src/occupation_selection_page.dart';
import 'package:floatit/src/widgets/banners.dart';
import 'package:floatit/src/theme_colors.dart';
import 'widgets/swimmer_icon_picker.dart';
import 'utils/validation_utils.dart';

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profile, _) {
        if (profile.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const StandardPageBanner(title: 'Your profile', showBackArrow: true),
              Expanded(
                child: ConstrainedContent(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Material(
                            color: AppThemeColors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () async {
                                final selectedColor = await showDialog<Color>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Choose your icon color'),
                                    content: SwimmerIconPicker(
                                      selectedColor: profile.iconColor ??
                                          Theme.of(context).colorScheme.primary,
                                      onColorSelected: (color) =>
                                          Navigator.of(context).pop(color),
                                    ),
                                  ),
                                );
                                if (selectedColor != null &&
                                    selectedColor != profile.iconColor) {
                                  if (context.mounted) {
                                    try {
                                      await Provider.of<UserProfileProvider>(context,
                                              listen: false)
                                          .updateIconColor(selectedColor);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to update icon color: ${e.toString()}')),
                                        );
                                      }
                                    }
                                  }
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SwimmerIconPicker.buildIcon(
                                      profile.iconColor ??
                                          Theme.of(context)
                                              .colorScheme
                                              .primary,
                                      radius: 36),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        shape: BoxShape.circle,
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppThemeColors.shadow,
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(Icons.edit_note,
                                          size: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            (profile.displayName != null &&
                                    profile.displayName!.trim().isNotEmpty)
                                ? profile.displayName!
                                : 'not set',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Text('Edit profile',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        if ((profile.displayName == null ||
                                profile.displayName!.trim().length < 2) ||
                            (profile.occupation == null ||
                                profile.occupation!.trim().isEmpty))
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppThemeColors.primaryOverlayLow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Please fill in your name and occupation before you can continue.',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Card(
                            elevation: 1,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.person_2),
                                  title: const Text('Name'),
                                  subtitle: Text(
                                      (profile.displayName != null &&
                                              profile.displayName!
                                                  .trim()
                                                  .isNotEmpty)
                                          ? profile.displayName!
                                          : 'not set'),
                                  trailing: const Icon(Icons.edit_note),
                                  onTap: () => _editDisplayName(context, profile),
                                ),
                                const Divider(height: 1),
                                ListTile(
                                  leading: const Icon(Icons.business_center),
                                  title: const Text('Occupation'),
                                  subtitle: Text(
                                      (profile.occupation != null &&
                                              profile.occupation!
                                                  .trim()
                                                  .isNotEmpty)
                                          ? profile.occupation!
                                          : 'not set'),
                                  trailing: const Icon(Icons.edit_note),
                                  onTap: () => _editOccupation(context, profile),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editDisplayName(
      BuildContext context, UserProfileProvider profile) async {
    final controller = TextEditingController(text: profile.displayName ?? '');
    String? error;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  errorText: error,
                ),
                autofocus: true,
                textInputAction: TextInputAction.done,
                maxLength: 30,
                validator: (value) {
                  return ValidationUtils.validateDisplayName(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            StatefulBuilder(
              builder: (context, setState) => TextButton(
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) {
                    setState(() => error = 'Name cannot be empty');
                    return;
                  }
                  if (newName.length < 2) {
                    setState(() => error = 'Name too short');
                    return;
                  }
                  if (newName.length > 30) {
                    setState(() => error = 'Name too long');
                    return;
                  }
                  if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(newName)) {
                    setState(() =>
                        error = 'Only letters, numbers, and spaces allowed');
                    return;
                  }
                  try {
                    await profile.updateDisplayName(newName);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Display name updated')));
                    }
                  } catch (e) {
                    setState(() => error = 'Failed to update name');
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editOccupation(
      BuildContext context, UserProfileProvider profile) async {
    final occupations = [
      'SWU',
      'GBI',
      'BDDIT',
      'BDS',
      'MDDIT',
      'DIM',
      'E-BUSS',
      'GAMES/DT',
      'GAMES/Tech',
      'CS',
      'SD',
      'MDS',
      'MIT',
      'Employee',
      'PhD',
      'Other',
    ];
    String? selected = profile.occupation;
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => OccupationSelectionPage(
          occupations: occupations,
          selected: selected,
        ),
      ),
    );
    if (result != null) {
      // Validate occupation (must be in allowed list)
      if (!occupations.contains(result)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid occupation')));
        return;
      }
      try {
        await profile.updateOccupation(result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Occupation updated')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update occupation: ${e.toString()}')),
          );
        }
      }
    }
  }
}
