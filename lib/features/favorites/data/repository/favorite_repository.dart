import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../model/favorite_product_response_model.dart';
import '../model/favorite_store_response_model.dart';


final favoriteRepositoryProvider = Provider(
      (ref) => FavoriteRepository(ref.read(apiClientProvider)),
);

class FavoriteRepository {
  final ApiClient api;
  FavoriteRepository(this.api);

  // ---------------- PRODUCTS ----------------
  Future<List<FavoriteProductResponseModel>> fetchFavoriteProducts() async {
    try {
      final res = await api.get('/customer/favorites/products');
      // ApiClient içinde jsonDecode zaten yapılıyorsa body['data'] olarak kullanın.
      // Eğer yapılmıyorsa:
      final body = json.decode(res.body);

      if (body['success'] == true) {
        return (body['data'] as List)
            .map((e) => FavoriteProductResponseModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Repo Error (fetchProducts): $e");
      return [];
    }
  }

  Future<bool> addFavoriteProduct(String id) async {
    debugPrint('🚀 [REPO] Product Fav Ekleme İsteği: $id');

    // 💡 ÇÖZÜM: POST isteğine boş bir body {} ekliyoruz.
    // Backend bazen "ne gönderdiğin belli değil" diyerek 400 döner.
    final res = await api.post('/customer/favorites/products/add/$id', body: {});

    final success = _isSuccess(res);
    debugPrint('✅ [REPO] Product Fav Ekleme Sonucu: $success (Kod: ${res.statusCode})');

    // Eğer hala başarısızsa backend'in ne dediğini görelim:
    if (!success) {
      debugPrint('⚠️ [REPO] Backend Hata Mesajı: ${res.body}');
    }

    return success;
  }

  Future<bool> removeFavoriteProduct(String id) async {
    debugPrint('🗑️ [REPO] Product Fav Silme İsteği: $id');
    final res = await api.delete('/customer/favorites/products/remove/$id');
    final success = _isSuccess(res);
    debugPrint('✅ [REPO] Product Fav Silme Sonucu: $success');
    return success;
  }

  // ---------------- STORES ----------------
  Future<List<FavoriteStoreResponseModel>> fetchFavoriteStores() async {
    try {
      final res = await api.get('/customer/favorites');
      final body = json.decode(res.body);

      if (body['success'] == true) {
        return (body['data'] as List)
            .map((e) => FavoriteStoreResponseModel.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Repo Error (fetchStores): $e");
      return [];
    }
  }

  Future<bool> addFavoriteStore(String id) async {
    debugPrint('🚀 [REPO] Store Fav Ekleme İsteği: $id');
    // Burada da boş body gönderiyoruz
    final res = await api.post('/customer/favorites/add/$id', body: {});
    final success = _isSuccess(res);
    debugPrint('✅ [REPO] Store Fav Sonucu: $success (Kod: ${res.statusCode})');
    return success;
  }

  Future<bool> removeFavoriteStore(String id) async {
    // 🚩 Dökümanındaki curl örneğinde DELETE '.../favorites/remove/1' kullanılmış.
    // Bu doğru, ancak dönüş kodlarını kontrol etmeliyiz.
    final res = await api.delete('/customer/favorites/remove/$id');
    return _isSuccess(res);
  }

  // Helper: İsteğin başarılı olup olmadığını kontrol eder
  bool _isSuccess(dynamic res) {
    try {
      final body = json.decode(res.body);
      // Backend "zaten var" diyorsa veya success true ise başarılı say
      if (res.statusCode == 400 && body['message'].toString().contains('zaten')) {
        return true;
      }
      return body['success'] == true;
    } catch (_) {
      return res.statusCode == 200 || res.statusCode == 201;
    }
  }
}
