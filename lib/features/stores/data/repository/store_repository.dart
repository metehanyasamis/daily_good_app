// lib/features/stores/data/repository/store_repository.dart

import 'package:dio/dio.dart';

import '../../../review/domain/models/review_model.dart';
import '../model/store_detail_model.dart';


class StoreRepository {
  final Dio _dio;

  StoreRepository(this._dio);

  // ✔ Mağaza detayı
  Future<StoreDetailModel> getStoreDetails(String storeId) async {
    final res = await _dio.get("/stores/$storeId");
    return StoreDetailModel.fromJson(res.data['data']);
  }

  // ✔ Mağaza yorumları
  Future<List<ReviewModel>> getStoreReviews(String storeId) async {
    final res = await _dio.get("/stores/$storeId/reviews");
    final List data = res.data['data'];
    return data.map((e) => ReviewModel.fromJson(e)).toList();
  }
}
