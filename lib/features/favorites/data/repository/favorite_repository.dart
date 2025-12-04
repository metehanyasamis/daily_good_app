import 'package:dio/dio.dart';
import '../model/favorite_product_response_model.dart';
import '../model/favorite_shop_response_model.dart';
import '../../../product/data/models/product_model.dart';

class FavoriteRepository {
  final Dio dio;
  FavoriteRepository(this.dio);

  // STORE FAVORITES --------------------
  Future<List<StoreSummary>> getFavoriteShops() async {
    final res = await dio.get('/customer/favorites');
    final List data = res.data['data'];

    return data
        .map((j) => FavoriteShopResponseModel.fromJson(j).toDomain())
        .toList();
  }

  Future<bool> addFavoriteShop(String id) async {
    final res = await dio.post('/customer/favorites/add/$id');
    return res.data['success'] == true;
  }

  Future<bool> removeFavoriteShop(String id) async {
    final res = await dio.delete('/customer/favorites/remove/$id');
    return res.data['success'] == true;
  }

  // PRODUCT FAVORITES --------------------
  Future<List<ProductModel>> getFavoriteProducts() async {
    final res = await dio.get('/customer/favorites/products');
    final List data = res.data['data'];

    return data
        .map((j) => FavoriteProductResponseModel.fromJson(j).toDomain())
        .toList();
  }

  Future<bool> addFavoriteProduct(String id) async {
    final res = await dio.post('/customer/favorites/products/add/$id');
    return res.data['success'] == true;
  }

  Future<bool> removeFavoriteProduct(String id) async {
    final res = await dio.delete('/customer/favorites/products/remove/$id');
    return res.data['success'] == true;
  }
}
