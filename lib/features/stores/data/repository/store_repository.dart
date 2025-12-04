import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/dio_provider.dart';
import '../../../product/data/models/store_summary.dart';
import '../../../review/data/models/review_response_model.dart';
import '../../../review/domain/models/review_model.dart';
import '../model/store_detail_model.dart';

/// 🔥 DIŞTA DURACAK — class içinde değil
final storeRepositoryProvider = Provider<StoreRepository>((ref) {
  return StoreRepository(ref.watch(dioProvider));
});

class StoreRepository {
  final Dio _dio;

  StoreRepository(this._dio);

  // ---------------------------------------------------------
  // 1️⃣ MAĞAZA LİSTESİ (ÖZET) — GET /stores
  // ---------------------------------------------------------
  Future<List<StoreSummary>> getStores() async {
    final res = await _dio.get("/stores");

    final List data = res.data["data"] ?? [];
    return data.map((e) => StoreSummary.fromJson(e)).toList();
  }

  // ---------------------------------------------------------
  // 2️⃣ MAĞAZA DETAY (GET /stores/:id)
  // ---------------------------------------------------------
  Future<StoreDetailModel> getStoreDetail(String storeId) async {
    final res = await _dio.get("/stores/$storeId");
    return StoreDetailModel.fromJson(res.data['data']);
  }

  // ---------------------------------------------------------
  // 3️⃣ MAĞAZA YORUMLARI (GET /stores/:id/reviews)
  // ---------------------------------------------------------
  Future<List<ReviewModel>> getStoreReviews(String storeId) async {
    final res = await _dio.get("/stores/$storeId/reviews");

    final List data = res.data['data'] ?? [];
    return data.map((e) {
      final response = ReviewResponseModel.fromJson(e);
      return ReviewModel.fromResponse(storeId, response);
    }).toList();
  }
}
