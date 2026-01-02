import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  // 1. Bildirimleri Listele (GET /customer/notifications)
  // NOT: Dökümanda bu endpoint başında /api/v1 yok, direkt /customer ile başlıyor.
  Future<List<NotificationModel>> getNotifications({int page = 1, String status = 'sent'}) async {
    try {
      debugPrint("📡 [REPO-NOTIF] Bildirimler çekiliyor... Sayfa: $page");
      final response = await _dio.get(
        '/customer/notifications',
        queryParameters: {
          'page': page,
          'per_page': 15,
          'status': status, // pending, sent, failed
        },
      );

      final List data = response.data['data'] ?? [];
      debugPrint("📥 [REPO-NOTIF] Gelen bildirim sayısı: ${data.length}");

      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] Liste çekme hatası: $e");
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
      debugPrint("📡 [REPO-NOTIF] FCM Token kaydediliyor...");
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
      debugPrint("✅ [REPO-NOTIF] Token başarıyla backend'e iletildi.");
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] Token kaydetme hatası: $e");
      rethrow;
    }
  }

  // 3. Okundu İşaretle (POST /api/v1/customer/notifications/{id}/read)
  // DİKKAT: Dökümanda bu endpoint /api/v1/ ile başlıyor.
  Future<void> markAsRead(String id) async {
    try {
      debugPrint("📡 [REPO-NOTIF] Bildirim okundu işaretleniyor: $id");
      await _dio.post('/api/v1/customer/notifications/$id/read');
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] Okundu işaretleme hatası: $e");
    }
  }

  // 4. Tümünü Okundu İşaretle (POST /api/v1/customer/notifications/mark-all-read)
  Future<void> markAllAsRead() async {
    try {
      debugPrint("📡 [REPO-NOTIF] Tüm bildirimler okundu işaretleniyor...");
      await _dio.post('/api/v1/customer/notifications/mark-all-read');
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] Tümünü okundu işaretleme hatası: $e");
    }
  }

  // 5. Bildirim Sil (DELETE /api/v1/customer/notifications/{id})
  Future<void> deleteNotification(String id) async {
    try {
      debugPrint("📡 [REPO-NOTIF] Bildirim siliniyor: $id");
      await _dio.delete('/api/v1/customer/notifications/$id');
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] Bildirim silme hatası: $e");
      rethrow;
    }
  }

  // 6. Okunmamış Bildirim Sayısı (GET /api/v1/customer/notifications/unread-count)
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/v1/customer/notifications/unread-count');
      return response.data['data']?['unread_count'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}