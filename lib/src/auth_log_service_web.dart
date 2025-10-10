// This file is intentionally web-only and uses `dart:html`.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<String?> getUserAgent() async {
  return html.window.navigator.userAgent;
}
