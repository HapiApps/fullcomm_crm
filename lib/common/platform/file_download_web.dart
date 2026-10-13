import 'package:web/web.dart' as web;

Future<void> downloadImage(String imageUrl, String fileName) async {
  final anchor = web.HTMLAnchorElement()
    ..href = imageUrl
    ..download = fileName
    ..target = '_blank';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}