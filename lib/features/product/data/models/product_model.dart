// (uyarladım: dosya yolunu proje yapına göre düzenle)
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

  /// Güvenli parse helper: raw List gelirse ilk elemanı kullan, Map gelirse doğrudan parse et.
  static ProductModel parse(dynamic raw) {
    debugPrint('TRACE MODEL: ProductModel.parse called with type=${raw.runtimeType}');
    if (raw is List) {
      debugPrint('⚠️ ProductModel.parse received a List, using first element. length=${raw.length}');
      if (raw.isEmpty) throw FormatException('Empty list when parsing ProductModel');
      raw = raw.first;
    }

    if (raw is! Map<String, dynamic>) {
      // Bazı durumlarda Map<String, Object?> olabilir, buna da izin ver
      if (raw is Map) {
        // cast safely by creating Map<String, dynamic>
        final map = <String, dynamic>{};
        raw.forEach((k, v) {
          map[k.toString()] = v;
        });
        return ProductModel.fromJsonMap(map);
      }

      debugPrint('❌ ProductModel.parse expected Map but got ${raw.runtimeType}: $raw');
      throw FormatException('Invalid product json type: ${raw.runtimeType}');
    }

    return ProductModel.fromJsonMap(raw);
  }

  // Ayrı metod: zaten Map ise burayı kullan
  factory ProductModel.fromJsonMap(Map<String, dynamic> json) {


    debugPrint("🔍 PARSING START: ID=${json['id']} NAME=${json['name']}");
    debugPrint("🔍 STORE DATA TYPE: ${json['store'].runtimeType} DATA: ${json['store']}");


    final dynamic storeData = json["store"];
    StoreSummary resolvedStore;


    if (storeData != null && storeData is Map<String, dynamic>) {
      resolvedStore = StoreSummary.fromJson(storeData);
    } else {
      debugPrint("⚠️ WARNING: Store verisi Map değil! (${storeData.runtimeType})");
      resolvedStore = StoreSummary(id: "", name: "Mağaza Bilgisi Yok", address: "", imageUrl: "");
    }

    return ProductModel(
      id: json["id"]?.toString() ?? "",
      name: json["name"] ?? "İsimsiz Ürün",
      listPrice: (json["list_price"] as num?)?.toDouble() ?? 0,
      salePrice: (json["sale_price"] as num?)?.toDouble() ?? 0,
      stock: (json["stock"] as num?)?.toInt() ?? 0,
      imageUrl: normalizeImageUrl(json["image_url"]),
      store: resolvedStore,
      startHour: json["start_hour"]?.toString() ?? "00:00:00",
      endHour: json["end_hour"]?.toString() ?? "00:00:00",
      startDate: json["start_date"]?.toString() ?? "",
      endDate: json["end_date"]?.toString() ?? "",
      createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? "") ?? DateTime.now(),
    );
  }

  // Mevcut getter vb.
  String get deliveryTimeLabel {
    // Debug logu kalsın, hangi üründe ne geldiğini terminalden izleriz
    debugPrint('🕒 TIME DEBUG [ID:$id]: start="$startHour", end="$endHour"');

    // "00:00:00" backend'in boş gönderdiği durumlarda senin atadığın default değerdi
    if (startHour.isEmpty ||
        endHour.isEmpty ||
        startHour == "00:00:00" ||
        endHour == "00:00:00") {
      return "Teslimat saati belirtilmedi";
    }

    try {
      // TimeFormatter içindeki substring veya split işlemleri burada patlayabilir
      return TimeFormatter.range(startHour, endHour);
    } catch (e) {
      // Eğer TimeFormatter çökerse uygulama kapanmasın, ham saati gösterelim
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