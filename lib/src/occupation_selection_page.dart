import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:floatit/src/widgets/banners.dart';

class OccupationSelectionPage extends StatefulWidget {
  final List<String> occupations;
  final String? selected;
  const OccupationSelectionPage(
      {super.key, required this.occupations, this.selected});

  @override
  State<OccupationSelectionPage> createState() =>
      OccupationSelectionPageState();
}

class OccupationSelectionPageState extends State<OccupationSelectionPage> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner with back arrow (use SubpageBanner which applies theming)
          const StandardPageBanner(title: 'Change occupation', showBackArrow: true),
          Expanded(
            child: ConstrainedContent(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Subtitle
                  const Text(
                    "What's your occupation?",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Occupation list styled like Settings page
                  Expanded(
                    child: Card(
                      elevation: 1,
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: widget.occupations.length,
                        separatorBuilder: (context, i) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final occ = widget.occupations[i];
                          return ListTile(
                            leading: Icon(
                              _selected == occ
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(occ),
                            onTap: () {
                              setState(() => _selected = occ);
                              Navigator.of(context).pop(occ);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
