import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/review_response_model.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  /// 1. Değerlendirme Oluşturma (POST)
  /// Doküman: /customer/stores/{storeId}/reviews
  Future<ReviewResponseModel> createReview({
    required String storeId,
    required int serviceRating,
    required int productQuantityRating,
    required int productTasteRating,
    required int productVarietyRating,
    String? comment,
    String? orderId,    // Sipariş bazlı yorum desteği
    String? productId,  // Ürün bazlı yorum desteği
  }) async {
    final payload = {
      "service_rating": serviceRating,
      "product_quantity_rating": productQuantityRating,
      "product_taste_rating": productTasteRating,
      "product_variety_rating": productVarietyRating,
      "comment": comment,
      if (orderId != null) "order_id": orderId,
      if (productId != null) "product_id": productId,
    };

    try {
      final res = await _dio.post(
        "/customer/stores/$storeId/reviews",
        data: payload,
      );

      // Backend 'data' objesi içinde dönüyor
      return ReviewResponseModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      _handleDioError(e, "Değerlendirme oluşturulamadı");
      rethrow; // _handleDioError hata fırlatmazsa diye güvenlik önlemi
    }
  }

  /// 2. Değerlendirme Güncelleme (PUT)
  /// Doküman: /customer/stores/{storeId}/reviews/{reviewId}
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
      _handleDioError(e, "Değerlendirme güncellenemedi");
      rethrow;
    }
  }

  /// 3. Değerlendirme Silme (DELETE)
  /// Doküman: /customer/stores/{storeId}/reviews/{reviewId}
  Future<bool> deleteReview({
    required String storeId,
    required String reviewId,
  }) async {
    try {
      final res = await _dio.delete(
        "/customer/stores/$storeId/reviews/$reviewId",
      );
      // Dokümana göre success: true dönüyor
      return res.data["success"] == true;
    } on DioException catch (e) {
      _handleDioError(e, "Değerlendirme silinemedi");
      return false;
    }
  }

  /// Merkezi Hata Yönetimi
  void _handleDioError(DioException e, String defaultMessage) {
    debugPrint("❌ Review API Error: ${e.response?.data}");

    // Backend'den gelen spesifik hata mesajını (örneğin: "Zaten yorum yaptınız") yakalar
    final errorMessage = e.response?.data["message"] ?? defaultMessage;

    throw errorMessage;
  }
}