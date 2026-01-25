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
      // json["id"] null gelebileceği için koruma ekledik
      id: json["id"]?.toString() ?? "",
      name: json["name"],
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
      overallRating: (json["overall_rating"] as num?)?.toDouble() ?? 0.0,
      totalReviews: json["total_reviews"] ?? 0,
      // average_ratings boş gelirse çökmemesi için {} ekledik
      averageRatings: (json["average_ratings"] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num?)?.toDouble() ?? 0.0),
      ) ?? {},
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
      id: json["id"]?.toString() ?? "",
      serviceRating: json["service_rating"] ?? 0,
      productQuantityRating: json["product_quantity_rating"] ?? 0,
      productTasteRating: json["product_taste_rating"] ?? 0,
      productVarietyRating: json["product_variety_rating"] ?? 0,
      comment: json["comment"],
      customer: json["customer"] != null
          ? ReviewCustomer.fromJson(json["customer"])
          : null,
      // Tarih parsing hatalarına karşı tryParse veya fallback
      createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),

      // 🔥 HATANIN KAYNAĞI BURASIYDI:
      // Eğer store_ratings null gelirse direkt boş bir StoreRatingDetail oluşturuyoruz
      storeRatings: json["store_ratings"] != null
          ? StoreRatingDetail.fromJson(json["store_ratings"] as Map<String, dynamic>)
          : StoreRatingDetail(
        overallRating: 0.0,
        totalReviews: 0,
        averageRatings: {},
      ),
    );
  }
}