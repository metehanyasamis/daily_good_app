import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/review_response_model.dart';

class ReviewRepository {
  final Dio _dio;

  ReviewRepository(this._dio);

  /// 1. Değerlendirme Oluşturma (POST)
  Future<ReviewResponseModel> createReview({
    required String storeId,
    required int serviceRating,
    required int productQuantityRating,
    required int productTasteRating,
    required int productVarietyRating,
    String? comment,
    String? orderId,
    String? productId,
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

      // 🔥 KRİTİK DÜZELTME: Veri var mı ve success mi kontrol et
      if (res.data == null || res.data["data"] == null) {
        throw res.data?["message"] ?? "Sunucudan boş veri döndü.";
      }

      return ReviewResponseModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      // Hata durumunda buraya düşer (400, 401, 500 vb.)
      _handleDioError(e, "Değerlendirme oluşturulamadı");
      rethrow;
    }
  }

  /// 2. Değerlendirme Güncelleme (PUT)
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

      if (res.data == null || res.data["data"] == null) {
        throw res.data?["message"] ?? "Güncelleme için veri dönmedi.";
      }

      return ReviewResponseModel.fromJson(res.data["data"]);
    } on DioException catch (e) {
      _handleDioError(e, "Değerlendirme güncellenemedi");
      rethrow;
    }
  }

  /// 3. Değerlendirme Silme (DELETE)
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
      // Silme hatasını da kullanıcıya düzgün gösterelim
      _handleDioError(e, "Değerlendirme silinemedi");
      return false;
    }
  }

  /// Merkezi Hata Yönetimi
  void _handleDioError(DioException e, String defaultMessage) {
    // Backend'den gelen hata yapısını debug edelim
    debugPrint("❌ Review API Error Response: ${e.response?.data}");

    String errorMessage = defaultMessage;

    if (e.response?.data != null && e.response?.data is Map) {
      // Backend'den gelen "message" alanını al (Örn: "Zaten değerlendirme yapılmış")
      errorMessage = e.response?.data["message"] ?? defaultMessage;
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = "Bağlantı zaman aşımına uğradı.";
    }

    // Bu throw, Controller'daki try-catch'e gider ve SnackBar'da görünür
    throw errorMessage;
  }
}