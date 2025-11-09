import '../../../product/data/models/product_model.dart';

class BusinessModel {
  final String id;
  final String name;
  final String address;
  final String businessShopLogoImage;
  final String businessShopBannerImage;
  final double rating;
  final double distance;
  final String workingHours;
  final List<ProductModel> products;
  final double latitude;   // ✅ eklendi
  final double longitude;  // ✅ eklendi
  bool isFav;

  BusinessModel({
    required this.id,
    required this.name,
    required this.address,
    required this.businessShopLogoImage,
    required this.businessShopBannerImage,
    required this.rating,
    required this.distance,
    required this.workingHours,
    required this.products,
    this.latitude = 41.0082,   // 🌍 Default: İstanbul
    this.longitude = 28.9784,
    this.isFav = false,
  });

  // 🔹 Eşitlik tanımı (id bazlı)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is BusinessModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
