// lib/features/stores/data/model/store_summary.dart

class StoreSummary {
  final String id;
  final String name;
  final String address;

  final double? latitude;
  final double? longitude;

  final String? bannerImageUrl;
  final String imageUrl;

  final bool? isFavorite;
  final double? distanceKm;

  final BrandSummary? brand;

  /// ⭐ RATING
  final double? overallRating;
  final int? totalReviews;
  final AverageRatings? averageRatings;

  StoreSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.latitude,
    this.longitude,
    this.bannerImageUrl,
    this.isFavorite,
    this.distanceKm,
    this.brand,
    this.overallRating,
    this.totalReviews,
    this.averageRatings,
  });

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    return StoreSummary(
      id: json["id"].toString(),
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      imageUrl: json["banner_image_url"] ?? json["image_url"] ?? "",
      latitude: (json["latitude"] as num?)?.toDouble(),
      longitude: (json["longitude"] as num?)?.toDouble(),
      bannerImageUrl: json["banner_image_url"],
      isFavorite: json["is_favorite"],
      distanceKm: (json["distance_km"] as num?)?.toDouble(),

      /// ⭐ RATING
      overallRating: (json["overall_rating"] as num?)?.toDouble(),
      totalReviews: json["total_reviews"],
      averageRatings: json["average_ratings"] != null
          ? AverageRatings.fromJson(json["average_ratings"])
          : null,

      /// ⭐ BRAND
      brand: json["brand"] != null
          ? BrandSummary.fromJson(json["brand"])
          : null,
    );
  }
}

// ============================================================================
// ⭐ AVERAGE RATINGS MODEL
// ============================================================================

class AverageRatings {
  final double service;
  final double productQuantity;
  final double productTaste;
  final double productVariety;

  const AverageRatings({
    required this.service,
    required this.productQuantity,
    required this.productTaste,
    required this.productVariety,
  });

  factory AverageRatings.fromJson(Map<String, dynamic> json) {
    return AverageRatings(
      service: (json["service"] as num?)?.toDouble() ?? 0,
      productQuantity:
      (json["product_quantity"] as num?)?.toDouble() ?? 0,
      productTaste:
      (json["product_taste"] as num?)?.toDouble() ?? 0,
      productVariety:
      (json["product_variety"] as num?)?.toDouble() ?? 0,
    );
  }
}

// ============================================================================
// ⭐ BRAND SUMMARY MODEL
// ============================================================================

class BrandSummary {
  final String id;
  final String name;
  final String logoUrl;

  BrandSummary({
    required this.id,
    required this.name,
    required this.logoUrl,
  });

  factory BrandSummary.fromJson(Map<String, dynamic> json) {
    return BrandSummary(
      id: json["id"]?.toString() ?? "",
      name: json["name"] ?? "",
      logoUrl: json["logo_url"] ?? "",
    );
  }
}
