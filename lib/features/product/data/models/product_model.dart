class ProductModel {
  final String businessId; // 🟢 YENİ: Hangi işletmeye ait olduğunu belirtir
  final String bannerImage; // Ürünün kendi görseli
  final String packageName;
  final String pickupTimeText;
  final double oldPrice;
  final double newPrice;
  final String stockLabel;
  // İşletmeye ait bilgiler (logo, rating, distance) bu modelden ÇIKARILDI

  ProductModel({
    required this.businessId, // 🟢 YENİ
    required this.bannerImage,
    required this.packageName,
    required this.pickupTimeText,
    required this.oldPrice,
    required this.newPrice,
    required this.stockLabel,
  });
}