// lib/features/review/domain/models/review_model.dart

import '../../data/models/review_response_model.dart';

class ReviewModel {
  final String id;
  final String storeId;

  final int serviceRating;
  final int productQuantityRating;
  final int productTasteRating;
  final int productVarietyRating;

  final String? comment;
  final double overallStoreRating;
  final int totalReviews;

  final DateTime createdAt;
  final DateTime updatedAt;

  const ReviewModel({
    required this.id,
    required this.storeId,
    required this.serviceRating,
    required this.productQuantityRating,
    required this.productTasteRating,
    required this.productVarietyRating,
    required this.comment,
    required this.overallStoreRating,
    required this.totalReviews,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromApi(String storeId, ReviewResponseModel r) {
    return ReviewModel(
      id: r.id,
      storeId: storeId,
      serviceRating: r.serviceRating,
      productQuantityRating: r.productQuantityRating,
      productTasteRating: r.productTasteRating,
      productVarietyRating: r.productVarietyRating,
      comment: r.comment,
      overallStoreRating: r.storeRatings.overallRating,
      totalReviews: r.storeRatings.totalReviews,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }
}
