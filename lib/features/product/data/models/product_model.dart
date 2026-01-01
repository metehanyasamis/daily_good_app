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
  final double rating;
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
    required this.rating,
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
    return ProductModel.fromJsonMap(Map<String, dynamic>.from(raw));
  }

  // Geriye dönük uyumluluk için alias
  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel.fromJsonMap(json);

  factory ProductModel.fromJsonMap(Map<String, dynamic> json) {
    // 🔥 SAYI KORUYUCU: Gelen değer String bile olsa sayıya çevirir
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

    // Mağaza bilgisini güvenli çöz
    final storeData = json["store"];
    final resolvedStore = (storeData is Map<String, dynamic>)
        ? StoreSummary.fromJson(storeData)
        : StoreSummary(id: "", name: "Mağaza Bilgisi Yok", address: "", imageUrl: "");

    return ProductModel(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "İsimsiz Ürün",
      listPrice: toDouble(json["list_price"]),
      salePrice: toDouble(json["sale_price"]),
      stock: toInt(json["stock"]),
      imageUrl: normalizeImageUrl(json["image_url"]),
      description: json['description']?.toString(),
      store: resolvedStore,
      rating: toDouble(json["overall_rating"] ?? json["rating"]),

      // Saat Formatlayıcı
      startHour: TimeFormatter.hm(json["start_hour"]?.toString()),
      endHour: TimeFormatter.hm(json["end_hour"]?.toString()),

      startDate: json["start_date"]?.toString() ?? "",
      endDate: json["end_date"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? "") ?? DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    double? listPrice,
    double? salePrice,
    int? stock,
    String? imageUrl,
    String? description,
    StoreSummary? store,
    double? rating,
    String? startHour,
    String? endHour,
    String? startDate,
    String? endDate,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      listPrice: listPrice ?? this.listPrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      store: store ?? this.store,
      rating: rating ?? this.rating,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get deliveryTimeLabel {
    if (startHour == "00:00" || endHour == "00:00") {
      return "Teslimat saati belirtilmedi";
    }
    return "Bugün teslim al: $startHour - $endHour";
  }
}

String normalizeImageUrl(dynamic raw) {
  if (raw == null) return "";
  final url = raw.toString().trim();
  if (url.isEmpty) return "";
  if (url.startsWith('http')) return url;

  final cleanPath = url.startsWith('/') ? url.substring(1) : url;
  const String activeStorageUrl = "https://dailygood.dijicrea.net/storage";
  return '$activeStorageUrl/$cleanPath';
}