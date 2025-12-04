// lib/features/product/data/models/store_summary.dart

class StoreSummary {
  final String id;
  final String name;
  final String address;

  final double? latitude;
  final double? longitude;

  final String? bannerImageUrl;
  final String imageUrl; // ürün listesinde kullanılacak

  final bool? isFavorite;
  final double? distanceKm;

  final BrandSummary? brand;
  final double? overallRating;

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
  });

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    return StoreSummary(
      id: json["id"].toString(),
      name: json["name"] ?? "",
      address: json["address"] ?? "",
      imageUrl: json["banner_image_url"] ?? json["image_url"] ?? "",
      latitude: double.tryParse(json["latitude"]?.toString() ?? ""),
      longitude: double.tryParse(json["longitude"]?.toString() ?? ""),
      bannerImageUrl: json["banner_image_url"],
      isFavorite: json["is_favorite"],
      distanceKm: (json["distance_km"] as num?)?.toDouble(),
      overallRating: (json["overall_rating"] as num?)?.toDouble(),
      brand: json["brand"] != null ? BrandSummary.fromJson(json["brand"]) : null,
    );
  }
}



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
      id: json["id"] ?? "",
      name: json["name"] ?? "",
      logoUrl: json["logo_url"] ?? "",
    );
  }
}
