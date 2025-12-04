class StoreInOrder {
  final String id;
  final String name;
  final String address;
  final String bannerImage;
  final double latitude;
  final double longitude;

  StoreInOrder({
    required this.id,
    required this.name,
    required this.address,
    required this.bannerImage,
    required this.latitude,
    required this.longitude,
  });

  factory StoreInOrder.fromJson(Map<String, dynamic> json) {
    return StoreInOrder(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      bannerImage: json['banner_image_url'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
