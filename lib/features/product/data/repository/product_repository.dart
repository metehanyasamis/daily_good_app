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
          'lat=$latitude lng=$longitude '
          'hemenYaninda=$hemenYaninda '
          'sonSans=$sonSans '
          'yeni=$yeni '
          'bugun=$bugun '
          'yarin=$yarin',
    );

    final params = <String, dynamic>{
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

    debugPrint(
      '🟢 PRODUCT API RESULT → '
          '${res.data['data']?.length ?? 0} ürün',
    );

    return ProductListResponse.fromJson(res.data);
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
      HomeSection.hemenYaninda:
      ProductListResponse.fromRawList(data['hemen_yaninda']),
      HomeSection.sonSans:
      ProductListResponse.fromRawList(data['son_sans']),
      HomeSection.yeni:
      ProductListResponse.fromRawList(data['yeni']),
      HomeSection.bugun:
      ProductListResponse.fromRawList(data['bugun']),
      HomeSection.yarin:
      ProductListResponse.fromRawList(data['yarin']),
    };
  }

}
