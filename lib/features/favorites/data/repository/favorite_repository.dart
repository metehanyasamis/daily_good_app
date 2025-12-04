// lib/features/favorites/data/repository/favorite_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../businessShop/data/model/businessShop_model.dart';
import '../../../product/data/models/product_model.dart';
import '../model/favorite_product_response_model.dart';
import '../model/favorite_shop_response_model.dart';

class FavoriteRepository {
  final Dio _dio;

  FavoriteRepository(this._dio);

  // ----------------------------------------------------
  // 🌟 İŞLETME METOTLARI (Daha önce yazılmıştı)
  // ----------------------------------------------------

  /// 🌟 GET /customer/favorites - Favori işletmeleri listeleme
  Future<List<BusinessModel>> getFavoriteShops() async {
    debugPrint('🌟 Favori İşletme listeleme isteği gönderiliyor: GET /customer/favorites');
    try {
      final response = await _dio.get('/customer/favorites');
      final List data = response.data['data'] as List;
      return data.map((json) => FavoriteShopResponseModel.fromJson(json).toDomain()).toList();
    } on DioException catch (e) {
      debugPrint('❌ Favori İşletme listeleme HATA: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  /// ➕ POST /customer/favorites/add/{storeId} - Favori işletme ekleme
  Future<bool> addFavoriteShop(String storeId) async {
    debugPrint('➕ Favori İşletme Ekleme isteği: POST /customer/favorites/add/$storeId');
    try {
      final response = await _dio.post('/customer/favorites/add/$storeId');
      return response.data['success'] == true;
    } on DioException catch (e) {
      debugPrint('❌ Favori İşletme ekleme HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }

  /// ➖ DELETE /customer/favorites/remove/{storeId} - Favori işletme kaldırma
  Future<bool> removeFavoriteShop(String storeId) async {
    debugPrint('➖ Favori İşletme Kaldırma isteği: DELETE /customer/favorites/remove/$storeId');
    try {
      final response = await _dio.delete('/customer/favorites/remove/$storeId');
      return response.data['success'] == true;
    } on DioException catch (e) {
      debugPrint('❌ Favori İşletme kaldırma HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }

  // ----------------------------------------------------
  // 💚 ÜRÜN METOTLARI (Yeni Eklendi)
  // ----------------------------------------------------

  /// 🌟 GET /customer/favorites/products - Favori ürünleri listeleme
  Future<List<ProductModel>> getFavoriteProducts() async {
    debugPrint('🌟 Favori Ürün listeleme isteği gönderiliyor: GET /customer/favorites/products');
    try {
      final response = await _dio.get('/customer/favorites/products');
      debugPrint('✅ Favori ürün listeleme yanıtı alındı (Status: ${response.statusCode})');

      final List data = response.data['data'] as List;
      debugPrint('➡️ ${data.length} adet favori ürün modele dönüştürülüyor.');

      return data.map((json) => FavoriteProductResponseModel.fromJson(json).toDomain()).toList();

    } on DioException catch (e) {
      debugPrint('❌ Favori Ürün listeleme HATA: ${e.response?.statusCode} - ${e.message}');
      if (e.response?.statusCode == 404) return [];
      rethrow;
    }
  }

  /// ➕ POST /customer/favorites/products/add/{productId} - Favori ürün ekleme
  Future<bool> addFavoriteProduct(String productId) async {
    debugPrint('➕ Favori Ürün Ekleme isteği: POST /customer/favorites/products/add/$productId');
    try {
      final response = await _dio.post('/customer/favorites/products/add/$productId');
      debugPrint('✅ Favori ürün ekleme başarılı.');
      return response.data['success'] == true;
    } on DioException catch (e) {
      debugPrint('❌ Favori Ürün ekleme HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }

  /// ➖ DELETE /customer/favorites/products/remove/{productId} - Favori ürün kaldırma
  Future<bool> removeFavoriteProduct(String productId) async {
    debugPrint('➖ Favori Ürün Kaldırma isteği: DELETE /customer/favorites/products/remove/$productId');
    try {
      final response = await _dio.delete('/customer/favorites/products/remove/$productId');
      debugPrint('✅ Favori ürün kaldırma başarılı.');
      return response.data['success'] == true;
    } on DioException catch (e) {
      debugPrint('❌ Favori Ürün kaldırma HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }
}