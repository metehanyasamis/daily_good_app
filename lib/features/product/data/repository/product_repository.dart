// lib/features/product/data/repository/product_repository.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../home/presentation/data/models/home_state.dart';
import '../models/product_list_response.dart';
import '../models/product_model.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.watch(dioProvider));
});

class ProductRepository {
  final Dio _dio;
  ProductRepository(this._dio);

  /// Existing method (kept) — returns ProductListResponse for compatibility.
  Future<ProductListResponse> fetchProducts({
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    String? search,
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
    debugPrint(
      '🟣 PRODUCT FETCH PARAMS → '
          'categoryId=$categoryId '
          'lat=$latitude lng=$longitude '
          'sortBy=$sortBy sortOrder=$sortOrder '
          'hemenYaninda=$hemenYaninda '
          'sonSans=$sonSans '
          'yeni=$yeni '
          'bugun=$bugun '
          'yarin=$yarin',
    );

    final params = <String, dynamic>{
      if (categoryId != null) 'categoryId': categoryId,
      if (storeId != null) 'store_id': storeId,
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

    final res = await _dio.get(
      '/products/category',
      queryParameters: params,
    );

    // safer logging: data may be a List or Map (grouped)
    final data = res.data['data'];
    if (data is Map) {
      int total = 0;
      data.forEach((k, v) {
        if (v is List) total += v.length;
      });
      debugPrint('🟢 PRODUCT API RESULT → grouped data with total $total items (groups: ${data.keys.toList()})');
    } else if (data is List) {
      debugPrint('🟢 PRODUCT API RESULT → list data with ${data.length} items');
    } else {
      debugPrint('🟢 PRODUCT API RESULT → data type = ${data.runtimeType}');
    }

    return ProductListResponse.fromJson(res.data);
  }

  /// New helper: returns flattened List<ProductModel> regardless of grouped/list shape.
  Future<List<ProductModel>> fetchProductsFlat({
    String? categoryId,
    String? storeId,
    double? latitude,
    double? longitude,
    String? search,
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
      if (categoryId != null) 'categoryId': categoryId,
      if (storeId != null) 'store_id': storeId,
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

    final data = res.data['data'];
    final List<ProductModel> out = [];

    if (data == null) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> data is null');
      return out;
    }

    if (data is Map) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> grouped data keys=${data.keys.toList()}');
      data.forEach((key, val) {
        if (val is List) {
          for (final item in val) {
            try {
              if (item is ProductModel) {
                out.add(item);
              } else {
                out.add(ProductModel.fromJson(item as Map<String, dynamic>));
              }
            } catch (e, st) {
              debugPrint('PRODUCT REPO: parse error for item in group $key -> $e\n$st');
            }
          }
        } else {
          // ignore non-list group values
        }
      });
    } else if (data is List) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> list length=${data.length}');
      for (final item in data) {
        try {
          if (item is ProductModel) {
            out.add(item);
          } else {
            out.add(ProductModel.fromJson(item as Map<String, dynamic>));
          }
        } catch (e, st) {
          debugPrint('PRODUCT REPO: parse error for list item -> $e\n$st');
        }
      }
    } else {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> unexpected data type ${data.runtimeType}');
    }

    debugPrint('PRODUCT REPO: fetchProductsFlat -> parsed ${out.length} products');
    return out;
  }

  Future<ProductModel> getProductDetail(String id) async {
    final res = await _dio.get('/products/$id');
    return ProductModel.fromJson(res.data['data']);
  }

  Future<Map<HomeSection, List<ProductModel>>> fetchHomeSections({
    required double latitude,
    required double longitude,
  }) async {
    debugPrint('🟢 HOME FETCH → lat=$latitude lng=$longitude');

    final res = await _dio.get(
      '/products/category',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
      },
    );

    final data = res.data['data'] as Map<String, dynamic>;

    return {
      HomeSection.hemenYaninda: ProductListResponse.fromRawList(data['hemen_yaninda']),
      HomeSection.sonSans: ProductListResponse.fromRawList(data['son_sans']),
      HomeSection.yeni: ProductListResponse.fromRawList(data['yeni']),
      HomeSection.bugun: ProductListResponse.fromRawList(data['bugun']),
      HomeSection.yarin: ProductListResponse.fromRawList(data['yarin']),
    };
  }
}