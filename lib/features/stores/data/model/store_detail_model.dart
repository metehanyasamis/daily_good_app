import '../../../product/data/models/product_model.dart';
import '../../../product/data/models/store_summary.dart';
import '../../../review/data/models/review_response_model.dart';
import '../../../review/domain/models/review_model.dart';
import 'working_hours_model.dart';
import 'store_brand_model.dart';

class StoreDetailModel {
  final String id;
  final String name;
  final String address;
  final String imageUrl;

  final double latitude;
  final double longitude;

  final String bannerImageUrl; // ✔ YENİ
  final bool isFavorite;

  final double? distanceKm;

  final StoreBrandModel? brand;
  final WorkingHoursModel? workingHours;

  final double overallRating;
  final int totalReviews;

  final AverageRatingsModel? averageRatings;
  final List<ProductModel>? products;
  final List<ReviewModel> reviews;

  StoreDetailModel({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.bannerImageUrl, // ✔ YENİ
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
    return StoreDetailModel(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      imageUrl: json['image_url'] ?? "",

      latitude: double.tryParse(json['latitude']?.toString() ?? "") ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? "") ?? 0.0,

      bannerImageUrl: json['banner_image'] ?? "", // ✔ ESKİ bannerImage yerine YENİ

      isFavorite: json['is_favorite'] == true,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),

      brand: json['brand'] != null ? StoreBrandModel.fromJson(json['brand']) : null,
      workingHours: json['working_hours'] != null
          ? WorkingHoursModel.fromJson(json['working_hours'])
          : null,

      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,

      averageRatings: json['average_ratings'] != null
          ? AverageRatingsModel.fromJson(json['average_ratings'])
          : null,

      products: json['products'] != null
          ? (json['products'] as List).map((e) => ProductModel.fromJson(e)).toList()
          : [],

      reviews: json['reviews'] != null
          ? (json['reviews'] as List).map((e) {
        final response = ReviewResponseModel.fromJson(e);
        return ReviewModel.fromResponse(json['id'].toString(), response);
      }).toList()
          : [],
    );
  }
}


extension StoreDetailMapper on StoreDetailModel {
  StoreSummary toProductStoreModel() {
    return StoreSummary(
      id: id,
      name: name,
      address: address,

      latitude: latitude,
      longitude: longitude,

      imageUrl: bannerImageUrl,     // ✔ backend’de store detail → banner_image_url
      distanceKm: distanceKm,
      overallRating: overallRating,
      isFavorite: isFavorite,
    );
  }
}





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
      service: (json['service'] as num?)?.toDouble() ?? 0,
      productQuantity: (json['product_quantity'] as num?)?.toDouble() ?? 0,
      productTaste: (json['product_taste'] as num?)?.toDouble() ?? 0,
      productVariety: (json['product_variety'] as num?)?.toDouble() ?? 0,
    );
  }
}
