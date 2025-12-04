
import 'package:daily_good/features/product/data/models/store_in_product_detail.dart';

class ProductDetail {
  final String id;
  final String name;
  final int listPrice;
  final int salePrice;
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
    required this.id,
    required this.name,
    required this.listPrice,
    required this.salePrice,
    required this.stock,
    required this.imageUrl,
    this.description,
    this.startHour,
    this.endHour,
    this.startDate,
    this.endDate,
    required this.store,
    required this.createdAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'].toString(),
      name: json['name'] ?? "",
      listPrice: json['list_price'] ?? 0,
      salePrice: json['sale_price'] ?? 0,
      stock: json['stock'] ?? 0,
      imageUrl: json['image_url'] ?? "",
      description: json['description'],
      startHour: json['start_hour'],
      endHour: json['end_hour'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      store: StoreInProductDetail.fromJson(json['store']),
      createdAt: json['created_at'] ?? "",
    );
  }
}
