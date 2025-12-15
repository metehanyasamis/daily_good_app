import '../../../stores/data/model/store_summary.dart';

class ProductModel {
  final String id;
  final String name;
  final double listPrice;
  final double salePrice;
  final int stock;
  final String imageUrl;

  final StoreSummary store;

  final String startHour;
  final String endHour;
  final String startDate;
  final String endDate;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.listPrice,
    required this.salePrice,
    required this.stock,
    required this.imageUrl,
    required this.store,
    required this.startHour,
    required this.endHour,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"].toString(),
      name: json["name"] ?? "",
      listPrice: (json["list_price"] as num?)?.toDouble() ?? 0,
      salePrice: (json["sale_price"] as num?)?.toDouble() ?? 0,
      stock: json["stock"] ?? 0,
      imageUrl: normalizeImageUrl(json["image_url"]),

      /// STORE null gelirse app çökmemesi için fallback ekledik
      store: json["store"] != null
          ? StoreSummary.fromJson(json["store"])
          : StoreSummary(
        id: "",
        name: "",
        address: "",
        imageUrl: "",
      ),

      startHour: json["start_hour"] ?? "",
      endHour: json["end_hour"] ?? "",
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",

      /// created_at null olursa crash olmasın
      createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
    );
  }
}


String normalizeImageUrl(dynamic raw) {
  if (raw == null) return "";

  final url = raw.toString().trim();
  if (url.isEmpty) return "";

  // ❌ storage + https://... gibi BOZUK URL
  if (url.contains('/storage/http')) {
    final idx = url.indexOf('/storage/');
    return url.substring(idx + 9); // '/storage/'.length = 9
  }


  // ✅ zaten tam URL
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  // ✅ sadece path geldiyse
  return 'https://dailygood.dijicrea.net/storage/$url';
}
