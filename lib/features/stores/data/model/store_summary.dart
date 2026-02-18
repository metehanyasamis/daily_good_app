// lib/features/stores/data/model/store_summary.dart

import 'package:flutter/material.dart';

class StoreSummary {
  final String id;
  final String name;
  final String? displayName;
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
    this.displayName,
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

  // 🔥 UI İÇİN FORMATLI İSİM GETTER'I
  // Kullanımı: Text(store.formattedName)
  String get formattedName {
    // 1. Marka varsa markayı, yoksa uzun ismi baz al
    String mainName = brand?.name ?? name;

    // 2. Display Name (Şube) varsa parantez içine ekle
    if (displayName != null && displayName!.isNotEmpty) {
      return "$mainName ($displayName)";
    }

    // 3. Yoksa sadece ana ismi dön
    return mainName;
  }

  factory StoreSummary.fromJson(Map<String, dynamic> json) {

    // 🔥🔥🔥 BURAYA BAK: Backend veriyi yolluyor mu? 🔥🔥🔥
    if (json['display_name'] != null) {
      debugPrint("🚀 [API GELEN] ${json['name']} için display_name: ${json['display_name']}");
    } else {
      debugPrint("⚠️ [API EKSİK] ${json['name']} için display_name NULL geldi!");
    }


    return StoreSummary(
      // 🔥 ID null gelirse boş string vererek patlamayı önlüyoruz
      id: json["id"]?.toString() ?? "",
      name: json["name"] ?? "Bilinmeyen Mağaza",

      displayName: json["display_name"],



      address: json["address"] ?? "",

      // Hem banner hem image url kontrolü
      imageUrl: json["banner_image_url"] ??
          json["image_url"] ??
          json["banner_image"] ?? // Dökümanda bazen bu geliyor
          json["image"] ??        // Fallback
          "",
      latitude: double.tryParse(json["latitude"]?.toString() ?? "") ?? 0.0,
      longitude: double.tryParse(json["longitude"]?.toString() ?? "") ?? 0.0,
      bannerImageUrl: json["banner_image_url"],
      isFavorite: json["is_favorite"] ?? false,
      distanceKm: (json["distance_km"] as num?)?.toDouble(),

      /// ⭐ RATING - Double dönüşümleri num üzerinden yapılmalı
      overallRating: (json["overall_rating"] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json["total_reviews"] as num?)?.toInt() ?? 0,

      averageRatings: json["average_ratings"] != null
          ? AverageRatings.fromJson(json["average_ratings"])
          : null,

      /// ⭐ BRAND
      brand: json["brand"] != null
          ? BrandSummary.fromJson(json["brand"])
          : null,
    );
  }

  StoreSummary copyWith({
    String? id,
    String? name,
    String? displayName,
    String? address,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? bannerImageUrl,
    bool? isFavorite,
    double? distanceKm,
    BrandSummary? brand,
    double? overallRating,
    int? totalReviews,
    AverageRatings? averageRatings,
  }) {
    return StoreSummary(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bannerImageUrl: bannerImageUrl ?? this.bannerImageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      distanceKm: distanceKm ?? this.distanceKm,
      brand: brand ?? this.brand,
      overallRating: overallRating ?? this.overallRating,
      totalReviews: totalReviews ?? this.totalReviews,
      averageRatings: averageRatings ?? this.averageRatings,
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
      // num? as double yaparak backend'den gelen int/double karmaşasını çözüyoruz
      service: (json["service"] as num?)?.toDouble() ?? 0.0,
      productQuantity: (json["product_quantity"] as num?)?.toDouble() ?? 0.0,
      productTaste: (json["product_taste"] as num?)?.toDouble() ?? 0.0,
      productVariety: (json["product_variety"] as num?)?.toDouble() ?? 0.0,
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