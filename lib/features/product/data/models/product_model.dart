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
  final StoreSummary store;

  // 🔥 DEĞİŞİKLİK: Saatleri nullable (String?) yaptık ki null gelirse patlamasın
  final String? startHour;
  final String? endHour;

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
    this.startHour,
    this.endHour,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  static ProductModel parse(dynamic raw) {
    if (raw is List) {
      if (raw.isEmpty) throw FormatException('Empty list when parsing ProductModel');
      raw = raw.first;
    }

    if (raw is! Map<String, dynamic>) {
      if (raw is Map) {
        final map = <String, dynamic>{};
        raw.forEach((k, v) => map[k.toString()] = v);
        return ProductModel.fromJsonMap(map);
      }
      throw FormatException('Invalid product json type: ${raw.runtimeType}');
    }

    return ProductModel.fromJsonMap(raw);
  }

  factory ProductModel.fromJsonMap(Map<String, dynamic> json) {
    final dynamic storeData = json["store"];
    StoreSummary resolvedStore;

    if (storeData != null && storeData is Map<String, dynamic>) {
      resolvedStore = StoreSummary.fromJson(storeData);
    } else {
      resolvedStore = StoreSummary(id: "", name: "Mağaza Bilgisi Yok", address: "", imageUrl: "");
    }

    return ProductModel(
      id: json["id"]?.toString() ?? "",
      name: json["name"] ?? "İsimsiz Ürün",
      listPrice: (json["list_price"] as num?)?.toDouble() ?? 0.0,
      salePrice: (json["sale_price"] as num?)?.toDouble() ?? 0.0,
      stock: (json["stock"] as num?)?.toInt() ?? 0,
      imageUrl: normalizeImageUrl(json["image_url"]),
      store: resolvedStore,

      // 🔥 KRİTİK: .toString() EKLEME. Null ise null kalsın.
      startHour: json["start_hour"]?.toString() ?? "00:00:00",
      endHour: json["end_hour"]?.toString() ?? "00:00:00",

      startDate: json["start_date"]?.toString() ?? "",
      endDate: json["end_date"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? "") ?? DateTime.now(),
    );
  }

  String get deliveryTimeLabel {
    // 🔥 GÜVENLİ KONTROL: null check + empty check + default value check
    if (startHour == null ||
        endHour == null ||
        startHour!.isEmpty ||
        endHour!.isEmpty ||
        startHour == "00:00:00" ||
        endHour == "00:00:00") {
      return "Teslimat saati belirtilmedi";
    }

    try {
      // Değerlerin null olmadığını yukarıda kontrol ettiğimiz için ! kullanabiliriz
      return TimeFormatter.range(startHour!, endHour!);
    } catch (e) {
      debugPrint("❌ TIME FORMATTER ERROR on Product $id: $e");
      return "$startHour - $endHour";
    }
  }
}

String normalizeImageUrl(dynamic raw) {
  if (raw == null) return "";
  final url = raw.toString().trim();
  if (url.isEmpty) return "";
  if (url.contains('http') && url.lastIndexOf('http') > 0) {
    return url.substring(url.lastIndexOf('http'));
  }
  if (url.startsWith('http')) return url;
  final cleanPath = url.startsWith('/') ? url.substring(1) : url;
  return 'https://dailygood.dijicrea.net/storage/$cleanPath';
}