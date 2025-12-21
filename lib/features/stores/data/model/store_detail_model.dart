// lib/features/stores/data/model/store_detail_model.dart
import 'package:flutter/material.dart';

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
    // NOTE:
    // API uses keys like `banner_image_url` and `image_url` (see docs).
    // Use safe parsing and fallbacks.
    final String banner = json['banner_image_url']?.toString() ??
        json['banner_image']?.toString() ??
        json['image_url']?.toString() ??
        '';

    final String image = json['image_url']?.toString() ??
        json['banner_image_url']?.toString() ??
        json['image']?.toString() ??
        '';

    // SAFELY PARSE PRODUCTS (backend bazen liste/objede tutarsızlık yapabiliyor)
    final rawProducts = asList(json['products']);
    final parsedProducts = rawProducts.map<ProductModel?>((e) {
      try {
        // ProductModel.fromJson kabul ediyor: Map veya List -> dinamik olarak işliyor
        return ProductModel.fromJsonMap(e);
      } catch (err, st) {
        debugPrint('STORE DETAIL: failed to parse product -> $err\n$st');
        return null;
      }
    }).whereType<ProductModel>().toList();

    // SAFELY PARSE REVIEWS
    final rawReviews = asList(json['reviews']);
    final parsedReviews = rawReviews.map<ReviewModel?>((e) {
      try {
        final m = asMap(e);
        if (m == null) {
          debugPrint('STORE DETAIL: skipping non-map review item: ${e.runtimeType}');
          return null;
        }
        final response = ReviewResponseModel.fromJson(m);
        return ReviewModel.fromResponse(json['id']?.toString() ?? '', response);
      } catch (err, st) {
        debugPrint('STORE DETAIL: failed to parse review -> $err\n$st');
        return null;
      }
    }).whereType<ReviewModel>().toList();

    return StoreDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      imageUrl: image,
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      bannerImageUrl: banner,
      isFavorite: json['is_favorite'] == true,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      brand: asMap(json['brand']) != null
          ? StoreBrandModel.fromJson(asMap(json['brand'])!)
          : null,
      workingHours: asMap(json['working_hours']) != null
          ? WorkingHoursModel.fromJson(asMap(json['working_hours'])!)
          : null,
      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      averageRatings: asMap(json['average_ratings']) != null
          ? AverageRatingsModel.fromJson(asMap(json['average_ratings'])!)
          : null,
      products: parsedProducts,
      reviews: parsedReviews,
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