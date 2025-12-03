// lib/features/review/domain/models/review_model.dart

class ReviewModel {
  final String id;
  final String storeId;
  final int serviceRating;
  final int productTasteRating;
  final String comment;
  final double overallStoreRating;
  // Daha fazla alan (yorum tarihi, müşteri adı vb.) eklenebilir.

  const ReviewModel({
    required this.id,
    required this.storeId,
    required this.serviceRating,
    required this.productTasteRating,
    required this.comment,
    required this.overallStoreRating,
  });
}