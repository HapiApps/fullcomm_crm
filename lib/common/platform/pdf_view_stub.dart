import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showPdfDialogImpl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}