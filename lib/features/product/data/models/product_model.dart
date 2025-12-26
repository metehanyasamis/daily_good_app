import 'package:flutter/material.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../stores/data/model/store_summary.dart';

class ProductModel {
  final String id;
  final String name;
  final double listPrice;
  final double salePrice;
  final int stock;
  final String imageUrl;
  final String? description;
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
    required this.description,
    required this.store,
    required this.startHour,
    required this.endHour,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  /// Karmaşık liste veya farklı map tiplerini temizleyen giriş noktası
  static ProductModel parse(dynamic raw) {
    if (raw is List && raw.isNotEmpty) raw = raw.first;
    if (raw is! Map) {
      throw FormatException('Ürün verisi beklenen formatta değil: ${raw.runtimeType}');
    }
    // Map<dynamic, dynamic> gelirse Map<String, dynamic>'e güvenli döküm
    return ProductModel.fromJsonMap(Map<String, dynamic>.from(raw));
  }

  factory ProductModel.fromJsonMap(Map<String, dynamic> json) {
    // Mağaza bilgisini güvenli çöz
    final storeData = json["store"];
    final resolvedStore = (storeData is Map<String, dynamic>)
        ? StoreSummary.fromJson(storeData)
        : StoreSummary(id: "", name: "Mağaza Bilgisi Yok", address: "", imageUrl: "");

    return ProductModel(
      id: json["id"]?.toString() ?? "",
      name: json["name"] ?? "İsimsiz Ürün",
      listPrice: (json["list_price"] as num?)?.toDouble() ?? 0.0,
      salePrice: (json["sale_price"] as num?)?.toDouble() ?? 0.0,
      stock: (json["stock"] as num?)?.toInt() ?? 0,
      imageUrl: normalizeImageUrl(json["image_url"]),
      description: json['description'],
      store: resolvedStore,

      // 🔥 SAATLER: Veri girerken TimeFormatter üzerinden yıkanıyor (00:00:00 -> 00:00)
      startHour: TimeFormatter.hm(json["start_hour"]?.toString()),
      endHour: TimeFormatter.hm(json["end_hour"]?.toString()),

      startDate: json["start_date"]?.toString() ?? "",
      endDate: json["end_date"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? "") ?? DateTime.now(),
    );
  }

  /// UI'da gösterilecek teslimat etiketi
  String get deliveryTimeLabel {
    // Saatler fabrikada (fromJsonMap) temizlendiği için burada kontrol çok basit
    if (startHour == "00:00" || endHour == "00:00") {
      return "Teslimat saati belirtilmedi";
    }
    return "Bugün teslim al: $startHour - $endHour";
  }
}

/// Görüntü URL'ini normalize eden private fonksiyon (Sadece bu dosyada lazım)
String normalizeImageUrl(dynamic raw) {
  if (raw == null) return "";
  final url = raw.toString().trim();
  if (url.isEmpty) return "";

  // Eğer zaten tam URL ise ve çift prefix yoksa döndür
  if (url.startsWith('http')) {
    // Bazen API hatalı olarak iç içe URL basabiliyor, onu temizle
    return url.substring(url.lastIndexOf('http'));
  }

  // Path temizleme ve base URL ekleme
  final cleanPath = url.startsWith('/') ? url.substring(1) : url;
  return 'https://dailygood.dijicrea.net/storage/$cleanPath';
}