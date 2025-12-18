import '../../../product/data/models/product_model.dart';
import '../../../review/data/models/review_response_model.dart';
import '../../../review/domain/models/review_model.dart';
import 'store_summary.dart';
import 'working_hours_model.dart';
import 'store_brand_model.dart';

/// ------------------------------------------------------------
/// SAFE HELPERS (backend tutarsızlığı için)
/// ------------------------------------------------------------
Map<String, dynamic>? asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  return null;
}

List asList(dynamic v) {
  if (v is List) return v;
  return const [];
}

/// ------------------------------------------------------------
/// STORE DETAIL MODEL
/// ------------------------------------------------------------
class StoreDetailModel {
  final String id;
  final String name;
  final String address;
  final String imageUrl;

  final double latitude;
  final double longitude;

  final String bannerImageUrl;
  final bool isFavorite;
  final double? distanceKm;

  final StoreBrandModel? brand;
  final WorkingHoursModel? workingHours;

  final double overallRating;
  final int totalReviews;

  final AverageRatingsModel? averageRatings;
  final List<ProductModel> products;
  final List<ReviewModel> reviews;

  StoreDetailModel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.bannerImageUrl,
    required this.isFavorite,
    required this.distanceKm,
    required this.brand,
    required this.workingHours,
    required this.overallRating,
    required this.totalReviews,
    required this.averageRatings,
    required this.products,
    required this.reviews,
  });

  factory StoreDetailModel.fromJson(Map<String, dynamic> json) {
    // 🔎 DEBUG (istersen açık bırak)
    /*
    debugPrint(
      "🧪 STORE JSON TYPES → "
      "brand=${json['brand']?.runtimeType} | "
      "working_hours=${json['working_hours']?.runtimeType} | "
      "average_ratings=${json['average_ratings']?.runtimeType} | "
      "products=${json['products']?.runtimeType} | "
      "reviews=${json['reviews']?.runtimeType}",
    );
    */

    return StoreDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: json['image_url'] ?? '',

      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,

      bannerImageUrl: json['banner_image'] ?? '',
      isFavorite: json['is_favorite'] == true,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),

      // 🟢 SAFE OBJECT PARSE
      brand: asMap(json['brand']) != null
          ? StoreBrandModel.fromJson(asMap(json['brand'])!)
          : null,

      workingHours: asMap(json['working_hours']) != null
          ? WorkingHoursModel.fromJson(asMap(json['working_hours'])!)
          : null,

      overallRating:
      (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,

      averageRatings: asMap(json['average_ratings']) != null
          ? AverageRatingsModel.fromJson(
        asMap(json['average_ratings'])!,
      )
          : null,

      // 🟢 SAFE LIST PARSE
      products: asList(json['products'])
          .map((e) => ProductModel.fromJson(e))
          .toList(),

      reviews: asList(json['reviews']).map((e) {
        final response = ReviewResponseModel.fromJson(e);
        return ReviewModel.fromResponse(
          json['id']?.toString() ?? '',
          response,
        );
      }).toList(),
    );
  }
}

/// ------------------------------------------------------------
/// AVERAGE RATINGS MODEL
/// ------------------------------------------------------------
class AverageRatingsModel {
  final double service;
  final double productQuantity;
  final double productTaste;
  final double productVariety;

  AverageRatingsModel({
    required this.service,
    required this.productQuantity,
    required this.productTaste,
    required this.productVariety,
  });

  factory AverageRatingsModel.fromJson(Map<String, dynamic> json) {
    return AverageRatingsModel(
      service: (json['service'] as num?)?.toDouble() ?? 0.0,
      productQuantity:
      (json['product_quantity'] as num?)?.toDouble() ?? 0.0,
      productTaste:
      (json['product_taste'] as num?)?.toDouble() ?? 0.0,
      productVariety:
      (json['product_variety'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// ------------------------------------------------------------
/// OPTIONAL MAPPER (kullanıyorsan)
/// ------------------------------------------------------------
extension StoreDetailMapper on StoreDetailModel {
  StoreSummary toStoreSummary() {
    return StoreSummary(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      imageUrl: bannerImageUrl,
      distanceKm: distanceKm,
      overallRating: overallRating,
      isFavorite: isFavorite,
    );
  }
}
