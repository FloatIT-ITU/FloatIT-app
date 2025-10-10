import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';
import 'package:floatit/src/styles.dart';

class SimpleMarkdown extends StatelessWidget {
  final String data;
  const SimpleMarkdown({super.key, required this.data});

  TextStyle _headingStyle(BuildContext context, int level) {
    final base = Theme.of(context).textTheme.bodyLarge ?? AppTextStyles.body();
    switch (level) {
      case 1:
        return base.copyWith(
            fontSize: AppFontSizes.heading, fontWeight: AppFontWeights.bold);
      case 2:
        return base.copyWith(
            fontSize: AppFontSizes.subheading, fontWeight: AppFontWeights.bold);
      case 3:
        return base.copyWith(
            fontSize: AppFontSizes.body, fontWeight: AppFontWeights.bold);
      default:
        return base.copyWith(fontWeight: AppFontWeights.bold);
    }
  }

  InlineSpan _inlineSpan(md.Node node, BuildContext context) {
    final baseStyle = DefaultTextStyle.of(context).style;
    if (node is md.Text) return TextSpan(text: node.text, style: baseStyle);
    if (node is md.Element) {
      final children =
          node.children?.map((c) => _inlineSpan(c, context)).toList() ??
              <InlineSpan>[];
      switch (node.tag) {
        case 'strong':
          return TextSpan(
              children: children,
              style: baseStyle.merge(AppTextStyles.body()
                  .copyWith(fontWeight: AppFontWeights.bold)));
        case 'em':
          return TextSpan(
              children: children,
              style: baseStyle.merge(
                  AppTextStyles.body().copyWith(fontStyle: FontStyle.italic)));
        case 'code':
          return TextSpan(
              children: children,
              style: baseStyle.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest));
        case 'a':
          final href = node.attributes['href'];
          return TextSpan(
            children: children,
            style: baseStyle.copyWith(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline),
            recognizer: (TapGestureRecognizer()
              ..onTap = () async {
                if (href != null) {
                  final uri = Uri.tryParse(href);
                  if (uri != null && await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              }),
          );
        default:
          return TextSpan(children: children);
      }
    }
    return const TextSpan(text: '');
  }

  Widget _buildParagraph(md.Element element, BuildContext context) {
    final spans = element.children
            ?.map<InlineSpan>((c) => _inlineSpan(c, context))
            .toList(growable: false) ??
        <InlineSpan>[];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: SelectableText.rich(
          TextSpan(children: spans, style: DefaultTextStyle.of(context).style)),
    );
  }

  Widget _buildHeading(md.Element element, BuildContext context, int level) {
    final spans = element.children
            ?.map<InlineSpan>((c) => _inlineSpan(c, context))
            .toList(growable: false) ??
        <InlineSpan>[];
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
      child: SelectableText.rich(
          TextSpan(children: spans, style: _headingStyle(context, level))),
    );
  }

  Widget _buildImage(md.Element element) {
    final src = element.attributes['src'] ?? '';
    if (src.startsWith('http')) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.network(src),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.asset(src),
      );
    }
  }

  Widget _buildCodeBlock(String code, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6.0)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SelectableText(code,
                      style: AppTextStyles.body()
                          .copyWith(fontFamily: 'monospace')),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Code copied')));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(md.Element listElement, BuildContext context,
      {bool ordered = false}) {
    final items = <Widget>[];
    int index = 1;
    for (var li in listElement.children ?? []) {
      // li is usually an Element with tag 'li'
      final content = li.children ?? [];
      final spans = content
          .map<InlineSpan>((c) => _inlineSpan(c, context))
          .toList(growable: false);
      final prefix = ordered ? '${index++}. ' : '• ';
      items.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prefix),
            const SizedBox(width: 6),
            Expanded(child: SelectableText.rich(TextSpan(children: spans))),
          ],
        ),
      ));
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(children: items),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = md.Document();
    final lines = data.split(RegExp('\r?\n'));
    final nodes = doc.parseLines(lines);

    final children = <Widget>[];
    for (var n in nodes) {
      if (n is md.Text) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SelectableText(n.text),
        ));
        continue;
      }
      if (n is md.Element) {
        switch (n.tag) {
          case 'p':
            children.add(_buildParagraph(n, context));
            break;
          case 'h1':
            children.add(_buildHeading(n, context, 1));
            break;
          case 'h2':
            children.add(_buildHeading(n, context, 2));
            break;
          case 'h3':
            children.add(_buildHeading(n, context, 3));
            break;
          case 'img':
            children.add(_buildImage(n));
            break;
          case 'pre':
            // code block usually in pre > code
            md.Element? codeChild;
            if (n.children != null) {
              for (var c in n.children!) {
                if (c is md.Element && c.tag == 'code') {
                  codeChild = c;
                  break;
                }
              }
            }
            if (codeChild != null &&
                codeChild.children != null &&
                codeChild.children!.isNotEmpty) {
              final text = codeChild.children!
                  .whereType<md.Text>()
                  .map((t) => t.text)
                  .join();
              children.add(_buildCodeBlock(text, context));
            }
            break;
          case 'ul':
            children.add(_buildList(n, context, ordered: false));
            break;
          case 'ol':
            children.add(_buildList(n, context, ordered: true));
            break;
          default:
            // Fallback: render as paragraph
            children.add(_buildParagraph(n, context));
            break;
        }
      }
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}
