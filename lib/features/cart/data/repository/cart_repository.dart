// lib/features/cart/data/repository/cart_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // debugPrint için
import '../../domain/models/cart_item.dart';
import '../../domain/models/cart_response_model.dart';

class CartRepository {
  final Dio _dio;

  CartRepository(this._dio);

  /// 🛒 GET /customer/cart - Sepeti listeleme
  Future<List<CartItem>> getCartItems() async {
    debugPrint('🛒 Sepet listeleme isteği gönderiliyor: GET /customer/cart');
    try {
      final response = await _dio.get('/customer/cart');
      debugPrint('✅ Sepet listeleme yanıtı alındı (Status: ${response.statusCode})');

      final List data = response.data['data'] as List;
      debugPrint('➡️ ${data.length} adet sepet öğesi modele dönüştürülüyor.');

      return data.map((json) => CartResponseModel.fromJson(json).toDomain()).toList();

    } on DioException catch (e) {
      debugPrint('❌ Sepet listeleme HATA: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 404 || e.response?.statusCode == 401) { // 401/404 durumunda boş dön.
        if (e.response?.statusCode == 401) {
          debugPrint('⚠️ Token geçersiz, kullanıcı login ekranına yönlendirilmeli (401)'); // 401 yönetimi
        }
        return [];
      }
      rethrow;
    }
  }

  /// ➕ POST /customer/cart/add - Sepete ürün ekleme veya miktar güncelleme
  Future<bool> addItemToCart({
    required String productId,
    required int quantity,
    String? notes,
  }) async {
    final payload = {
      'product_id': productId,
      'quantity': quantity,
      'notes': notes,
    };
    debugPrint('📦 Sepete ürün ekleme/güncelleme isteği gönderiliyor: POST /customer/cart/add. Payload: $payload');

    try {
      final response = await _dio.post(
        '/customer/cart/add',
        data: payload,
      );

      debugPrint('✅ Sepet güncelleme başarılı. (Status: ${response.statusCode})');
      return response.data['success'] == true;

    } on DioException catch (e) {
      debugPrint('❌ Sepet güncelleme HATA: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 400) { // Bad Request: Genellikle stok, format hatası vb.
        debugPrint('❗ Backend yanıtı: ${e.response?.data['message']}');
      }
      rethrow;
    }
  }

}