// lib/core/notifications/notification_permission.dart
import 'package:permission_handler/permission_handler.dart';

class NotificationPermission {
  static Future<bool> request() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> isGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
}
