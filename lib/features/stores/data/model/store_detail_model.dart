import 'package:flutter/material.dart';
import '../../../product/data/models/product_model.dart';
import '../../../review/domain/models/review_model.dart';
import 'store_summary.dart';
import 'working_hours_model.dart';
import 'store_brand_model.dart';

Map<String, dynamic>? asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  return null;
}

List<dynamic> asList(dynamic v) {
  if (v is List) return v;
  return const <dynamic>[];
}

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
  final String? createdAt;
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
    required this.createdAt,
    required this.overallRating,
    required this.totalReviews,
    required this.averageRatings,
    required this.products,
    required this.reviews,
  });

  /// [UI İÇİN DİNAMİK YIL HESAPLAMA]
  int get struggleYears {
    if (createdAt == null || createdAt!.isEmpty) return 1;
    try {
      final createdDate = DateTime.parse(createdAt!);
      final now = DateTime.now();
      int difference = now.year - createdDate.year;
      final result = difference <= 0 ? 1 : difference;
      debugPrint("🧬 [GETTER] Hesaplanan Yıl: $result (Kaynak: $createdAt)");
      return result;
    } catch (e) {
      debugPrint("❌ [GETTER ERROR] Tarih parse hatası: $e");
      return 1;
    }
  }

  factory StoreDetailModel.fromJson(Map<String, dynamic> json) {
    try {
      final String banner = json['banner_image_url']?.toString() ??
          json['banner_image']?.toString() ??
          json['image_url']?.toString() ?? '';

      final String image = json['image_url']?.toString() ??
          json['banner_image_url']?.toString() ?? '';

      final rawProducts = asList(json['products']);
      final parsedProducts = rawProducts.map<ProductModel?>((e) {
        try {
          return ProductModel.fromJsonMap(e as Map<String, dynamic>);
        } catch (err) {
          debugPrint("❌ Ürün Parse Hatası: $err");
          return null;
        }
      }).whereType<ProductModel>().toList();

      final double lat = double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0;
      final double lng = double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0;
      final double rating = (json['overall_rating'] as num?)?.toDouble() ?? 0.0;
      final int reviewsCount = (json['total_reviews'] as num?)?.toInt() ?? 0;

      WorkingHoursModel? wh;
      final rawWH = json['working_hours'];
      if (rawWH != null) {
        if (rawWH is List) {
          wh = WorkingHoursModel.fromList(rawWH);
        } else if (rawWH is Map<String, dynamic>) {
          wh = WorkingHoursModel.fromJson(rawWH);
        }
      }

      final String? createdAtStr = json['created_at']?.toString();
      debugPrint("""
      -------------------------------------------
      ✅ [MODEL PARSE SUCCESS]
      Mağaza: ${json['name']}
      Tarih: $createdAtStr
      Saat Sayısı: ${wh?.days.length ?? 0}
      -------------------------------------------
      """);

      return StoreDetailModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        imageUrl: image,
        latitude: lat,
        longitude: lng,
        bannerImageUrl: banner,
        isFavorite: json['is_favorite'] == true || json['is_favorite'] == 1,
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        brand: asMap(json['brand']) != null ? StoreBrandModel.fromJson(asMap(json['brand'])!) : null,
        workingHours: wh,
        createdAt: createdAtStr,
        overallRating: rating,
        totalReviews: reviewsCount,
        averageRatings: asMap(json['average_ratings']) != null
            ? AverageRatingsModel.fromJson(asMap(json['average_ratings'])!)
            : null,
        products: parsedProducts,
        reviews: const [], // Backend yorumları eklediğinde burası güncellenecek
      );

    } catch (e, stack) {
      debugPrint("‼️ [KRİTİK ÇÖKME] StoreDetailModel.fromJson: $e");
      debugPrint("Stack: $stack");
      rethrow;
    }
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
      service: (json['service'] as num?)?.toDouble() ?? 0.0,
      productQuantity: (json['product_quantity'] as num?)?.toDouble() ?? 0.0,
      productTaste: (json['product_taste'] as num?)?.toDouble() ?? 0.0,
      productVariety: (json['product_variety'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// [MAPPER KALIYOR - DİĞER EKRANLAR İÇİN GEREKLİ]

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