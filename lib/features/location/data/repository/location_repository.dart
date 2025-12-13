// lib/features/location/data/repository/location_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LocationRepository {
  final Dio _dio;

  LocationRepository(this._dio);

  /// 🌍 PUT /customer/location/update
  Future<bool> updateCustomerLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    debugPrint("📍 Konum API isteği → PUT /customer/location/update");

    try {
      final body = {
        "latitude": latitude.toString(),   // backend STRING bekliyor
        "longitude": longitude.toString(),
        "address": address,
      };

      debugPrint("📤 Gönderilen BODY: $body");

      final res = await _dio.put(
        '/customer/location/update',
        data: body,
      );

      debugPrint("📥 Response: ${res.data}");

      return res.data['success'] == true;
    } on DioException catch (e) {
      debugPrint("❌ LOCATION ERROR STATUS: ${e.response?.statusCode}");
      debugPrint("❌ LOCATION ERROR DATA: ${e.response?.data}");
      return false;
    }
  }
}
