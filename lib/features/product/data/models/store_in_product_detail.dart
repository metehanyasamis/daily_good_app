import 'package:daily_good/features/product/data/models/product_model.dart';

import '../../../stores/data/model/store_summary.dart';

class StoreInProductDetail {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String bannerImage;
  final double overallRating;
  final double? distanceKm; // 👈 1. BURASI: Mesafeyi ekledik

  StoreInProductDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.bannerImage,
    required this.overallRating,
    this.distanceKm, // 👈 2. BURASI: Mesafeyi ekledik
  });

  factory StoreInProductDetail.fromJson(Map<String, dynamic>? json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    if (json == null) return StoreInProductDetail.empty();

    return StoreInProductDetail(
      id: json['id']?.toString() ?? "",
      name: json['name']?.toString() ?? "Bilinmeyen Mağaza",
      address: json['address']?.toString() ?? "",
      phone: json['phone']?.toString() ?? "",
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      bannerImage: ProductModel.normalizeImageUrl(json['banner_image_url'] ?? json['banner_image'] ?? ""),

      // 🔥 3. BURASI: Hem puanı hem mesafeyi API'den gelen farklı isimlere karşı korumalı alıyoruz
      overallRating: toDouble(json['overall_rating'] ?? json['rating'] ?? json['store_rating']),
      distanceKm: json['distance_km'] != null ? toDouble(json['distance_km']) : null,
    );
  }

  // Boş mağaza durumu için isimlendirilmiş constructor (Temiz kod)
  factory StoreInProductDetail.empty() {
    return StoreInProductDetail(
      id: "",
      name: "Mağaza Bilgisi Yok",
      address: "",
      phone: "",
      latitude: 0.0,
      longitude: 0.0,
      bannerImage: "",
      overallRating: 0.0,
    );
  }

  StoreSummary toStoreSummary() {
    return StoreSummary(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      imageUrl: bannerImage,
      distanceKm: distanceKm,
      overallRating: overallRating,
      isFavorite: false,
    );
  }
}