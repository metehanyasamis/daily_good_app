// lib/features/review/providers/review_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/dio_provider.dart';
import '../data/repository/review_repository.dart';
import '../data/models/review_response_model.dart';
import '../domain/models/review_model.dart';

final reviewRepositoryProvider = Provider(
      (ref) => ReviewRepository(ref.watch(dioProvider)),
);

class ReviewController
    extends StateNotifier<AsyncValue<ReviewModel?>> {
  final ReviewRepository _repo;

  ReviewController(this._repo)
      : super(const AsyncValue.data(null));

  Future<bool> submitReview({
    required String storeId,
    required String? productId,
    required String? existingReviewId,
    required Map<String, int> ratings,
    required String comment,
    String? orderId,
  }) async {
    // 🔍 DEBUG PRINT: Gönderilen ham veriyi kontrol et
    debugPrint("🚀 Review Submission Started");
    debugPrint("📍 Store ID: $storeId");
    debugPrint("📦 Order ID: $orderId");
    debugPrint("🛒 Product ID: $productId");
    debugPrint("⭐ Ratings: $ratings");
    debugPrint("💬 Comment: $comment");
    debugPrint("🔄 Existing Review ID: $existingReviewId");

    state = const AsyncValue.loading();

    try {
      ReviewResponseModel result;

      if (existingReviewId == null) {
        result = await _repo.createReview(
          storeId: storeId,
          orderId: orderId,
          productId: productId,
          serviceRating: ratings["Servis"]!,
          productQuantityRating: ratings["Ürün Miktarı"]!,
          productTasteRating: ratings["Ürün Lezzeti"]!,
          productVarietyRating: ratings["Ürün Çeşitliliği"]!,
          comment: comment,
        );
      } else {
        result = await _repo.updateReview(
          storeId: storeId,
          reviewId: existingReviewId,
          serviceRating: ratings["Servis"]!,
          productQuantityRating: ratings["Ürün Miktarı"]!,
          productTasteRating: ratings["Ürün Lezzeti"]!,
          productVarietyRating: ratings["Ürün Çeşitliliği"]!,
          comment: comment,
        );
      }

      final review = ReviewModel.fromResponse(storeId, result);
      state = AsyncValue.data(review);
      debugPrint("✅ Review Submitted Successfully: ${result.id}"); // Başarı logu
      return true;
    } catch (e, st) {
      debugPrint("❌ Review Submission Failed: $e"); // Hata logu
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteReview({
    required String storeId,
    required String reviewId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final ok = await _repo.deleteReview(
        storeId: storeId,
        reviewId: reviewId,
      );
      if (ok) state = const AsyncValue.data(null);
      return ok;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final reviewControllerProvider =
StateNotifierProvider<ReviewController, AsyncValue<ReviewModel?>>(
      (ref) => ReviewController(ref.watch(reviewRepositoryProvider)),
);
