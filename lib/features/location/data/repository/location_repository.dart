// lib/features/location/data/repository/location_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LocationRepository {
  final Dio _dio;

  LocationRepository(this._dio);

  /// 🌍 PUT /customer/location/update - Müşteri konumunu API'ye kaydeder.
  Future<bool> updateCustomerLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    debugPrint('🔄 Konum güncelleme isteği: PUT /customer/location/update');
    try {
      final response = await _dio.put(
        '/customer/location/update',
        data: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'address': address,
        },
      );

      // Başarılı yanıt geldiğinde true döner (200 OK)
      return response.data['success'] == true;
    } on DioException catch (e) {
      debugPrint('❌ Konum Güncelleme HATA: ${e.response?.statusCode} - ${e.message}');
      // DioException'ı tekrar fırlatırız ki, Provider katmanı hatayı yakalasın.
      rethrow;
    }
  }
}