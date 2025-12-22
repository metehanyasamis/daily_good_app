import 'package:daily_good/features/product/data/models/product_model.dart';
import 'package:daily_good/features/product/data/models/store_in_product_detail.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/time_formatter.dart';

class ProductDetail {
  final String id;
  final String name;
  final double listPrice;
  final double salePrice;
  final int stock;
  final String imageUrl;
  final String? description;
  final String? startHour;
  final String? endHour;
  final String? startDate;
  final String? endDate;
  final StoreInProductDetail store;
  final String createdAt;

  ProductDetail({
    required this.id, required this.name, required this.listPrice,
    required this.salePrice, required this.stock, required this.imageUrl,
    this.description, this.startHour, this.endHour, this.startDate, this.endDate,
    required this.store, required this.createdAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    try {
      debugPrint("🛠️ ProductDetail Parse Başladı: ID=${json['id']}");

      // 1. ADIM: Store verisini akıllıca ayıkla (Senin dediğin List vs Map hatasını çözer)
      final dynamic rawStore = json['store'];
      Map<String, dynamic>? storeMap;

      if (rawStore is List && rawStore.isNotEmpty) {
        // Eğer liste geldiyse ilk elemanı Map olarak al
        storeMap = rawStore.first as Map<String, dynamic>;
      } else if (rawStore is Map<String, dynamic>) {
        // Zaten Map ise doğrudan kullan
        storeMap = rawStore;
      }

      // 2. ADIM: Nesneyi oluştur
      return ProductDetail(
        id: json['id']?.toString() ?? "",
        name: json['name']?.toString() ?? "İsimsiz Ürün",

        listPrice: (json['list_price'] as num?)?.toDouble() ?? 0.0,
        salePrice: (json['sale_price'] as num?)?.toDouble() ?? 0.0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,

        imageUrl: normalizeImageUrl(json["image_url"]),
        description: json['description']?.toString() ?? "",

        // Saat ve Tarihler: Null gelirse .toString() "null" kelimesini üretmesin diye ?. kullanıyoruz
        startHour: json['start_hour']?.toString(),
        endHour: json['end_hour']?.toString(),
        startDate: json['start_date']?.toString(),
        endDate: json['end_date']?.toString(),

        // Temizlediğimiz storeMap'i gönderiyoruz
        store: StoreInProductDetail.fromJson(storeMap),

        createdAt: json['created_at']?.toString() ?? "",
      );
    } catch (e, stackTrace) {
      debugPrint("❌❌ KRİTİK HATA: ProductDetail parse edilemedi!");
      debugPrint("Hata Mesajı: $e");

      // Çökmemesi için acil durum modeli
      return ProductDetail(
        id: "error",
        name: "Veri Hatası",
        listPrice: 0,
        salePrice: 0,
        stock: 0,
        imageUrl: "",
        store: StoreInProductDetail.fromJson(null),
        createdAt: "",
      );
    }
  }

  String get deliveryTimeLabel {
    // startHour veya endHour null/boş ise direkt uyarı dön
    if (startHour == null || endHour == null ||
        startHour!.isEmpty || endHour!.isEmpty ||
        startHour == "00:00:00" || endHour == "00:00:00") {
      return "Teslimat saati belirtilmedi";
    }
    try {
      return TimeFormatter.range(startHour!, endHour!);
    } catch (e) {
      return "$startHour - $endHour";
    }
  }
}