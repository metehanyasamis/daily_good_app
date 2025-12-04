import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/favorite_product_response_model.dart';
import '../model/favorite_shop_response_model.dart';

final favoriteRepositoryProvider = Provider((ref) => FavoriteRepository());

class FavoriteRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "https://dailygood.dijicrea.net/api/v1",
    headers: {"Accept": "application/json"},
  ));

  // -------------------------------
  // PRODUCTS
  // -------------------------------
  Future<List<FavoriteProductResponseModel>> getFavoriteProducts() async {
    final res = await _dio.get("/customer/favorites/products");
    final list = res.data["data"] as List;
    return list
        .map((e) => FavoriteProductResponseModel.fromJson(e))
        .toList();
  }

  Future<void> addFavoriteProduct(String id) async {
    await _dio.post("/customer/favorites/products/add/$id");
  }

  Future<void> removeFavoriteProduct(String id) async {
    await _dio.delete("/customer/favorites/products/remove/$id");
  }

  // -------------------------------
  // STORES
  // -------------------------------
  Future<List<FavoriteShopResponseModel>> getFavoriteStores() async {
    final res = await _dio.get("/customer/favorites");
    final list = res.data["data"] as List;
    return list
        .map((e) => FavoriteShopResponseModel.fromJson(e))
        .toList();
  }

  Future<void> addFavoriteStore(String id) async {
    await _dio.post("/customer/favorites/add/$id");
  }

  Future<void> removeFavoriteStore(String id) async {
    await _dio.delete("/customer/favorites/remove/$id");
  }
}
