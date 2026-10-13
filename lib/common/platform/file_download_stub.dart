import 'package:url_launcher/url_launcher.dart';

Future<void> downloadImage(String imageUrl, String fileName) async {
  final uri = Uri.parse(imageUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}