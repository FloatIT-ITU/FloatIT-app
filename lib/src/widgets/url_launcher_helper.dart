import 'package:url_launcher/url_launcher.dart' as url_launcher;

Future<bool> canLaunchUrl(Uri url) async {
  return await url_launcher.canLaunchUrl(url);
}

Future<void> launchUrl(Uri url,
    {url_launcher.LaunchMode mode =
        url_launcher.LaunchMode.platformDefault}) async {
  await url_launcher.launchUrl(url, mode: mode);
}
