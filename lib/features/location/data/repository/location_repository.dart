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
    String? address,
  }) async {
    debugPrint("📍 Konum API isteği → PUT /customer/location/update");

    try {
      final Map<String, dynamic> body = {
        "latitude": latitude.toString(),     // ✅ STRING
        "longitude": longitude.toString(),   // ✅ STRING
      };

      if (address != null && address.isNotEmpty) {
        body["address"] = address;           // address zaten string → sorun yok
      }

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
      rethrow;
    }
  }
}
