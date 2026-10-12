import 'dart:js_interop';
import 'package:web/web.dart' as web;

class NotificationService {
  static Future<bool> requestPermission() async {
    final result = await web.Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  static void show(
      String title,
      String body, {
        String? tag,
        bool sticky = false,
        void Function()? onClick,
      }) {
    if (web.Notification.permission != 'granted') return;

    final n = web.Notification(
      title,
      web.NotificationOptions(
        body: body,
        icon: 'icons/Icon-192.png',
        tag: tag ?? '',
        requireInteraction: sticky,
      ),
    );

    n.onclick = ((web.Event e) {
      web.window.focus();
      n.close();
      if (onClick != null) onClick();
    }).toJS;
  }
}