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

    final dynamic data = res.data != null ? res.data['data'] : null;
    final List<ProductModel> out = [];

    if (data == null) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> data is null');
      return out;
    }

    // Local helper to try to parse a single "item" into ProductModel and push to out.
    void _tryParseItem(dynamic item, String ctx) {
      try {

        debugPrint(' denenen item: $item');

        if (item == null) {
          debugPrint('PRODUCT REPO: skip null item in $ctx');
          return;
        }

        if (item is ProductModel) {
          out.add(item);
          return;
        }

        // Many server responses are Map<String, dynamic>
        if (item is Map<String, dynamic>) {
          out.add(ProductModel.fromJsonMap(item));
          return;
        }

        // If item is a List (nested), try first element if it's a Map
        if (item is List && item.isNotEmpty) {
          final first = item.first;
          if (first is ProductModel) {
            out.add(first);
            return;
          } else if (first is Map<String, dynamic>) {
            out.add(ProductModel.fromJsonMap(first));
            return;
          } else {
            debugPrint('PRODUCT REPO: nested list item has unsupported first type in $ctx -> ${first.runtimeType}');
            return;
          }
        }

        // If it's a JSON-like decoded object but typed as LinkedHashMap (non-generic), handle generically
        if (item is Map) {
          // attempt to cast to Map<String, dynamic>
          final castMap = Map<String, dynamic>.from(item);
          out.add(ProductModel.fromJsonMap(castMap));
          return;
        }

        debugPrint('PRODUCT REPO: unexpected item type in $ctx -> ${item.runtimeType} : $item');
      } catch (e, st) {
        debugPrint('PRODUCT REPO: parse error for item in $ctx -> $e\n$st');
        debugPrint('🔥 PARSE FAIL in $ctx! Hata: $e');
        debugPrint('🔥 HATALI ITEM DATA: $item');
      }
    }

    // If server returned grouped object (hemen_yaninda, yeni, etc.)
    if (data is Map) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> grouped data keys=${data.keys.toList()}');
      data.forEach((key, val) {
        if (val == null) return;
        if (val is List) {
          for (final item in val) {
            _tryParseItem(item, 'group:$key');
          }
        } else if (val is Map) {
          // some groups might be a single object instead of list — attempt parse
          _tryParseItem(val, 'group:$key');
        } else {
          debugPrint('PRODUCT REPO: ignoring non-list/non-map group value for key=$key -> ${val.runtimeType}');
        }
      });
    }
    // If server returned a flat list of products
    else if (data is List) {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> list length=${data.length}');
      for (final item in data) {
        _tryParseItem(item, 'list');
      }
    } else {
      debugPrint('PRODUCT REPO: fetchProductsFlat -> unexpected data type ${data.runtimeType}');
    }

    debugPrint('PRODUCT REPO: fetchProductsFlat -> parsed ${out.length} products');
    return out;
  }

  Future<ProductModel> getProductDetail(String id) async {
    final res = await _dio.get('/products/$id');

    // BURAYA EKLE: Ham veriyi ve tipini görelim
    debugPrint('🚨 RAW DETAIL DATA: ${res.data['data']}');
    debugPrint('🚨 RAW DETAIL TYPE: ${res.data['data'].runtimeType}');

    final data = res.data['data'];
    debugPrint('📦 REPO DEBUG: data type = ${data.runtimeType}');

    if (data is List && data.isNotEmpty) {
      debugPrint('ℹ️ INFO: Veri liste olarak geldi, ilki alınıyor.');
      debugPrint('⚠️ UYARI: Detay verisi List geldi, ilk eleman zorlanıyor.');
      return ProductModel.fromJsonMap(data.first);
    }

    if (data == null) {
      debugPrint('❌ ERROR: Data null geldi!');
      throw FormatException('Product detail data is null for id=$id');
    }

    return ProductModel.fromJsonMap(data);
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