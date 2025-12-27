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
      debugPrint("📡 [REPO_FAV_STORES] İstek atılıyor: /customer/favorites");
      final res = await api.get('/customer/favorites');

      // 1. Ham Body'i gör (Backend tam olarak ne gönderiyor?)
      debugPrint("📦 [REPO_FAV_STORES] Ham Yanıt: ${res.body}");

      final body = json.decode(res.body);

      if (body['success'] == true) {
        final List data = body['data'] ?? [];
        debugPrint("📊 [REPO_FAV_STORES] Liste Uzunluğu: ${data.length}");

        // 2. Her bir elemanı map ederken detayları bas
        return data.map((e) {
          debugPrint("🏢 [REPO_FAV_STORES] Map edilen eleman: $e");
          try {
            return FavoriteStoreResponseModel.fromJson(e);
          } catch (mapError) {
            debugPrint("❌ [REPO_FAV_STORES] Model Dönüştürme Hatası: $mapError");
            rethrow;
          }
        }).toList();
      } else {
        debugPrint("⚠️ [REPO_FAV_STORES] API Success False döndü: ${body['message']}");
        return [];
      }
    } catch (e, stack) {
      debugPrint("🚨 [REPO_FAV_STORES_CRITICAL] Hata: $e");
      debugPrint("🚨 StackTrace: $stack");
      return [];
    }
  }

  Future<bool> addFavoriteStore(String id) async {
    final res = await api.post('/customer/favorites/add/$id');
    debugPrint("🚩 [STORE_ADD_RES]: ${res.body}");
    return _isSuccess(res); // 🎯 DÜZELTME: Burası _isSuccess olmalı
  }

  Future<bool> removeFavoriteStore(String id) async {
    final res = await api.delete('/customer/favorites/remove/$id');
    debugPrint("🚩 [STORE_REMOVE_RES]: ${res.body}");
    return _isSuccess(res); // 🎯 DÜZELTME: Burası _isSuccess olmalı
  }

  // Helper: İsteğin başarılı olup olmadığını kontrol eder
  bool _isSuccess(dynamic res) {
    try {
      // 1. Önce HTTP koduna bak (200 veya 201 her zaman başarıdır)
      if (res.statusCode == 200 || res.statusCode == 201) {
        final body = json.decode(res.body);
        // Eğer 200 dönüp içinde success: false diyorsa bile "zaten" varsa true dön
        if (body['success'] == false && body['message'].toString().contains('zaten')) {
          return true;
        }
        return body['success'] == true;
      }

      // 2. Eğer 400 veya başka hata kodu geldiyse mesajı kontrol et
      final body = json.decode(res.body);
      final message = body['message'].toString().toLowerCase();

      if (message.contains('zaten') || message.contains('already')) {
        debugPrint("ℹ️ [REPO] Zaten favori uyarısı alındı, başarı kabul ediliyor.");
        return true;
      }

      return body['success'] == true;
    } catch (e) {
      // JSON parse edilemezse sadece HTTP koduna güven
      return res.statusCode >= 200 && res.statusCode < 300;
    }
  }
}
