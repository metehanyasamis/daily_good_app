import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;
  NotificationRepository(this._dio);

  // 1) Bildirimleri Listele (GET /customer/notifications)
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    String status = 'sent',
    bool? read,
  }) async {
    try {
      debugPrint("📡 [REPO-NOTIF] getNotifications page=$page status=$status read=$read");

      final res = await _dio.get(
        '/customer/notifications',
        queryParameters: {
          'page': page,
          'per_page': 15,
          'status': status,
          if (read != null) 'read': read,
        },
      );

      final code = res.statusCode ?? 0;
      if (code < 200 || code >= 300) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          type: DioExceptionType.badResponse,
        );
      }

      final List data = (res.data['data'] as List?) ?? [];
      debugPrint("📥 [REPO-NOTIF] notifications count=${data.length}");

      return data.map((j) => NotificationModel.fromJson(j)).toList();
    } on DioException catch (e) {
      debugPrint("❌ [REPO-NOTIF] getNotifications failed: ${e.response?.statusCode} ${e.response?.data}");
      rethrow;
    }
  }

  // 2) FCM Token Kaydet/Güncelle (POST /customer/notifications/token)
  Future<void> saveDeviceToken({
    required String deviceType,
    required String fcmToken,
    required String deviceId,
    required String deviceName,
    required String appVersion,
  }) async {
    final payload = {
      "device_type": deviceType,
      "fcm_token": fcmToken,
      "device_id": deviceId,
      "device_name": deviceName,
      "app_version": appVersion,
    };

    try {
      debugPrint("📡 [REPO-NOTIF] saveDeviceToken -> /customer/notifications/token");

      final res = await _dio.post('/customer/notifications/token', data: payload);
      final code = res.statusCode ?? 0;

      if (code == 200 || code == 201) {
        debugPrint("✅ [REPO-NOTIF] saveDeviceToken OK (status=$code)");
        return;
      }

      debugPrint("❌ [REPO-NOTIF] saveDeviceToken unexpected status=$code data=${res.data}");
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      debugPrint("❌ [REPO-NOTIF] saveDeviceToken failed: ${e.response?.statusCode} ${e.response?.data}");
      rethrow;
    }
  }

  // 3) FCM Token Sil (DELETE /customer/notifications/token)
  Future<void> deleteDeviceToken({required String fcmToken}) async {
    try {
      debugPrint("📡 [REPO-NOTIF] deleteDeviceToken -> /customer/notifications/token");

      final res = await _dio.delete(
        '/customer/notifications/token',
        data: {"fcm_token": fcmToken},
      );

      final code = res.statusCode ?? 0;
      if (code == 200) {
        debugPrint("✅ [REPO-NOTIF] deleteDeviceToken OK");
        return;
      }

      debugPrint("❌ [REPO-NOTIF] deleteDeviceToken unexpected status=$code data=${res.data}");
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        type: DioExceptionType.badResponse,
      );
    } on DioException catch (e) {
      debugPrint("❌ [REPO-NOTIF] deleteDeviceToken failed: ${e.response?.statusCode} ${e.response?.data}");
      rethrow;
    }
  }

  // 4) Okunmamış Bildirim Sayısı (GET /api/v1/customer/notifications/unread-count)
  Future<int> getUnreadCount() async {
    try {
      final res = await _dio.get('/customer/notifications/unread-count');
      return res.data['data']?['unread_count'] ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // 5) Okundu İşaretle
  Future<void> markAsRead(String id) async {
    try {
      await _dio.post('/customer/notifications/$id/read');
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] markAsRead failed: $e");
    }
  }

  // 6) Tümünü Okundu İşaretle
  Future<void> markAllAsRead() async {
    try {
      await _dio.post('/customer/notifications/mark-all-read');
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] markAllAsRead failed: $e");
    }
  }

  // 7) Bildirim Sil
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('/customer/notifications/$id');
    } catch (e) {
      debugPrint("❌ [REPO-NOTIF] deleteNotification failed: $e");
      rethrow;
    }
  }
}
