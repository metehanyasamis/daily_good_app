class ProductModel {
  final String productId; // ✅ daha açıklayıcı
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
    this.isFav = false,
  });

  // 🔹 Eşitlik tanımı artık productId üzerinden
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ProductModel &&
              runtimeType == other.runtimeType &&
              productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}
