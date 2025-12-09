import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../models/product_list_response.dart';

final productRepositoryProvider = Provider((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: "https://dailygood.dijicrea.net/api/v1",
    headers: {"Accept": "application/json"},
  ));
  return ProductRepository(dio);
});

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  /// 🔥 ANA METHOD → tüm filtreler buradan çalışır
  Future<ProductListResponse> fetchProducts({
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
    String? search,
    String? categoryId,
    String? storeId,
    int perPage = 20,
    double? latitude,
    double? longitude,
  }) async {

    final params = {
      if (hemenYaninda == true) "hemen_yaninda": true,
      if (sonSans == true) "son_sans": true,
      if (yeni == true) "yeni": true,
      if (bugun == true) "bugun": true,
      if (yarin == true) "yarin": true,
      if (search != null && search.isNotEmpty) "name": search,
      if (categoryId != null) "categoryId": categoryId,
      if (storeId != null) "store_id": storeId,
      "per_page": perPage,
      if (latitude != null) "latitude": latitude,
      if (longitude != null) "longitude": longitude,
    };

    final res = await _dio.get(
      "/products/category",
      queryParameters: params,
    );

    return ProductListResponse.fromJson(res.data);
  }

  /// ✔ ÜRÜN DETAY endpoint
  Future<ProductModel> getProductDetail(String id) async {
    final response = await _dio.get('/products/$id');
    return ProductModel.fromJson(response.data['data']);
  }
}
