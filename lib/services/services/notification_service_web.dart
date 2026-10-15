import 'dart:js_interop';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import '../api_services.dart';

class NotificationService {
  static const String _vapidKey =
      'BGd15ox4c1DIBOc8gXDC6LvP_oOd-LwP7UZW9jUqtwN6TNdByH6iJ6NdqO9wQNPEOSEr5jBr2hE9XmffdVlDTO4';

  static bool _listening = false;

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

  static Future<String?> getFcmToken() async {
    try {
      final granted = await requestPermission();
      if (!granted) return null;

      final token =
      await FirebaseMessaging.instance.getToken(vapidKey: _vapidKey);
      debugPrint('FCM Web Token WEB: $token');
      return token;
    } catch (e) {
      debugPrint('FCM token error: $e');
      return null;
    }
  }

  static void listenForeground() {
    if (_listening) return;
    _listening = true;

    FirebaseMessaging.onMessage.listen((RemoteMessage m) {
      print("Received foreground message: ${m.messageId}");
      apiService.getCustomLeads();
      show(
        m.notification?.title ?? m.data['title'] ?? 'Notification',
        m.notification?.body ?? m.data['body'] ?? '',
        tag: m.messageId,
      );
    });
  }

  static void listenTokenRefresh(void Function(String token) onRefresh) {
    FirebaseMessaging.instance.onTokenRefresh.listen(onRefresh);
  }
}