// lib/features/review/providers/review_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/providers/dio_provider.dart';
import '../data/models/review_response_model.dart';
import '../data/repository/review_repository.dart';

// --- API KATMANI PROVIDER'I ---
final reviewRepositoryProvider = Provider((ref) {
  return ReviewRepository(ref.watch(dioProvider));
});


// --- STATE NOTIFIER ---
// Bu notifier, kullanıcının bir mağaza için yaptığı aktif değerlendirmeyi tutabilir.
// (Örneğin, kullanıcı zaten değerlendirme yaptıysa, onu burada saklayabiliriz.)
// Şimdilik sadece API çağrılarının yapılacağı bir "Controller" olarak kullanacağız.

class ReviewController extends StateNotifier<AsyncValue<ReviewResponseModel?>> {
  final ReviewRepository _repository;

  ReviewController(this._repository) : super(const AsyncValue.data(null));

  /// Değerlendirme oluşturma veya güncelleme
  Future<bool> submitReview({
    required String storeId,
    required String? existingReviewId, // null ise oluştur, varsa güncelle
    required Map<String, int> ratings, // UI'dan gelen oylar
    required String comment,
  }) async {
    state = const AsyncValue.loading();

    // Rating'leri API'nin beklediği isimlere map et
    final serviceRating = ratings['Servis']!;
    final productQuantityRating = ratings['Ürün Miktarı']!;
    final productTasteRating = ratings['Ürün Lezzeti']!;
    final productVarietyRating = ratings['Ürün Çeşitliliği']!;

    try {
      if (existingReviewId == null) {
        // Yeni değerlendirme oluşturma (POST)
        final result = await _repository.createReview(
          storeId: storeId,
          serviceRating: serviceRating,
          productQuantityRating: productQuantityRating,
          productTasteRating: productTasteRating,
          productVarietyRating: productVarietyRating,
          comment: comment,
        );
        state = AsyncValue.data(result);
        debugPrint('✅ Değerlendirme başarıyla oluşturuldu: ${result.id}');
      } else {
        // Mevcut değerlendirmeyi güncelleme (PUT)
        final result = await _repository.updateReview(
          storeId: storeId,
          reviewId: existingReviewId,
          serviceRating: serviceRating,
          productQuantityRating: productQuantityRating,
          productTasteRating: productTasteRating,
          productVarietyRating: productVarietyRating,
          comment: comment,
        );
        state = AsyncValue.data(result);
        debugPrint('✅ Değerlendirme başarıyla güncellendi: ${result.id}');
      }
      return true;

    } catch (e, st) {
      state = AsyncValue.error(e, st);
      debugPrint('❌ Değerlendirme gönderme hatası: $e');
      return false;
    }
  }

  /// Değerlendirme silme
  Future<bool> deleteReview({
    required String storeId,
    required String reviewId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final success = await _repository.deleteReview(storeId: storeId, reviewId: reviewId);
      if (success) {
        state = const AsyncValue.data(null);
        debugPrint('✅ Değerlendirme başarıyla silindi.');
      }
      return success;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      debugPrint('❌ Değerlendirme silme hatası: $e');
      return false;
    }
  }
}

final reviewControllerProvider = StateNotifierProvider<ReviewController, AsyncValue<ReviewResponseModel?>>(
      (ref) => ReviewController(ref.watch(reviewRepositoryProvider)),
);