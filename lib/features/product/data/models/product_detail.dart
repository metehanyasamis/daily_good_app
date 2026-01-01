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
    // 🛡️ Koruyucu Fonksiyonlar
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

    try {
      debugPrint("🛠️ ProductDetail Parse Başladı: ID=${json['id']}");

      final dynamic rawStore = json['store'];
      Map<String, dynamic>? storeMap;
      if (rawStore is List && rawStore.isNotEmpty) {
        storeMap = rawStore.first as Map<String, dynamic>;
      } else if (rawStore is Map<String, dynamic>) {
        storeMap = rawStore;
      }

      return ProductDetail(
        id: json['id']?.toString() ?? "",
        name: json['name']?.toString() ?? "İsimsiz Ürün",
        // 🔥 AS NUM? YERİNE BURALARI DÜZELTTİK
        listPrice: toDouble(json['list_price']),
        salePrice: toDouble(json['sale_price']),
        stock: toInt(json['stock']),
        imageUrl: normalizeImageUrl(json["image_url"]),
        description: json['description']?.toString() ?? "",
        startHour: json['start_hour']?.toString(),
        endHour: json['end_hour']?.toString(),
        startDate: json['start_date']?.toString(),
        endDate: json['end_date']?.toString(),
        store: StoreInProductDetail.fromJson(storeMap),
        createdAt: json['created_at']?.toString() ?? "",
      );
    } catch (e) {
      debugPrint("❌❌ KRİTİK HATA: ProductDetail parse edilemedi! Hata: $e");

      // 🎯 BURASI ÇOK ÖNEMLİ: Hata alsa bile ID'yi "error" yapma!
      // Ham verideki ID'yi string olarak kurtar ki kalp sönmesin.
      return ProductDetail(
        id: json['id']?.toString() ?? "id-kurtarilamadi",
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