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

  StoreInProductDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.bannerImage,
  });

  factory StoreInProductDetail.fromJson(Map<String, dynamic>? json) {
    // 🛡️ 1. KORUMA: Eğer 'store' objesi komple null geldiyse
    if (json == null) {
      return StoreInProductDetail(
        id: "",
        name: "Mağaza Bilgisi Yok",
        address: "",
        phone: "",
        latitude: 0.0,
        longitude: 0.0,
        bannerImage: "",
      );
    }

    // 🛡️ 2. KORUMA: Her bir alanı tek tek null check'ten geçiriyoruz
    return StoreInProductDetail(
      // .toString() öncesi '?' koymak hayati önem taşır!
      id: json['id']?.toString() ?? "",
      name: json['name']?.toString() ?? "Bilinmeyen Mağaza",
      address: json['address']?.toString() ?? "Adres bilgisi yok",
      phone: json['phone']?.toString() ?? "",

      // 🔥 Akman Elektrik burada patlıyor: num? as double? ?? 0.0
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,

      // Resim URL'sini normalize ediyoruz
      bannerImage: normalizeImageUrl(
          json['banner_image_url'] ?? json['banner_image'] ?? ""
      ),
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
      distanceKm: null,
      overallRating: 0.0,
      isFavorite: false,
    );
  }
}