import '../../../../core/utils/time_formatter.dart';
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
      store: json["store"] != null
          ? StoreSummary(
        id: json["store"]["id"]?.toString() ?? "",
        name: json["store"]["name"] ?? "",
        address: json["store"]["address"] ?? "",
        // Store'un kendi görselini de normalize ediyoruz
        imageUrl: normalizeImageUrl(json["store"]["image_url"] ?? json["store"]["banner_image_url"]),
      )
          : StoreSummary(id: "", name: "", address: "", imageUrl: ""),
      startHour: json["start_hour"] ?? "",
      endHour: json["end_hour"] ?? "",
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",
      createdAt:
      DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
    );
  }

  /// ✅ UI için temiz teslim saati
  /// "11:50:00 - 02:11:00" -> "11:50 - 02:11"
  String get deliveryTimeLabel {
    return TimeFormatter.range(startHour, endHour);
  }
}



String normalizeImageUrl(dynamic raw) {
  if (raw == null) return "";

  final url = raw.toString().trim();
  if (url.isEmpty) return "";

  // 1. Durum: İç içe geçmiş bozuk URL kontrolü
  // Eğer string içinde "http" ifadesi birden fazla geçiyorsa veya
  // storage kelimesinden sonra tekrar http geliyorsa en sondaki http'yi al.
  if (url.contains('http') && url.lastIndexOf('http') > 0) {
    return url.substring(url.lastIndexOf('http'));
  }

  // 2. Durum: Zaten tek bir tam URL ise
  if (url.startsWith('http')) {
    return url;
  }

  // 3. Durum: Sadece dosya yolu (path) ise
  // Başındaki eğik çizgiyi temizle ki çift slash olmasın
  final cleanPath = url.startsWith('/') ? url.substring(1) : url;
  return 'https://dailygood.dijicrea.net/storage/$cleanPath';
}
