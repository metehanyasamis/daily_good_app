// lib/features/product/data/repository/product_repository.dart
// ⚠️ Sende zaten var. Aşağıdaki imzayı birebir buna çevir ki notifier uyusun.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/dio_provider.dart';
import '../models/product_list_response.dart';
import '../models/product_model.dart';
import 'package:dio/dio.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  Future<ProductListResponse> fetchProducts({
    String? categoryId,
    double? latitude,
    double? longitude,
    String? search, // name
    int perPage = 15,
    int page = 1,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
    bool? hemenYaninda,
    bool? sonSans,
    bool? yeni,
    bool? bugun,
    bool? yarin,
  }) async {
    final params = <String, dynamic>{
      //if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
      'category_id': 1, // 🔥 GEÇİCİ – görseller için
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (search != null && search.isNotEmpty) 'name': search,
      'per_page': perPage,
      'page': page,
      'sort_by': sortBy,
      'sort_order': sortOrder,
      if (hemenYaninda == true) 'hemen_yaninda': true,
      if (sonSans == true) 'son_sans': true,
      if (yeni == true) 'yeni': true,
      if (bugun == true) 'bugun': true,
      if (yarin == true) 'yarin': true,
    };

    final res = await _dio.get('/products/category', queryParameters: params);
    return ProductListResponse.fromJson(res.data);
  }

  Future<ProductModel> getProductDetail(String id) async {
    final res = await _dio.get('/products/$id');
    return ProductModel.fromJson(res.data['data']);
  }
}
