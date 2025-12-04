// lib/features/review/data/models/review_response_model.dart

class ReviewCustomer {
  final String id;
  final String? name;

  ReviewCustomer({
    required this.id,
    this.name,
  });

  factory ReviewCustomer.fromJson(Map<String, dynamic> json) {
    return ReviewCustomer(
      id: json["id"] as String,
      name: json["name"] as String?,
    );
  }
}

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
      overallRating: (json["overall_rating"] as num).toDouble(),
      totalReviews: json["total_reviews"],
      averageRatings: (json["average_ratings"] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }
}

class ReviewResponseModel {
  final String id;
  final int serviceRating;
  final int productQuantityRating;
  final int productTasteRating;
  final int productVarietyRating;
  final String? comment;
  final ReviewCustomer? customer;
  final DateTime createdAt;
  final DateTime updatedAt;
  final StoreRatingDetail storeRatings;

  ReviewResponseModel({
    required this.id,
    required this.serviceRating,
    required this.productQuantityRating,
    required this.productTasteRating,
    required this.productVarietyRating,
    required this.comment,
    required this.customer,
    required this.createdAt,
    required this.updatedAt,
    required this.storeRatings,
  });

  factory ReviewResponseModel.fromJson(Map<String, dynamic> json) {
    return ReviewResponseModel(
      id: json["id"],
      serviceRating: json["service_rating"],
      productQuantityRating: json["product_quantity_rating"],
      productTasteRating: json["product_taste_rating"],
      productVarietyRating: json["product_variety_rating"],
      comment: json["comment"],
      customer: json["customer"] != null
          ? ReviewCustomer.fromJson(json["customer"])
          : null,
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      storeRatings:
      StoreRatingDetail.fromJson(json["store_ratings"] as Map<String, dynamic>),
    );
  }
}
