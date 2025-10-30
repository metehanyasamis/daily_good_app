import '../../../product/data/models/product_model.dart';

class BusinessModel {
  final String id;
  final String name;
  final String address;
  final String businessShopLogoImage;
  final double rating;
  final double distance;
  final String workingHours;
  final List<ProductModel> products;
  bool isFav; // ❤️ favori alanı

  BusinessModel({
    required this.id,
    required this.name,
    required this.address,
    required this.businessShopLogoImage,
    required this.rating,
    required this.distance,
    required this.workingHours,
    required this.products,
    this.isFav = false, // varsayılan false
  });
}
