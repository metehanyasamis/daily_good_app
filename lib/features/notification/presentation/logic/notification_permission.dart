import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../../core/data/prefs_service.dart';

class NotificationPermission {
  static Future<void> request() async {
    // 1. Daha önce sorduk mu?
    final hasAsked = await PrefsService.getHasAskedNotification();
    if (hasAsked) return; // Zaten sorulmuşsa fonksiyondan çık.

    // 2. iOS ise Firebase üzerinden veya permission_handler üzerinden iste
    // FirebaseMessaging kullanmak iOS'ta daha sağlıklıdır:
    if (Platform.isIOS) {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Kullanıcı ister izin versin ister vermesin, "sorduk" kabul ediyoruz.
      await PrefsService.setHasAskedNotification(true);
    }
    // Android 13+ için permission_handler kullanabilirsin:
    else if (Platform.isAndroid) {
      // Android'de izin isteme logic'i buraya gelebilir
      await PrefsService.setHasAskedNotification(true);
    }
  }
}