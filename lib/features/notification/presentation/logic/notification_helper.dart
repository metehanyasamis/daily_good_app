import 'notification_service.dart';

/// Basit notification wrapper.
/// Uygulama içinde çağrılacak kolay metodlar.
class NotificationHelper {
  /// 🟢 Uygulama açıldığında hoş geldin bildirimi
  static Future<void> sendWelcomeNotification() async {
    await NotificationService.show(
      id: 1,
      title: 'Daily Good’e Hoş Geldin 🌱',
      body: 'Bugün gıdanı koruyarak harika bir adım attın!',
    );
  }

  /// 🕓 5 saniye sonra test bildirimi
  static Future<void> sendTestNotificationAfterDelay() async {
    await NotificationService.schedule(
      id: 2,
      title: 'Zamanlanmış Bildirim',
      body: 'Bu bildirim 5 saniye sonra gösterildi!',
      after: const Duration(seconds: 5),
    );
  }

  /// 🧹 Tüm bildirimleri temizle
  static Future<void> clearAllNotifications() async {
    await NotificationService.cancelAll();
  }
}
