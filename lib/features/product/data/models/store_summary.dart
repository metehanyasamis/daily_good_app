// lib/features/product/data/models/store_summary.dart

class StoreSummary {
  final String id;
  final String name;
  final String address;
  final double? distanceKm;
  final double? overallRating;
  final String imageUrl;

  StoreSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    this.distanceKm,
    this.overallRating,
  });

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    return StoreSummary(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      imageUrl: json['image_url'] ?? "",
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      overallRating: (json['overall_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "address": address,
    "image_url": imageUrl,
    "distance_km": distanceKm,
    "overall_rating": overallRating,
  };
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      logoUrl: json['logo_url'] ?? '',
    );
  }
}
