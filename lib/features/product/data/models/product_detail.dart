import 'package:daily_good/features/product/data/models/product_model.dart';
import 'store_in_product_detail.dart';

class ProductDetail {
  final String id;
  final String name;
  final double listPrice;
  final double salePrice;
  final int stock;
  final String imageUrl;
  final String? description;
  final StoreInProductDetail store;
  final double rating;
  final String startHour;
  final String endHour;
  final String? startDate;
  final String? endDate;
  final DateTime createdAt;

  ProductDetail({
    required this.id,
    required this.name,
    required this.listPrice,
    required this.salePrice,
    required this.stock,
    required this.imageUrl,
    required this.description,
    required this.store,
    required this.rating,
    required this.startHour,
    required this.endHour,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? 0;
    }

    return ProductDetail(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "İsimsiz Ürün",
      listPrice: toDouble(json["list_price"]),
      salePrice: toDouble(json["sale_price"]),
      stock: toInt(json["stock"]),
      // ✅ ÇÖZÜM: ProductModel içindeki statik metodu kullanıyoruz
      imageUrl: ProductModel.normalizeImageUrl(json["image_url"]),
      description: json['description']?.toString(),
      store: StoreInProductDetail.fromJson(json["store"] ?? {}),
      rating: toDouble(json["overall_rating"] ?? json["rating"]),
      startHour: json["start_hour"]?.toString() ?? "",
      endHour: json["end_hour"]?.toString() ?? "",
      startDate: json["start_date"]?.toString(),
      endDate: json["end_date"]?.toString(),
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? "") ?? DateTime.now(),
    );
  }

  // ✅ UI'da Today/Tomorrow mantığını buraya da ekliyoruz
  String get deliveryTimeLabel {
    if (startHour.isEmpty || endHour.isEmpty) return "Teslimat saati belirtilmedi";

    final sH = startHour.split(':').take(2).join(':');
    final eH = endHour.split(':').take(2).join(':');

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (startDate != null && startDate != "null" && startDate!.isNotEmpty) {
        final deliveryDateRaw = DateTime.parse(startDate!);
        final deliveryDate = DateTime(deliveryDateRaw.year, deliveryDateRaw.month, deliveryDateRaw.day);
        final diffInDays = deliveryDate.difference(today).inDays;

        if (diffInDays == 0) return "Bugün teslim al: $sH - $eH";
        if (diffInDays == 1) return "Yarın teslim al: $sH - $eH";
        return "${deliveryDate.day}.${deliveryDate.month} teslim al: $sH - $eH";
      }

      int startInt = int.parse(sH.replaceAll(':', ''));
      int endInt = int.parse(eH.replaceAll(':', ''));
      if (endInt < startInt) return "Yarın teslim al: $sH - $eH";

      return "Bugün teslim al: $sH - $eH";
    } catch (e) {
      return "Bugün teslim al: $sH - $eH";
    }
  }

  // Favorites veya Sepet için ProductModel'e dönüştürme gerekirse:
  ProductModel toProductModel() {
    return ProductModel(
      id: id,
      name: name,
      listPrice: listPrice,
      salePrice: salePrice,
      stock: stock,
      imageUrl: imageUrl,
      description: description,
      store: store.toStoreSummary(),
      rating: rating,
      startHour: startHour,
      endHour: endHour,
      startDate: startDate ?? "",
      endDate: endDate ?? "",
      createdAt: DateTime.now(),
    );
  }
}