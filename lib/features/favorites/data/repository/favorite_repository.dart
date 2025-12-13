import 'dart:convert';
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
    final res = await api.get('/customer/favorites/products');
    final body = jsonDecode(res.body);
    return (body['data'] as List)
        .map((e) => FavoriteProductResponseModel.fromJson(e))
        .toList();
  }

  Future<void> addFavoriteProduct(String id) =>
      api.post('/customer/favorites/products/add/$id');

  Future<void> removeFavoriteProduct(String id) =>
      api.delete('/customer/favorites/products/remove/$id');

  // ---------------- STORES ----------------
  Future<List<FavoriteStoreResponseModel>> fetchFavoriteStores() async {
    final res = await api.get('/customer/favorites');
    final body = jsonDecode(res.body);
    return (body['data'] as List)
        .map((e) => FavoriteStoreResponseModel.fromJson(e))
        .toList();
  }

  Future<void> addFavoriteStore(String id) =>
      api.post('/customer/favorites/add/$id');

  Future<void> removeFavoriteStore(String id) =>
      api.delete('/customer/favorites/remove/$id');
}
