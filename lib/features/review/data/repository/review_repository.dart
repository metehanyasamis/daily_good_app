// lib/features/review/data/repository/review_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/review_response_model.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  /// 📤 POST /customer/stores/{storeId}/reviews - Değerlendirme oluşturma
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

    debugPrint('⭐ Değerlendirme oluşturma isteği gönderiliyor: POST /customer/stores/$storeId/reviews. Payload: $payload');

    try {
      final response = await _dio.post(
        '/customer/stores/$storeId/reviews',
        data: payload,
      );

      debugPrint('✅ Değerlendirme oluşturma başarılı. (Status: ${response.statusCode})');
      return ReviewResponseModel.fromJson(response.data['data']);

    } on DioException catch (e) {
      debugPrint('❌ Değerlendirme oluşturma HATA: ${e.response?.statusCode} - ${e.message}');
      // 400 genellikle "zaten değerlendirme yapılmış" anlamına gelebilir.
      rethrow;
    }
  }

  /// 🔄 PUT /customer/stores/{storeId}/reviews/{reviewId} - Değerlendirme güncelleme
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

    debugPrint('⭐ Değerlendirme güncelleme isteği gönderiliyor: PUT /customer/stores/$storeId/reviews/$reviewId. Payload: $payload');

    try {
      final response = await _dio.put(
        '/customer/stores/$storeId/reviews/$reviewId',
        data: payload,
      );

      debugPrint('✅ Değerlendirme güncelleme başarılı. (Status: ${response.statusCode})');
      return ReviewResponseModel.fromJson(response.data['data']);

    } on DioException catch (e) {
      debugPrint('❌ Değerlendirme güncelleme HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }

  /// 🗑️ DELETE /customer/stores/{storeId}/reviews/{reviewId} - Değerlendirme silme
  Future<bool> deleteReview({
    required String storeId,
    required String reviewId,
  }) async {
    debugPrint('⭐ Değerlendirme silme isteği gönderiliyor: DELETE /customer/stores/$storeId/reviews/$reviewId');

    try {
      final response = await _dio.delete(
        '/customer/stores/$storeId/reviews/$reviewId',
      );

      debugPrint('✅ Değerlendirme silme başarılı. (Status: ${response.statusCode})');
      return response.statusCode == 200 && response.data['success'] == true;

    } on DioException catch (e) {
      debugPrint('❌ Değerlendirme silme HATA: ${e.response?.statusCode} - ${e.message}');
      rethrow;
    }
  }
}