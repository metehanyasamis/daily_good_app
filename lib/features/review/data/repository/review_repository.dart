// lib/features/review/data/repository/review_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/review_response_model.dart';

class ReviewRepository {
  final Dio _dio;
  ReviewRepository(this._dio);

  Future<ReviewResponseModel> createReview({
    required String storeId,
    required int serviceRating,
    required int productQuantityRating,
    required int productTasteRating,
    required int productVarietyRating,
    String? comment,
  }) async {
    final payload = {
      "service_rating": serviceRating,
      "product_quantity_rating": productQuantityRating,
      "product_taste_rating": productTasteRating,
      "product_variety_rating": productVarietyRating,
      "comment": comment,
    };

    try {
      final res = await _dio.post(
        "/customer/stores/$storeId/reviews",
        data: payload,
      );
      return ReviewResponseModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      debugPrint("Review create error: ${e.response?.data}");
      throw e.response?.data["message"] ?? "Bir hata oluştu.";
    }
  }

  Future<ReviewResponseModel> updateReview({
    required String storeId,
    required String reviewId,
    required int serviceRating,
    required int productQuantityRating,
    required int productTasteRating,
    required int productVarietyRating,
    String? comment,
  }) async {
    final payload = {
      "service_rating": serviceRating,
      "product_quantity_rating": productQuantityRating,
      "product_taste_rating": productTasteRating,
      "product_variety_rating": productVarietyRating,
      "comment": comment,
    };

    try {
      final res = await _dio.put(
        "/customer/stores/$storeId/reviews/$reviewId",
        data: payload,
      );
      return ReviewResponseModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Güncelleme hatası.";
    }
  }

  Future<bool> deleteReview({
    required String storeId,
    required String reviewId,
  }) async {
    try {
      final res = await _dio.delete(
        "/customer/stores/$storeId/reviews/$reviewId",
      );
      return res.data["success"] == true;
    } on DioException catch (e) {
      throw e.response?.data["message"] ?? "Silme işlemi başarısız.";
    }
  }
}
