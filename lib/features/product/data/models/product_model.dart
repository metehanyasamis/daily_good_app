import '../../../explore/presentation/widgets/category_filter_option.dart';

class ProductModel {
  final String productId;
  final String businessId;
  final String businessName;
  final String bannerImage;
  final String packageName;
  final String pickupTimeText;
  final double oldPrice;
  final double newPrice;
  final String stockLabel;
  final double rating;
  final double distance;
  bool isFav;
  final CategoryFilterOption category;
  final double carbonSaved;


  ProductModel({
    required this.productId,
    required this.businessId,
    required this.businessName,
    required this.bannerImage,
    required this.packageName,
    required this.pickupTimeText,
    required this.oldPrice,
    required this.newPrice,
    required this.stockLabel,
    required this.rating,
    required this.distance,
    required this.category,
    this.isFav = false,
    this.carbonSaved = 0.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductModel &&
              runtimeType == other.runtimeType &&
              productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}
