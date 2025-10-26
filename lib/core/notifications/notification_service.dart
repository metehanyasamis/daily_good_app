import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Basit notification service – Flutter 3.24 ve
/// flutter_local_notifications ^19.5.0 sürümüne uyumlu.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  /// Başlatma
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings =
    InitializationSettings(android: androidInit, iOS: iosInit);

    await _notifications.initialize(initSettings);
  }

  /// Basit bildirim gönder
  static Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }

  /// Belirli bir süre sonra bildirim
  static Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required Duration after,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(after),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: null, // ✅ artık sadece bu yeterli
    );
  }

  /// Bildirimi iptal et
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Tüm bildirimleri iptal et
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// Ortak detaylar
  static NotificationDetails _notificationDetails() {
    const android = AndroidNotificationDetails(
      'daily_good_channel',
      'Daily Good Notifications',
      channelDescription: 'Uygulama genel bildirimleri',
      importance: Importance.max,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();

    return const NotificationDetails(android: android, iOS: ios);
  }
}
