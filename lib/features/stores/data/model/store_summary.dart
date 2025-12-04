class StoreSummary {
  final String id;
  final String name;
  final String address;

  final double latitude;
  final double longitude;

  final String bannerImageUrl;
  final String logoUrl;

  final double rating;
  final double distanceKm;
  final bool isFavorite;

  StoreSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.bannerImageUrl,
    required this.logoUrl,
    required this.rating,
    required this.distanceKm,
    required this.isFavorite,
  });

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    return StoreSummary(
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      address: json['address'] ?? "",

      latitude: double.tryParse(json['latitude']?.toString() ?? "") ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? "") ?? 0.0,

      bannerImageUrl: json['banner_image'] ?? "",
      logoUrl: json['brand']?['logo_url'] ?? "",

      rating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,

      isFavorite: json['is_favorite'] == true,
    );
  }
}
