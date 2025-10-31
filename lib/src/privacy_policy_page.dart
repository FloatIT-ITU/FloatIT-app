import 'package:flutter/material.dart';
import 'layout_widgets.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:floatit/src/widgets/banners.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String? _markdown;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadMarkdown();
  }

  Future<void> _loadMarkdown() async {
    final text = await rootBundle.loadString('assets/privacy_policy.md');
    setState(() {
      _markdown = text;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const StandardPageBanner(
              title: 'Privacy Policy', showBackArrow: true),
          Expanded(
            child: ConstrainedContent(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Markdown(
                        data: _markdown ?? '',
                        onTapLink: (text, href, title) async {
                          if (href == null) return;
                          final uri = Uri.tryParse(href);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
