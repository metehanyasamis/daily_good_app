// lib/features/stores/data/model/store_detail_model.dart
import 'package:flutter/material.dart';

import '../../../product/data/models/product_model.dart';
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

List<dynamic> asList(dynamic v) {
  if (v is List) return v;
  return const <dynamic>[];
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
    try {
      debugPrint("🔍 [ADIM 1] Temel Veriler Parse Ediliyor: ID=${json['id']}");

      final String banner = json['banner_image_url']?.toString() ??
          json['banner_image']?.toString() ??
          json['image_url']?.toString() ?? '';

      final String image = json['image_url']?.toString() ??
          json['banner_image_url']?.toString() ?? '';

      debugPrint("🔍 [ADIM 2] Ürünler Parse Ediliyor...");
      final rawProducts = asList(json['products']);
      final parsedProducts = rawProducts.map<ProductModel?>((e) {
        try {
          return ProductModel.fromJsonMap(e);
        } catch (err) {
          debugPrint("❌ Ürün Parse Hatası: $err");
          return null;
        }
      }).whereType<ProductModel>().toList();

      debugPrint("🔍 [ADIM 3] Sayısal Değerler Kontrol Ediliyor...");
      final double lat = double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0;
      final double lng = double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0;
      final double rating = (json['overall_rating'] as num?)?.toDouble() ?? 0.0;

      // 🧨 MUHTEMEL PATLAMA NOKTASI 1: total_reviews
      debugPrint("🔍 [ADIM 4] total_reviews Dönüştürülüyor: ${json['total_reviews']}");
      final int reviewsCount = (json['total_reviews'] as num?)?.toInt() ?? 0;

      // 🧨 MUHTEMEL PATLAMA NOKTASI 2: working_hours
      debugPrint("🔍 [ADIM 5] working_hours Dönüştürülüyor...");
      WorkingHoursModel? wh;
      if (asMap(json['working_hours']) != null) {
        try {
          wh = WorkingHoursModel.fromJson(asMap(json['working_hours'])!);
        } catch (e) {
          debugPrint("❌ WORKING HOURS HATASI: $e");
          // Saat hatası sayfayı çökertmesin diye null geçiyoruz
          wh = null;
        }
      }

      debugPrint("✅ [BAŞARI] StoreDetailModel Başarıyla Oluşturuldu");

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
        overallRating: rating,
        totalReviews: reviewsCount,
        averageRatings: asMap(json['average_ratings']) != null ? AverageRatingsModel.fromJson(asMap(json['average_ratings'])!) : null,
        products: parsedProducts,
        reviews: const [], // Şimdilik boş
      );

    } catch (e, stack) {
      debugPrint("‼️ [KRİTİK ÇÖKME] StoreDetailModel.fromJson içinde hata!");
      debugPrint("Hata: $e");
      debugPrint("Stack: $stack");
      rethrow;
    }
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
      productTaste: (json['product_taste'] as num?)?.toDouble() ?? 0.0,
      productVariety: (json['product_variety'] as num?)?.toDouble() ?? 0.0,
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