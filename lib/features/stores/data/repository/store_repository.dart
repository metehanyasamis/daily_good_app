import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../model/store_summary.dart';
import '../../../review/data/models/review_response_model.dart';
import '../../../review/domain/models/review_model.dart';
import '../model/store_detail_model.dart';

/// 🔥 PROVIDER
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository(ref.watch(dioProvider));
});

class StoreRepository {
  final Dio _dio;

  StoreRepository(this._dio);

  // ---------------------------------------------------------
  // 1️⃣ MAĞAZA LİSTESİ
  // ---------------------------------------------------------
  Future<List<StoreSummary>> getStores() async {
    debugPrint('📡 GET /stores (simple)');

    final res = await _dio.get('/stores');

    debugPrint('📥 RESPONSE /stores → ${res.data}');

    final List data = res.data['data'] ?? [];
    return data.map((e) => StoreSummary.fromJson(e)).toList();
  }

  // ---------------------------------------------------------
  // 2️⃣ MAĞAZA DETAY
  // ---------------------------------------------------------
  Future<StoreDetailModel> getStoreDetail(String storeId) async {
    debugPrint('📡 GET /stores/$storeId');

    final res = await _dio.get('/stores/$storeId');

    debugPrint('📥 STORE DETAIL RESPONSE → ${res.data}');

    return StoreDetailModel.fromJson(res.data['data']);
  }

  // ---------------------------------------------------------
  // 3️⃣ MAĞAZA YORUMLARI
  // ---------------------------------------------------------
  Future<List<ReviewModel>> getStoreReviews(String storeId) async {
    debugPrint('📡 GET /stores/$storeId/reviews');

    final res = await _dio.get('/stores/$storeId/reviews');

    debugPrint('📥 REVIEWS RESPONSE → ${res.data}');

    final List data = res.data['data'] ?? [];
    return data.map((e) {
      final response = ReviewResponseModel.fromJson(e);
      return ReviewModel.fromResponse(storeId, response);
    }).toList();
  }

  // ---------------------------------------------------------
  // 4️⃣ KONUMA + KATEGORİYE GÖRE MAĞAZALAR
  // ---------------------------------------------------------
  Future<List<StoreSummary>> getStoresByLocation({
    required double latitude,
    required double longitude,
    String sortBy = 'distance',
    String sortOrder = 'asc',
    int page = 1,
    int perPage = 15,
    String? search,
    String? category,
  }) async {
    final query = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'page': page,
      'per_page': perPage,
    };

    if (search != null && search.isNotEmpty) {
      query['search'] = search;
    }

    if (category != null && category.isNotEmpty) {
      query['category'] = category;
    }

    // 🔥 KRİTİK DEBUG
    debugPrint('🟢 STORES REQUEST QUERY');
    debugPrint('➡️ $query');
    debugPrint('🟣 CATEGORY PARAM → ${query['category']}');

    final res = await _dio.get(
      '/stores',
      queryParameters: query,
    );

    debugPrint('📥 STORES RESPONSE');
    debugPrint(res.data.toString());

    debugPrint('📥 STORES RESPONSE COUNT → ${(res.data['data'] as List?)?.length}');


    final List data = res.data['data'] ?? [];
    return data.map((e) => StoreSummary.fromJson(e)).toList();
  }
}
