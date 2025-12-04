class StoreSummary {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  final String imageUrl;
  final double? distanceKm;
  final double overallRating;
  final bool isFavorite;

  StoreSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.distanceKm,
    required this.overallRating,
    required this.isFavorite,
  });

  factory StoreSummary.fromJson(Map<String, dynamic> json) {
    final img = json['banner_image_url'] ??
        json['banner_image'] ??
        json['image_url'] ??
        "";

    return StoreSummary(
      id: json['id']?.toString() ?? "",
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      latitude: double.tryParse(json['latitude']?.toString() ?? "") ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? "") ?? 0.0,
      imageUrl: img,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      overallRating: (json['overall_rating'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['is_favorite'] == true,
    );
  }
}
