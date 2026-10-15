import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../api_services.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();
  static bool _inited = false;

  static Future<void> _init() async {
    if (_inited) return;
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
    _inited = true;
  }

  static Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: true, sound: true) ?? false;
    }
    return true;
  }

  static void show(
      String title,
      String body, {
        String? tag,
        bool sticky = false,
        void Function()? onClick,
      }) async {
    await _init();
    final id = (tag ?? title).hashCode & 0x7fffffff;

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'crm_channel',
          'CRM Notifications',
          importance: Importance.high,
          priority: Priority.high,
          ongoing: sticky,
          autoCancel: !sticky,
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
  static Future<String?> getFcmToken() async {
    try {
      final granted = await requestPermission();
      if (!granted) return null;

      final messaging = FirebaseMessaging.instance;

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apns = await messaging.getAPNSToken();
        int retry = 0;
        while (apns == null && retry < 5) {
          await Future.delayed(const Duration(seconds: 1));
          apns = await messaging.getAPNSToken();
          retry++;
        }
      }

      final token = await messaging.getToken();
      print('FCM Mobile Token App: $token');
      return token;
    } catch (e) {
      print('FCM token error: $e');
      return null;
    }
  }

  static void listenForeground() {
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