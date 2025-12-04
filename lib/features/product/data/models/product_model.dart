// lib/features/product/data/models/product_model.dart

import 'store_summary.dart';

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
      id: json["id"],
      name: json["name"],
      listPrice: (json["list_price"] as num).toDouble(),
      salePrice: (json["sale_price"] as num).toDouble(),
      stock: json["stock"] ?? 0,
      imageUrl: json["image_url"] ?? "",
      store: StoreSummary.fromJson(json["store"]),
      startHour: json["start_hour"] ?? "",
      endHour: json["end_hour"] ?? "",
      startDate: json["start_date"] ?? "",
      endDate: json["end_date"] ?? "",
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
