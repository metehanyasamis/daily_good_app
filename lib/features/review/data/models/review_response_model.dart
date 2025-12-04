// lib/features/review/data/models/review_response_model.dart

class StoreRatingDetail {
  final double overallRating;
  final int totalReviews;
  final Map<String, double> averageRatings;

  StoreRatingDetail({
    required this.overallRating,
    required this.totalReviews,
    required this.averageRatings,
  });

  factory StoreRatingDetail.fromJson(Map<String, dynamic> json) {
    return StoreRatingDetail(
      overallRating: (json['overall_rating'] as num).toDouble(),
      totalReviews: json['total_reviews'] as int,
      averageRatings: (json['average_ratings'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
    );
  }
}

class ReviewResponseModel {
  final String id;
  final int serviceRating;
  final int productQuantityRating;
  final int productTasteRating;
  final int productVarietyRating;
  final String comment;
  final StoreRatingDetail storeRatings;
  // Diğer alanlar (customer, created_at, updated_at) basitçe atlanmıştır.

  ReviewResponseModel({
    required this.id,
    required this.serviceRating,
    required this.productQuantityRating,
    required this.productTasteRating,
    required this.productVarietyRating,
    required this.comment,
    required this.storeRatings,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      id: json['id'] as String,
      serviceRating: json['service_rating'] as int,
      productQuantityRating: json['product_quantity_rating'] as int,
      productTasteRating: json['product_taste_rating'] as int,
      productVarietyRating: json['product_variety_rating'] as int,
      comment: json['comment'] as String,
      storeRatings: StoreRatingDetail.fromJson(json['store_ratings'] as Map<String, dynamic>),
    );
  }

// ℹ️ Değerlendirmenin ID'si, kullanıcının bu şube için daha önce değerlendirme yapıp yapmadığını anlamak (ve güncellemek/silmek) için kritik.
}