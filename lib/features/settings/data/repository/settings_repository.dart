import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // debugPrint için
import '../models/legal_settings_model.dart';

class SettingsRepository {
  final Dio _dio;
  SettingsRepository(this._dio);

// lib/features/settings/data/repository/settings_repository.dart

  Future<LegalSettingsModel> getLegalSettings() async {
    debugPrint("📡 [SettingsRepo] Doğru adrese istek atılıyor: /settings");

    try {
      // 🔥 /settings/general olan yeri /settings olarak değiştirdik
      final response = await _dio.get('/settings');

      debugPrint("📥 [SettingsRepo] Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (response.data['success'] == true) {
          return LegalSettingsModel.fromJson(response.data);
        } else {
          throw Exception(response.data['message'] ?? 'Yasal bilgiler alınamadı');
        }
      } else {
        throw Exception('Sunucu hatası: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint("🚨 [SettingsRepo] DIO HATASI! URL: ${e.requestOptions.uri}");
      rethrow;
    }
  }
}