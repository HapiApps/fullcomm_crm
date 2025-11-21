import 'dart:html' as html;


final NotificationUtils notificationUtils = NotificationUtils._();
class NotificationUtils {
  NotificationUtils._();

  void showBrowserNotification() {
    final permission = html.Notification.permission;
    if (permission == "granted") {
      html.Notification(
        "New Order Update!",
        body: "Your order #12345 status updated.",
        icon: "https://cdn-icons-png.flaticon.com/512/1827/1827318.png",
      );
    } else if (permission != "denied") {
      html.Notification.requestPermission().then((p) {
        if (p == "granted") {
          html.Notification(
            "New Order Update!",
            body: "Your order #12345 status updated.",
            icon: "https://cdn-icons-png.flaticon.com/512/1827/1827318.png",
          );
        } else {
          print("Permission Denied");
        }
      });
    } else {
      html.window.alert(
        "Notification blocked!\nPlease enable it in browser settings.",
      );
    }
  }
}