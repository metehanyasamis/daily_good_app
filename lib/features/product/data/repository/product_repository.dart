// lib/features/product/data/repository/product_repository.dart

import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  // ✔ GET /products/category
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? name,
    int? page,
    int? perPage,
    double? latitude,
    double? longitude,
    bool hemenYaninda = false,
    bool sonSans = false,
    bool yeni = false,
    bool bugun = false,
    bool yarin = false,
  }) async {
    final response = await _dio.get(
      '/products/category',
      queryParameters: {
        'categoryId': categoryId,
        'name': name,
        'page': page,
        'per_page': perPage,
        'latitude': latitude,
        'longitude': longitude,
        'hemen_yaninda': hemenYaninda,
        'son_sans': sonSans,
        'yeni': yeni,
        'bugun': bugun,
        'yarin': yarin,
      }..removeWhere((key, value) => value == null),
    );

    final List data = response.data['data'];
    return data.map((e) => ProductModel.fromJson(e)).toList();
  }

  // ✔ GET /products/{productId}
  Future<ProductModel> getProductDetail(String id) async {
    final response = await _dio.get('/products/$id');
    return ProductModel.fromJson(response.data['data']);
  }
}
