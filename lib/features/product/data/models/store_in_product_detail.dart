import 'store_summary.dart';

class StoreInProductDetail {
  final String id;
  final String name;
  final String address;
  final String phone;
  final double latitude;
  final double longitude;
  final String bannerImage;

  StoreInProductDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.bannerImage,
  });

  factory StoreInProductDetail.fromJson(Map<String, dynamic> json) {
    return StoreInProductDetail(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      address: json['address'] ?? "",
      phone: json['phone'] ?? "",
      latitude: double.tryParse(json['latitude'].toString()) ?? 0,
      longitude: double.tryParse(json['longitude'].toString()) ?? 0,
      bannerImage: json['banner_image'] ?? "",
    );
  }

  StoreSummary toStoreSummary() {
    return StoreSummary(
      id: id,
      name: name,
      address: address,

      latitude: latitude,
      longitude: longitude,

      imageUrl: bannerImage,   // ✔ ürün detayında banner_image var
      distanceKm: null,        // ürün detayında yok
      overallRating: 0.0,      // ürün detayında rating yok
      isFavorite: false,       // ürün detayında yok
    );
  }
}
