import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  // 1. Bildirimleri Listele (GET /customer/notifications)
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    try {
      final response = await _dio.get(
        '/customer/notifications',
        queryParameters: {'page': page, 'per_page': 15},
      );

      final List data = response.data['data'];
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // 2. FCM Token Kaydet (POST /customer/notifications/token)
  Future<void> saveDeviceToken({
    required String fcmToken,
    required String deviceId,
    required String deviceName,
    required String deviceType,
    required String appVersion,
  }) async {
    try {
      await _dio.post(
        '/customer/notifications/token',
        data: {
          "device_type": deviceType,
          "fcm_token": fcmToken,
          "device_id": deviceId,
          "device_name": deviceName,
          "app_version": appVersion,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // 3. Okundu İşaretle (POST /customer/notifications/{id}/read)
  Future<void> markAsRead(String id) async {
    await _dio.post('/customer/notifications/$id/read');
  }

  // 4. Tümünü Okundu İşaretle (POST /customer/notifications/mark-all-read)
  Future<void> markAllAsRead() async {
    await _dio.post('/customer/notifications/mark-all-read');
  }

  // 5. Bildirim Sil (DELETE /customer/notifications/{id})
  Future<void> deleteNotification(String id) async {
    await _dio.delete('/customer/notifications/$id');
  }
}