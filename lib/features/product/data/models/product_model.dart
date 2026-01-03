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
    // 1. Güvenlik Kontrolü: Saatler yoksa direkt çık
    if (startHour == null || endHour == null) return "Teslimat saati belirtilmedi";

    // Saatleri temizle (12:59:00 -> 12:59)
    final sH = startHour!.length > 5 ? startHour!.substring(0, 5) : startHour;
    final eH = endHour!.length > 5 ? endHour!.substring(0, 5) : endHour;

    // 2. Tarih Kontrolü
    if (startDate == null) {
      return "Bugün teslim al: $sH - $eH";
    }

    try {
      final now = DateTime.now();
      // Saat, dakika, saniyeyi sıfırlayarak sadece "gün" karşılaştırması yapıyoruz
      final today = DateTime(now.year, now.month, now.day);
      final deliveryDateRaw = DateTime.parse(startDate!);
      final deliveryDate = DateTime(deliveryDateRaw.year, deliveryDateRaw.month, deliveryDateRaw.day);

      // Gün farkını net hesapla
      final diffInDays = deliveryDate.difference(today).inDays;

      String dayLabel;
      if (diffInDays == 0) {
        dayLabel = "Bugün";
      } else if (diffInDays == 1) {
        dayLabel = "Yarın";
      } else if (diffInDays > 1 && diffInDays < 7) {
        // Eğer 1 haftadan azsa (Örn: Çarşamba) - Opsiyonel, istemezsen direkt tarihe geç
        dayLabel = _getDayName(deliveryDate.weekday);
      } else {
        // 1 haftadan uzaksa direkt tarih
        dayLabel = "${deliveryDate.day.toString().padLeft(2, '0')}.${deliveryDate.month.toString().padLeft(2, '0')}";
      }

      return "$dayLabel teslim al: $sH - $eH";
    } catch (e) {
      // Parse hatası olursa fallback
      return "Bugün teslim al: $sH - $eH";
    }
  }

// Yardımcı metod (Modelin içine veya utils'e atabilirsin)
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Pazartesi";
      case 2: return "Salı";
      case 3: return "Çarşamba";
      case 4: return "Perşembe";
      case 5: return "Cuma";
      case 6: return "Cumartesi";
      case 7: return "Pazar";
      default: return "";
    }
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